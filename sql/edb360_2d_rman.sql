@@&&edb360_0g.tkprof.sql
DEF section_id = '2d';
DEF section_name = 'Backup and Recovery';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'Block Corruption';
DEF main_table = 'V$DATABASE_BLOCK_CORRUPTION';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$database_block_corruption
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Block Change Tracking';
DEF main_table = 'V$BLOCK_CHANGE_TRACKING';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$block_change_tracking
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'RMAN Backup Job Details';
DEF main_table = 'V$RMAN_BACKUP_JOB_DETAILS';
BEGIN
  :sql_text := '
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$rman_backup_job_details
 --WHERE start_time >= (SYSDATE - 100)
 ORDER BY
       start_time DESC
';
END;
/
-- skipped on 10g due to bug as per mos 420200.1
@@&&skip_10g.edb360_9a_pre_one.sql

DEF title = 'RMAN Backup Set Details';
DEF main_table = 'V$BACKUP_SET_DETAILS';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$backup_set_details
 ORDER BY
       1, 2, 3, 4, 5
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'RMAN Output';
DEF main_table = 'V$RMAN_OUTPUT';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$rman_output
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Fast Recovery Area';
DEF main_table = 'V$RECOVERY_FILE_DEST';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$recovery_file_dest
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Fast Recovery Area Usage';
DEF main_table = 'V$RECOVERY_AREA_USAGE';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$recovery_area_usage
';
END;
/
@@&&skip_10g.edb360_9a_pre_one.sql

DEF title = 'Restore Point';
DEF main_table = 'V$RESTORE_POINT';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$restore_point
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Flashback Statistics';
DEF main_table = 'V$FLASHBACK_DATABASE_STAT';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$flashback_database_stat
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Flashback Log';
DEF main_table = 'V$FLASHBACK_DATABASE_LOG';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$flashback_database_log
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'REDO LOG';
DEF main_table = 'V$LOG';
BEGIN
  :sql_text := '
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
     *
  FROM v$log
 ORDER BY 1, 2, 3, 4
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'REDO LOG Files';
DEF main_table = 'V$LOGFILE';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
     *
  FROM v$logfile
 ORDER BY 1, 2, 3, 4
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'REDO LOG History';
DEF main_table = 'V$LOG_HISTORY';
BEGIN
  :sql_text := '
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
 THREAD#, TO_CHAR(trunc(FIRST_TIME), ''YYYY-MON-DD'') day, count(*)
from v$log_history
where FIRST_TIME >= (sysdate - 31)
group by rollup(THREAD#, trunc(FIRST_TIME))
order by THREAD#, trunc(FIRST_TIME)
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'REDO LOG Switches Frequency Map';
DEF main_table = 'V$LOG_HISTORY';
COL row_num_noprint NOPRI;
BEGIN
  :sql_text := '
-- requested by Weidong
WITH
log AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       thread#,
       TO_CHAR(TRUNC(first_time), ''YYYY-MM-DD'') yyyy_mm_dd,
       TO_CHAR(TRUNC(first_time), ''Dy'') day,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''00'', 1, 0)) h00,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''01'', 1, 0)) h01,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''02'', 1, 0)) h02,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''03'', 1, 0)) h03,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''04'', 1, 0)) h04,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''05'', 1, 0)) h05,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''06'', 1, 0)) h06,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''07'', 1, 0)) h07,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''08'', 1, 0)) h08,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''09'', 1, 0)) h09,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''10'', 1, 0)) h10,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''11'', 1, 0)) h11,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''12'', 1, 0)) h12,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''13'', 1, 0)) h13,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''14'', 1, 0)) h14,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''15'', 1, 0)) h15,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''16'', 1, 0)) h16,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''17'', 1, 0)) h17,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''18'', 1, 0)) h18,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''19'', 1, 0)) h19,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''20'', 1, 0)) h20,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''21'', 1, 0)) h21,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''22'', 1, 0)) h22,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''23'', 1, 0)) h23,
       COUNT(*) per_day
  FROM v$log_history
 GROUP BY
       thread#,
       TRUNC(first_time)
 ORDER BY
       thread#,
       TRUNC(first_time) DESC NULLS LAST
),
ordered_log AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       ROWNUM row_num_noprint, log.*
  FROM log
),
min_set AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       thread#,
       MIN(row_num_noprint) min_row_num
  FROM ordered_log
 GROUP BY 
       thread#
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       log.*
  FROM ordered_log log,
       min_set ms
 WHERE log.thread# = ms.thread#
   AND log.row_num_noprint < ms.min_row_num + 14
 ORDER BY
       log.thread#,
       log.yyyy_mm_dd DESC
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'ARCHIVED LOG Frequency Map per Thread';
DEF main_table = 'V$ARCHIVED_LOG';
COL row_num_noprint NOPRI;
BEGIN
  :sql_text := '
