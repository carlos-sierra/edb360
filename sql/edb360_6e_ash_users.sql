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
SELECT /*+ &&sq_fact_hints. &&ds_hint. */
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
