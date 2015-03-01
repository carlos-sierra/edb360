@@edb360_0g_tkprof.sql
DEF section_id = '1f';
DEF section_name = 'Resources (outdated section)';
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_name.</h2>
SPO OFF;

COL db_name FOR A9;
COL host_name FOR A64;
COL instance_name FOR A16;
COL db_unique_name FOR A30;
COL platform_name FOR A101;
COL version FOR A17;

COL aas_on_cpu_and_resmgr_peak    FOR 999999999999990.0 HEA "CPU and RESMGR Peak";
COL aas_on_cpu_peak               FOR 999999999999990.0 HEA "CPU Peak";
COL aas_resmgr_cpu_quantum_peak   FOR 999999999999990.0 HEA "RESMGR Peak";
COL aas_on_cpu_and_resmgr_9999    FOR 999999999999990.0 HEA "CPU and RESMGR 99.99th";
COL aas_on_cpu_9999               FOR 999999999999990.0 HEA "CPU 99.99th";
COL aas_resmgr_cpu_quantum_9999   FOR 999999999999990.0 HEA "RESMGR 99.99th";
COL aas_on_cpu_and_resmgr_999     FOR 999999999999990.0 HEA "CPU and RESMGR 99.9th";
COL aas_on_cpu_999                FOR 999999999999990.0 HEA "CPU 99.9th";
COL aas_resmgr_cpu_quantum_999    FOR 999999999999990.0 HEA "RESMGR 99.9th";
COL aas_on_cpu_and_resmgr_99      FOR 999999999999990.0 HEA "CPU and RESMGR 99th";
COL aas_on_cpu_99                 FOR 999999999999990.0 HEA "CPU 99th";
COL aas_resmgr_cpu_quantum_99     FOR 999999999999990.0 HEA "RESMGR 99th";
COL aas_on_cpu_and_resmgr_95      FOR 999999999999990.0 HEA "CPU and RESMGR 95th";
COL aas_on_cpu_95                 FOR 999999999999990.0 HEA "CPU 95th";
COL aas_resmgr_cpu_quantum_95     FOR 999999999999990.0 HEA "RESMGR 95th";
COL aas_on_cpu_and_resmgr_90      FOR 999999999999990.0 HEA "CPU and RESMGR 90th";
COL aas_on_cpu_90                 FOR 999999999999990.0 HEA "CPU 90th";
COL aas_resmgr_cpu_quantum_90     FOR 999999999999990.0 HEA "RESMGR 90th";
COL aas_on_cpu_and_resmgr_75      FOR 999999999999990.0 HEA "CPU and RESMGR 75th";
COL aas_on_cpu_75                 FOR 999999999999990.0 HEA "CPU 75th";
COL aas_resmgr_cpu_quantum_75     FOR 999999999999990.0 HEA "RESMGR 75th";
COL aas_on_cpu_and_resmgr_median  FOR 999999999999990.0 HEA "CPU and RESMGR MEDIAN";
COL aas_on_cpu_median             FOR 999999999999990.0 HEA "CPU MEDIAN";
COL aas_resmgr_cpu_quantum_median FOR 999999999999990.0 HEA "RESMGR MEDIAN";
COL aas_on_cpu_and_resmgr_avg     FOR 999999999999990.0 HEA "CPU and RESMGR AVG";
COL aas_on_cpu_avg                FOR 999999999999990.0 HEA "CPU AVG";
COL aas_resmgr_cpu_quantum_avg    FOR 999999999999990.0 HEA "RESMGR AVG";

DEF title = 'CPU Demand (MEM)';
DEF main_table = 'GV$ACTIVE_SESSION_HISTORY';
DEF abstract = 'Number of Sessions demanding CPU. Includes Peak (max), percentiles and average.'
DEF foot = 'Consider Peak for sizing. Instance Number -1 means aggregated values (SUM) while -2 means over all instances (combined).'
BEGIN
  :sql_text := '
