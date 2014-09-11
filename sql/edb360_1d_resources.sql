DEF section_name = 'Resources';
SPO &&main_report_name..html APP;
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
COL aas_on_cpu_and_resmgr_9999    FOR 999999999999990.0 HEA "CPU and RESMGR 99.99%";
COL aas_on_cpu_9999               FOR 999999999999990.0 HEA "CPU 99.99%";
COL aas_resmgr_cpu_quantum_9999   FOR 999999999999990.0 HEA "RESMGR 99.99%";
COL aas_on_cpu_and_resmgr_999     FOR 999999999999990.0 HEA "CPU and RESMGR 99.9%";
COL aas_on_cpu_999                FOR 999999999999990.0 HEA "CPU 99.9%";
COL aas_resmgr_cpu_quantum_999    FOR 999999999999990.0 HEA "RESMGR 99.9%";
COL aas_on_cpu_and_resmgr_99      FOR 999999999999990.0 HEA "CPU and RESMGR 99%";
COL aas_on_cpu_99                 FOR 999999999999990.0 HEA "CPU 99%";
COL aas_resmgr_cpu_quantum_99     FOR 999999999999990.0 HEA "RESMGR 99%";
COL aas_on_cpu_and_resmgr_95      FOR 999999999999990.0 HEA "CPU and RESMGR 95%";
COL aas_on_cpu_95                 FOR 999999999999990.0 HEA "CPU 95%";
COL aas_resmgr_cpu_quantum_95     FOR 999999999999990.0 HEA "RESMGR 95%";
COL aas_on_cpu_and_resmgr_90      FOR 999999999999990.0 HEA "CPU and RESMGR 90%";
COL aas_on_cpu_90                 FOR 999999999999990.0 HEA "CPU 90%";
COL aas_resmgr_cpu_quantum_90     FOR 999999999999990.0 HEA "RESMGR 90%";
COL aas_on_cpu_and_resmgr_75      FOR 999999999999990.0 HEA "CPU and RESMGR 75%";
COL aas_on_cpu_75                 FOR 999999999999990.0 HEA "CPU 75%";
COL aas_resmgr_cpu_quantum_75     FOR 999999999999990.0 HEA "RESMGR 75%";
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
       d.dbid,
       d.name db_name,
       i.host_name,
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
       gv$instance i,
       v$database d
 WHERE i.inst_id = c.inst_id
 GROUP BY
       d.dbid,
       d.name,
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
SELECT /*+ &&sq_fact_hints. */
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
SELECT /*+ &&sq_fact_hints. */
       c.dbid,
       di.db_name,
       di.host_name,
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

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"';
DEF tit_01 = 'ON CPU + resmgr:cpu quantum';
DEF tit_02 = 'ON CPU';
DEF tit_03 = 'resmgr:cpu quantum';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

BEGIN
  :sql_text_backup := '
