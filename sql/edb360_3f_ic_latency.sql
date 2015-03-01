@@edb360_0g_tkprof.sql
DEF section_id = '3f';
DEF section_name = 'Interconnect Ping Latency Stats';
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_name.</h2>
SPO OFF;

DEF main_table = 'DBA_HIST_INTERCONNECT_PINGS';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'Average Ping Latencies in Milliseconds';
DEF vbaseline = '';

BEGIN
  :sql_text_backup := '
WITH
per_source_and_target AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */
       MAX(h1.snap_id) snap_id,
       h1.instance_number,
       h1.target_instance,
       TO_CHAR(s1.begin_interval_time, ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(s1.end_interval_time, ''YYYY-MM-DD HH24:MI'') end_time,
       SUM(h1.cnt_500b - h0.cnt_500b) cnt_500b,
       SUM(h1.cnt_8k - h0.cnt_8k) cnt_8k,
       SUM(h1.wait_500b - h0.wait_500b) wait_500b,
       SUM(h1.wait_8k - h0.wait_8k) wait_8k,
       ROUND(SUM(h1.wait_500b - h0.wait_500b) / SUM(h1.cnt_500b - h0.cnt_500b) / 1000, 2) Avg_Latency_500B_msg,
       ROUND(SUM(h1.wait_8k - h0.wait_8k) / SUM(h1.cnt_8k - h0.cnt_8k) / 1000, 2) Avg_Latency_8K_msg
  FROM dba_hist_interconnect_pings h0,
       dba_hist_interconnect_pings h1,
       dba_hist_snapshot s0,
       dba_hist_snapshot s1
 WHERE h0.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h0.dbid = &&edb360_dbid.
   AND h1.snap_id = h0.snap_id + 1
   AND h1.dbid = h0.dbid
   AND h1.instance_number = h0.instance_number
   AND h1.target_instance = h0.target_instance
   AND s0.snap_id = h0.snap_id
   AND s0.dbid = h0.dbid
   AND s0.instance_number = h0.instance_number
   AND s0.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s0.dbid = &&edb360_dbid.
   AND s1.snap_id = h1.snap_id
   AND s1.dbid = h1.dbid
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
   AND s1.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s1.dbid = &&edb360_dbid.
   AND s1.begin_interval_time > (s0.begin_interval_time + (1 / (24 * 60))) /* filter out snaps apart < 1 min */
   AND ((TO_DATE(TO_CHAR(s1.end_interval_time, ''YYYY-MM-DD HH24:MI''), ''YYYY-MM-DD HH24:MI'') -
         TO_DATE(TO_CHAR(s1.begin_interval_time, ''YYYY-MM-DD HH24:MI''), ''YYYY-MM-DD HH24:MI'')) * 24 * 3600) > 0
   AND (h1.cnt_500b - h0.cnt_500b) > 0
   AND (h1.cnt_8k - h0.cnt_8k) > 0
   AND (h1.wait_500b - h0.wait_500b) > 0
   AND (h1.wait_8k - h0.wait_8k) > 0
 GROUP BY
       h1.instance_number,
       h1.target_instance,
       TO_CHAR(s1.begin_interval_time, ''YYYY-MM-DD HH24:MI''),
       TO_CHAR(s1.end_interval_time, ''YYYY-MM-DD HH24:MI'')
),
per_source AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       instance_number,
       -1 target_instance,
       begin_time,
       end_time,
       SUM(cnt_500b) cnt_500b,
       SUM(cnt_8k) cnt_8k,
       SUM(wait_500b) wait_500b,
       SUM(wait_8k) wait_8k,
       ROUND(SUM(wait_500b) / SUM(cnt_500b) / 1000, 2) Avg_Latency_500B_msg,
       ROUND(SUM(wait_8k) / SUM(cnt_8k) / 1000, 2) Avg_Latency_8K_msg
  FROM per_source_and_target
 GROUP BY
       snap_id,
       instance_number,
       begin_time,
       end_time
),
per_target AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       -1 instance_number,
       target_instance,
       begin_time,
       end_time,
       SUM(cnt_500b) cnt_500b,
       SUM(cnt_8k) cnt_8k,
       SUM(wait_500b) wait_500b,
       SUM(wait_8k) wait_8k,
       ROUND(SUM(wait_500b) / SUM(cnt_500b) / 1000, 2) Avg_Latency_500B_msg,
       ROUND(SUM(wait_8k) / SUM(cnt_8k) / 1000, 2) Avg_Latency_8K_msg
  FROM per_source_and_target
 GROUP BY
       snap_id,
       target_instance,
       begin_time,
       end_time
),
per_cluster AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       -1 instance_number,
       -1 target_instance,
       begin_time,
       end_time,
       SUM(cnt_500b) cnt_500b,
       SUM(cnt_8k) cnt_8k,
       SUM(wait_500b) wait_500b,
       SUM(wait_8k) wait_8k,
       ROUND(SUM(wait_500b) / SUM(cnt_500b) / 1000, 2) Avg_Latency_500B_msg,
       ROUND(SUM(wait_8k) / SUM(cnt_8k) / 1000, 2) Avg_Latency_8K_msg
  FROM per_source_and_target
 GROUP BY
       snap_id,
       begin_time,
       end_time
),
source_and_target_extended AS (
SELECT /*+ &&sq_fact_hints. */
       st.snap_id,
       st.instance_number,
       st.target_instance,
       st.begin_time,
       st.end_time,
       st.Avg_Latency_500B_msg,
       st.Avg_Latency_8K_msg,
       s.Avg_Latency_500B_msg s_Avg_Latency_500B_msg,
       s.Avg_Latency_8K_msg s_Avg_Latency_8K_msg,
       t.Avg_Latency_500B_msg t_Avg_Latency_500B_msg,
       t.Avg_Latency_8K_msg t_Avg_Latency_8K_msg,
       c.Avg_Latency_500B_msg c_Avg_Latency_500B_msg,
       c.Avg_Latency_8K_msg c_Avg_Latency_8K_msg
  FROM per_source_and_target st,
       per_source s,
       per_target t,
       per_cluster c
-- all these outerjoins are not needed, but they workaround a performance issue here
 WHERE s.snap_id(+) = st.snap_id
   AND s.instance_number(+) = st.instance_number
   AND s.begin_time(+) = st.begin_time
   AND s.end_time(+) = st.end_time
   AND t.snap_id(+) = st.snap_id
   AND t.target_instance(+) = st.target_instance
   AND t.begin_time(+) = st.begin_time
   AND t.end_time(+) = st.end_time
   AND c.snap_id(+) = st.snap_id
   AND c.begin_time(+) = st.begin_time
   AND c.end_time(+) = st.end_time
 UNION ALL
SELECT s.snap_id,
       s.instance_number,
       s.target_instance,
       s.begin_time,
       s.end_time,
       s.Avg_Latency_500B_msg,
       s.Avg_Latency_8K_msg,
       0 s_Avg_Latency_500B_msg,
       0 s_Avg_Latency_8K_msg,
       0 t_Avg_Latency_500B_msg,
       0 t_Avg_Latency_8K_msg,
       c.Avg_Latency_500B_msg c_Avg_Latency_500B_msg,
       c.Avg_Latency_8K_msg c_Avg_Latency_8K_msg
  FROM per_source s,
       per_cluster c
 WHERE c.snap_id = s.snap_id
   AND c.begin_time = s.begin_time
   AND c.end_time = s.end_time
 UNION ALL
SELECT t.snap_id,
       t.instance_number,
       t.target_instance,
       t.begin_time,
       t.end_time,
       t.Avg_Latency_500B_msg,
       t.Avg_Latency_8K_msg,
       0 s_Avg_Latency_500B_msg,
       0 s_Avg_Latency_8K_msg,
       0 t_Avg_Latency_500B_msg,
       0 t_Avg_Latency_8K_msg,
       c.Avg_Latency_500B_msg c_Avg_Latency_500B_msg,
       c.Avg_Latency_8K_msg c_Avg_Latency_8K_msg
  FROM per_target t,
       per_cluster c
 WHERE c.snap_id = t.snap_id
   AND c.begin_time = t.begin_time
   AND c.end_time = t.end_time
),
denorm_target AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       begin_time,
       end_time,
       instance_number inst_num,
       SUM(CASE target_instance WHEN 1 THEN Avg_Latency_500B_msg ELSE 0 END) Avg_Latency_500B_msg_i1,
       SUM(CASE target_instance WHEN 1 THEN Avg_Latency_8K_msg ELSE 0 END) Avg_Latency_8K_msg_i1,
       SUM(CASE target_instance WHEN 2 THEN Avg_Latency_500B_msg ELSE 0 END) Avg_Latency_500B_msg_i2,
       SUM(CASE target_instance WHEN 2 THEN Avg_Latency_8K_msg ELSE 0 END) Avg_Latency_8K_msg_i2,
       SUM(CASE target_instance WHEN 3 THEN Avg_Latency_500B_msg ELSE 0 END) Avg_Latency_500B_msg_i3,
       SUM(CASE target_instance WHEN 3 THEN Avg_Latency_8K_msg ELSE 0 END) Avg_Latency_8K_msg_i3,
       SUM(CASE target_instance WHEN 4 THEN Avg_Latency_500B_msg ELSE 0 END) Avg_Latency_500B_msg_i4,
       SUM(CASE target_instance WHEN 4 THEN Avg_Latency_8K_msg ELSE 0 END) Avg_Latency_8K_msg_i4,
       SUM(CASE target_instance WHEN 5 THEN Avg_Latency_500B_msg ELSE 0 END) Avg_Latency_500B_msg_i5,
       SUM(CASE target_instance WHEN 5 THEN Avg_Latency_8K_msg ELSE 0 END) Avg_Latency_8K_msg_i5,
       SUM(CASE target_instance WHEN 6 THEN Avg_Latency_500B_msg ELSE 0 END) Avg_Latency_500B_msg_i6,
       SUM(CASE target_instance WHEN 6 THEN Avg_Latency_8K_msg ELSE 0 END) Avg_Latency_8K_msg_i6,
       SUM(CASE target_instance WHEN 7 THEN Avg_Latency_500B_msg ELSE 0 END) Avg_Latency_500B_msg_i7,
       SUM(CASE target_instance WHEN 7 THEN Avg_Latency_8K_msg ELSE 0 END) Avg_Latency_8K_msg_i7,
       SUM(CASE target_instance WHEN 8 THEN Avg_Latency_500B_msg ELSE 0 END) Avg_Latency_500B_msg_i8,
       SUM(CASE target_instance WHEN 8 THEN Avg_Latency_8K_msg ELSE 0 END) Avg_Latency_8K_msg_i8,
       MAX(s_Avg_Latency_500B_msg) i_Avg_Latency_500B_msg,
       MAX(s_Avg_Latency_8K_msg) i_Avg_Latency_8K_msg,
       MAX(c_Avg_Latency_500B_msg) c_Avg_Latency_500B_msg,
       MAX(c_Avg_Latency_8K_msg) c_Avg_Latency_8K_msg
  FROM source_and_target_extended
 WHERE instance_number = @instance_number@
 GROUP BY
       snap_id,
       begin_time,
       end_time,
       instance_number
),
denorm_source AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       begin_time,
       end_time,
       target_instance inst_num,
       SUM(CASE instance_number WHEN 1 THEN Avg_Latency_500B_msg ELSE 0 END) Avg_Latency_500B_msg_i1,
       SUM(CASE instance_number WHEN 1 THEN Avg_Latency_8K_msg ELSE 0 END) Avg_Latency_8K_msg_i1,
       SUM(CASE instance_number WHEN 2 THEN Avg_Latency_500B_msg ELSE 0 END) Avg_Latency_500B_msg_i2,
       SUM(CASE instance_number WHEN 2 THEN Avg_Latency_8K_msg ELSE 0 END) Avg_Latency_8K_msg_i2,
       SUM(CASE instance_number WHEN 3 THEN Avg_Latency_500B_msg ELSE 0 END) Avg_Latency_500B_msg_i3,
       SUM(CASE instance_number WHEN 3 THEN Avg_Latency_8K_msg ELSE 0 END) Avg_Latency_8K_msg_i3,
       SUM(CASE instance_number WHEN 4 THEN Avg_Latency_500B_msg ELSE 0 END) Avg_Latency_500B_msg_i4,
       SUM(CASE instance_number WHEN 4 THEN Avg_Latency_8K_msg ELSE 0 END) Avg_Latency_8K_msg_i4,
       SUM(CASE instance_number WHEN 5 THEN Avg_Latency_500B_msg ELSE 0 END) Avg_Latency_500B_msg_i5,
       SUM(CASE instance_number WHEN 5 THEN Avg_Latency_8K_msg ELSE 0 END) Avg_Latency_8K_msg_i5,
       SUM(CASE instance_number WHEN 6 THEN Avg_Latency_500B_msg ELSE 0 END) Avg_Latency_500B_msg_i6,
       SUM(CASE instance_number WHEN 6 THEN Avg_Latency_8K_msg ELSE 0 END) Avg_Latency_8K_msg_i6,
       SUM(CASE instance_number WHEN 7 THEN Avg_Latency_500B_msg ELSE 0 END) Avg_Latency_500B_msg_i7,
       SUM(CASE instance_number WHEN 7 THEN Avg_Latency_8K_msg ELSE 0 END) Avg_Latency_8K_msg_i7,
       SUM(CASE instance_number WHEN 8 THEN Avg_Latency_500B_msg ELSE 0 END) Avg_Latency_500B_msg_i8,
       SUM(CASE instance_number WHEN 8 THEN Avg_Latency_8K_msg ELSE 0 END) Avg_Latency_8K_msg_i8,
       MAX(t_Avg_Latency_500B_msg) i_Avg_Latency_500B_msg,
       MAX(t_Avg_Latency_8K_msg) i_Avg_Latency_8K_msg,
       MAX(c_Avg_Latency_500B_msg) c_Avg_Latency_500B_msg,
       MAX(c_Avg_Latency_8K_msg) c_Avg_Latency_8K_msg
  FROM source_and_target_extended
 WHERE target_instance = @instance_number@
 GROUP BY
       snap_id,
       begin_time,
       end_time,
       target_instance
)
SELECT snap_id,
       begin_time,
       end_time,
       c_Avg_Latency_@msg@_msg cluster_avg,
       i_Avg_Latency_@msg@_msg instance_avg,
       Avg_Latency_@msg@_msg_i1 inst_1,
       Avg_Latency_@msg@_msg_i2 inst_2,
       Avg_Latency_@msg@_msg_i3 inst_3,
       Avg_Latency_@msg@_msg_i4 inst_4,
       Avg_Latency_@msg@_msg_i5 inst_5,
       Avg_Latency_@msg@_msg_i6 inst_6,
       Avg_Latency_@msg@_msg_i7 inst_7,
       Avg_Latency_@msg@_msg_i8 inst_8,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM denorm_@denorm@
 ORDER BY       
       snap_id,
       begin_time
