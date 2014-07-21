DEF section_name = 'Active Session History (ASH)';
SPO &&main_report_name..html APP;
PRO <h2>&&section_name.</h2>
SPO OFF;

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF chartype = 'AreaChart';
DEF stacked = 'isStacked: true,';
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
DEF vbaseline = '';
DEF tit_01 = '';
DEF tit_02 = 'On CPU';
DEF tit_03 = 'Administrative';
DEF tit_04 = 'Application';
DEF tit_05 = 'Cluster';
DEF tit_06 = 'Commit';
DEF tit_07 = 'Concurrency';
DEF tit_08 = 'Configuration';
DEF tit_09 = 'Idle';
DEF tit_10 = 'Network';
DEF tit_11 = 'Other';
DEF tit_12 = 'Queueing';
DEF tit_13 = 'Scheduler';
DEF tit_14 = 'System I/O';
DEF tit_15 = 'User I/O';
COL aas_total FOR 999990.000;
COL aas_on_cpu FOR 999990.000;
COL aas_administrative FOR 999990.000;
COL aas_application FOR 999990.000;
COL aas_cluster FOR 999990.000;
COL aas_commit FOR 999990.000;
COL aas_concurrency FOR 999990.000;
COL aas_configuration FOR 999990.000;
COL aas_idle FOR 999990.000;
COL aas_network FOR 999990.000;
COL aas_other FOR 999990.000;
COL aas_queueing FOR 999990.000;
COL aas_scheduler FOR 999990.000;
COL aas_system_io FOR 999990.000;
COL aas_user_io FOR 999990.000;
BEGIN
  :sql_text_backup := '