WITH 
cpu_per_inst_and_sample AS (
SELECT /*+ &&sq_fact_hints. */
       instance_number,
       snap_id,
       sample_id,
       MIN(sample_time) sample_time,
       SUM(CASE session_state WHEN ''ON CPU'' THEN 1 ELSE 0 END) on_cpu,
       SUM(CASE event WHEN ''resmgr:cpu quantum'' THEN 1 ELSE 0 END) resmgr,
       COUNT(*) on_cpu_and_resmgr
  FROM dba_hist_active_sess_history
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
   AND (session_state = ''ON CPU'' OR event = ''resmgr:cpu quantum'')
 GROUP BY
       instance_number,
       snap_id,
       sample_id
),
cpu_per_inst_and_hour AS (
SELECT /*+ &&sq_fact_hints. */
       MIN(snap_id) snap_id,
       instance_number, 
       TRUNC(CAST(sample_time AS DATE), ''HH'') begin_time, 
       TRUNC(CAST(sample_time AS DATE), ''HH'') + (1/24) end_time, 
       MAX(on_cpu) on_cpu,
       MAX(resmgr) resmgr,
       MAX(on_cpu_and_resmgr) on_cpu_and_resmgr
  FROM cpu_per_inst_and_sample
 GROUP BY
       instance_number,
       TRUNC(CAST(sample_time AS DATE), ''HH'')
)
SELECT MIN(snap_id) snap_id,
       TO_CHAR(begin_time, ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(end_time, ''YYYY-MM-DD HH24:MI'') end_time,
       SUM(on_cpu_and_resmgr) on_cpu_and_resmgr,
       SUM(on_cpu) on_cpu,
       SUM(resmgr) resmgr,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM cpu_per_inst_and_hour
 GROUP BY
       begin_time,
       end_time
 ORDER BY
       end_time
';
END;
/

DEF vbaseline = 'baseline:&&sum_cpu_count.,'; 

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'CPU Demand Series (Peak) for Cluster';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF vbaseline = 'baseline:&&avg_cpu_count.,';

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'CPU Demand Series (Peak) for Instance 1';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'CPU Demand Series (Peak) for Instance 2';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'CPU Demand Series (Peak) for Instance 3';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'CPU Demand Series (Peak) for Instance 4';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'CPU Demand Series (Peak) for Instance 5';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'CPU Demand Series (Peak) for Instance 6';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'CPU Demand Series (Peak) for Instance 7';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'CPU Demand Series (Peak) for Instance 8';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'Sessions "ON CPU"';
DEF tit_01 = 'Maximum (peak)';
DEF tit_02 = '99% Percentile';
DEF tit_03 = '95% Percentile';
DEF tit_04 = '90% Percentile';
DEF tit_05 = '75% Percentile';
DEF tit_06 = 'Median';
DEF tit_07 = 'Average';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

BEGIN
  :sql_text_backup := '
WITH 
cpu_per_inst_and_sample AS (
SELECT /*+ &&sq_fact_hints. */
       instance_number,
       snap_id,
       sample_id,
       MIN(sample_time) sample_time,
       COUNT(*) on_cpu
  FROM dba_hist_active_sess_history
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
   AND session_state = ''ON CPU''
 GROUP BY
       instance_number,
       snap_id,
       sample_id
),
cpu_per_inst_and_hour AS (
SELECT /*+ &&sq_fact_hints. */
       MIN(snap_id) snap_id,
       instance_number, 
       TRUNC(CAST(sample_time AS DATE), ''HH'')             begin_time, 
       TRUNC(CAST(sample_time AS DATE), ''HH'') + (1/24)    end_time, 
       MAX(on_cpu)                                          on_cpu_max,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY on_cpu) on_cpu_99p,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY on_cpu) on_cpu_95p,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY on_cpu) on_cpu_90p,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY on_cpu) on_cpu_75p,
       ROUND(MEDIAN(on_cpu), 1)                             on_cpu_med,
       ROUND(AVG(on_cpu), 1)                                on_cpu_avg
  FROM cpu_per_inst_and_sample
 GROUP BY
       instance_number,
       TRUNC(CAST(sample_time AS DATE), ''HH'')
)
SELECT MIN(snap_id) snap_id,
       TO_CHAR(begin_time, ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(end_time, ''YYYY-MM-DD HH24:MI'') end_time,
       SUM(on_cpu_max) on_cpu_max,
       SUM(on_cpu_99p) on_cpu_99p,
       SUM(on_cpu_95p) on_cpu_95p,
       SUM(on_cpu_90p) on_cpu_90p,
       SUM(on_cpu_75p) on_cpu_75p,
       SUM(on_cpu_med) on_cpu_med,
       SUM(on_cpu_avg) on_cpu_avg,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM cpu_per_inst_and_hour
 GROUP BY
       begin_time,
       end_time
 ORDER BY
       end_time
';
END;
/

DEF vbaseline = 'baseline:&&sum_cpu_count.,'; 

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'CPU Demand Series (Percentile) for Cluster';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF vbaseline = 'baseline:&&avg_cpu_count.,';

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'CPU Demand Series (Percentile) for Instance 1';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'CPU Demand Series (Percentile) for Instance 2';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'CPU Demand Series (Percentile) for Instance 3';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'CPU Demand Series (Percentile) for Instance 4';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'CPU Demand Series (Percentile) for Instance 5';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'CPU Demand Series (Percentile) for Instance 6';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'CPU Demand Series (Percentile) for Instance 7';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'CPU Demand Series (Percentile) for Instance 8';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF vbaseline = 'baseline:&&sum_cpu_count.,'; 

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/

DEF title = 'Memory Size (MEM)';
DEF main_table = 'GV$SYSTEM_PARAMETER2';
DEF abstract = 'Consolidated view of Memory requirements.'
DEF abstract2 = 'It considers AMM if setup, else ASMM if setup, else no memory management settings (individual pools size).'
DEF foot = 'Consider "Giga Bytes (GB)" column for sizing. Instance Number -1 means aggregated values (SUM) while -2 means over all instances (combined).'
BEGIN
  :sql_text := '
WITH
par AS (
SELECT /*+ &&sq_fact_hints. */
       d.dbid,
       d.name db_name,
       i.inst_id,
       i.host_name,
       i.instance_number,
       i.instance_name,
       SUM(CASE p.name WHEN ''memory_target'' THEN TO_NUMBER(value) END) memory_target,
       SUM(CASE p.name WHEN ''memory_max_target'' THEN TO_NUMBER(value) END) memory_max_target,
       SUM(CASE p.name WHEN ''sga_target'' THEN TO_NUMBER(value) END) sga_target,
       SUM(CASE p.name WHEN ''sga_max_size'' THEN TO_NUMBER(value) END) sga_max_size,
       SUM(CASE p.name WHEN ''pga_aggregate_target'' THEN TO_NUMBER(value) END) pga_aggregate_target
  FROM gv$instance i,
       gv$database d,
       gv$system_parameter2 p
 WHERE d.inst_id = i.inst_id
   AND p.inst_id = i.inst_id
   AND p.name IN (''memory_target'', ''memory_max_target'', ''sga_target'', ''sga_max_size'', ''pga_aggregate_target'')
 GROUP BY
       d.dbid,
       d.name,
       i.inst_id,
       i.host_name,
       i.instance_number,
       i.instance_name
),
sga_max AS (
SELECT /*+ &&sq_fact_hints. */
       inst_id,
       bytes
  FROM gv$sgainfo
 WHERE name = ''Maximum SGA Size''
),
pga_max AS (
SELECT /*+ &&sq_fact_hints. */
       inst_id,
       value bytes
  FROM gv$pgastat
 WHERE name = ''maximum PGA allocated''
),
pga AS (
SELECT /*+ &&sq_fact_hints. */
       par.dbid,
       par.db_name,
       par.inst_id,
       par.host_name,
       par.instance_number,
       par.instance_name,
       par.pga_aggregate_target,
       pga_max.bytes max_bytes,
       GREATEST(NVL(par.pga_aggregate_target, 0), NVL(pga_max.bytes, 0)) bytes
  FROM par,
       pga_max
 WHERE par.inst_id = pga_max.inst_id
),
amm AS (
SELECT /*+ &&sq_fact_hints. */
       par.dbid,
       par.db_name,
       par.inst_id,
       par.host_name,
       par.instance_number,
       par.instance_name,
       par.memory_target,
       par.memory_max_target,
       GREATEST(NVL(par.memory_target, 0), NVL(par.memory_max_target, 0)) + (6 * 1024 * 1024) bytes
  FROM par
),
asmm AS (
SELECT /*+ &&sq_fact_hints. */
       par.dbid,
       par.db_name,
       par.inst_id,
       par.host_name,
       par.instance_number,
       par.instance_name,
       par.sga_target,
       par.sga_max_size,
       pga.bytes pga_bytes,
       GREATEST(NVL(sga_target, 0), NVL(sga_max_size, 0)) + NVL(pga.bytes, 0) + (6 * 1024 * 1024) bytes
  FROM par,
       pga
 WHERE par.inst_id = pga.inst_id
),
no_mm AS (
SELECT /*+ &&sq_fact_hints. */
       pga.dbid,
       pga.db_name,
       pga.inst_id,
       pga.host_name,
       pga.instance_number,
       pga.instance_name,
       sga_max.bytes max_sga,
       pga.bytes max_pga,
       pga.pga_aggregate_target,
       sga_max.bytes + pga.bytes + (5 * 1024 * 1024) bytes
  FROM sga_max,
       pga
 WHERE sga_max.inst_id = pga.inst_id
),
them_all AS (
SELECT /*+ &&sq_fact_hints. */
       amm.dbid,
       amm.db_name,
       amm.inst_id,
       amm.host_name,
       amm.instance_number,
       amm.instance_name,
       GREATEST(NVL(amm.bytes, 0), NVL(asmm.bytes, 0), NVL(no_mm.bytes, 0)) bytes,
       amm.memory_target,
       amm.memory_max_target,
       asmm.sga_target,
       asmm.sga_max_size,
       no_mm.max_sga,
       no_mm.pga_aggregate_target,
       no_mm.max_pga
  FROM amm,
       asmm,
       no_mm
 WHERE asmm.inst_id = amm.inst_id
   AND no_mm.inst_id = amm.inst_id
 ORDER BY
       amm.inst_id
)
SELECT dbid,
       db_name,
       host_name,
       instance_number,
       instance_name,
       bytes total_required,
       ROUND(bytes/POWER(2,30),3) total_required_gb,
       memory_target,
       ROUND(memory_target/POWER(2,30),3) memory_target_gb,
       memory_max_target,
       ROUND(memory_max_target/POWER(2,30),3) memory_max_target_gb,
       sga_target,
       ROUND(sga_target/POWER(2,30),3) sga_target_gb,
       sga_max_size,
       ROUND(sga_max_size/POWER(2,30),3) sga_max_size_gb,
       max_sga max_sga_alloc,
       ROUND(max_sga/POWER(2,30),3) max_sga_alloc_gb,
       pga_aggregate_target,
       ROUND(pga_aggregate_target/POWER(2,30),3) pga_aggregate_target_gb,
       max_pga max_pga_alloc,
       ROUND(max_pga/POWER(2,30),3) max_pga_alloc_gb
  FROM them_all
 UNION ALL
SELECT TO_NUMBER(NULL) dbid,
       NULL db_name,
       NULL host_name,
       -1 instance_number,
       NULL instance_name,
       SUM(bytes) total_required,
       ROUND(SUM(bytes)/POWER(2,30),3) total_required_gb,
       SUM(memory_target) memory_target,
       ROUND(SUM(memory_target)/POWER(2,30),3) memory_target_gb,
       SUM(memory_max_target) memory_max_target,
       ROUND(SUM(memory_max_target)/POWER(2,30),3) memory_max_target_gb,
       SUM(sga_target) sga_target,
       ROUND(SUM(sga_target)/POWER(2,30),3) sga_target_gb,
       SUM(sga_max_size) sga_max_size,
       ROUND(SUM(sga_max_size)/POWER(2,30),3) sga_max_size_gb,
       SUM(max_sga) max_sga_alloc,
       ROUND(SUM(max_sga)/POWER(2,30),3) max_sga_alloc_gb,
       SUM(pga_aggregate_target) pga_aggregate_target,
       ROUND(SUM(pga_aggregate_target)/POWER(2,30),3) pga_aggregate_target_gb,
       SUM(max_pga) max_pga_alloc,
       ROUND(SUM(max_pga)/POWER(2,30),3) max_pga_alloc_gb
  FROM them_all
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Memory Size (AWR)';
DEF main_table = 'DBA_HIST_PARAMETER';
DEF abstract = 'Consolidated view of Memory requirements.'
DEF abstract2 = 'It considers AMM if setup, else ASMM if setup, else no memory management settings (individual pools size).'
DEF foot = 'Consider "Giga Bytes (GB)" column for sizing. Instance Number -1 means aggregated values (SUM) while -2 means over all instances (combined).'
BEGIN
  :sql_text := '
WITH
max_snap AS (
SELECT /*+ &&sq_fact_hints. */
       MAX(snap_id) snap_id,
       dbid,
       instance_number,
       parameter_name
  FROM dba_hist_parameter
 WHERE parameter_name IN (''memory_target'', ''memory_max_target'', ''sga_target'', ''sga_max_size'', ''pga_aggregate_target'')
   AND (snap_id, dbid, instance_number) IN (SELECT s.snap_id, s.dbid, s.instance_number FROM dba_hist_snapshot s)
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 GROUP BY
       dbid,
       instance_number,
       parameter_name
),
last_value AS (
SELECT /*+ &&sq_fact_hints. */
       s.snap_id,
       s.dbid,
       s.instance_number,
       s.parameter_name,
       p.value
  FROM max_snap s,
       dba_hist_parameter p
 WHERE p.snap_id = s.snap_id
   AND p.dbid = s.dbid
   AND p.instance_number = s.instance_number
   AND p.parameter_name = s.parameter_name
   AND p.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND p.dbid = &&edb360_dbid.
),
last_snap AS (
SELECT /*+ &&sq_fact_hints. */
       p.snap_id,
       p.dbid,
       p.instance_number,
       p.parameter_name,
       p.value,
       s.startup_time
  FROM last_value p,
       dba_hist_snapshot s
 WHERE s.snap_id = p.snap_id
   AND s.dbid = p.dbid
   AND s.instance_number = p.instance_number
   AND s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
),
par AS (
SELECT /*+ &&sq_fact_hints. */
       p.dbid,
       di.db_name,
       di.host_name,
       p.instance_number,
       di.instance_name,
       SUM(CASE p.parameter_name WHEN ''memory_target'' THEN TO_NUMBER(p.value) ELSE 0 END) memory_target,
       SUM(CASE p.parameter_name WHEN ''memory_max_target'' THEN TO_NUMBER(p.value) ELSE 0 END) memory_max_target,
       SUM(CASE p.parameter_name WHEN ''sga_target'' THEN TO_NUMBER(p.value) ELSE 0 END) sga_target,
       SUM(CASE p.parameter_name WHEN ''sga_max_size'' THEN TO_NUMBER(p.value) ELSE 0 END) sga_max_size,
       SUM(CASE p.parameter_name WHEN ''pga_aggregate_target'' THEN TO_NUMBER(p.value) ELSE 0 END) pga_aggregate_target
  FROM last_snap p,
       dba_hist_database_instance di
 WHERE di.dbid = p.dbid
   AND di.instance_number = p.instance_number
   AND di.startup_time = p.startup_time
   AND di.dbid = &&edb360_dbid.
 GROUP BY
       p.dbid,
       di.db_name,
       di.host_name,
       p.instance_number,
       di.instance_name
),
sgainfo AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       instance_number,
       SUM(value) sga_size
  FROM dba_hist_sga
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 GROUP BY
       snap_id,
       dbid,
       instance_number
),
sga_max AS (
SELECT /*+ &&sq_fact_hints. */
       dbid,
       instance_number,
       MAX(sga_size) bytes
  FROM sgainfo
 GROUP BY
       dbid,
       instance_number
),
pga_max AS (
SELECT /*+ &&sq_fact_hints. */
       dbid,
       instance_number,
       MAX(value) bytes
  FROM dba_hist_pgastat
 WHERE name = ''maximum PGA allocated''
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 GROUP BY
       dbid,
       instance_number
),
pga AS (
SELECT /*+ &&sq_fact_hints. */
       par.dbid,
       par.db_name,
       par.host_name,
       par.instance_number,
       par.instance_name,
       par.pga_aggregate_target,
       pga_max.bytes max_bytes,
       GREATEST(NVL(par.pga_aggregate_target, 0), NVL(pga_max.bytes, 0)) bytes
  FROM pga_max,
       par
 WHERE par.dbid = pga_max.dbid
   AND par.instance_number = pga_max.instance_number
),
amm AS (
SELECT /*+ &&sq_fact_hints. */
       par.dbid,
       par.db_name,
       par.host_name,
       par.instance_number,
       par.instance_name,
       par.memory_target,
       par.memory_max_target,
       GREATEST(NVL(par.memory_target, 0), NVL(par.memory_max_target, 0)) + (6 * 1024 * 1024) bytes
  FROM par
),
asmm AS (
SELECT /*+ &&sq_fact_hints. */
       par.dbid,
       par.db_name,
       par.host_name,
       par.instance_number,
       par.instance_name,
       par.sga_target,
       par.sga_max_size,
       pga.bytes pga_bytes,
       GREATEST(NVL(sga_target, 0), NVL(sga_max_size, 0)) + NVL(pga.bytes, 0) + (6 * 1024 * 1024) bytes
  FROM pga,
       par
 WHERE par.dbid = pga.dbid
   AND par.instance_number = pga.instance_number
),
no_mm AS (
SELECT /*+ &&sq_fact_hints. */
       pga.dbid,
       pga.db_name,
       pga.host_name,
       pga.instance_number,
       pga.instance_name,
       sga_max.bytes max_sga,
       pga.bytes max_pga,
       pga.pga_aggregate_target,
       sga_max.bytes + pga.bytes + (5 * 1024 * 1024) bytes
  FROM pga,
       sga_max
 WHERE sga_max.dbid = pga.dbid
   AND sga_max.instance_number = pga.instance_number
),
them_all AS (
SELECT /*+ &&sq_fact_hints. */
       amm.dbid,
       amm.db_name,
       amm.host_name,
       amm.instance_number,
       amm.instance_name,
       GREATEST(NVL(amm.bytes, 0), NVL(asmm.bytes, 0), NVL(no_mm.bytes, 0)) bytes,
       amm.memory_target,
       amm.memory_max_target,
       asmm.sga_target,
       asmm.sga_max_size,
       no_mm.max_sga,
       no_mm.pga_aggregate_target,
       no_mm.max_pga
  FROM amm,
       asmm,
       no_mm
 WHERE asmm.instance_number = amm.instance_number
   AND asmm.dbid = amm.dbid
   AND no_mm.instance_number = amm.instance_number
   AND no_mm.dbid = amm.dbid
 ORDER BY
       amm.dbid,
       amm.instance_number
)
SELECT dbid,
       db_name,
       host_name,
       instance_number,
       instance_name,
       bytes total_required,
       ROUND(bytes/POWER(2,30),3) total_required_gb,
       memory_target,
       ROUND(memory_target/POWER(2,30),3) memory_target_gb,
       memory_max_target,
       ROUND(memory_max_target/POWER(2,30),3) memory_max_target_gb,
       sga_target,
       ROUND(sga_target/POWER(2,30),3) sga_target_gb,
       sga_max_size,
       ROUND(sga_max_size/POWER(2,30),3) sga_max_size_gb,
       max_sga max_sga_alloc,
       ROUND(max_sga/POWER(2,30),3) max_sga_alloc_gb,
       pga_aggregate_target,
       ROUND(pga_aggregate_target/POWER(2,30),3) pga_aggregate_target_gb,
       max_pga max_pga_alloc,
       ROUND(max_pga/POWER(2,30),3) max_pga_alloc_gb
  FROM them_all
 UNION ALL