';
END;
/

SET SERVEROUT ON;
SPO 9980_&&common_edb360_prefix._chart_setup_driver2.sql;
DECLARE
  l_count NUMBER;
BEGIN
  FOR i IN 1 .. 13
  LOOP
    SELECT COUNT(*) INTO l_count FROM gv$instance WHERE instance_number = i;
    IF l_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('COL inst_'||LPAD(i, 2, '0')||' NOPRI;');
      DBMS_OUTPUT.PUT_LINE('DEF tit_'||LPAD(i + 2, 2, '0')||' = '''';');
    ELSE
      DBMS_OUTPUT.PUT_LINE('COL inst_'||LPAD(i, 2, '0')||' HEA ''Inst '||i||''' FOR 999990.0 PRI;');
      DBMS_OUTPUT.PUT_LINE('DEF tit_'||LPAD(i + 2, 2, '0')||' = ''Inst '||i||''';');
    END IF;
  END LOOP;
END;
/
SPO OFF;
SET SERVEROUT OFF;
@9980_&&common_edb360_prefix._chart_setup_driver2.sql;
HOS zip -mq &&edb360_main_filename._&&edb360_file_time. 9980_&&common_edb360_prefix._chart_setup_driver2.sql

DEF tit_01 = 'Cluster Avg';
DEF tit_02 = '';

DEF skip_lch = '';
DEF title = '8K msg pings from all Instances';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '-1');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '8K');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'source');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '8K msg pings sent to all Instances';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '-1');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '8K');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'target');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '500B msg pings from all Instances';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '-1');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '500B');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'source');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = '500B msg pings sent to all Instances';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '-1');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '500B');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'target');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF tit_02 = 'Inst Avg';

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = '8K msg pings received from Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '8K');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'target');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = '8K msg pings sent to Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '8K');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'source');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = '500B msg pings received from Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '500B');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'target');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = '500B msg pings sent to Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '500B');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'source');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql


DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = '8K msg pings received from Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '8K');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'target');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = '8K msg pings sent to Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '8K');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'source');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = '500B msg pings received from Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '500B');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'target');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = '500B msg pings sent to Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '500B');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'source');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql


DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = '8K msg pings received from Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '8K');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'target');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = '8K msg pings sent to Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '8K');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'source');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = '500B msg pings received from Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '500B');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'target');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = '500B msg pings sent to Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '500B');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'source');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql


DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = '8K msg pings received from Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '8K');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'target');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = '8K msg pings sent to Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '8K');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'source');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = '500B msg pings received from Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '500B');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'target');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = '500B msg pings sent to Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '500B');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'source');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql


DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = '8K msg pings received from Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '8K');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'target');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = '8K msg pings sent to Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '8K');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'source');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = '500B msg pings received from Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '500B');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'target');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = '500B msg pings sent to Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '500B');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'source');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql


DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = '8K msg pings received from Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '8K');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'target');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = '8K msg pings sent to Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '8K');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'source');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = '500B msg pings received from Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '500B');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'target');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = '500B msg pings sent to Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '500B');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'source');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql


DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = '8K msg pings received from Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '8K');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'target');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = '8K msg pings sent to Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '8K');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'source');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = '500B msg pings received from Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '500B');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'target');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = '500B msg pings sent to Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '500B');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'source');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql


DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = '8K msg pings received from Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '8K');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'target');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = '8K msg pings sent to Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '8K');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'source');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = '500B msg pings received from Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '500B');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'target');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = '500B msg pings sent to Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
EXEC :sql_text := REPLACE(:sql_text, '@msg@', '500B');
EXEC :sql_text := REPLACE(:sql_text, '@denorm@', 'source');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = 'Y';

