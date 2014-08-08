DEF section_name = 'Active Session History (ASH) - Top Timed Events';
SPO &&main_report_name..html APP;
PRO <h2>&&section_name.</h2>
SPO OFF;

DEF main_table = 'GV$ACTIVE_SESSION_HISTORY';
DEF slices = '15';
BEGIN
  :sql_text_backup := '
WITH
events AS (
SELECT /*+ &&sq_fact_hints. */
       CASE h.session_state WHEN ''ON CPU'' THEN h.session_state ELSE h.wait_class||'' "''||h.event||''"'' END timed_event,
       COUNT(*) samples
  FROM gv$active_session_history h
 WHERE ''&&diagnostics_pack.'' = ''Y''
   AND @filter_predicate@
 GROUP BY
       CASE h.session_state WHEN ''ON CPU'' THEN h.session_state ELSE h.wait_class||'' "''||h.event||''"'' END
 ORDER BY
       2 DESC
),
total AS (
SELECT SUM(samples) samples,
       SUM(CASE WHEN ROWNUM > &&slices. THEN samples ELSE 0 END) others
  FROM events
)
SELECT e.timed_event,
       e.samples,
       ROUND(100 * e.samples / t.samples, 1) percent,
       NULL dummy_01
  FROM events e,
       total t
 WHERE ROWNUM <= &&slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT ''Others'',
       others samples,
       ROUND(100 * others / samples, 1) percent,
       NULL dummy_01
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
';
END;
/

/*****************************************************************************************/