SELECT TO_NUMBER(NULL) dbid,
       NULL db_name,
       NULL host_name,
       -1 instance_number,
       NULL instance_name,
       SUM(bytes) total_required,
       ROUND(SUM(bytes)/POWER(2,30),3) total_required_gb,
       SUM(memory_target) memory_target,
       ROUND(SUM(memory_target)/POWER(2,30),3) memory_target_gb,
       SUM(memory_max_target) memory_max_target,
       ROUND(SUM(memory_max_target)/POWER(2,30),3) memory_max_target_gb,
       SUM(sga_target) sga_target,
       ROUND(SUM(sga_target)/POWER(2,30),3) sga_target_gb,
       SUM(sga_max_size) sga_max_size,
       ROUND(SUM(sga_max_size)/POWER(2,30),3) sga_max_size_gb,
       SUM(max_sga) max_sga_alloc,
       ROUND(SUM(max_sga)/POWER(2,30),3) max_sga_alloc_gb,
       SUM(pga_aggregate_target) pga_aggregate_target,
       ROUND(SUM(pga_aggregate_target)/POWER(2,30),3) pga_aggregate_target_gb,
       SUM(max_pga) max_pga_alloc,
       ROUND(SUM(max_pga)/POWER(2,30),3) max_pga_alloc_gb
  FROM them_all