WITH 
samples_on_cpu AS (
SELECT /*+ &&sq_fact_hints. */
       inst_id,
       sample_id,
       COUNT(*) aas_on_cpu_and_resmgr,
       SUM(CASE session_state WHEN ''ON CPU'' THEN 1 ELSE 0 END) aas_on_cpu,
       SUM(CASE event WHEN ''resmgr:cpu quantum'' THEN 1 ELSE 0 END) aas_resmgr_cpu_quantum       
  FROM gv$active_session_history
 WHERE (session_state = ''ON CPU'' OR event = ''resmgr:cpu quantum'')
 GROUP BY
       inst_id,
       sample_id
),
sub_totals AS (
SELECT /*+ &&sq_fact_hints. */
       (SELECT dbid FROM v$database) dbid,
       (SELECT name FROM v$database) db_name,
       LOWER(SUBSTR(i.host_name||''.'', 1, INSTR(i.host_name||''.'', ''.'') - 1)) host_name,
       i.instance_number,
       i.instance_name,
       MAX(c.aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_peak,
       MAX(c.aas_on_cpu) aas_on_cpu_peak,
       MAX(c.aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_peak,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY c.aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_9999,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY c.aas_on_cpu) aas_on_cpu_9999,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY c.aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_9999,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY c.aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_999,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY c.aas_on_cpu) aas_on_cpu_999,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY c.aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_999,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY c.aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_99,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY c.aas_on_cpu) aas_on_cpu_99,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY c.aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_99,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY c.aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_95,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY c.aas_on_cpu) aas_on_cpu_95,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY c.aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_95,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY c.aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_90,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY c.aas_on_cpu) aas_on_cpu_90,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY c.aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_90,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY c.aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_75,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY c.aas_on_cpu) aas_on_cpu_75,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY c.aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_75,
       MEDIAN(c.aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_median,
       MEDIAN(c.aas_on_cpu) aas_on_cpu_median,
       MEDIAN(c.aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_median,
       ROUND(AVG(c.aas_on_cpu_and_resmgr), 1) aas_on_cpu_and_resmgr_avg,
       ROUND(AVG(c.aas_on_cpu), 1) aas_on_cpu_avg,
       ROUND(AVG(c.aas_resmgr_cpu_quantum), 1) aas_resmgr_cpu_quantum_avg
  FROM samples_on_cpu c,
       gv$instance i
 WHERE i.inst_id(+) = c.inst_id
 GROUP BY
       i.host_name,
       i.instance_number,
       i.instance_name
 ORDER BY
       i.instance_number
)
SELECT dbid,
       db_name,
       host_name,
       instance_number,
       instance_name,
       aas_on_cpu_and_resmgr_peak,
       aas_on_cpu_peak,
       aas_resmgr_cpu_quantum_peak,
       aas_on_cpu_and_resmgr_9999,
       aas_on_cpu_9999,
       aas_resmgr_cpu_quantum_9999,
       aas_on_cpu_and_resmgr_999,
       aas_on_cpu_999,
       aas_resmgr_cpu_quantum_999,
       aas_on_cpu_and_resmgr_99,
       aas_on_cpu_99,
       aas_resmgr_cpu_quantum_99,
       aas_on_cpu_and_resmgr_95,
       aas_on_cpu_95,
       aas_resmgr_cpu_quantum_95,
       aas_on_cpu_and_resmgr_90,
       aas_on_cpu_90,
       aas_resmgr_cpu_quantum_90,
       aas_on_cpu_and_resmgr_75,
       aas_on_cpu_75,
       aas_resmgr_cpu_quantum_75,
       aas_on_cpu_and_resmgr_median,
       aas_on_cpu_median,
       aas_resmgr_cpu_quantum_median,
       aas_on_cpu_and_resmgr_avg,
       aas_on_cpu_avg,
       aas_resmgr_cpu_quantum_avg
  FROM sub_totals
 UNION ALL
SELECT MAX(dbid) dbid,
       MAX(db_name) db_name,
       NULL host_name,
       -1 instance_number,
       NULL instance_name,
       SUM(aas_on_cpu_and_resmgr_peak)    aas_on_cpu_and_resmgr_peak,
       SUM(aas_on_cpu_peak)               aas_on_cpu_peak,
       SUM(aas_resmgr_cpu_quantum_peak)   aas_resmgr_cpu_quantum_peak,
       SUM(aas_on_cpu_and_resmgr_9999)    aas_on_cpu_and_resmgr_9999,
       SUM(aas_on_cpu_9999)               aas_on_cpu_9999,
       SUM(aas_resmgr_cpu_quantum_9999)   aas_resmgr_cpu_quantum_9999,
       SUM(aas_on_cpu_and_resmgr_999)     aas_on_cpu_and_resmgr_999,
       SUM(aas_on_cpu_999)                aas_on_cpu_999,
       SUM(aas_resmgr_cpu_quantum_999)    aas_resmgr_cpu_quantum_999,
       SUM(aas_on_cpu_and_resmgr_99)      aas_on_cpu_and_resmgr_99,
       SUM(aas_on_cpu_99)                 aas_on_cpu_99,
       SUM(aas_resmgr_cpu_quantum_99)     aas_resmgr_cpu_quantum_99,
       SUM(aas_on_cpu_and_resmgr_95)      aas_on_cpu_and_resmgr_95,
       SUM(aas_on_cpu_95)                 aas_on_cpu_95,
       SUM(aas_resmgr_cpu_quantum_95)     aas_resmgr_cpu_quantum_95,
       SUM(aas_on_cpu_and_resmgr_90)      aas_on_cpu_and_resmgr_90,
       SUM(aas_on_cpu_90)                 aas_on_cpu_90,
       SUM(aas_resmgr_cpu_quantum_90)     aas_resmgr_cpu_quantum_90,
       SUM(aas_on_cpu_and_resmgr_75)      aas_on_cpu_and_resmgr_75,
       SUM(aas_on_cpu_75)                 aas_on_cpu_75,
       SUM(aas_resmgr_cpu_quantum_75)     aas_resmgr_cpu_quantum_75,
       SUM(aas_on_cpu_and_resmgr_median)  aas_on_cpu_and_resmgr_median,
       SUM(aas_on_cpu_median)             aas_on_cpu_median,
       SUM(aas_resmgr_cpu_quantum_median) aas_resmgr_cpu_quantum_median,
       SUM(aas_on_cpu_and_resmgr_avg)     aas_on_cpu_and_resmgr_avg,
       SUM(aas_on_cpu_avg)                aas_on_cpu_avg,
       SUM(aas_resmgr_cpu_quantum_avg)    aas_resmgr_cpu_quantum_avg
  FROM sub_totals
';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'CPU Demand (AWR)';
DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF abstract = 'Number of Sessions demanding CPU. Includes Peak (max), percentiles and average.'
DEF foot = 'Consider Peak or high Percentile for sizing. Instance Number -1 means aggregated values (SUM) while -2 means over all instances (combined).'
BEGIN
  :sql_text := '
WITH 
cpu_per_inst_and_sample AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */
       dbid,
       instance_number,
       snap_id,
       sample_id,
       COUNT(*) aas_on_cpu_and_resmgr,
       SUM(CASE session_state WHEN ''ON CPU'' THEN 1 ELSE 0 END) aas_on_cpu,
       SUM(CASE event WHEN ''resmgr:cpu quantum'' THEN 1 ELSE 0 END) aas_resmgr_cpu_quantum       
  FROM dba_hist_active_sess_history
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND (session_state = ''ON CPU'' OR event = ''resmgr:cpu quantum'')
 GROUP BY
       dbid,
       instance_number,
       snap_id,
       sample_id
),
cpu_per_inst AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */
       c.dbid,
       di.db_name,
       LOWER(SUBSTR(di.host_name||''.'', 1, INSTR(di.host_name||''.'', ''.'') - 1)) host_name,
       c.instance_number,
       di.instance_name,
       MAX(c.aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_peak,
       MAX(c.aas_on_cpu) aas_on_cpu_peak,
       MAX(c.aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_peak,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY c.aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_9999,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY c.aas_on_cpu) aas_on_cpu_9999,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY c.aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_9999,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY c.aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_999,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY c.aas_on_cpu) aas_on_cpu_999,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY c.aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_999,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY c.aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_99,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY c.aas_on_cpu) aas_on_cpu_99,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY c.aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_99,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY c.aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_95,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY c.aas_on_cpu) aas_on_cpu_95,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY c.aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_95,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY c.aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_90,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY c.aas_on_cpu) aas_on_cpu_90,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY c.aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_90,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY c.aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_75,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY c.aas_on_cpu) aas_on_cpu_75,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY c.aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_75,
       MEDIAN(c.aas_on_cpu_and_resmgr) aas_on_cpu_and_resmgr_median,
       MEDIAN(c.aas_on_cpu) aas_on_cpu_median,
       MEDIAN(c.aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_median,
       ROUND(AVG(c.aas_on_cpu_and_resmgr), 1) aas_on_cpu_and_resmgr_avg,
       ROUND(AVG(c.aas_on_cpu), 1) aas_on_cpu_avg,
       ROUND(AVG(c.aas_resmgr_cpu_quantum), 1) aas_resmgr_cpu_quantum_avg
  FROM cpu_per_inst_and_sample c,
       dba_hist_snapshot s,
       dba_hist_database_instance di
 WHERE s.snap_id = c.snap_id
   AND s.dbid = c.dbid
   AND s.instance_number = c.instance_number
   AND di.dbid = s.dbid
   AND di.instance_number = s.instance_number
   AND di.startup_time = s.startup_time
 GROUP BY
       c.dbid,
       di.db_name,
       di.host_name,
       c.instance_number,
       di.instance_name
 ORDER BY
       c.instance_number
)
SELECT dbid,
       db_name,
       host_name,
       instance_number,
       instance_name,
       aas_on_cpu_and_resmgr_peak,
       aas_on_cpu_peak,
       aas_resmgr_cpu_quantum_peak,
       aas_on_cpu_and_resmgr_9999,
       aas_on_cpu_9999,
       aas_resmgr_cpu_quantum_9999,
       aas_on_cpu_and_resmgr_999,
       aas_on_cpu_999,
       aas_resmgr_cpu_quantum_999,
       aas_on_cpu_and_resmgr_99,
       aas_on_cpu_99,
       aas_resmgr_cpu_quantum_99,
       aas_on_cpu_and_resmgr_95,
       aas_on_cpu_95,
       aas_resmgr_cpu_quantum_95,
       aas_on_cpu_and_resmgr_90,
       aas_on_cpu_90,
       aas_resmgr_cpu_quantum_90,
       aas_on_cpu_and_resmgr_75,
       aas_on_cpu_75,
       aas_resmgr_cpu_quantum_75,
       aas_on_cpu_and_resmgr_median,
       aas_on_cpu_median,
       aas_resmgr_cpu_quantum_median,
       aas_on_cpu_and_resmgr_avg,
       aas_on_cpu_avg,
       aas_resmgr_cpu_quantum_avg
  FROM cpu_per_inst
 UNION ALL