DEF skip_pch = '';
DEF title = 'ASH Top Timed Events for Cluster for past 1 hour';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(h.sample_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (1 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE inst_id = 1;
DEF title = 'ASH Top Timed Events for Instance 1 for past 1 hour';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.inst_id = 1 AND CAST(h.sample_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (1 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE inst_id = 2;
DEF title = 'ASH Top Timed Events for Instance 2 for past 1 hour';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.inst_id = 2 AND CAST(h.sample_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (1 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE inst_id = 3;
DEF title = 'ASH Top Timed Events for Instance 3 for past 1 hour';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.inst_id = 3 AND CAST(h.sample_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (1 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE inst_id = 4;
DEF title = 'ASH Top Timed Events for Instance 4 for past 1 hour';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.inst_id = 4 AND CAST(h.sample_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (1 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE inst_id = 5;
DEF title = 'ASH Top Timed Events for Instance 5 for past 1 hour';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.inst_id = 5 AND CAST(h.sample_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (1 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE inst_id = 6;
DEF title = 'ASH Top Timed Events for Instance 6 for past 1 hour';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.inst_id = 6 AND CAST(h.sample_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (1 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE inst_id = 7;
DEF title = 'ASH Top Timed Events for Instance 7 for past 1 hour';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.inst_id = 7 AND CAST(h.sample_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (1 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE inst_id = 8;
DEF title = 'ASH Top Timed Events for Instance 8 for past 1 hour';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.inst_id = 8 AND CAST(h.sample_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (1 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF slices = '15';
BEGIN
  :sql_text_backup := '
WITH
events AS (
SELECT /*+ &&sq_fact_hints. */
       CASE h.session_state WHEN ''ON CPU'' THEN h.session_state ELSE h.wait_class||'' "''||h.event||''"'' END timed_event,
       COUNT(*) samples
  FROM dba_hist_active_sess_history h,
       dba_hist_snapshot s
 WHERE ''&&diagnostics_pack.'' = ''Y''
   AND @filter_predicate@
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
 GROUP BY
       CASE h.session_state WHEN ''ON CPU'' THEN h.session_state ELSE h.wait_class||'' "''||h.event||''"'' END
 ORDER BY
       2 DESC
),
total AS (
SELECT SUM(samples) samples,
       SUM(CASE WHEN ROWNUM > &&slices. THEN samples ELSE 0 END) others
  FROM events
)
SELECT e.timed_event,
       e.samples,
       ROUND(100 * e.samples / t.samples, 1) percent,
       NULL dummy_01
  FROM events e,
       total t
 WHERE ROWNUM <= &&slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT ''Others'',
       others samples,
       ROUND(100 * others / samples, 1) percent,
       NULL dummy_01
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
';
END;
/

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Timed Events for Cluster for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top Timed Events for Instance 1 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top Timed Events for Instance 2 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top Timed Events for Instance 3 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top Timed Events for Instance 4 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top Timed Events for Instance 5 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top Timed Events for Instance 6 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top Timed Events for Instance 7 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top Timed Events for Instance 8 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Timed Events for Cluster for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top Timed Events for Instance 1 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top Timed Events for Instance 2 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top Timed Events for Instance 3 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top Timed Events for Instance 4 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top Timed Events for Instance 5 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top Timed Events for Instance 6 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top Timed Events for Instance 7 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top Timed Events for Instance 8 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Timed Events for Cluster for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top Timed Events for Instance 1 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top Timed Events for Instance 2 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top Timed Events for Instance 3 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top Timed Events for Instance 4 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top Timed Events for Instance 5 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top Timed Events for Instance 6 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top Timed Events for Instance 7 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top Timed Events for Instance 8 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Timed Events for Cluster for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top Timed Events for Instance 1 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top Timed Events for Instance 2 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top Timed Events for Instance 3 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top Timed Events for Instance 4 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top Timed Events for Instance 5 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top Timed Events for Instance 6 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top Timed Events for Instance 7 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top Timed Events for Instance 8 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Timed Events for Cluster for past &&history_days. days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', '1 = 1');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top Timed Events for Instance 1 for past &&history_days. days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top Timed Events for Instance 2 for past &&history_days. days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top Timed Events for Instance 3 for past &&history_days. days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top Timed Events for Instance 4 for past &&history_days. days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top Timed Events for Instance 5 for past &&history_days. days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top Timed Events for Instance 6 for past &&history_days. days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top Timed Events for Instance 7 for past &&history_days. days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top Timed Events for Instance 8 for past &&history_days. days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF section_name = 'Active Session History (ASH) - Top SQL';
SPO &&main_report_name..html APP;
PRO <h2>&&section_name.</h2>
SPO OFF;

DEF main_table = 'GV$ACTIVE_SESSION_HISTORY';
DEF slices = '15';
BEGIN
  :sql_text_backup := '
WITH
events AS (
SELECT /*+ &&sq_fact_hints. */
       NVL(h.sql_id, ''null'') sql_id,
       COUNT(*) samples
  FROM gv$active_session_history h
 WHERE ''&&diagnostics_pack.'' = ''Y''
   AND @filter_predicate@
 GROUP BY
       h.sql_id
 ORDER BY
       2 DESC
),
total AS (
SELECT SUM(samples) samples,
       SUM(CASE WHEN ROWNUM > &&slices. THEN samples ELSE 0 END) others
  FROM events
)
SELECT e.sql_id,
       e.samples,
       ROUND(100 * e.samples / t.samples, 1) percent,
       (SELECT v2.sql_text FROM gv$sql v2 WHERE v2.sql_id = e.sql_id AND ROWNUM = 1) sql_text
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

/*****************************************************************************************/

DEF skip_pch = '';
DEF title = 'ASH Top SQL for Cluster for past 1 hour';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(h.sample_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (1 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE inst_id = 1;
DEF title = 'ASH Top SQL for Instance 1 for past 1 hour';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.inst_id = 1 AND CAST(h.sample_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (1 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE inst_id = 2;
DEF title = 'ASH Top SQL for Instance 2 for past 1 hour';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.inst_id = 2 AND CAST(h.sample_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (1 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE inst_id = 3;
DEF title = 'ASH Top SQL for Instance 3 for past 1 hour';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.inst_id = 3 AND CAST(h.sample_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (1 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE inst_id = 4;
DEF title = 'ASH Top SQL for Instance 4 for past 1 hour';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.inst_id = 4 AND CAST(h.sample_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (1 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE inst_id = 5;
DEF title = 'ASH Top SQL for Instance 5 for past 1 hour';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.inst_id = 5 AND CAST(h.sample_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (1 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE inst_id = 6;
DEF title = 'ASH Top SQL for Instance 6 for past 1 hour';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.inst_id = 6 AND CAST(h.sample_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (1 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE inst_id = 7;
DEF title = 'ASH Top SQL for Instance 7 for past 1 hour';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.inst_id = 7 AND CAST(h.sample_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (1 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE inst_id = 8;
DEF title = 'ASH Top SQL for Instance 8 for past 1 hour';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.inst_id = 8 AND CAST(h.sample_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (1 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF slices = '15';
BEGIN
  :sql_text_backup := '
WITH
events AS (
SELECT /*+ &&sq_fact_hints. */
       NVL(h.sql_id, ''null'') sql_id,
       h.dbid,
       COUNT(*) samples
  FROM dba_hist_active_sess_history h,
       dba_hist_snapshot s
 WHERE ''&&diagnostics_pack.'' = ''Y''
   AND @filter_predicate@
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
 GROUP BY
       h.sql_id,
       h.dbid
 ORDER BY
       3 DESC
),
total AS (
SELECT SUM(samples) samples,
       SUM(CASE WHEN ROWNUM > &&slices. THEN samples ELSE 0 END) others
  FROM events
)
SELECT e.sql_id,
       e.samples,
       ROUND(100 * e.samples / t.samples, 1) percent,
       (SELECT DBMS_LOB.SUBSTR(s.sql_text, 1000, 1) FROM dba_hist_sqltext s WHERE s.sql_id = e.sql_id AND s.dbid = e.dbid AND ROWNUM = 1) sql_text
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

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top SQL for Cluster for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top SQL for Instance 1 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top SQL for Instance 2 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top SQL for Instance 3 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top SQL for Instance 4 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top SQL for Instance 5 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top SQL for Instance 6 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top SQL for Instance 7 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top SQL for Instance 8 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top SQL for Cluster for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top SQL for Instance 1 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top SQL for Instance 2 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top SQL for Instance 3 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top SQL for Instance 4 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top SQL for Instance 5 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top SQL for Instance 6 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top SQL for Instance 7 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top SQL for Instance 8 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top SQL for Cluster for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top SQL for Instance 1 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top SQL for Instance 2 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top SQL for Instance 3 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top SQL for Instance 4 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top SQL for Instance 5 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top SQL for Instance 6 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top SQL for Instance 7 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top SQL for Instance 8 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top SQL for Cluster for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top SQL for Instance 1 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top SQL for Instance 2 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top SQL for Instance 3 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top SQL for Instance 4 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top SQL for Instance 5 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top SQL for Instance 6 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top SQL for Instance 7 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top SQL for Instance 8 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top SQL for Cluster for past &&history_days. days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', '1 = 1');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top SQL for Instance 1 for past &&history_days. days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top SQL for Instance 2 for past &&history_days. days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top SQL for Instance 3 for past &&history_days. days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top SQL for Instance 4 for past &&history_days. days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top SQL for Instance 5 for past &&history_days. days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top SQL for Instance 6 for past &&history_days. days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top SQL for Instance 7 for past &&history_days. days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top SQL for Instance 8 for past &&history_days. days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF section_name = 'Active Session History (ASH) - Top Programs';
SPO &&main_report_name..html APP;
PRO <h2>&&section_name.</h2>
SPO OFF;

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF slices = '15';
BEGIN
  :sql_text_backup := '
WITH
events AS (
SELECT /*+ &&sq_fact_hints. */
       NVL(h.program, ''null'') program,
       COUNT(*) samples
  FROM dba_hist_active_sess_history h,
       dba_hist_snapshot s
 WHERE ''&&diagnostics_pack.'' = ''Y''
   AND @filter_predicate@
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
 GROUP BY
       h.program
 ORDER BY
       2 DESC
),
total AS (
SELECT SUM(samples) samples,
       SUM(CASE WHEN ROWNUM > &&slices. THEN samples ELSE 0 END) others
  FROM events
)
SELECT e.program,
       e.samples,
       ROUND(100 * e.samples / t.samples, 1) percent,
       NULL dummy_01
  FROM events e,
       total t
 WHERE ROWNUM <= &&slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT ''Others'',
       others samples,
       ROUND(100 * others / samples, 1) percent,
       NULL dummy_01
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
';
END;
/

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Programs for Cluster for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top Programs for Instance 1 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top Programs for Instance 2 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top Programs for Instance 3 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top Programs for Instance 4 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top Programs for Instance 5 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top Programs for Instance 6 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top Programs for Instance 7 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top Programs for Instance 8 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Programs for Cluster for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top Programs for Instance 1 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top Programs for Instance 2 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top Programs for Instance 3 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top Programs for Instance 4 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top Programs for Instance 5 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top Programs for Instance 6 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top Programs for Instance 7 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top Programs for Instance 8 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Programs for Cluster for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top Programs for Instance 1 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top Programs for Instance 2 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top Programs for Instance 3 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top Programs for Instance 4 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top Programs for Instance 5 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top Programs for Instance 6 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top Programs for Instance 7 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top Programs for Instance 8 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Programs for Cluster for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top Programs for Instance 1 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top Programs for Instance 2 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top Programs for Instance 3 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top Programs for Instance 4 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top Programs for Instance 5 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top Programs for Instance 6 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top Programs for Instance 7 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top Programs for Instance 8 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF section_name = 'Active Session History (ASH) - Top Modules and Actions';
SPO &&main_report_name..html APP;
PRO <h2>&&section_name.</h2>
SPO OFF;

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF slices = '15';
BEGIN
  :sql_text_backup := '
WITH
events AS (
SELECT /*+ &&sq_fact_hints. */
       NVL(TRIM(h.module||'' ''||h.action), ''null'') module_action,
       COUNT(*) samples
  FROM dba_hist_active_sess_history h,
       dba_hist_snapshot s
 WHERE ''&&diagnostics_pack.'' = ''Y''
   AND @filter_predicate@
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
 GROUP BY
       TRIM(h.module||'' ''||h.action)
 ORDER BY
       2 DESC
),
total AS (
SELECT SUM(samples) samples,
       SUM(CASE WHEN ROWNUM > &&slices. THEN samples ELSE 0 END) others
  FROM events
)
SELECT e.module_action,
       e.samples,
       ROUND(100 * e.samples / t.samples, 1) percent,
       NULL dummy_01
  FROM events e,
       total t
 WHERE ROWNUM <= &&slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT ''Others'',
       others samples,
       ROUND(100 * others / samples, 1) percent,
       NULL dummy_01
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
';
END;
/

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Modules and Actions for Cluster for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top Modules and Actions for Instance 1 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top Modules and Actions for Instance 2 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top Modules and Actions for Instance 3 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top Modules and Actions for Instance 4 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top Modules and Actions for Instance 5 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top Modules and Actions for Instance 6 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top Modules and Actions for Instance 7 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top Modules and Actions for Instance 8 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Modules and Actions for Cluster for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top Modules and Actions for Instance 1 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top Modules and Actions for Instance 2 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top Modules and Actions for Instance 3 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top Modules and Actions for Instance 4 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top Modules and Actions for Instance 5 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top Modules and Actions for Instance 6 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top Modules and Actions for Instance 7 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top Modules and Actions for Instance 8 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Modules and Actions for Cluster for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top Modules and Actions for Instance 1 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top Modules and Actions for Instance 2 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top Modules and Actions for Instance 3 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top Modules and Actions for Instance 4 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top Modules and Actions for Instance 5 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top Modules and Actions for Instance 6 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top Modules and Actions for Instance 7 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top Modules and Actions for Instance 8 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Modules and Actions for Cluster for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top Modules and Actions for Instance 1 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top Modules and Actions for Instance 2 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top Modules and Actions for Instance 3 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top Modules and Actions for Instance 4 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top Modules and Actions for Instance 5 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top Modules and Actions for Instance 6 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top Modules and Actions for Instance 7 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top Modules and Actions for Instance 8 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF section_name = 'Active Session History (ASH) - Top Users';
SPO &&main_report_name..html APP;
PRO <h2>&&section_name.</h2>
SPO OFF;

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF slices = '15';
BEGIN
  :sql_text_backup := '
WITH
events AS (
SELECT /*+ &&sq_fact_hints. */
       h.user_id,
       COUNT(*) samples
  FROM dba_hist_active_sess_history h,
       dba_hist_snapshot s
 WHERE ''&&diagnostics_pack.'' = ''Y''
   AND @filter_predicate@
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
 GROUP BY
       h.user_id
 ORDER BY
       2 DESC
),
total AS (
SELECT SUM(samples) samples,
       SUM(CASE WHEN ROWNUM > &&slices. THEN samples ELSE 0 END) others
  FROM events
)
SELECT NVL((SELECT u.username FROM dba_users u WHERE u.user_id = e.user_id AND ROWNUM = 1), ''null'') username,
       e.samples,
       ROUND(100 * e.samples / t.samples, 1) percent,
       NULL dummy_01       
  FROM events e,
       total t
 WHERE ROWNUM <= &&slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT ''Others'',
       others samples,
       ROUND(100 * others / samples, 1) percent,
       NULL dummy_01       
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
';
END;
/

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Users for Cluster for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top Users for Instance 1 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top Users for Instance 2 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top Users for Instance 3 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top Users for Instance 4 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top Users for Instance 5 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top Users for Instance 6 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top Users for Instance 7 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top Users for Instance 8 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Users for Cluster for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top Users for Instance 1 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top Users for Instance 2 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top Users for Instance 3 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top Users for Instance 4 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top Users for Instance 5 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top Users for Instance 6 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top Users for Instance 7 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top Users for Instance 8 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Users for Cluster for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top Users for Instance 1 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top Users for Instance 2 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top Users for Instance 3 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top Users for Instance 4 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top Users for Instance 5 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top Users for Instance 6 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top Users for Instance 7 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top Users for Instance 8 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top Users for Cluster for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top Users for Instance 1 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top Users for Instance 2 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top Users for Instance 3 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top Users for Instance 4 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top Users for Instance 5 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top Users for Instance 6 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top Users for Instance 7 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top Users for Instance 8 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/

DEF section_name = 'Active Session History (ASH) - Top PLSQL Procedures';
SPO &&main_report_name..html APP;
PRO <h2>&&section_name.</h2>
SPO OFF;

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF slices = '15';
BEGIN
  :sql_text_backup := '
WITH
events AS (
SELECT /*+ &&sq_fact_hints. */
       COUNT(*) samples,
       e.owner plsql_entry_owner,
       e.object_name plsql_entry_object_name,
       e.procedure_name plsql_entry_procedure_name,
       p.owner plsql_owner,
       p.object_name plsql_object_name,
       p.procedure_name plsql_procedure_name
  FROM dba_hist_active_sess_history h,
       dba_hist_snapshot s,
       dba_procedures e,
       dba_procedures p
 WHERE ''&&diagnostics_pack.'' = ''Y''
   AND @filter_predicate@
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
   AND e.object_id = h.plsql_entry_object_id 
   AND e.subprogram_id = h.plsql_entry_subprogram_id
   AND p.object_id(+) = CASE WHEN h.plsql_entry_object_id != h.plsql_object_id AND h.plsql_entry_subprogram_id != h.plsql_subprogram_id THEN h.plsql_object_id END
   AND p.subprogram_id(+) = CASE WHEN h.plsql_entry_object_id != h.plsql_object_id AND h.plsql_entry_subprogram_id != h.plsql_subprogram_id THEN h.plsql_subprogram_id END
 GROUP BY
       e.owner,
       e.object_name,
       e.procedure_name,
       p.owner,
       p.object_name,
       p.procedure_name
 ORDER BY
       1 DESC
),
total AS (
SELECT SUM(samples) samples,
       SUM(CASE WHEN ROWNUM > &&slices. THEN samples ELSE 0 END) others
  FROM events
)
SELECT CASE WHEN e.plsql_entry_procedure_name||e.plsql_entry_object_name||e.plsql_entry_owner IS NULL THEN ''null'' ELSE
       NVL(e.plsql_entry_owner, ''null'')||''.''||NVL(e.plsql_entry_object_name, ''null'')||''.''||NVL(e.plsql_entry_procedure_name, ''null'')
       END||
       ''(''||CASE WHEN e.plsql_procedure_name||e.plsql_object_name||e.plsql_owner IS NULL THEN ''null'' ELSE
       NVL(e.plsql_owner, ''null'')||''.''||NVL(e.plsql_object_name, ''null'')||''.''||NVL(e.plsql_procedure_name, ''null'')
       END||'')''
       procedure_name,
       e.samples,
       ROUND(100 * e.samples / t.samples, 1) percent,
       NULL dummy_01       
  FROM events e,
       total t
 WHERE ROWNUM <= &&slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT ''Others'',
       others samples,
       ROUND(100 * others / samples, 1) percent,
       NULL dummy_01       
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
';
END;
/

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top PLSQL Procedures for Cluster for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top PLSQL Procedures for Instance 1 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top PLSQL Procedures for Instance 2 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top PLSQL Procedures for Instance 3 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top PLSQL Procedures for Instance 4 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top PLSQL Procedures for Instance 5 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top PLSQL Procedures for Instance 6 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top PLSQL Procedures for Instance 7 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top PLSQL Procedures for Instance 8 for past 4 hours';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - (4 / 24) AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top PLSQL Procedures for Cluster for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top PLSQL Procedures for Instance 1 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top PLSQL Procedures for Instance 2 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top PLSQL Procedures for Instance 3 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top PLSQL Procedures for Instance 4 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top PLSQL Procedures for Instance 5 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top PLSQL Procedures for Instance 6 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top PLSQL Procedures for Instance 7 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top PLSQL Procedures for Instance 8 for past 1 day';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 1 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top PLSQL Procedures for Cluster for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top PLSQL Procedures for Instance 1 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top PLSQL Procedures for Instance 2 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top PLSQL Procedures for Instance 3 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top PLSQL Procedures for Instance 4 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top PLSQL Procedures for Instance 5 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top PLSQL Procedures for Instance 6 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top PLSQL Procedures for Instance 7 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top PLSQL Procedures for Instance 8 for past 5 working days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''D'') BETWEEN ''2'' AND ''6'' AND TO_CHAR(CAST(s.end_interval_time AS DATE), ''HH24'') BETWEEN ''0800'' AND ''1900''');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_pch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'ASH Top PLSQL Procedures for Cluster for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'ASH Top PLSQL Procedures for Instance 1 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 1 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'ASH Top PLSQL Procedures for Instance 2 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 2 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'ASH Top PLSQL Procedures for Instance 3 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 3 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'ASH Top PLSQL Procedures for Instance 4 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 4 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'ASH Top PLSQL Procedures for Instance 5 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 5 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'ASH Top PLSQL Procedures for Instance 6 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 6 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'ASH Top PLSQL Procedures for Instance 7 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 7 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'ASH Top PLSQL Procedures for Instance 8 for past 7 days';
DEF title_suffix = '&&as_of_date.';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'h.instance_number = 8 AND CAST(s.end_interval_time AS DATE) BETWEEN TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'') - 7 AND TO_DATE(''&&tool_sysdate.'', ''YYYYMMDDHH24MISS'')');
@@&&skip_all.edb360_9a_pre_one.sql

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/