';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF main_table = 'DBA_HIST_SGA';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vbaseline = '';
DEF vaxis = 'Memory in Giga Bytes (GB)';
DEF tit_01 = 'Total (SGA + PGA)';
DEF tit_02 = 'SGA';
DEF tit_03 = 'PGA';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

BEGIN
  :sql_text_backup := '
WITH
sga AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       instance_number,
       SUM(value) bytes
  FROM dba_hist_sga
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
 GROUP BY
       snap_id,
       dbid,
       instance_number
),
pga AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       instance_number,
       value bytes
  FROM dba_hist_pgastat
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
   AND name = ''maximum PGA allocated''
),
mem AS (
SELECT /*+ &&sq_fact_hints. */
       snp.snap_id,
       snp.dbid,
       snp.instance_number,
       snp.begin_interval_time,
       snp.end_interval_time,
       TO_CHAR(TRUNC(CAST(snp.begin_interval_time AS DATE), ''HH''), ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(TRUNC(CAST(snp.begin_interval_time AS DATE), ''HH'') + (1/24), ''YYYY-MM-DD HH24:MI'') end_time,
       sga.bytes sga_bytes,
       pga.bytes pga_bytes,
       (sga.bytes + pga.bytes) mem_bytes
  FROM sga, pga, dba_hist_snapshot snp
 WHERE pga.snap_id = sga.snap_id
   AND pga.dbid = sga.dbid
   AND pga.instance_number = sga.instance_number
   AND snp.snap_id = sga.snap_id
   AND snp.dbid = sga.dbid
   AND snp.instance_number = sga.instance_number
   AND snp.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND snp.dbid = &&edb360_dbid.
),
hourly_inst AS (
SELECT /*+ &&sq_fact_hints. */
       MIN(snap_id) snap_id,
       dbid,
       instance_number,
       begin_time,
       end_time,
       MAX(sga_bytes) sga_bytes,
       MAX(pga_bytes) pga_bytes,
       MAX(mem_bytes) mem_bytes,
       MIN(begin_interval_time) begin_interval_time,
       MAX(end_interval_time) end_interval_time
  FROM mem
 GROUP BY
       dbid,
       instance_number,
       begin_time,
       end_time
),
hourly AS (
SELECT /*+ &&sq_fact_hints. */
       MIN(snap_id) snap_id,
       begin_time,
       end_time,
       ROUND(SUM(sga_bytes) / POWER(2, 30), 3) sga_gb,
       ROUND(SUM(pga_bytes) / POWER(2, 30), 3) pga_gb,
       ROUND(SUM(mem_bytes) / POWER(2, 30), 3) mem_gb,
       SUM(sga_bytes) sga_bytes,
       SUM(pga_bytes) pga_bytes,
       SUM(mem_bytes) mem_bytes,
       MIN(begin_interval_time) begin_interval_time,
       MAX(end_interval_time) end_interval_time
  FROM hourly_inst
 GROUP BY
       begin_time,
       end_time
)
SELECT snap_id,
       begin_time,
       end_time,
       mem_gb,
       sga_gb,
       pga_gb,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM hourly
 ORDER BY
       end_time
';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Memory Size Series for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Memory Size Series for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Memory Size Series for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Memory Size Series for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Memory Size Series for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Memory Size Series for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Memory Size Series for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Memory Size Series for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Memory Size Series for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/

DEF title = 'Database Size on Disk';
DEF main_table = 'GV$DATABASE';
DEF abstract = 'Displays Space on Disk including datafiles, tempfiles, log and control files.'
DEF foot = 'Consider "Tera Bytes (TB)" column for sizing.'
COL gb FOR 999990.000;
BEGIN
  :sql_text := '
WITH 
sizes AS (
SELECT /*+ &&sq_fact_hints. */
       ''Data'' file_type,
       SUM(bytes) bytes
  FROM v$datafile
 UNION ALL
SELECT ''Temp'' file_type,
       SUM(bytes) bytes
  FROM v$tempfile
 UNION ALL
SELECT ''Log'' file_type,
       SUM(bytes) * MAX(members) bytes
  FROM gv$log
 UNION ALL
SELECT ''Control'' file_type,
       SUM(block_size * file_size_blks) bytes
  FROM v$controlfile
),
dbsize AS (
SELECT /*+ &&sq_fact_hints. */
       ''Total'' file_type,
       SUM(bytes) bytes
  FROM sizes
)
SELECT d.dbid,
       d.name db_name,
       s.file_type,
       s.bytes,
       ROUND(s.bytes/POWER(2,30),3) gb,
       CASE 
       WHEN s.bytes > POWER(2,50) THEN ROUND(s.bytes/POWER(2,50),3)||'' P''
       WHEN s.bytes > POWER(2,40) THEN ROUND(s.bytes/POWER(2,40),3)||'' T''
       WHEN s.bytes > POWER(2,30) THEN ROUND(s.bytes/POWER(2,30),3)||'' G''
       WHEN s.bytes > POWER(2,20) THEN ROUND(s.bytes/POWER(2,20),3)||'' M''
       WHEN s.bytes > POWER(2,10) THEN ROUND(s.bytes/POWER(2,10),3)||'' K''
       WHEN s.bytes > 0 THEN s.bytes||'' B'' END display
  FROM v$database d,
       sizes s
 UNION ALL
SELECT d.dbid,
       d.name db_name,
       s.file_type,
       s.bytes,
       ROUND(s.bytes/POWER(2,30),3) gb,
       CASE 
       WHEN s.bytes > POWER(2,50) THEN ROUND(s.bytes/POWER(2,50),3)||'' P''
       WHEN s.bytes > POWER(2,40) THEN ROUND(s.bytes/POWER(2,40),3)||'' T''
       WHEN s.bytes > POWER(2,30) THEN ROUND(s.bytes/POWER(2,30),3)||'' G''
       WHEN s.bytes > POWER(2,20) THEN ROUND(s.bytes/POWER(2,20),3)||'' M''
       WHEN s.bytes > POWER(2,10) THEN ROUND(s.bytes/POWER(2,10),3)||'' K''
       WHEN s.bytes > 0 THEN s.bytes||'' B'' END display
  FROM v$database d,
       dbsize s
';
END;
/
@@edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF main_table = 'DBA_HIST_TBSPC_SPACE_USAGE';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vbaseline = '';
DEF vaxis = 'Tablespace Size in Giga Bytes (GB)';
DEF tit_01 = 'Total (Perm + Undo + Temp)';
DEF tit_02 = 'Permanent';
DEF tit_03 = 'Undo';
DEF tit_04 = 'Temporary';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

BEGIN
  :sql_text := '
WITH
ts_per_snap_id AS (
SELECT /*+ &&sq_fact_hints. */
       us.snap_id,
       TRUNC(CAST(sn.end_interval_time AS DATE), ''HH'') + (1/24) end_time,
       SUM(us.tablespace_size * ts.block_size) all_tablespaces_bytes,
       SUM(CASE ts.contents WHEN ''PERMANENT'' THEN us.tablespace_size * ts.block_size ELSE 0 END) perm_tablespaces_bytes,
       SUM(CASE ts.contents WHEN ''UNDO''      THEN us.tablespace_size * ts.block_size ELSE 0 END) undo_tablespaces_bytes,
       SUM(CASE ts.contents WHEN ''TEMPORARY'' THEN us.tablespace_size * ts.block_size ELSE 0 END) temp_tablespaces_bytes
  FROM dba_hist_tbspc_space_usage us,
       dba_hist_snapshot sn,
       v$tablespace vt,
       dba_tablespaces ts
 WHERE us.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND us.dbid = &&edb360_dbid.
   AND sn.snap_id = us.snap_id
   AND sn.dbid = us.dbid
   AND sn.instance_number = &&connect_instance_number.
   AND vt.ts# = us.tablespace_id
   AND ts.tablespace_name = vt.name
 GROUP BY
       us.snap_id,
       sn.end_interval_time
)
SELECT MAX(snap_id) snap_id,
       (end_time - (1/24)) begin_time,
       end_time,
       ROUND(MAX(all_tablespaces_bytes) / POWER(2, 30), 3),
       ROUND(MAX(perm_tablespaces_bytes) / POWER(2, 30), 3),
       ROUND(MAX(undo_tablespaces_bytes) / POWER(2, 30), 3),
       ROUND(MAX(temp_tablespaces_bytes) / POWER(2, 30), 3),
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM ts_per_snap_id
 GROUP BY
       end_time
 ORDER BY
       end_time
';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'Tablespace Size Series';
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

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
       i.host_name,
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
       SUM(r_bytes_perc),
       SUM(w_bytes_perc),
       SUM(rw_mbps_peak),
       SUM(r_mbps_peak),
       SUM(w_mbps_peak),
       SUM(rw_mbps_999),
       SUM(r_mbps_999),
       SUM(w_mbps_999),
       SUM(rw_mbps_99),
       SUM(r_mbps_99),
       SUM(w_mbps_99),
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

DEF main_table = 'DBA_HIST_SYSSTAT';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vbaseline = '';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

BEGIN
  :sql_text_backup := '
WITH
sysstat_io AS (
SELECT /*+ &&sq_fact_hints. */
       instance_number,
       snap_id,
       SUM(CASE WHEN stat_name = ''physical read total IO requests'' THEN value ELSE 0 END) r_reqs,
       SUM(CASE WHEN stat_name IN (''physical write total IO requests'', ''redo writes'') THEN value ELSE 0 END) w_reqs,
       SUM(CASE WHEN stat_name = ''physical read total bytes'' THEN value ELSE 0 END) r_bytes,
       SUM(CASE WHEN stat_name IN (''physical write total bytes'', ''redo size'') THEN value ELSE 0 END) w_bytes
  FROM dba_hist_sysstat
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND instance_number = @instance_number@
   AND stat_name IN (''physical read total IO requests'', ''physical write total IO requests'', ''redo writes'', ''physical read total bytes'', ''physical write total bytes'', ''redo size'')
 GROUP BY
       instance_number,
       snap_id
),
io_per_inst_and_snap_id AS (
SELECT /*+ &&sq_fact_hints. */
       s1.snap_id,
       h1.instance_number,
       TRUNC(CAST(s1.end_interval_time AS DATE), ''HH'') begin_time,
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
   AND (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 > 60 -- ignore snaps too close
),
io_per_inst_and_hr AS (
SELECT /*+ &&sq_fact_hints. */
       MIN(snap_id) snap_id,
       instance_number,
       begin_time,
       begin_time + (1/24) end_time,
       ROUND(MAX((r_reqs + w_reqs) / elapsed_sec)) rw_iops,
       ROUND(MAX(r_reqs / elapsed_sec)) r_iops,
       ROUND(MAX(w_reqs / elapsed_sec)) w_iops,
       ROUND(MAX((r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec), 3) rw_mbps,
       ROUND(MAX(r_bytes / POWER(2, 20) / elapsed_sec), 3) r_mbps,
       ROUND(MAX(w_bytes / POWER(2, 20) / elapsed_sec), 3) w_mbps
  FROM io_per_inst_and_snap_id
 GROUP BY
       instance_number,
       begin_time
)
SELECT MIN(snap_id) snap_id,
       begin_time,
       end_time,
       SUM(@column1@) @column1@,
       SUM(@column2@) @column2@,
       SUM(@column3@) @column3@,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM io_per_inst_and_hr
 GROUP BY
       begin_time,
       end_time
 ORDER BY
       end_time
';
END;
/

DEF tit_01 = 'RW IOPS';
DEF tit_02 = 'R IOPS';
DEF tit_03 = 'W IOPS';
DEF vaxis = 'IOPS (RW, R and W)';

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).'
DEF title = 'IOPS Series for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).'
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'IOPS Series for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).'
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'IOPS Series for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).'
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'IOPS Series for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).'
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'IOPS Series for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).'
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'IOPS Series for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).'
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'IOPS Series for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).'
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'IOPS Series for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).'
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'IOPS Series for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF tit_01 = 'RW MBPS';
DEF tit_02 = 'R MBPS';
DEF tit_03 = 'W MBPS';
DEF vaxis = 'MBPS (RW, R and W)';

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).'
DEF title = 'MBPS Series for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).'
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'MBPS Series for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).'
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'MBPS Series for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).'
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'MBPS Series for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).'
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'MBPS Series for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).'
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'MBPS Series for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).'
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'MBPS Series for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).'
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'MBPS Series for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).'
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'MBPS Series for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
EXEC :sql_text := REPLACE(:sql_text, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';
DEF abstract = '';

/*****************************************************************************************/