WITH
ash_denorm_2 AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       instance_number,
       COUNT(*) total,
       SUM(CASE session_state WHEN ''ON CPU''         THEN 1 ELSE 0 END) on_cpu,
       SUM(CASE wait_class    WHEN ''Administrative'' THEN 1 ELSE 0 END) w_administrative,
       SUM(CASE wait_class    WHEN ''Application''    THEN 1 ELSE 0 END) w_application,
       SUM(CASE wait_class    WHEN ''Cluster''        THEN 1 ELSE 0 END) w_cluster,
       SUM(CASE wait_class    WHEN ''Commit''         THEN 1 ELSE 0 END) w_commit,
       SUM(CASE wait_class    WHEN ''Concurrency''    THEN 1 ELSE 0 END) w_concurrency,
       SUM(CASE wait_class    WHEN ''Configuration''  THEN 1 ELSE 0 END) w_configuration,
       SUM(CASE wait_class    WHEN ''Idle''           THEN 1 ELSE 0 END) w_idle,
       SUM(CASE wait_class    WHEN ''Network''        THEN 1 ELSE 0 END) w_network,
       SUM(CASE wait_class    WHEN ''Other''          THEN 1 ELSE 0 END) w_other,
       SUM(CASE wait_class    WHEN ''Queueing''       THEN 1 ELSE 0 END) w_queueing,
       SUM(CASE wait_class    WHEN ''Scheduler''      THEN 1 ELSE 0 END) w_scheduler,
       SUM(CASE wait_class    WHEN ''System I/O''     THEN 1 ELSE 0 END) w_system_io,
       SUM(CASE wait_class    WHEN ''User I/O''       THEN 1 ELSE 0 END) w_user_io       
  FROM dba_hist_active_sess_history
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND instance_number = @instance_number@
 GROUP BY
       snap_id,
       dbid,
       instance_number
),
ash_denorm_3 AS (
SELECT /*+ &&sq_fact_hints. */
       a.snap_id,
       a.dbid,
       a.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       ROUND((CAST(s.end_interval_time AS DATE) - CAST(s.begin_interval_time AS DATE)) * 24 * 60 * 60) interval_secs,
       (10 * total)            total,
       (10 * on_cpu)           on_cpu,
       (10 * w_administrative) w_administrative,
       (10 * w_application)    w_application,
       (10 * w_cluster)        w_cluster,
       (10 * w_commit)         w_commit,
       (10 * w_concurrency)    w_concurrency,
       (10 * w_configuration)  w_configuration,
       (10 * w_idle)           w_idle,
       (10 * w_network)        w_network,
       (10 * w_other)          w_other,
       (10 * w_queueing)       w_queueing,
       (10 * w_scheduler)      w_scheduler,
       (10 * w_system_io)      w_system_io,
       (10 * w_user_io)        w_user_io
  FROM ash_denorm_2 a,
       dba_hist_snapshot s
 WHERE s.snap_id = a.snap_id
   AND s.dbid = a.dbid
   AND s.instance_number = a.instance_number
   AND s.end_interval_time > (s.begin_interval_time + (1 / (24 * 60))) /* filter out snaps apart < 1 min */
),
ash_aas AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       instance_number,
       TO_CHAR(begin_interval_time, ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(end_interval_time, ''YYYY-MM-DD HH24:MI'')   end_time,
       (total / interval_secs)            aas_total,
       (on_cpu / interval_secs)           aas_on_cpu,
       (w_administrative / interval_secs) aas_administrative,
       (w_application / interval_secs)    aas_application,
       (w_cluster / interval_secs)        aas_cluster,
       (w_commit / interval_secs)         aas_commit,
       (w_concurrency / interval_secs)    aas_concurrency,
       (w_configuration / interval_secs)  aas_configuration,
       (w_idle / interval_secs)           aas_idle,
       (w_network / interval_secs)        aas_network,
       (w_other / interval_secs)          aas_other,
       (w_queueing / interval_secs)       aas_queueing,
       (w_scheduler / interval_secs)      aas_scheduler,
       (w_system_io / interval_secs)      aas_system_io,
       (w_user_io / interval_secs)        aas_user_io
  FROM ash_denorm_3
)
SELECT snap_id,
       MIN(begin_time)                   begin_time,
       MIN(end_time)                     end_time,
       ROUND(SUM(aas_total), 3)          aas_total,
       ROUND(SUM(aas_on_cpu), 3)         aas_on_cpu,
       ROUND(SUM(aas_administrative), 3) aas_administrative,
       ROUND(SUM(aas_application), 3)    aas_application,
       ROUND(SUM(aas_cluster), 3)        aas_cluster,
       ROUND(SUM(aas_commit), 3)         aas_commit,
       ROUND(SUM(aas_concurrency), 3)    aas_concurrency,
       ROUND(SUM(aas_configuration), 3)  aas_configuration,
       ROUND(SUM(aas_idle), 3)           aas_idle,
       ROUND(SUM(aas_network), 3)        aas_network,
       ROUND(SUM(aas_other), 3)          aas_other,
       ROUND(SUM(aas_queueing), 3)       aas_queueing,
       ROUND(SUM(aas_scheduler), 3)      aas_scheduler,
       ROUND(SUM(aas_system_io), 3)      aas_system_io,
       ROUND(SUM(aas_user_io), 3)        aas_user_io
  FROM ash_aas
 GROUP BY
       snap_id
 ORDER BY
       snap_id
';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'AAS per Wait Class for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'AAS per Wait Class for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'AAS per Wait Class for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'AAS per Wait Class for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'AAS per Wait Class for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'AAS per Wait Class for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'AAS per Wait Class for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'AAS per Wait Class for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'AAS per Wait Class for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

SET SERVEROUT ON;
SPO 9983_&&common_prefix._chart_setup_driver2.sql;
DECLARE
  l_count NUMBER;
