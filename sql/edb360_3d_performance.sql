DEF section_name = 'Performance Summaries';
SPO &&main_report_name..html APP;
PRO <h2>&&section_name.</h2>
SPO OFF;

DEF title = 'AAS for past minute';
DEF main_table = 'GV$WAITCLASSMETRIC';
COL aas FOR 999990.000;
BEGIN
  :sql_text := '
-- inspired by Kyle Hailey blogs
-- http://www.kylehailey.com/wait-event-and-wait-class-metrics-vs-vsystem_event/
-- http://www.kylehailey.com/oracle-cpu-time/
WITH 
ora_cpu_used AS (
SELECT /*+ &&sq_fact_hints. */
       ''2'' row_type,
       ''Oracle CPU used'' timed_event,
       sm.inst_id,
       sm.begin_time,
       sm.end_time,
       ROUND(sm.value / 100, 3) aas --(/ 100 is to convert from cs to sec)
  FROM gv$sysmetric sm
 WHERE sm.metric_name=''CPU Usage Per Sec''
   AND sm.group_id = 2 -- 1 minute
),
system_cpu_used AS (
SELECT /*+ &&sq_fact_hints. */
       ''4'' row_type,
       ''System CPU used'' timed_event,
       sm.inst_id,
       sm.begin_time,
       sm.end_time,
       ROUND((sm.value / 100) * TO_NUMBER(p.value), 3) aas -- (/ 100 is to convert % to fraction)
  FROM gv$sysmetric sm,
       gv$system_parameter2 p
 WHERE sm.metric_name=''Host CPU Utilization (%)''
   AND sm.group_id = 2 -- 1 minute
   AND sm.inst_id = p.inst_id
   AND p.name = ''cpu_count''
),
non_idle_waits AS (
SELECT /*+ &&sq_fact_hints. */
       ''6'' row_type,
       wc.wait_class timed_event,
       wcm.inst_id,
       wcm.begin_time,
       wcm.end_time,
       ROUND(wcm.time_waited/wcm.intsize_csec, 3) aas
  FROM gv$waitclassmetric wcm,
       gv$system_wait_class wc
 WHERE wcm.inst_id = wc.inst_id
   AND wcm.wait_class_id = wc.wait_class_id
   AND wcm.wait_class# = wc.wait_class#
   AND wcm.time_waited > 0
   AND wcm.wait_count > 0
   AND wc.wait_class != ''Idle''
   AND ROUND(wcm.time_waited/wcm.intsize_csec, 3) >= 0.001
),
time_window AS ( -- one row with oldest and newest date sample
SELECT MIN(begin_time) begin_time, MAX(end_time) end_time FROM (
SELECT MIN(begin_time) begin_time, MAX(end_time) end_time FROM ora_cpu_used
 UNION ALL
SELECT MIN(begin_time) begin_time, MAX(end_time) end_time FROM system_cpu_used
 UNION ALL
SELECT MIN(begin_time) begin_time, MAX(end_time) end_time FROM non_idle_waits
)),
ora_dem_cpu AS (
SELECT /*+ &&sq_fact_hints. */
       ''1'' row_type,
       ''Oracle demand for CPU'' timed_event,
       ash.inst_id,
       tw.begin_time,
       tw.end_time,
       ROUND(COUNT(*) / ((tw.end_time - tw.begin_time) * 24 * 60 * 60), 3) aas -- samples over time in secs
  FROM gv$active_session_history ash,
       time_window tw
 WHERE ash.session_state = ''ON CPU''
   AND CAST(sample_time AS DATE) BETWEEN tw.begin_time AND tw.end_time
   AND ''&&diagnostics_pack.'' = ''Y''
 GROUP BY
       ash.inst_id,
       tw.begin_time,
       tw.end_time
),
ora_wait_cpu AS (
SELECT ''3'' row_type,
       ''Oracle wait for CPU (demand - used)'' timed_event,
       d.inst_id,
       LEAST(d.begin_time, u.begin_time) begin_time,
       GREATEST(d.end_time, u.end_time) end_time,
       CASE WHEN d.aas > u.aas THEN d.aas - u.aas ELSE 0 END aas
  FROM ora_dem_cpu d,
       ora_cpu_used u
 WHERE d.inst_id = u.inst_id
),
system_cpu_used_no_ora AS (
SELECT ''5'' row_type,
       ''System CPU used (excludes Oracle)'' timed_event,
       s.inst_id,
       LEAST(s.begin_time, u.begin_time) begin_time,
       GREATEST(s.end_time, u.end_time) end_time,
       CASE WHEN s.aas > u.aas THEN s.aas - u.aas ELSE 0 END aas
  FROM system_cpu_used s,
       ora_cpu_used u
 WHERE s.inst_id = u.inst_id
),
all_pieces AS (
SELECT * FROM ora_dem_cpu
 UNION ALL
SELECT * FROM ora_cpu_used
 UNION ALL
SELECT * FROM ora_wait_cpu
 UNION ALL
SELECT * FROM system_cpu_used
 UNION ALL
SELECT * FROM system_cpu_used_no_ora
 UNION ALL
SELECT * FROM non_idle_waits
)
SELECT /*+ &&top_level_hints. */
       inst_id,
       timed_event,
       aas
  FROM all_pieces
 ORDER BY
       inst_id,
       row_type,
       aas DESC,
       timed_event