SELECT MAX(dbid) dbid,
       MAX(db_name) db_name,
       NULL host_name,
       -1 instance_number,
       NULL instance_name,
       SUM(aas_on_cpu_and_resmgr_peak)    aas_on_cpu_and_resmgr_peak,
       SUM(aas_on_cpu_peak)               aas_on_cpu_peak,
       SUM(aas_resmgr_cpu_quantum_peak)   aas_resmgr_cpu_quantum_peak,
       SUM(aas_on_cpu_and_resmgr_9999)    aas_on_cpu_and_resmgr_9999,
       SUM(aas_on_cpu_9999)               aas_on_cpu_9999,
       SUM(aas_resmgr_cpu_quantum_9999)   aas_resmgr_cpu_quantum_9999,
       SUM(aas_on_cpu_and_resmgr_999)     aas_on_cpu_and_resmgr_999,
       SUM(aas_on_cpu_999)                aas_on_cpu_999,
       SUM(aas_resmgr_cpu_quantum_999)    aas_resmgr_cpu_quantum_999,
       SUM(aas_on_cpu_and_resmgr_99)      aas_on_cpu_and_resmgr_99,
       SUM(aas_on_cpu_99)                 aas_on_cpu_99,
       SUM(aas_resmgr_cpu_quantum_99)     aas_resmgr_cpu_quantum_99,
       SUM(aas_on_cpu_and_resmgr_95)      aas_on_cpu_and_resmgr_95,
       SUM(aas_on_cpu_95)                 aas_on_cpu_95,
       SUM(aas_resmgr_cpu_quantum_95)     aas_resmgr_cpu_quantum_95,
       SUM(aas_on_cpu_and_resmgr_90)      aas_on_cpu_and_resmgr_90,
       SUM(aas_on_cpu_90)                 aas_on_cpu_90,
       SUM(aas_resmgr_cpu_quantum_90)     aas_resmgr_cpu_quantum_90,
       SUM(aas_on_cpu_and_resmgr_75)      aas_on_cpu_and_resmgr_75,
       SUM(aas_on_cpu_75)                 aas_on_cpu_75,
       SUM(aas_resmgr_cpu_quantum_75)     aas_resmgr_cpu_quantum_75,
       SUM(aas_on_cpu_and_resmgr_median)  aas_on_cpu_and_resmgr_median,
       SUM(aas_on_cpu_median)             aas_on_cpu_median,
       SUM(aas_resmgr_cpu_quantum_median) aas_resmgr_cpu_quantum_median,
       SUM(aas_on_cpu_and_resmgr_avg)     aas_on_cpu_and_resmgr_avg,
       SUM(aas_on_cpu_avg)                aas_on_cpu_avg,
       SUM(aas_resmgr_cpu_quantum_avg)    aas_resmgr_cpu_quantum_avg
  FROM cpu_per_inst