BEGIN
  FOR i IN 1 .. 15
  LOOP
    SELECT COUNT(*) INTO l_count FROM gv$instance WHERE instance_number = i;
    IF l_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('COL inst_'||LPAD(i, 2, '0')||' NOPRI;');
      DBMS_OUTPUT.PUT_LINE('DEF tit_'||LPAD(i, 2, '0')||' = '''';');
    ELSE
      DBMS_OUTPUT.PUT_LINE('COL inst_'||LPAD(i, 2, '0')||' HEA ''Inst '||i||''' FOR 999990.0 PRI;');
      DBMS_OUTPUT.PUT_LINE('DEF tit_'||LPAD(i, 2, '0')||' = ''Inst '||i||''';');
    END IF;
  END LOOP;
END;
/
SPO OFF;
SET SERVEROUT OFF;
@9983_&&common_prefix._chart_setup_driver2.sql;
HOS zip -mq &&main_compressed_filename._&&file_creation_time. 9983_&&common_prefix._chart_setup_driver2.sql

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF vaxis = 'Average Active Sessions - AAS (stacked)';
DEF vbaseline = '';
BEGIN
  :sql_text_backup := '
WITH
ash_denorm_2 AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       instance_number,
       COUNT(*) total,
       SUM(CASE session_state WHEN ''ON CPU''         THEN 1 ELSE 0 END) on_cpu,
       SUM(CASE wait_class    WHEN ''Administrative'' THEN 1 ELSE 0 END) w_administrative,
       SUM(CASE wait_class    WHEN ''Application''    THEN 1 ELSE 0 END) w_application,
       SUM(CASE wait_class    WHEN ''Cluster''        THEN 1 ELSE 0 END) w_cluster,
       SUM(CASE wait_class    WHEN ''Commit''         THEN 1 ELSE 0 END) w_commit,
       SUM(CASE wait_class    WHEN ''Concurrency''    THEN 1 ELSE 0 END) w_concurrency,
       SUM(CASE wait_class    WHEN ''Configuration''  THEN 1 ELSE 0 END) w_configuration,
       SUM(CASE wait_class    WHEN ''Idle''           THEN 1 ELSE 0 END) w_idle,
       SUM(CASE wait_class    WHEN ''Network''        THEN 1 ELSE 0 END) w_network,
       SUM(CASE wait_class    WHEN ''Other''          THEN 1 ELSE 0 END) w_other,
       SUM(CASE wait_class    WHEN ''Queueing''       THEN 1 ELSE 0 END) w_queueing,
       SUM(CASE wait_class    WHEN ''Scheduler''      THEN 1 ELSE 0 END) w_scheduler,
       SUM(CASE wait_class    WHEN ''System I/O''     THEN 1 ELSE 0 END) w_system_io,
       SUM(CASE wait_class    WHEN ''User I/O''       THEN 1 ELSE 0 END) w_user_io       
  FROM dba_hist_active_sess_history
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND @filter_predicate@
 GROUP BY
       snap_id,
       dbid,
       instance_number
),
ash_denorm_3 AS (
SELECT /*+ &&sq_fact_hints. */
       a.snap_id,
       a.dbid,
       a.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       ROUND((CAST(s.end_interval_time AS DATE) - CAST(s.begin_interval_time AS DATE)) * 24 * 60 * 60) interval_secs,
       (10 * total)            total,
       (10 * on_cpu)           on_cpu,
       (10 * w_administrative) w_administrative,
       (10 * w_application)    w_application,
       (10 * w_cluster)        w_cluster,
       (10 * w_commit)         w_commit,
       (10 * w_concurrency)    w_concurrency,
       (10 * w_configuration)  w_configuration,
       (10 * w_idle)           w_idle,
       (10 * w_network)        w_network,
       (10 * w_other)          w_other,
       (10 * w_queueing)       w_queueing,
       (10 * w_scheduler)      w_scheduler,
       (10 * w_system_io)      w_system_io,
       (10 * w_user_io)        w_user_io
  FROM ash_denorm_2 a,
       dba_hist_snapshot s
 WHERE s.snap_id = a.snap_id
   AND s.dbid = a.dbid
   AND s.instance_number = a.instance_number
   AND s.end_interval_time > (s.begin_interval_time + (1 / (24 * 60))) /* filter out snaps apart < 1 min */
),
ash_aas AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       instance_number,
       TO_CHAR(begin_interval_time, ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(end_interval_time, ''YYYY-MM-DD HH24:MI'')   end_time,
       (total / interval_secs)            aas_total,
       (on_cpu / interval_secs)           aas_on_cpu,
       (w_administrative / interval_secs) aas_administrative,
       (w_application / interval_secs)    aas_application,
       (w_cluster / interval_secs)        aas_cluster,
       (w_commit / interval_secs)         aas_commit,
       (w_concurrency / interval_secs)    aas_concurrency,
       (w_configuration / interval_secs)  aas_configuration,
       (w_idle / interval_secs)           aas_idle,
       (w_network / interval_secs)        aas_network,
       (w_other / interval_secs)          aas_other,
       (w_queueing / interval_secs)       aas_queueing,
       (w_scheduler / interval_secs)      aas_scheduler,
       (w_system_io / interval_secs)      aas_system_io,
       (w_user_io / interval_secs)        aas_user_io
  FROM ash_denorm_3
),
aas_denorm_4 AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       begin_time,
       end_time,
       CASE instance_number WHEN 1 THEN @column_name@ ELSE 0 END inst_01,
       CASE instance_number WHEN 2 THEN @column_name@ ELSE 0 END inst_02,
       CASE instance_number WHEN 3 THEN @column_name@ ELSE 0 END inst_03,
       CASE instance_number WHEN 4 THEN @column_name@ ELSE 0 END inst_04,
       CASE instance_number WHEN 5 THEN @column_name@ ELSE 0 END inst_05,
       CASE instance_number WHEN 6 THEN @column_name@ ELSE 0 END inst_06,
       CASE instance_number WHEN 7 THEN @column_name@ ELSE 0 END inst_07,
       CASE instance_number WHEN 8 THEN @column_name@ ELSE 0 END inst_08
  FROM ash_aas
)
SELECT snap_id,
       MIN(begin_time) begin_time,
       MIN(end_time) end_time,
       ROUND(SUM(inst_01), 3) inst_01,
       ROUND(SUM(inst_02), 3) inst_02,
       ROUND(SUM(inst_03), 3) inst_03,
       ROUND(SUM(inst_04), 3) inst_04,
       ROUND(SUM(inst_05), 3) inst_05,
       ROUND(SUM(inst_06), 3) inst_06,
       ROUND(SUM(inst_07), 3) inst_07,
       ROUND(SUM(inst_08), 3) inst_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM aas_denorm_4
 GROUP BY
       snap_id
 ORDER BY
       snap_id
';
END;
/

DEF skip_lch = '';
DEF title = 'AAS Total per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', '1 = 1');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS On CPU per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'session_state = ''ON CPU''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_on_cpu');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF section_name = 'Active Session History (ASH) on Wait Class';
SPO &&main_report_name..html APP;
PRO <h2>&&section_name.</h2>
SPO OFF;

DEF skip_lch = '';
DEF title = 'AAS Waiting on Administrative per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Administrative''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_administrative');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Application per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Application''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_application');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Cluster per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Cluster''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_cluster');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Commit per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Commit''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_commit');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Concurrency per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Concurrency''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_concurrency');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Configuration per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Configuration''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_configuration');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Idle per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Idle''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_idle');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Network per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Network''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_network');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Other per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Other''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_other');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Queueing per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Queueing''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_queueing');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Scheduler per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Scheduler''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_scheduler');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on System IO per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''System I/O''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_system_io');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on User IO per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''User I/O''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_user_io');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF section_name = 'Active Session History (ASH) on CPU and Top Wait Events';
SPO &&main_report_name..html APP;
PRO <h2>&&section_name.</h2>
SPO OFF;

COL wait_class_01 NEW_V wait_class_01;
COL event_name_01 NEW_V event_name_01;
COL wait_class_02 NEW_V wait_class_02;
COL event_name_02 NEW_V event_name_02;
COL wait_class_03 NEW_V wait_class_03;
COL event_name_03 NEW_V event_name_03;
COL wait_class_04 NEW_V wait_class_04;
COL event_name_04 NEW_V event_name_04;
COL wait_class_05 NEW_V wait_class_05;
COL event_name_05 NEW_V event_name_05;
COL wait_class_06 NEW_V wait_class_06;
COL event_name_06 NEW_V event_name_06;
COL wait_class_07 NEW_V wait_class_07;
COL event_name_07 NEW_V event_name_07;
COL wait_class_08 NEW_V wait_class_08;
COL event_name_08 NEW_V event_name_08;
COL wait_class_09 NEW_V wait_class_09;
COL event_name_09 NEW_V event_name_09;
COL wait_class_10 NEW_V wait_class_10;
COL event_name_10 NEW_V event_name_10;
COL wait_class_11 NEW_V wait_class_11;
COL event_name_11 NEW_V event_name_11;
COL wait_class_12 NEW_V wait_class_12;
COL event_name_12 NEW_V event_name_12;

WITH
events AS (
SELECT /*+ &&sq_fact_hints. */
       h.wait_class,
       h.event event_name,
       COUNT(*)
  FROM dba_hist_active_sess_history h,
       dba_hist_snapshot s
 WHERE '&&diagnostics_pack.' = 'Y'
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.session_state = 'WAITING'
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
 GROUP BY
       h.wait_class,
       h.event
 ORDER BY
       3 DESC
)
SELECT MIN(CASE ROWNUM WHEN 01 THEN wait_class END) wait_class_01,
       MIN(CASE ROWNUM WHEN 01 THEN event_name END) event_name_01,
       MIN(CASE ROWNUM WHEN 02 THEN wait_class END) wait_class_02,
       MIN(CASE ROWNUM WHEN 02 THEN event_name END) event_name_02,
       MIN(CASE ROWNUM WHEN 03 THEN wait_class END) wait_class_03,
       MIN(CASE ROWNUM WHEN 03 THEN event_name END) event_name_03,
       MIN(CASE ROWNUM WHEN 04 THEN wait_class END) wait_class_04,
       MIN(CASE ROWNUM WHEN 04 THEN event_name END) event_name_04,
       MIN(CASE ROWNUM WHEN 05 THEN wait_class END) wait_class_05,
       MIN(CASE ROWNUM WHEN 05 THEN event_name END) event_name_05,
       MIN(CASE ROWNUM WHEN 06 THEN wait_class END) wait_class_06,
       MIN(CASE ROWNUM WHEN 06 THEN event_name END) event_name_06,
       MIN(CASE ROWNUM WHEN 07 THEN wait_class END) wait_class_07,
       MIN(CASE ROWNUM WHEN 07 THEN event_name END) event_name_07,
       MIN(CASE ROWNUM WHEN 08 THEN wait_class END) wait_class_08,
       MIN(CASE ROWNUM WHEN 08 THEN event_name END) event_name_08,
       MIN(CASE ROWNUM WHEN 09 THEN wait_class END) wait_class_09,
       MIN(CASE ROWNUM WHEN 09 THEN event_name END) event_name_09,
       MIN(CASE ROWNUM WHEN 10 THEN wait_class END) wait_class_10,
       MIN(CASE ROWNUM WHEN 10 THEN event_name END) event_name_10,
       MIN(CASE ROWNUM WHEN 11 THEN wait_class END) wait_class_11,
       MIN(CASE ROWNUM WHEN 11 THEN event_name END) event_name_11,
       MIN(CASE ROWNUM WHEN 12 THEN wait_class END) wait_class_12,
       MIN(CASE ROWNUM WHEN 12 THEN event_name END) event_name_12
  FROM events
 WHERE ROWNUM < 13;

COL recovery NEW_V recovery;
SELECT CHR(38)||' recovery' recovery FROM DUAL;
-- this above is to handle event "RMAN backup & recovery I/O"

DEF slices = '15';
BEGIN
  :sql_text_backup2 := '
WITH
events AS (
SELECT /*+ &&sq_fact_hints. */
       SUBSTR(TRIM(h.sql_id||'' ''||h.program||'' ''||
       CASE h.module WHEN h.program THEN NULL ELSE h.module END), 1, 128) source,
       h.dbid,
       COUNT(*) samples
  FROM dba_hist_active_sess_history h,
       dba_hist_snapshot s
 WHERE @filter_predicate@
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
 GROUP BY
       h.sql_id,
       h.program,
       h.module,
       h.dbid
 ORDER BY
       3 DESC
),
total AS (
SELECT SUM(samples) samples,
       SUM(CASE WHEN ROWNUM > &&slices. THEN samples ELSE 0 END) others
  FROM events
)
SELECT e.source,
       e.samples,
       ROUND(100 * e.samples / t.samples, 1) percent,
       (SELECT DBMS_LOB.SUBSTR(s.sql_text, 1000, 1) FROM dba_hist_sqltext s WHERE s.sql_id = SUBSTR(e.source, 1, 13) AND s.dbid = e.dbid AND ROWNUM = 1) sql_text
  FROM events e,
       total t
 WHERE ROWNUM <= &&slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT ''Others'',
       others samples,
       ROUND(100 * others / samples, 1) percent,
       NULL sql_text
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
';
END;
/

DEF skip_lch = '';
DEF title = 'AAS on CPU per Instance';
DEF abstract = 'Average Active Sessions (AAS) on CPU'
DEF vaxis = 'Average Active Sessions (AAS) on CPU (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'session_state = ''ON CPU''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS on CPU per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.session_state = ''ON CPU''');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_01. "&&event_name_01." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_01. "&&event_name_01."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_01. "&&event_name_01." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_01.'') AND event = TRIM(''&&event_name_01.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_01. "&&event_name_01." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_01.'') AND h.event = TRIM(''&&event_name_01.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_02. "&&event_name_02." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_02. "&&event_name_02."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_02. "&&event_name_02." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_02.'') AND event = TRIM(''&&event_name_02.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_02. "&&event_name_02." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_02.'') AND h.event = TRIM(''&&event_name_02.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_03. "&&event_name_03." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_03. "&&event_name_03."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_03. "&&event_name_03." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_03.'') AND event = TRIM(''&&event_name_03.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_03. "&&event_name_03." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_03.'') AND h.event = TRIM(''&&event_name_03.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_04. "&&event_name_04." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_04. "&&event_name_04."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_04. "&&event_name_04." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_04.'') AND event = TRIM(''&&event_name_04.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_04. "&&event_name_04." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_04.'') AND h.event = TRIM(''&&event_name_04.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_05. "&&event_name_05." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_05. "&&event_name_05."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_05. "&&event_name_05." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_05.'') AND event = TRIM(''&&event_name_05.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_05. "&&event_name_05." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_05.'') AND h.event = TRIM(''&&event_name_05.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_06. "&&event_name_06." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_06. "&&event_name_06."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_06. "&&event_name_06." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_06.'') AND event = TRIM(''&&event_name_06.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_06. "&&event_name_06." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_06.'') AND h.event = TRIM(''&&event_name_06.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_07. "&&event_name_07." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_07. "&&event_name_07."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_07. "&&event_name_07." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_07.'') AND event = TRIM(''&&event_name_07.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_07. "&&event_name_07." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_07.'') AND h.event = TRIM(''&&event_name_07.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_08. "&&event_name_08." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_08. "&&event_name_08."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_08. "&&event_name_08." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_08.'') AND event = TRIM(''&&event_name_08.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_08. "&&event_name_08." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_08.'') AND h.event = TRIM(''&&event_name_08.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_09. "&&event_name_09." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_09. "&&event_name_09."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_09. "&&event_name_09." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_09.'') AND event = TRIM(''&&event_name_09.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_09. "&&event_name_09." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_09.'') AND h.event = TRIM(''&&event_name_09.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_10. "&&event_name_10." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_10. "&&event_name_10."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_10. "&&event_name_10." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_10.'') AND event = TRIM(''&&event_name_10.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_10. "&&event_name_10." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_10.'') AND h.event = TRIM(''&&event_name_10.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_11. "&&event_name_11." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_11. "&&event_name_11."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_11. "&&event_name_11." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_11.'') AND event = TRIM(''&&event_name_11.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_11. "&&event_name_11." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_11.'') AND h.event = TRIM(''&&event_name_11.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_12. "&&event_name_12." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_12. "&&event_name_12."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_12. "&&event_name_12." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_12.'') AND event = TRIM(''&&event_name_12.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_12. "&&event_name_12." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_12.'') AND h.event = TRIM(''&&event_name_12.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';