';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql       

DEF title = 'Wait Class Metric for past minute';
DEF main_table = 'GV$WAITCLASSMETRIC';
BEGIN
  :sql_text := '
-- inspired by Kyle Hailey blogs
-- http://www.kylehailey.com/wait-event-and-wait-class-metrics-vs-vsystem_event/
-- http://www.kylehailey.com/oracle-cpu-time/
SELECT /*+ &&top_level_hints. */
       wc.wait_class,
       wcm.*,
       ROUND(wcm.time_waited/wcm.intsize_csec, 3) aas,
       CASE WHEN wc.wait_class = ''User I/O'' THEN 
       ROUND(10 * wcm.time_waited  / wcm.wait_count, 3) END avg_io_ms
  FROM gv$waitclassmetric wcm,
       gv$system_wait_class wc
 WHERE wcm.inst_id = wc.inst_id
   AND wcm.wait_class_id = wc.wait_class_id
   AND wcm.wait_class# = wc.wait_class#
   AND wcm.time_waited > 0
   AND wcm.wait_count > 0
   AND wc.wait_class != ''Idle''
   AND ROUND(wcm.time_waited/wcm.intsize_csec, 3) >= 0.001
 ORDER BY
       wcm.inst_id,
       wc.wait_class
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Event Metric for past minute';
DEF main_table = 'GV$EVENTMETRIC';
BEGIN
  :sql_text := '
-- inspired by Kyle Hailey blogs
-- http://www.kylehailey.com/wait-event-and-wait-class-metrics-vs-vsystem_event/
-- http://www.kylehailey.com/oracle-cpu-time/
SELECT /*+ &&top_level_hints. */
       en.wait_class,
       en.name event,
       em.*,
       ROUND(em.time_waited / em.intsize_csec, 3) aas,
       CASE WHEN en.wait_class = ''User I/O'' THEN 10 * em.time_waited  / em.wait_count END avg_io_ms
  FROM gv$eventmetric em,
       gv$event_name en
 WHERE em.inst_id = en.inst_id
   AND em.event_id = en.event_id
   AND em.event# = en.event#
   AND em.time_waited > 0
   AND em.wait_count > 0
   AND en.wait_class != ''Idle''
 ORDER BY
       em.inst_id,
       en.wait_class,
       en.name';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'System Metric for past minute';
DEF main_table = 'GV$SYSMETRIC';
BEGIN
  :sql_text := '
-- inspired by Kyle Hailey blogs
-- http://www.kylehailey.com/wait-event-and-wait-class-metrics-vs-vsystem_event/
-- http://www.kylehailey.com/oracle-cpu-time/
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$sysmetric
 WHERE group_id = 2 -- 1 minute
 ORDER BY
       inst_id,
       metric_name
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'System Metric Summary for past hour';
DEF main_table = 'GV$SYSMETRIC_SUMMARY';
BEGIN
  :sql_text := '
-- inspired by Kyle Hailey blogs
-- http://www.kylehailey.com/wait-event-and-wait-class-metrics-vs-vsystem_event/
-- http://www.kylehailey.com/oracle-cpu-time/
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$sysmetric_summary
 ORDER BY
       inst_id,
       metric_name
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Wait Statistics';
DEF main_table = 'GV$WAITSTAT';
BEGIN
  :sql_text := '
-- incarnation from health_check_4.4 (Jon Adams and Jack Agustin)
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$waitstat
 WHERE count > 0
 ORDER BY
       class,
       inst_id
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'System Wait Class';
DEF main_table = 'GV$SYSTEM_WAIT_CLASS';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$system_wait_class
 ORDER BY
       inst_id,
       time_waited DESC
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Segment Statistics';
DEF main_table = 'GV$SEGSTAT';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       statistic_name, SUM(value) value
  FROM gv$segstat
 GROUP BY 
       statistic_name
 ORDER BY 1
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'SQL Monitor Recent Executions Detail';
DEF abstract = 'Aggregated by SQL_ID and SQL Execution. Sorted by SQL_ID and Execution Start Time.';
DEF main_table = 'GV$SQL_MONITOR';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       sql_id,
       sql_exec_start,
       sql_exec_id,
       NVL(MAX(px_qcinst_id), MAX(inst_id)) inst_id,
       MAX(sql_plan_hash_value) sql_plan_hash_value,
       MAX(username) username,
       MAX(service_name) service_name,
       MAX(module) module,
       MAX(px_is_cross_instance) px_is_cross_instance,
       MAX(px_maxdop) px_maxdop,
       MAX(px_maxdop_instances) px_maxdop_instances,
       MAX(px_servers_requested) px_servers_requested,
       MAX(px_servers_allocated) px_servers_allocated,
       MAX(error_number) error_number,
       MAX(error_facility) error_facility,
       MAX(error_message) error_message,
       COUNT(*) processes,
       1 executions,
       SUM(fetches) fetches,
       SUM(buffer_gets) buffer_gets,
       SUM(disk_reads) disk_reads,
       SUM(direct_writes) direct_writes,
       SUM(io_interconnect_bytes) io_interconnect_bytes,
       SUM(physical_read_requests) physical_read_requests,
       SUM(physical_read_bytes) physical_read_bytes,
       SUM(physical_write_requests) physical_write_requests,
       SUM(physical_write_bytes) physical_write_bytes,
       SUM(elapsed_time) elapsed_time,
       SUM(queuing_time) queuing_time,
       SUM(cpu_time) cpu_time,
       SUM(application_wait_time) application_wait_time,
       SUM(concurrency_wait_time) concurrency_wait_time,
       SUM(cluster_wait_time) cluster_wait_time,
       SUM(user_io_wait_time) user_io_wait_time,
       SUM(plsql_exec_time) plsql_exec_time,
       SUM(java_exec_time) java_exec_time,
       MAX(sql_text) sql_text
  FROM gv$sql_monitor
 WHERE status LIKE ''DONE%''
 GROUP BY
       sql_id,
       sql_exec_start,
       sql_exec_id
HAVING MAX(sql_text) IS NOT NULL
 ORDER BY
       sql_id,
       sql_exec_start,
       sql_exec_id
';
END;
/
@@&&skip_tuning.&&skip_10g.edb360_9a_pre_one.sql

DEF title = 'SQL Monitor Recent Executions Summary';
DEF abstract = 'Aggregated by SQL_ID and sorted by Total Elapsed Time.';
DEF main_table = 'GV$SQL_MONITOR';
BEGIN
  :sql_text := '
WITH
monitored_sql AS (
SELECT /*+ &&sq_fact_hints. */
       sql_id,
       sql_exec_start,
       sql_exec_id,
       NVL(MAX(px_qcinst_id), MAX(inst_id)) inst_id,
       MAX(sql_plan_hash_value) sql_plan_hash_value,
       MAX(username) username,
       MAX(service_name) service_name,
       MAX(module) module,
       MAX(px_is_cross_instance) px_is_cross_instance,
       MAX(px_maxdop) px_maxdop,
       MAX(px_maxdop_instances) px_maxdop_instances,
       MAX(px_servers_requested) px_servers_requested,
       MAX(px_servers_allocated) px_servers_allocated,
       MAX(error_number) error_number,
       MAX(error_facility) error_facility,
       MAX(error_message) error_message,
       COUNT(*) processes,
       1 executions,
       SUM(fetches) fetches,
       SUM(buffer_gets) buffer_gets,
       SUM(disk_reads) disk_reads,
       SUM(direct_writes) direct_writes,
       SUM(io_interconnect_bytes) io_interconnect_bytes,
       SUM(physical_read_requests) physical_read_requests,
       SUM(physical_read_bytes) physical_read_bytes,
       SUM(physical_write_requests) physical_write_requests,
       SUM(physical_write_bytes) physical_write_bytes,
       SUM(elapsed_time) elapsed_time,
       SUM(queuing_time) queuing_time,
       SUM(cpu_time) cpu_time,
       SUM(application_wait_time) application_wait_time,
       SUM(concurrency_wait_time) concurrency_wait_time,
       SUM(cluster_wait_time) cluster_wait_time,
       SUM(user_io_wait_time) user_io_wait_time,
       SUM(plsql_exec_time) plsql_exec_time,
       SUM(java_exec_time) java_exec_time,
       MAX(sql_text) sql_text
  FROM gv$sql_monitor
 WHERE status LIKE ''DONE%''
 GROUP BY
       sql_id,
       sql_exec_start,
       sql_exec_id
HAVING MAX(sql_text) IS NOT NULL
)
SELECT /*+ &&top_level_hints. */
       sql_id,
       SUM(executions) executions,
       MIN(sql_exec_start) min_sql_exec_start,
       MAX(sql_exec_start) max_sql_exec_start,
       SUM(elapsed_time) sum_elapsed_time,
       ROUND(AVG(elapsed_time)) avg_elapsed_time,
       ROUND(MIN(elapsed_time)) min_elapsed_time,
       ROUND(MAX(elapsed_time)) max_elapsed_time,
       SUM(cpu_time) sum_cpu_time,
       ROUND(AVG(cpu_time)) avg_cpu_time,
       ROUND(MIN(cpu_time)) min_cpu_time,
       ROUND(MAX(cpu_time)) max_cpu_time,
       SUM(user_io_wait_time) sum_user_io_wait_time,
       ROUND(AVG(user_io_wait_time)) avg_user_io_wait_time,
       ROUND(MIN(user_io_wait_time)) min_user_io_wait_time,
       ROUND(MAX(user_io_wait_time)) max_user_io_wait_time,
       SUM(buffer_gets) sum_buffer_gets,
       ROUND(AVG(buffer_gets)) avg_buffer_gets,
       ROUND(MIN(buffer_gets)) min_buffer_gets,
       ROUND(MAX(buffer_gets)) max_buffer_gets,
       SUM(disk_reads) sum_disk_reads,
       ROUND(AVG(disk_reads)) avg_disk_reads,
       ROUND(MIN(disk_reads)) min_disk_reads,
       ROUND(MAX(disk_reads)) max_disk_reads,
       SUM(processes) sum_processes,
       ROUND(AVG(processes)) avg_processes,
       ROUND(MIN(processes)) min_processes,
       ROUND(MAX(processes)) max_processes,
       COUNT(DISTINCT inst_id) distinct_inst_id,
       MIN(inst_id) min_inst_id,
       MAX(inst_id) max_inst_id,
       COUNT(DISTINCT sql_plan_hash_value) distinct_sql_plan_hash_value,
       MIN(sql_plan_hash_value) min_sql_plan_hash_value,
       MAX(sql_plan_hash_value) max_sql_plan_hash_value,
       COUNT(DISTINCT username) distinct_username,
       MAX(username) max_username,
       COUNT(DISTINCT service_name) distinct_service_name,
       MAX(service_name) max_service_name,
       COUNT(DISTINCT module) distinct_module,
       MAX(module) max_module,
       MAX(px_is_cross_instance) max_px_is_cross_instance,
       MIN(px_is_cross_instance) min_px_is_cross_instance,
       MAX(px_maxdop) max_px_maxdop,
       MIN(px_maxdop) min_px_maxdop,
       MAX(px_maxdop_instances) max_px_maxdop_instances,
       MIN(px_maxdop_instances) min_px_maxdop_instances,
       MAX(px_servers_requested) max_px_servers_requested,
       MIN(px_servers_requested) min_px_servers_requested,
       MAX(px_servers_allocated) max_px_servers_allocated,
       MIN(px_servers_allocated) min_px_servers_allocated,
       MAX(error_number) max_error_number,
       MAX(error_facility) max_error_facility,
       MAX(error_message) max_error_message,
       MAX(sql_text) sql_text
  FROM monitored_sql
 GROUP BY
       sql_id
 ORDER BY
       sum_elapsed_time DESC,
       sql_id
';
END;
/
@@&&skip_tuning.&&skip_10g.edb360_9a_pre_one.sql

DEF title = 'SQL Monitor Recent Executions DONE (ERROR)';
DEF abstract = 'Aggregated by SQL_ID and Error.';
DEF main_table = 'GV$SQL_MONITOR';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       sql_id,
       error_number,
       error_facility,
       error_message,
       COUNT(*) executions
  FROM gv$sql_monitor
 WHERE status = ''DONE (ERROR)''
 GROUP BY
       sql_id,
       error_number,
       error_facility,
       error_message
HAVING MAX(sql_text) IS NOT NULL
 ORDER BY
       sql_id,
       error_number,
       error_facility,
       error_message
';
END;
/
@@&&skip_tuning.&&skip_10g.edb360_9a_pre_one.sql