-- requested by Abdul Khan and Srinivas Kanaparthy
WITH
log AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       DISTINCT 
       thread#,
       sequence#,
       first_time,
       blocks,
       block_size
  FROM v$archived_log
 WHERE first_time IS NOT NULL
),
log_denorm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       thread#,
       TO_CHAR(TRUNC(first_time), ''YYYY-MM-DD'') yyyy_mm_dd,
       TO_CHAR(TRUNC(first_time), ''Dy'') day,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''00'', 1, 0)) h00,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''01'', 1, 0)) h01,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''02'', 1, 0)) h02,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''03'', 1, 0)) h03,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''04'', 1, 0)) h04,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''05'', 1, 0)) h05,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''06'', 1, 0)) h06,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''07'', 1, 0)) h07,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''08'', 1, 0)) h08,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''09'', 1, 0)) h09,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''10'', 1, 0)) h10,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''11'', 1, 0)) h11,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''12'', 1, 0)) h12,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''13'', 1, 0)) h13,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''14'', 1, 0)) h14,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''15'', 1, 0)) h15,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''16'', 1, 0)) h16,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''17'', 1, 0)) h17,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''18'', 1, 0)) h18,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''19'', 1, 0)) h19,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''20'', 1, 0)) h20,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''21'', 1, 0)) h21,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''22'', 1, 0)) h22,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''23'', 1, 0)) h23,
       ROUND(SUM(blocks * block_size) / POWER(10,9), 1) TOT_GB,
       COUNT(*) cnt,
       ROUND(SUM(blocks * block_size) / POWER(10,9) / COUNT(*), 1) AVG_GB
  FROM log
 GROUP BY
       thread#,
       TRUNC(first_time)
 ORDER BY
       thread#,
       TRUNC(first_time) DESC
),
ordered_log AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       ROWNUM row_num_noprint, log_denorm.*
  FROM log_denorm
),
min_set AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       thread#,
       MIN(row_num_noprint) min_row_num
  FROM ordered_log
 GROUP BY 
       thread#
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       log.*
  FROM ordered_log log,
       min_set ms
 WHERE log.thread# = ms.thread#
   AND log.row_num_noprint < ms.min_row_num + 14
 ORDER BY
       log.thread#,
       log.yyyy_mm_dd DESC
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'ARCHIVED LOG Frequency Map per Cluster';
DEF main_table = 'V$ARCHIVED_LOG';
COL row_num_noprint NOPRI;
BEGIN
  :sql_text := '
WITH
log AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       DISTINCT 
       thread#,
       sequence#,
       first_time,
       blocks,
       block_size
  FROM v$archived_log
 WHERE first_time IS NOT NULL
),
log_denorm AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       TO_CHAR(TRUNC(first_time), ''YYYY-MM-DD'') yyyy_mm_dd,
       TO_CHAR(TRUNC(first_time), ''Dy'') day,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''00'', 1, 0)) h00,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''01'', 1, 0)) h01,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''02'', 1, 0)) h02,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''03'', 1, 0)) h03,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''04'', 1, 0)) h04,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''05'', 1, 0)) h05,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''06'', 1, 0)) h06,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''07'', 1, 0)) h07,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''08'', 1, 0)) h08,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''09'', 1, 0)) h09,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''10'', 1, 0)) h10,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''11'', 1, 0)) h11,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''12'', 1, 0)) h12,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''13'', 1, 0)) h13,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''14'', 1, 0)) h14,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''15'', 1, 0)) h15,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''16'', 1, 0)) h16,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''17'', 1, 0)) h17,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''18'', 1, 0)) h18,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''19'', 1, 0)) h19,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''20'', 1, 0)) h20,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''21'', 1, 0)) h21,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''22'', 1, 0)) h22,
       SUM(DECODE(TO_CHAR(first_time, ''HH24''), ''23'', 1, 0)) h23,
       ROUND(SUM(blocks * block_size) / POWER(10,9), 1) TOT_GB,
       COUNT(*) cnt,
       ROUND(SUM(blocks * block_size) / POWER(10,9) / COUNT(*), 1) AVG_GB
  FROM log
 GROUP BY
       TRUNC(first_time)
 ORDER BY
       TRUNC(first_time) DESC
),
ordered_log AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       ROWNUM row_num_noprint, log_denorm.*
  FROM log_denorm
),
min_set AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       MIN(row_num_noprint) min_row_num
  FROM ordered_log
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       log.*
  FROM ordered_log log,
       min_set ms
 WHERE log.row_num_noprint < ms.min_row_num + 14
 ORDER BY
       log.yyyy_mm_dd DESC
';
END;
/
@@edb360_9a_pre_one.sql

-- special contribution from David Mann
-- http://ba6.us/?q=ArchivedLogRedoInGB_HeatMap
EXEC :file_seq := :file_seq + 1;
SELECT LPAD(:file_seq, 5, '0')||'_&&common_edb360_prefix._&&section_id._&&report_sequence._archived_redo_log_heat_map' one_spool_filename FROM DUAL;
SET SERVEROUT ON
SET SERVEROUT ON SIZE 1000000;
SET SERVEROUT ON SIZE UNL;
SPO &&one_spool_filename..html
@@2016-03-08-RedoLogSizeHeatMap.sql
SPO OFF
SET SERVEROUT OFF
HOS zip -m &&edb360_main_filename._&&edb360_file_time. &&one_spool_filename..html >> &&edb360_log3..txt
-- update main report
SPO &&edb360_main_report..html APP;
PRO <li title="V$ARCHIVED_LOG">ARCHIVED REDO LOG Heat Map for past 31 Days
PRO <a href="&&one_spool_filename..html">html</a>
PRO </li>
SPO OFF;
HOS zip &&edb360_main_filename._&&edb360_file_time. &&edb360_main_report..html >> &&edb360_log3..txt
-- report sequence
EXEC :repo_seq := :repo_seq + 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

DEF title = 'NOLOGGING Objects';
DEF main_table = 'DBA_TABLESPACES';
BEGIN
  :sql_text := '