';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF title = 'IOPS and MBPS';
DEF main_table = 'DBA_HIST_SYSSTAT';
DEF abstract = 'I/O Operations per Second (IOPS) and I/O Mega Bytes per Second (MBPS). Includes Peak (max), percentiles and average for read (R), write (W) and read+write (RW) operations.'
DEF foot = 'Consider Peak or high Percentile for sizing. Instance Number -1 means aggregated values (SUM) while -2 means over all instances (combined).'
BEGIN
  :sql_text := '
WITH
sysstat_io AS (
SELECT /*+ &&sq_fact_hints. */
       d.dbid,
       d.name db_name,
       LOWER(SUBSTR(i.host_name||''.'', 1, INSTR(i.host_name||''.'', ''.'') - 1)) host_name,
       h.instance_number,
       i.instance_name,
       h.snap_id,
       SUM(CASE WHEN h.stat_name = ''physical read total IO requests'' THEN value ELSE 0 END) r_reqs,
       SUM(CASE WHEN h.stat_name IN (''physical write total IO requests'', ''redo writes'') THEN value ELSE 0 END) w_reqs,
       SUM(CASE WHEN h.stat_name = ''physical read total bytes'' THEN value ELSE 0 END) r_bytes,
       SUM(CASE WHEN h.stat_name IN (''physical write total bytes'', ''redo size'') THEN value ELSE 0 END) w_bytes
  FROM gv$instance i,
       gv$database d,
       dba_hist_sysstat h
 WHERE d.inst_id = i.inst_id
   AND h.instance_number = i.instance_number
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND h.stat_name IN (''physical read total IO requests'', ''physical write total IO requests'', ''redo writes'', ''physical read total bytes'', ''physical write total bytes'', ''redo size'')
 GROUP BY
       d.dbid,
       d.name,
       i.host_name,
       h.instance_number,
       i.instance_name,
       h.snap_id
),
io_per_inst_and_snap_id AS (
SELECT /*+ &&sq_fact_hints. */
       h1.dbid,
       h1.db_name,
       h1.host_name,
       h1.instance_number,
       h1.instance_name,
       h1.snap_id,
       (h1.r_reqs - h0.r_reqs) r_reqs,
       (h1.w_reqs - h0.w_reqs) w_reqs,
       (h1.r_bytes - h0.r_bytes) r_bytes,
       (h1.w_bytes - h0.w_bytes) w_bytes,
       (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 elapsed_sec
  FROM sysstat_io h0,
       dba_hist_snapshot s0,
       sysstat_io h1,
       dba_hist_snapshot s1
 WHERE s0.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s0.dbid = &&edb360_dbid.
   AND s0.snap_id = h0.snap_id
   AND s0.instance_number = h0.instance_number
   AND h1.instance_number = h0.instance_number
   AND h1.snap_id = h0.snap_id + 1
   AND s1.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s1.dbid = &&edb360_dbid.
   AND s1.snap_id = h1.snap_id
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
),
io_per_snap_id AS (
SELECT /*+ &&sq_fact_hints. */
       dbid,
       db_name,
       snap_id,
       SUM(r_reqs) r_reqs,
       SUM(w_reqs) w_reqs,
       SUM(r_bytes) r_bytes,
       SUM(w_bytes) w_bytes,
       AVG(elapsed_sec) elapsed_sec
  FROM io_per_inst_and_snap_id
 GROUP BY
       dbid,
       db_name,
       snap_id
),
io_per_inst AS (
SELECT dbid,
       db_name,
       host_name,
       instance_number,
       instance_name,
       ROUND(100 * SUM(r_reqs) / (SUM(r_reqs) + SUM(w_reqs)), 1) r_reqs_perc,
       ROUND(100 * SUM(w_reqs) / (SUM(r_reqs) + SUM(w_reqs)), 1) w_reqs_perc,
       ROUND(MAX((r_reqs + w_reqs) / elapsed_sec)) rw_iops_peak,
       ROUND(MAX(r_reqs / elapsed_sec)) r_iops_peak,
       ROUND(MAX(w_reqs / elapsed_sec)) w_iops_peak,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_999,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_99,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_97,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_95,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_90,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_75,
       ROUND(MEDIAN((r_reqs + w_reqs) / elapsed_sec)) rw_iops_median,
       ROUND(MEDIAN(r_reqs / elapsed_sec)) r_iops_median,
       ROUND(MEDIAN(w_reqs / elapsed_sec)) w_iops_median,
       ROUND(AVG((r_reqs + w_reqs) / elapsed_sec)) rw_iops_avg,
       ROUND(AVG(r_reqs / elapsed_sec)) r_iops_avg,
       ROUND(AVG(w_reqs / elapsed_sec)) w_iops_avg,
       ROUND(100 * SUM(r_bytes) / (SUM(r_bytes) + SUM(w_bytes)), 1) r_bytes_perc,
       ROUND(100 * SUM(w_bytes) / (SUM(r_bytes) + SUM(w_bytes)), 1) w_bytes_perc,
       ROUND(MAX((r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_peak,
       ROUND(MAX(r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_peak,
       ROUND(MAX(w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_peak,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_999,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_99,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_97,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_95,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_90,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_75,
       ROUND(MEDIAN((r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_median,
       ROUND(MEDIAN(r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_median,
       ROUND(MEDIAN(w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_median,
       ROUND(AVG((r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_avg,
       ROUND(AVG(r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_avg,
       ROUND(AVG(w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_avg
  FROM io_per_inst_and_snap_id
 WHERE elapsed_sec > 60 -- ignore snaps too close
 GROUP BY
       dbid,
       db_name,
       host_name,
       instance_number,
       instance_name
),
io_per_cluster AS ( -- combined
SELECT dbid,
       db_name,
       NULL host_name,
       -2 instance_number,
       NULL instance_name,
       ROUND(100 * SUM(r_reqs) / (SUM(r_reqs) + SUM(w_reqs)), 1) r_reqs_perc,
       ROUND(100 * SUM(w_reqs) / (SUM(r_reqs) + SUM(w_reqs)), 1) w_reqs_perc,
       ROUND(MAX((r_reqs + w_reqs) / elapsed_sec)) rw_iops_peak,
       ROUND(MAX(r_reqs / elapsed_sec)) r_iops_peak,
       ROUND(MAX(w_reqs / elapsed_sec)) w_iops_peak,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_999,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_99,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_97,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_95,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_90,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (r_reqs + w_reqs) / elapsed_sec)) rw_iops_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_reqs / elapsed_sec)) r_iops_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY w_reqs / elapsed_sec)) w_iops_75,
       ROUND(MEDIAN((r_reqs + w_reqs) / elapsed_sec)) rw_iops_median,
       ROUND(MEDIAN(r_reqs / elapsed_sec)) r_iops_median,
       ROUND(MEDIAN(w_reqs / elapsed_sec)) w_iops_median,
       ROUND(AVG((r_reqs + w_reqs) / elapsed_sec)) rw_iops_avg,
       ROUND(AVG(r_reqs / elapsed_sec)) r_iops_avg,
       ROUND(AVG(w_reqs / elapsed_sec)) w_iops_avg,
       ROUND(100 * SUM(r_bytes) / (SUM(r_bytes) + SUM(w_bytes)), 1) r_bytes_perc,
       ROUND(100 * SUM(w_bytes) / (SUM(r_bytes) + SUM(w_bytes)), 1) w_bytes_perc,
       ROUND(MAX((r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_peak,
       ROUND(MAX(r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_peak,
       ROUND(MAX(w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_peak,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_999,
       ROUND(PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_999,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_99,
       ROUND(PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_99,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_97,
       ROUND(PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_97,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_95,
       ROUND(PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_95,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_90,
       ROUND(PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_90,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY (r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_75,
       ROUND(PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_75,
       ROUND(MEDIAN((r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_median,
       ROUND(MEDIAN(r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_median,
       ROUND(MEDIAN(w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_median,
       ROUND(AVG((r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_avg,
       ROUND(AVG(r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_avg,
       ROUND(AVG(w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_avg
  FROM io_per_snap_id
 WHERE elapsed_sec > 60 -- ignore snaps too close
 GROUP BY
       dbid,
       db_name
),
io_sum AS ( -- simple aggregate
SELECT dbid,
       db_name,
       NULL host_name,
       -1 instance_number,
       NULL instance_name,
       ROUND(AVG(r_reqs_perc), 1) r_reqs_perc,
       ROUND(AVG(w_reqs_perc), 1) w_reqs_perc,
       SUM(rw_iops_peak),
       SUM(r_iops_peak),
       SUM(w_iops_peak),
       SUM(rw_iops_999),
       SUM(r_iops_999),
       SUM(w_iops_999),
       SUM(rw_iops_99),
       SUM(r_iops_99),
       SUM(w_iops_99),
       SUM(rw_iops_97),
       SUM(r_iops_97),
       SUM(w_iops_97),
       SUM(rw_iops_95),
       SUM(r_iops_95),
       SUM(w_iops_95),
       SUM(rw_iops_90),
       SUM(r_iops_90),
       SUM(w_iops_90),
       SUM(rw_iops_75),
       SUM(r_iops_75),
       SUM(w_iops_75),
       SUM(rw_iops_median),
       SUM(r_iops_median),
       SUM(w_iops_median),
       SUM(rw_iops_avg),
       SUM(r_iops_avg),
       SUM(w_iops_avg),
       ROUND(AVG(r_bytes_perc), 1) r_bytes_perc,
       ROUND(AVG(w_bytes_perc), 1) w_bytes_perc,
       SUM(rw_mbps_peak),
       SUM(r_mbps_peak),
       SUM(w_mbps_peak),
       SUM(rw_mbps_999),
       SUM(r_mbps_999),
       SUM(w_mbps_999),
       SUM(rw_mbps_99),
       SUM(r_mbps_99),
       SUM(w_mbps_99),
       SUM(rw_mbps_97),
       SUM(r_mbps_97),
       SUM(w_mbps_97),
       SUM(rw_mbps_95),
       SUM(r_mbps_95),
       SUM(w_mbps_95),
       SUM(rw_mbps_90),
       SUM(r_mbps_90),
       SUM(w_mbps_90),
       SUM(rw_mbps_75),
       SUM(r_mbps_75),
       SUM(w_mbps_75),
       SUM(rw_mbps_median),
       SUM(r_mbps_median),
       SUM(w_mbps_median),
       SUM(rw_mbps_avg),
       SUM(r_mbps_avg),
       SUM(w_mbps_avg)
  FROM io_per_inst
 GROUP BY
       dbid,
       db_name
)
SELECT * FROM io_per_inst
UNION ALL
SELECT * FROM io_sum
UNION ALL
SELECT * FROM io_per_cluster 
';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql
