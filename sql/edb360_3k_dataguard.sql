@@&&edb360_0g.tkprof.sql
DEF section_id = '3k';
DEF section_name = 'Data Guard Primary Site';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'Database Role';
DEF main_table = 'V$DATABASE';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT database_role role, name, db_unique_name, platform_id, open_mode, log_mode, flashback_on, protection_mode, protection_level /* &&section_id..&&report_sequence. */
FROM v$database
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Force Logging';
DEF main_table = 'V$DATABASE';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT force_logging, remote_archive, supplemental_log_data_pk, supplemental_log_data_ui, switchover_status, dataguard_broker /* &&section_id..&&report_sequence. */
FROM v$database
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Catproc Release';
DEF main_table = 'DBA_REGISTRY';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT version, modified, status /* &&section_id..&&report_sequence. */
  FROM dba_registry WHERE comp_id = 'CATPROC'
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Threads';
DEF main_table = 'V$THREAD';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT thread#, instance, status /* &&section_id..&&report_sequence. */
FROM v$thread
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Instances';
DEF main_table = 'GV$INSTANCE';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT thread#, instance_name, host_name, version, archiver, log_switch_wait /* &&section_id..&&report_sequence. */
FROM gv$instance ORDER BY thread#
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Log Switching';
DEF main_table = 'V$ARCHIVED_LOG';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT fs.log_switches_under_20_mins, ss.log_switches_over_20_mins /* &&section_id..&&report_sequence. */
  FROM (
SELECT SUM(COUNT (ROUND((b.first_time - a.first_time) * 1440) )) "LOG_SWITCHES_UNDER_20_MINS"  
  FROM v$archived_log a, v$archived_log b 
 WHERE a.sequence# + 1 = b.sequence# 
   AND a.dest_id = 1 
   AND a.thread# = b.thread#  
   AND a.dest_id = b.dest_id 
   AND a.dest_id = (
SELECT MIN(dest_id) 
  FROM gv$archive_dest 
 WHERE target='PRIMARY' 
   AND destination IS NOT NULL) 
   AND ROUND((b.first_time - a.first_time) * 1440)  < 20 
 GROUP BY ROUND((b.first_time - a.first_time) * 1440))  fs, (
SELECT  SUM(COUNT (ROUND((b.first_time - a.first_time) * 1440) )) "LOG_SWITCHES_OVER_20_MINS"  
  FROM v$archived_log a, v$archived_log b 
 WHERE a.sequence# + 1 = b.sequence# 
   AND a.dest_id = 1 
   AND a.thread# = b.thread#  
   AND a.dest_id = b.dest_id 
   AND a.dest_id = (
SELECT MIN(dest_id) 
  FROM gv$archive_dest 
 WHERE target='PRIMARY' 
   AND destination IS NOT NULL) 
   AND ROUND((b.first_time - a.first_time) * 1440)  > 19 
 GROUP BY ROUND((b.first_time - a.first_time) * 1440)) ss
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Log Switches';
DEF main_table = 'V$ARCHIVED_LOG';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT (CASE WHEN bucket = 1 THEN '<= ' || TO_CHAR(bucket * 5) /* &&section_id..&&report_sequence. */
             WHEN (bucket >1 AND bucket < 9) THEN TO_CHAR(bucket * 5 - 4) || ' TO ' || TO_CHAR(bucket * 5) 
             WHEN bucket > 8 THEN '>= ' || TO_CHAR(bucket * 5 - 4) END) "MINUTES", 
       switches "LOG_SWITCHES" 
  FROM (
SELECT bucket , COUNT(b.bucket) SWITCHES 
  FROM (
SELECT WIDTH_BUCKET(ROUND((b.first_time - a.first_time) * 1440), 0, 40, 8) bucket 
  FROM v$archived_log a, v$archived_log b 
 WHERE a.sequence# + 1 = b.sequence# 
   AND a.dest_id = b.dest_id  
   AND a.thread# = b.thread#  
   AND a.dest_id = (
SELECT MIN(dest_id) 
  FROM gv$archive_dest 
 WHERE target = 'PRIMARY' 
   AND destination IS NOT NULL)) b 
 GROUP BY bucket ORDER BY bucket)
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Redo Log Group';
DEF main_table = 'V$LOG';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT thread#, group#, sequence#, bytes, archived ,status /* &&section_id..&&report_sequence. */
FROM v$log ORDER BY thread#, group#
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Standby Logs';
DEF main_table = 'V$STANDBY_LOG';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT thread#, group#, sequence#, bytes, archived, status /* &&section_id..&&report_sequence. */
FROM v$standby_log order by thread#, group#
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Archive Destinations';
DEF main_table = 'GV$ARCHIVE_DEST';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT thread#, dest_id, destination, target, schedule, process /* &&section_id..&&report_sequence. */
 FROM gv$archive_dest gvad, gv$instance gvi 
 WHERE gvad.inst_id = gvi.inst_id 
   AND destination is NOT NULL 
 ORDER BY thread#, dest_id
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Destination Details';
DEF main_table = 'GV$ARCHIVE_DEST';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT thread#, dest_id, gvad.archiver, transmit_mode, affirm, /* &&section_id..&&report_sequence. */
       async_blocks, net_timeout, max_failure, delay_mins, reopen_secs reopen, register, binding 
  FROM gv$archive_dest gvad, gv$instance gvi 
 WHERE gvad.inst_id = gvi.inst_id 
   AND destination is NOT NULL 
 ORDER BY thread#, dest_id
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Destination Errors';
DEF main_table = 'GV$ARCHIVE_DEST';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT thread#, dest_id, gvad.status, error, fail_sequence /* &&section_id..&&report_sequence. */
 FROM gv$archive_dest gvad, gv$instance gvi 
WHERE gvad.inst_id = gvi.inst_id 
  AND destination is NOT NULL 
ORDER BY thread#, dest_id
]';
END;
/
@@edb360_9a_pre_one.sql       
 
DEF title = 'Error Conditions';
DEF main_table = 'GV$DATAGUARD_STATUS';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT gvi.thread#, timestamp, message /* &&section_id..&&report_sequence. */
  FROM gv$dataguard_status gvds, gv$instance gvi 
 WHERE gvds.inst_id = gvi.inst_id 
   AND severity in ('Error','Fatal') 
 ORDER BY timestamp, thread#
]';
END;
/
@@edb360_9a_pre_one.sql       
 
DEF title = 'Status Processes Redo Shipping';
DEF main_table = 'GV$MANAGED_STANDBY';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT inst_id, thread#, process, pid, status, client_process, /* &&section_id..&&report_sequence. */
       client_pid, sequence#, block#, active_agents, known_agents 
  FROM gv$managed_standby 
 ORDER BY thread#, pid
]';
END;
/
@@edb360_9a_pre_one.sql       
 
DEF title = 'Current and Last Seq#';
DEF main_table = 'GV$ARCHIVE_DEST';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT cu.thread#, cu.dest_id, la.lastarchived "Last Archived", /* &&section_id..&&report_sequence. */
       cu.currentsequence "Current Sequence", appl.lastapplied "Last Applied" 
 FROM (
select gvi.thread#, gvd.dest_id, MAX(gvd.log_sequence) currentsequence 
  FROM gv$archive_dest gvd, gv$instance gvi 
 WHERE gvd.status = 'VALID' 
   AND gvi.inst_id = gvd.inst_id 
 GROUP BY thread#, dest_id) cu, (
SELECT thread#, dest_id, MAX(sequence#) lastarchived 
  FROM gv$archived_log 
 WHERE resetlogs_change# = (
SELECT resetlogs_change# 
  FROM v$database) 
   AND archived = 'YES' 
 GROUP BY thread#, dest_id) la, (
SELECT thread#, dest_id, MAX(sequence#) lastapplied 
  FROM gv$archived_log 
 WHERE resetlogs_change# = (
SELECT resetlogs_change# 
  FROM v$database) 
   AND applied = 'YES' 
 GROUP BY thread#, dest_id) appl 
 WHERE cu.thread# = la.thread# 
   AND cu.thread# = appl.thread# 
   AND cu.dest_id = la.dest_id 
   AND cu.dest_id = appl.dest_id 
 ORDER BY 1, 2
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Standby Dest';
DEF main_table = 'V$ARCHIVE_DEST_STATUS';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT dest_id, database_mode, recovery_mode, protection_mode, standby_logfile_count, standby_logfile_active /* &&section_id..&&report_sequence. */
  FROM v$archive_dest_status 
 WHERE destination IS NOT NULL
]';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'Non-default Init Parameters';
DEF main_table = 'V$PARAMETER';
BEGIN
  :sql_text := q'[
-- from MOS Doc ID: 1577401.1 
SELECT num, '*' "THREAD#", name, value /* &&section_id..&&report_sequence. */
  FROM v$PARAMETER WHERE NUM IN (
SELECT num 
  FROM v$parameter 
 WHERE (isdefault = 'FALSE' OR ismodified <> 'FALSE') 
   AND name NOT LIKE 'nls%'
 MINUS
SELECT num 
  FROM gv$parameter gvp, gv$instance gvi 
 WHERE num IN (
SELECT DISTINCT gvpa.num 
  FROM gv$parameter gvpa, gv$parameter gvpb 
 WHERE gvpa.num = gvpb.num 
   AND  gvpa.value <> gvpb.value 
   AND (gvpa.isdefault = 'FALSE' OR gvpa.ismodified <> 'FALSE') 
   AND gvpa.name NOT LIKE 'nls%') 
   AND gvi.inst_id = gvp.inst_id  
   AND (gvp.isdefault = 'FALSE' OR gvp.ismodified <> 'FALSE') 
   AND gvp.name NOT LIKE 'nls%')
 UNION
SELECT num, TO_CHAR(thread#) "THREAD#", name, value 
  FROM gv$parameter gvp, gv$instance gvi 
 WHERE num IN (
SELECT DISTINCT gvpa.num 
  FROM gv$parameter gvpa, gv$parameter gvpb 
 WHERE gvpa.num = gvpb.num 
   AND gvpa.value <> gvpb.value 
   AND (gvpa.isdefault = 'FALSE' OR gvpa.ismodified <> 'FALSE') 
   AND gvp.name NOT LIKE 'nls%') 
   AND gvi.inst_id = gvp.inst_id  
   AND (gvp.isdefault = 'FALSE' OR gvp.ismodified <> 'FALSE') 
   AND gvp.name NOT LIKE 'nls%' 
 ORDER BY 1, 2
]';
END;
/
@@edb360_9a_pre_one.sql       

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