WITH 
objects AS (
SELECT 1 record_type,
       ''TABLESPACE'' object_type,
       tablespace_name,
       NULL owner,
       NULL name,
       NULL column_name,
       NULL partition,
       NULL subpartition
  FROM dba_tablespaces
 WHERE logging = ''NOLOGGING''
   AND contents != ''TEMPORARY''
UNION ALL       
SELECT 2 record_type,
       ''TABLE'' object_type,
       tablespace_name,
       owner,
       table_name name,
       NULL column_name,
       NULL partition,
       NULL subpartition
  FROM dba_all_tables
 WHERE logging = ''NO''
   AND temporary = ''N''
UNION ALL       
SELECT 3 record_type,
       ''INDEX'' object_type,
       tablespace_name,
       owner,
       index_name name,
       NULL column_name,
       NULL partition,
       NULL subpartition
  FROM dba_indexes
 WHERE logging = ''NO''
   AND temporary = ''N''
UNION ALL       
SELECT 4 record_type,
       ''LOB'' object_type,
       tablespace_name,
       owner,
       table_name name,
       SUBSTR(column_name, 1, 30) column_name,
       NULL partition,
       NULL subpartition
  FROM dba_lobs
 WHERE logging = ''NO''
UNION ALL       
SELECT 5 record_type,
       ''TAB_PARTITION'' object_type,
       tablespace_name,
       table_owner owner,
       table_name name,
       NULL column_name,
       partition_name partition,
       NULL subpartition
  FROM dba_tab_partitions
 WHERE logging = ''NO''
UNION ALL       
SELECT 6 record_type,
       ''IND_PARTITION'' object_type,
       tablespace_name,
       index_owner owner,
       index_name name,
       NULL column_name,
       partition_name partition,
       NULL subpartition
  FROM dba_ind_partitions
 WHERE logging = ''NO''
UNION ALL       
SELECT 7 record_type,
       ''LOB_PARTITION'' object_type,
       tablespace_name,
       table_owner owner,
       table_name name,
       SUBSTR(column_name, 1, 30) column_name,
       partition_name partition,
       NULL subpartition
  FROM dba_lob_partitions
 WHERE logging = ''NO''
UNION ALL       
SELECT 8 record_type,
       ''TAB_SUBPARTITION'' object_type,
       tablespace_name,
       table_owner owner,
       table_name name,
       NULL column_name,
       partition_name partition,
       subpartition_name subpartition
  FROM dba_tab_subpartitions
 WHERE logging = ''NO''
UNION ALL       
SELECT 9 record_type,
       ''IND_SUBPARTITION'' object_type,
       tablespace_name,
       index_owner owner,
       index_name name,
       NULL column_name,
       partition_name partition,
       subpartition_name subpartition
  FROM dba_ind_subpartitions
 WHERE logging = ''NO''
UNION ALL       
SELECT 10 record_type,
       ''LOB_SUBPARTITION'' object_type,
       tablespace_name,
       table_owner owner,
       table_name name,
       SUBSTR(column_name, 1, 30) column_name,
       lob_partition_name partition,
       subpartition_name subpartition
  FROM dba_lob_subpartitions
 WHERE logging = ''NO''
)
SELECT object_type,
       tablespace_name,
       owner,
       name,
       column_name,
       partition,
       subpartition
  FROM objects
 ORDER BY
       record_type,
       tablespace_name,
       owner,
       name,
       column_name,
       partition,
       subpartition
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Unrecoverable Datafile';
DEF main_table = 'V$DATAFILE';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$datafile
 WHERE unrecoverable_change# > 0
 ORDER BY
       file#
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Unrecoverable Datafile after Backup';
DEF main_table = 'V$DATAFILE';
BEGIN
  :sql_text := '
-- from http://www.pythian.com/blog/oracle-what-is-an-unrecoverable-data-file/
-- by Catherine Chow
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
df.name data_file_name, df.unrecoverable_time
FROM v$datafile df, v$backup bk
WHERE df.file#=bk.file#
and df.unrecoverable_change#!=0
and df.unrecoverable_time >  
(select max(end_time) from v$rman_backup_job_details
where INPUT_TYPE in (''DB FULL'' ,''DB INCR'') and status = ''COMPLETED'')
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Objects affected by Unrecoverable Operations';
DEF main_table = 'V$DATAFILE';
BEGIN
  :sql_text := '
-- from http://www.pythian.com/blog/oracle-what-is-an-unrecoverable-data-file/
-- by Catherine Chow
select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
distinct dbo.owner,dbo.object_name, dbo.object_type, dfs.tablespace_name,
dbt.logging table_level_logging, ts.logging tablespace_level_logging
from v$segstat ss, dba_tablespaces ts, dba_objects dbo, dba_tables dbt,
v$datafile df, dba_data_files dfs, v$tablespace vts
where ss.statistic_name =''physical writes direct''
and dbo.object_id = ss.obj#
and vts.ts# = ss.ts#
and ts.tablespace_name = vts.name
and ss.value != 0
and df.unrecoverable_change# != 0
and dfs.file_name = df.name
and ts.tablespace_name = dfs.tablespace_name
and dbt.owner = dbo.owner
and dbt.table_name = dbo.object_name
';
END;
/
--@@edb360_9a_pre_one.sql too slow! possibly bug 1532624.1

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
