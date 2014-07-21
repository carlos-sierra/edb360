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

COL aas_cpu_peak       FOR 999999999999990.0 HEA "CPU Demand Peak";
COL aas_cpu_99_99_perc FOR 999999999999990.0 HEA "CPU Demand 99.99% Percentile";
COL aas_cpu_99_9_perc  FOR 999999999999990.0 HEA "CPU Demand 99.9% Percentile";
COL aas_cpu_99_perc    FOR 999999999999990.0 HEA "CPU Demand 99% Percentile";
COL aas_cpu_95_perc    FOR 999999999999990.0 HEA "CPU Demand 95% Percentile";
COL aas_cpu_90_perc    FOR 999999999999990.0 HEA "CPU Demand 90% Percentile";
COL aas_cpu_75_perc    FOR 999999999999990.0 HEA "CPU Demand 75% Percentile";
COL aas_cpu_50_perc    FOR 999999999999990.0 HEA "CPU Demand 50% Percentile";

DEF title = 'CPU Demand (MEM)';
DEF main_table = 'GV$ACTIVE_SESSION_HISTORY';
DEF abstract = 'Number of Sessions demanding CPU. Includes Peak (max), percentiles and average.'
DEF foot = 'Consider Peak for sizing.'
BEGIN
  :sql_text := '
WITH 
samples_on_cpu AS (
SELECT /*+ &&sq_fact_hints. */
       inst_id,
       sample_id,
       COUNT(*) on_cpu
  FROM gv$active_session_history
 WHERE (session_state = ''ON CPU''
    OR event = ''resmgr:cpu quantum'')
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
       MAX(c.on_cpu) peak_on_cpu,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY c.on_cpu) perc_99_99_on_cpu,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY c.on_cpu) perc_99_9_on_cpu,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY c.on_cpu) perc_99_on_cpu,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY c.on_cpu) perc_95_on_cpu,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY c.on_cpu) perc_90_on_cpu,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY c.on_cpu) perc_75_on_cpu,
       PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY c.on_cpu) perc_50_on_cpu,
       ROUND(AVG(c.on_cpu), 3) avg_on_cpu
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
       peak_on_cpu aas_cpu_peak,
       perc_99_99_on_cpu aas_cpu_99_99_perc,
       perc_99_9_on_cpu aas_cpu_99_9_perc,
       perc_99_on_cpu aas_cpu_99_perc,
       perc_95_on_cpu aas_cpu_95_perc,
       perc_90_on_cpu aas_cpu_90_perc,
       perc_75_on_cpu aas_cpu_75_perc,
       perc_50_on_cpu aas_cpu_50_perc,
       avg_on_cpu aas_cpu_avg
  FROM sub_totals
 UNION ALL
SELECT MAX(dbid) dbid,
       MAX(db_name) db_name,
       NULL host_name,
       TO_NUMBER(NULL) instance_number,
       NULL instance_name,
       SUM(peak_on_cpu) aas_cpu_peak,
       SUM(perc_99_99_on_cpu) aas_cpu_99_99_perc,
       SUM(perc_99_9_on_cpu) aas_cpu_99_9_perc,
       SUM(perc_99_on_cpu) aas_cpu_99_perc,
       SUM(perc_95_on_cpu) aas_cpu_95_perc,
       SUM(perc_90_on_cpu) aas_cpu_90_perc,
       SUM(perc_75_on_cpu) aas_cpu_75_perc,
       SUM(perc_50_on_cpu) aas_cpu_50_perc,
       SUM(avg_on_cpu) aas_cpu_avg
  FROM sub_totals
';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'CPU Demand (AWR)';
DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF abstract = 'Number of Sessions demanding CPU. Includes Peak (max), percentiles and average.'
DEF foot = 'Consider Peak or high Percentile for sizing.'
BEGIN
  :sql_text := '
WITH 
samples_on_cpu AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       instance_number,
       sample_id,
       COUNT(*) on_cpu
  FROM dba_hist_active_sess_history
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND (session_state = ''ON CPU''
    OR event = ''resmgr:cpu quantum'')
 GROUP BY
       snap_id,
       dbid,
       instance_number,
       sample_id
),
sub_totals AS (
SELECT /*+ &&sq_fact_hints. */
       c.dbid,
       di.db_name,
       di.host_name,
       c.instance_number,
       di.instance_name,
       MAX(c.on_cpu) peak_on_cpu,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY c.on_cpu) perc_99_99_on_cpu,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY c.on_cpu) perc_99_9_on_cpu,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY c.on_cpu) perc_99_on_cpu,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY c.on_cpu) perc_95_on_cpu,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY c.on_cpu) perc_90_on_cpu,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY c.on_cpu) perc_75_on_cpu,
       PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY c.on_cpu) perc_50_on_cpu,
       ROUND(AVG(c.on_cpu), 3) avg_on_cpu
  FROM samples_on_cpu c,
       dba_hist_snapshot s,
       dba_hist_database_instance di
 WHERE s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.snap_id = c.snap_id
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
       peak_on_cpu aas_cpu_peak,
       perc_99_99_on_cpu aas_cpu_99_99_perc,
       perc_99_9_on_cpu aas_cpu_99_9_perc,
       perc_99_on_cpu aas_cpu_99_perc,
       perc_95_on_cpu aas_cpu_95_perc,
       perc_90_on_cpu aas_cpu_90_perc,
       perc_75_on_cpu aas_cpu_75_perc,
       perc_50_on_cpu aas_cpu_50_perc,
       avg_on_cpu aas_cpu_avg
  FROM sub_totals
 UNION ALL
SELECT MAX(dbid) dbid,
       MAX(db_name) db_name,
       NULL host_name,
       TO_NUMBER(NULL) instance_number,
       NULL instance_name,
       SUM(peak_on_cpu) aas_cpu_peak,
       SUM(perc_99_99_on_cpu) aas_cpu_99_99_perc,
       SUM(perc_99_9_on_cpu) aas_cpu_99_9_perc,
       SUM(perc_99_on_cpu) aas_cpu_99_perc,
       SUM(perc_95_on_cpu) aas_cpu_95_perc,
       SUM(perc_90_on_cpu) aas_cpu_90_perc,
       SUM(perc_75_on_cpu) aas_cpu_75_perc,
       SUM(perc_50_on_cpu) aas_cpu_50_perc,
       SUM(avg_on_cpu) aas_cpu_avg
  FROM sub_totals
';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'Sessions "ON CPU" or waiting for "resmgr:cpu quantum"';
DEF tit_01 = 'CPU demand';
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
samples AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       instance_number,
       sample_time,
       COUNT(*) cpu_demand,
       SUM(CASE session_state WHEN ''ON CPU'' THEN 1 ELSE 0 END) on_cpu,
       SUM(CASE event WHEN ''resmgr:cpu quantum'' THEN 1 ELSE 0 END) waiting_for_cpu,
       TO_CHAR(TRUNC(CAST(sample_time AS DATE), ''HH''), ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(TRUNC(CAST(sample_time AS DATE), ''HH'') + (1/24), ''YYYY-MM-DD HH24:MI'') end_time
  FROM dba_hist_active_sess_history
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND instance_number = @instance_number@
   AND (session_state = ''ON CPU'' OR event = ''resmgr:cpu quantum'')
 GROUP BY
       snap_id,
       dbid,
       instance_number,
       sample_time
),
peak_demand_per_hour AS (
SELECT /*+ &&sq_fact_hints. */
       MIN(snap_id) snap_id,
       dbid,
       instance_number,
       begin_time,
       MAX(cpu_demand) cpu_demand
  FROM samples
 GROUP BY
       dbid,
       instance_number,
       begin_time
),
max_sample_per_hour_and_inst AS (
SELECT /*+ &&sq_fact_hints. */
       s.dbid,
       s.instance_number,
       s.begin_time,
       MIN(s.sample_time) sample_time
  FROM peak_demand_per_hour m,
       samples s
 WHERE s.dbid = m.dbid
   AND s.instance_number = m.instance_number
   AND s.begin_time = m.begin_time
   AND s.cpu_demand = m.cpu_demand
 GROUP BY
       s.dbid,
       s.instance_number,
       s.begin_time
),
max_per_hour_and_inst AS (
SELECT /*+ &&sq_fact_hints. */
       s.snap_id,
       s.dbid,
       s.instance_number,
       s.begin_time,
       s.end_time,
       s.sample_time,
       s.cpu_demand,
       s.on_cpu,
       s.waiting_for_cpu
  FROM max_sample_per_hour_and_inst m,
       samples s
 WHERE s.dbid = m.dbid
   AND s.instance_number = m.instance_number
   AND s.begin_time = m.begin_time
   AND s.sample_time = m.sample_time
)
SELECT MIN(snap_id) snap_id,
       begin_time,
       end_time,
       SUM(cpu_demand) cpu_demand,
       SUM(on_cpu) on_cpu,
       SUM(waiting_for_cpu) waiting_for_cpu,
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
  FROM max_per_hour_and_inst
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
DEF foot = 'Sessions "ON CPU" or waiting on "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF vbaseline = 'baseline:&&avg_cpu_count.,';

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'CPU Demand Series (Peak) for Instance 1';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.'
DEF foot = 'Sessions "ON CPU" or waiting on "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'CPU Demand Series (Peak) for Instance 2';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.'
DEF foot = 'Sessions "ON CPU" or waiting on "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'CPU Demand Series (Peak) for Instance 3';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.'
DEF foot = 'Sessions "ON CPU" or waiting on "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'CPU Demand Series (Peak) for Instance 4';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.'
DEF foot = 'Sessions "ON CPU" or waiting on "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'CPU Demand Series (Peak) for Instance 5';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.'
DEF foot = 'Sessions "ON CPU" or waiting on "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'CPU Demand Series (Peak) for Instance 6';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.'
DEF foot = 'Sessions "ON CPU" or waiting on "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'CPU Demand Series (Peak) for Instance 7';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.'
DEF foot = 'Sessions "ON CPU" or waiting on "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'CPU Demand Series (Peak) for Instance 8';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.'
DEF foot = 'Sessions "ON CPU" or waiting on "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF vbaseline = 'baseline:&&sum_cpu_count.,'; 

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'Sessions "ON CPU" or waiting for "resmgr:cpu quantum"';
DEF tit_01 = 'Maximum (peak)';
DEF tit_02 = 'Average';
DEF tit_03 = 'Median';
DEF tit_04 = 'Minimum';
DEF tit_05 = '99% Percentile';
DEF tit_06 = '95% Percentile';
DEF tit_07 = '90% Percentile';
DEF tit_08 = '75% Percentile';
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
samples AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       instance_number,
       sample_time,
       COUNT(*) cpu_demand,
       TO_CHAR(TRUNC(CAST(sample_time AS DATE), ''HH''), ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(TRUNC(CAST(sample_time AS DATE), ''HH'') + (1/24), ''YYYY-MM-DD HH24:MI'') end_time
  FROM dba_hist_active_sess_history
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND instance_number = @instance_number@
   AND (session_state = ''ON CPU'' OR event = ''resmgr:cpu quantum'')
 GROUP BY
       snap_id,
       dbid,
       instance_number,
       sample_time
),
mm_demand_per_hour AS (
SELECT /*+ &&sq_fact_hints. */
       dbid,
       instance_number,
       begin_time,
       end_time,
       MIN(sample_time) sample_time,
       MIN(snap_id) snap_id,
       MAX(cpu_demand)                                          cpu_demand_max,
       ROUND(AVG(cpu_demand), 1)                                cpu_demand_avg,
       ROUND(MEDIAN(cpu_demand), 1)                             cpu_demand_med,
       MIN(cpu_demand)                                          cpu_demand_min,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY cpu_demand) cpu_demand_99p,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY cpu_demand) cpu_demand_95p,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY cpu_demand) cpu_demand_90p,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY cpu_demand) cpu_demand_75p
  FROM samples
 GROUP BY
       dbid,
       instance_number,
       begin_time,
       end_time
)
SELECT MIN(snap_id) snap_id,
       begin_time,
       end_time,
       SUM(cpu_demand_max) cpu_demand_max,
       SUM(cpu_demand_avg) cpu_demand_avg,
       SUM(cpu_demand_med) cpu_demand_med,
       SUM(cpu_demand_min) cpu_demand_min,
       SUM(cpu_demand_99p) cpu_demand_99p,
       SUM(cpu_demand_95p) cpu_demand_95p,
       SUM(cpu_demand_90p) cpu_demand_90p,
       SUM(cpu_demand_75p) cpu_demand_75p,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM mm_demand_per_hour
 GROUP BY
       begin_time,
       end_time
 ORDER BY 
       begin_time,
       end_time
';
END;
/

DEF vbaseline = 'baseline:&&sum_cpu_count.,'; 

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'CPU Demand Series (Percentile) for Cluster';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU" or waiting on "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF vbaseline = 'baseline:&&avg_cpu_count.,';

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'CPU Demand Series (Percentile) for Instance 1';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU" or waiting on "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'CPU Demand Series (Percentile) for Instance 2';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU" or waiting on "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'CPU Demand Series (Percentile) for Instance 3';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU" or waiting on "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'CPU Demand Series (Percentile) for Instance 4';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU" or waiting on "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'CPU Demand Series (Percentile) for Instance 5';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU" or waiting on "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'CPU Demand Series (Percentile) for Instance 6';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU" or waiting on "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'CPU Demand Series (Percentile) for Instance 7';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU" or waiting on "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'CPU Demand Series (Percentile) for Instance 8';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU" or waiting on "resmgr:cpu quantum"'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF vbaseline = 'baseline:&&sum_cpu_count.,'; 

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/

COL aas_cpu_peak       FOR 999999999999990.0 HEA "AAS CPU Peak";
COL aas_cpu_99_perc    FOR 999999999999990.0 HEA "AAS CPU 99% Percentile";
COL aas_cpu_95_perc    FOR 999999999999990.0 HEA "AAS CPU 95% Percentile";
COL aas_cpu_90_perc    FOR 999999999999990.0 HEA "AAS CPU 90% Percentile";
COL aas_cpu_75_perc    FOR 999999999999990.0 HEA "AAS CPU 75% Percentile";
COL aas_cpu_50_perc    FOR 999999999999990.0 HEA "AAS CPU 50% Percentile";

DEF title = 'CPU Consumption (AWR)';
DEF main_table = 'DBA_HIST_SYS_TIME_MODEL';
DEF abstract = 'Average Active Sessions (AAS) consuming CPU.'
DEF foot = 'DB CPU corresponds to Foreground processes. Consider Peak or high Percentile for sizing.'

BEGIN
  :sql_text := '
WITH
cpu_time AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       instance_number,
       SUM(value / 1e6) consumed_cpu,
       SUM(CASE stat_name WHEN ''background cpu time'' THEN value / 1e6 ELSE 0 END) background_cpu,
       SUM(CASE stat_name WHEN ''DB CPU'' THEN value / 1e6 ELSE 0 END) db_cpu
  FROM dba_hist_sys_time_model
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND stat_name IN (''background cpu time'', ''DB CPU'')
 GROUP BY
       snap_id,
       dbid,
       instance_number
),
cpu_time_extended AS (
SELECT /*+ &&sq_fact_hints. */
       h1.snap_id,
       h1.dbid,
       di.db_name,
       di.host_name,
       h1.instance_number,
       di.instance_name,
       s1.begin_interval_time,
       s1.end_interval_time,
       TO_CHAR(TRUNC(CAST(s1.begin_interval_time AS DATE), ''HH''), ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(TRUNC(CAST(s1.begin_interval_time AS DATE), ''HH'') + (1/24), ''YYYY-MM-DD HH24:MI'') end_time,
       ROUND((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 24 * 60 * 60) interval_secs,
       (h1.consumed_cpu - h0.consumed_cpu) consumed_cpu,
       (h1.background_cpu - h0.background_cpu) background_cpu,
       (h1.db_cpu - h0.db_cpu) db_cpu
  FROM cpu_time h0,
       cpu_time h1,
       dba_hist_snapshot s0,
       dba_hist_snapshot s1,
       dba_hist_database_instance di
 WHERE h1.snap_id = h0.snap_id + 1
   AND h1.dbid = h0.dbid
   AND h1.instance_number = h0.instance_number
   AND s0.snap_id = h0.snap_id
   AND s0.dbid = h0.dbid
   AND s0.instance_number = h0.instance_number
   AND s1.snap_id = h1.snap_id
   AND s1.dbid = h1.dbid
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.dbid = s0.dbid
   AND s1.instance_number = s0.instance_number
   AND s1.startup_time = s0.startup_time
   AND s1.begin_interval_time > (s0.begin_interval_time + (1 / (24 * 60))) /* filter out snaps apart < 1 min */
   AND di.dbid = s1.dbid
   AND di.instance_number = s1.instance_number
   AND di.startup_time = s1.startup_time
),
cpu_time_aas AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       db_name,
       host_name,
       instance_number,
       instance_name,
       begin_interval_time,
       end_interval_time,
       begin_time,
       end_time,
       interval_secs,
       consumed_cpu,
       background_cpu,
       db_cpu,
       ROUND(consumed_cpu / interval_secs, 3) aas_consumed_cpu,
       ROUND(background_cpu / interval_secs, 3) aas_background_cpu,
       ROUND(db_cpu / interval_secs, 3) aas_db_cpu
  FROM cpu_time_extended
),
sub_totals AS (
SELECT /*+ &&sq_fact_hints. */
       dbid,
       db_name,
       host_name,
       instance_number,
       instance_name,
       MAX(aas_consumed_cpu) peak_consumed_cpu,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY aas_consumed_cpu) perc_99_consumed_cpu,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY aas_consumed_cpu) perc_95_consumed_cpu,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY aas_consumed_cpu) perc_90_consumed_cpu,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY aas_consumed_cpu) perc_75_consumed_cpu,
       PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY aas_consumed_cpu) perc_50_consumed_cpu,
       ROUND(AVG(aas_consumed_cpu), 3) avg_consumed_cpu
  FROM cpu_time_aas
 GROUP BY
       dbid,
       db_name,
       host_name,
       instance_number,
       instance_name
 ORDER BY
       instance_number
)
SELECT dbid,
       db_name,
       host_name,
       instance_number,
       instance_name,
       peak_consumed_cpu aas_cpu_peak,
       perc_99_consumed_cpu aas_cpu_99_perc,
       perc_95_consumed_cpu aas_cpu_95_perc,
       perc_90_consumed_cpu aas_cpu_90_perc,
       perc_75_consumed_cpu aas_cpu_75_perc,
       perc_50_consumed_cpu aas_cpu_50_perc,
       avg_consumed_cpu aas_cpu_avg
  FROM sub_totals
 UNION ALL
SELECT MAX(dbid) dbid,
       MAX(db_name) db_name,
       NULL host_name,
       TO_NUMBER(NULL) instance_number,
       NULL instance_name,
       SUM(peak_consumed_cpu) aas_cpu_peak,
       SUM(perc_99_consumed_cpu) aas_cpu_99_perc,
       SUM(perc_95_consumed_cpu) aas_cpu_95_perc,
       SUM(perc_90_consumed_cpu) aas_cpu_90_perc,
       SUM(perc_75_consumed_cpu) aas_cpu_75_perc,
       SUM(perc_50_consumed_cpu) aas_cpu_50_perc,
       SUM(avg_consumed_cpu) aas_cpu_avg
  FROM sub_totals
';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF main_table = 'DBA_HIST_SYS_TIME_MODEL';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'AAS consuming CPU';
DEF tit_01 = 'Consumed CPU (Background + Foreground)';
DEF tit_02 = 'Background CPU';
DEF tit_03 = 'DB CPU (Foreground)';
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
cpu_time AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       instance_number,
       SUM(value / 1e6) consumed_cpu,
       SUM(CASE stat_name WHEN ''background cpu time'' THEN value / 1e6 ELSE 0 END) background_cpu,
       SUM(CASE stat_name WHEN ''DB CPU'' THEN value / 1e6 ELSE 0 END) db_cpu
  FROM dba_hist_sys_time_model
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND instance_number = @instance_number@
   AND stat_name IN (''background cpu time'', ''DB CPU'')
 GROUP BY
       snap_id,
       dbid,
       instance_number
),
cpu_time_extended AS (
SELECT /*+ &&sq_fact_hints. */
       h1.snap_id,
       h1.dbid,
       h1.instance_number,
       s1.begin_interval_time,
       s1.end_interval_time,
       TO_CHAR(TRUNC(CAST(s1.begin_interval_time AS DATE), ''HH''), ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(TRUNC(CAST(s1.begin_interval_time AS DATE), ''HH'') + (1/24), ''YYYY-MM-DD HH24:MI'') end_time,
       ROUND((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 24 * 60 * 60) interval_secs,
       (h1.consumed_cpu - h0.consumed_cpu) consumed_cpu,
       (h1.background_cpu - h0.background_cpu) background_cpu,
       (h1.db_cpu - h0.db_cpu) db_cpu
  FROM cpu_time h0,
       cpu_time h1,
       dba_hist_snapshot s0,
       dba_hist_snapshot s1
 WHERE h1.snap_id = h0.snap_id + 1
   AND h1.dbid = h0.dbid
   AND h1.instance_number = h0.instance_number
   AND s0.snap_id = h0.snap_id
   AND s0.dbid = h0.dbid
   AND s0.instance_number = h0.instance_number
   AND s1.snap_id = h1.snap_id
   AND s1.dbid = h1.dbid
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.dbid = s0.dbid
   AND s1.instance_number = s0.instance_number
   AND s1.startup_time = s0.startup_time
   AND s1.begin_interval_time > (s0.begin_interval_time + (1 / (24 * 60))) /* filter out snaps apart < 1 min */
),
cpu_time_aas AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       instance_number,
       begin_interval_time,
       end_interval_time,
       begin_time,
       end_time,
       interval_secs,
       consumed_cpu,
       background_cpu,
       db_cpu,
       ROUND(consumed_cpu / interval_secs, 3) aas_consumed_cpu,
       ROUND(background_cpu / interval_secs, 3) aas_background_cpu,
       ROUND(db_cpu / interval_secs, 3) aas_db_cpu
  FROM cpu_time_extended
),
peak_consumption_per_hour AS (
SELECT /*+ &&sq_fact_hints. */
       dbid,
       instance_number,
       begin_time,
       MAX(aas_consumed_cpu) aas_consumed_cpu
  FROM cpu_time_aas
 GROUP BY
       dbid,
       instance_number,
       begin_time
),
max_sample_per_hour_and_inst AS (
SELECT /*+ &&sq_fact_hints. */
       s.dbid,
       s.instance_number,
       s.begin_time,
       MIN(s.snap_id) snap_id
  FROM peak_consumption_per_hour m,
       cpu_time_aas s
 WHERE s.dbid = m.dbid
   AND s.instance_number = m.instance_number
   AND s.begin_time = m.begin_time
   AND s.aas_consumed_cpu = m.aas_consumed_cpu
 GROUP BY
       s.dbid,
       s.instance_number,
       s.begin_time
),
max_per_hour_and_inst AS (
SELECT /*+ &&sq_fact_hints. */
       s.snap_id,
       s.dbid,
       s.instance_number,
       s.begin_time,
       s.end_time,
       s.begin_interval_time,
       s.end_interval_time,
       s.consumed_cpu,
       s.background_cpu,
       s.db_cpu,
       s.aas_consumed_cpu,
       s.aas_background_cpu,
       s.aas_db_cpu
  FROM max_sample_per_hour_and_inst m,
       cpu_time_aas s
 WHERE s.dbid = m.dbid
   AND s.instance_number = m.instance_number
   AND s.begin_time = m.begin_time
   AND s.snap_id = m.snap_id
)
SELECT MIN(snap_id) snap_id,
       begin_time,
       end_time,
       SUM(aas_consumed_cpu) aas_consumed_cpu,
       SUM(aas_background_cpu) aas_background_cpu,
       SUM(aas_db_cpu) aas_db_cpu,
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
  FROM max_per_hour_and_inst
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
DEF title = 'CPU Consumption Series for Cluster';
DEF abstract = 'Average Active Sessions (AAS) consuming CPU.'
DEF foot = 'DB CPU corresponds to Foreground processes'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'instance_number');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF vbaseline = 'baseline:&&avg_cpu_count.,';

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'CPU Consumption Series for Instance 1';
DEF abstract = 'Average Active Sessions (AAS) consuming CPU.'
DEF foot = 'DB CPU corresponds to Foreground processes'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'CPU Consumption Series for Instance 2';
DEF abstract = 'Average Active Sessions (AAS) consuming CPU.'
DEF foot = 'DB CPU corresponds to Foreground processes'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'CPU Consumption Series for Instance 3';
DEF abstract = 'Average Active Sessions (AAS) consuming CPU.'
DEF foot = 'DB CPU corresponds to Foreground processes'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'CPU Consumption Series for Instance 4';
DEF abstract = 'Average Active Sessions (AAS) consuming CPU.'
DEF foot = 'DB CPU corresponds to Foreground processes'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'CPU Consumption Series for Instance 5';
DEF abstract = 'Average Active Sessions (AAS) consuming CPU.'
DEF foot = 'DB CPU corresponds to Foreground processes'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'CPU Consumption Series for Instance 6';
DEF abstract = 'Average Active Sessions (AAS) consuming CPU.'
DEF foot = 'DB CPU corresponds to Foreground processes'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'CPU Consumption Series for Instance 7';
DEF abstract = 'Average Active Sessions (AAS) consuming CPU.'
DEF foot = 'DB CPU corresponds to Foreground processes'
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'CPU Consumption Series for Instance 8';
DEF abstract = 'Average Active Sessions (AAS) consuming CPU.'
DEF foot = 'DB CPU corresponds to Foreground processes'
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
DEF foot = 'Consider "Giga Bytes (GB)" column for sizing.'
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
       GREATEST(par.pga_aggregate_target, pga_max.bytes) bytes
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
       GREATEST(par.memory_target, par.memory_max_target) + (6 * 1024 * 1024) bytes
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
       GREATEST(sga_target, sga_max_size) + pga.bytes + (6 * 1024 * 1024) bytes
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
       GREATEST(amm.bytes, asmm.bytes, no_mm.bytes) bytes,
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
       TO_NUMBER(NULL) instance_number,
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
DEF foot = 'Consider "Giga Bytes (GB)" column for sizing.'
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
       GREATEST(par.pga_aggregate_target, pga_max.bytes) bytes
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
       GREATEST(par.memory_target, par.memory_max_target) + (6 * 1024 * 1024) bytes
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
       GREATEST(sga_target, sga_max_size) + pga.bytes + (6 * 1024 * 1024) bytes
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
       GREATEST(amm.bytes, asmm.bytes, no_mm.bytes) bytes,
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
       TO_NUMBER(NULL) instance_number,
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

DEF title = 'IOPS and MBPS';
DEF main_table = 'DBA_HIST_SYSSTAT';
DEF abstract = 'I/O Operations per Second (IOPS) and I/O Mega Bytes per Second (MBPS). Includes Peak (max), percentiles and average for read (R), write (W) and read+write (RW) operations.'
DEF foot = 'Consider Peak or high Percentile for sizing.'
BEGIN
  :sql_text := '
WITH 
sysstat_io AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       instance_number,
       SUM(CASE WHEN stat_name = ''physical read total IO requests'' THEN value ELSE 0 END) r_reqs,
       SUM(CASE WHEN stat_name IN (''physical write total IO requests'', ''redo writes'') THEN value ELSE 0 END) w_reqs,
       SUM(CASE WHEN stat_name = ''physical read total bytes'' THEN value ELSE 0 END) r_bytes,
       SUM(CASE WHEN stat_name IN (''physical write total bytes'', ''redo size'') THEN value ELSE 0 END) w_bytes
  FROM dba_hist_sysstat
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND stat_name IN (''physical read total IO requests'', ''physical write total IO requests'', ''redo writes'', ''physical read total bytes'', ''physical write total bytes'', ''redo size'')
 GROUP BY
       snap_id,
       dbid,
       instance_number
),
snaps AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       instance_number,
       begin_interval_time,
       end_interval_time,
       ((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 24 * 60 * 60) elapsed_sec,
       startup_time
  FROM dba_hist_snapshot
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
),
rw_per_snap_and_inst AS (
SELECT /*+ &&sq_fact_hints. ORDERED */
       t1.snap_id,
       t1.dbid,
       t1.instance_number,
       di.instance_name,
       di.db_name,
       di.host_name,
       ROUND((t1.r_reqs - t0.r_reqs) / s1.elapsed_sec) r_iops,
       ROUND((t1.w_reqs - t0.w_reqs) / s1.elapsed_sec) w_iops,
       ROUND((t1.r_bytes - t0.r_bytes) / 1024 / 1024 / s1.elapsed_sec) r_mbps,
       ROUND((t1.w_bytes - t0.w_bytes) / 1024 / 1024 / s1.elapsed_sec) w_mbps
  FROM sysstat_io t0,
       sysstat_io t1,
       snaps s0,
       snaps s1,
       dba_hist_database_instance di
 WHERE t1.snap_id = t0.snap_id + 1
   AND t1.dbid = t0.dbid
   AND t1.instance_number = t0.instance_number
   AND s0.snap_id = t0.snap_id
   AND s0.dbid = t0.dbid
   AND s0.instance_number = t0.instance_number
   AND s1.snap_id = t1.snap_id
   AND s1.dbid = t1.dbid
   AND s1.instance_number = t1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
   AND s1.elapsed_sec > 60 -- ignore snaps too close
   AND di.dbid = s1.dbid
   AND di.instance_number = s1.instance_number
   AND di.startup_time = s1.startup_time
),
rw_per_snap_and_cluster AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       db_name,
       SUM(r_iops) r_iops,
       SUM(w_iops) w_iops,
       SUM(r_mbps) r_mbps,
       SUM(w_mbps) w_mbps
  FROM rw_per_snap_and_inst
 GROUP BY
       snap_id,
       dbid,
       db_name
),
rw_max_per_inst AS (
SELECT /*+ &&sq_fact_hints. */
       dbid,
       instance_number,
       instance_name,
       db_name,
       host_name,
       MAX(r_iops + w_iops) peak_rw_iops,
       MAX(r_mbps + w_mbps) peak_rw_mbps,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_99_rw_iops,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_99_rw_mbps,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_95_rw_iops,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_95_rw_mbps,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_90_rw_iops,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_90_rw_mbps,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_75_rw_iops,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_75_rw_mbps,
       PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_50_rw_iops,
       PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_50_rw_mbps,
       ROUND(AVG(r_iops + w_iops)) avg_rw_iops,
       ROUND(AVG(r_mbps + w_mbps)) avg_rw_mbps,
       ROUND(AVG(r_iops)) avg_r_iops,
       ROUND(AVG(w_iops)) avg_w_iops,
       ROUND(AVG(r_mbps)) avg_r_mbps,
       ROUND(AVG(w_mbps)) avg_w_mbps
  FROM rw_per_snap_and_inst
 GROUP BY
       dbid,
       instance_number,
       instance_name,
       db_name,
       host_name
),
rw_max_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */
       dbid,
       db_name,
       MAX(r_iops + w_iops) peak_rw_iops,
       MAX(r_mbps + w_mbps) peak_rw_mbps,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_99_rw_iops,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_99_rw_mbps,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_95_rw_iops,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_95_rw_mbps,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_90_rw_iops,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_90_rw_mbps,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_75_rw_iops,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_75_rw_mbps,
       PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY r_iops + w_iops) perc_50_rw_iops,
       PERCENTILE_DISC(0.50) WITHIN GROUP (ORDER BY r_mbps + w_mbps) perc_50_rw_mbps,
       ROUND(AVG(r_iops + w_iops)) avg_rw_iops,
       ROUND(AVG(r_mbps + w_mbps)) avg_rw_mbps,
       ROUND(AVG(r_iops)) avg_r_iops,
       ROUND(AVG(w_iops)) avg_w_iops,
       ROUND(AVG(r_mbps)) avg_r_mbps,
       ROUND(AVG(w_mbps)) avg_w_mbps
  FROM rw_per_snap_and_cluster
 GROUP BY
       dbid,
       db_name
),
peak_rw_iops_per_inst AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_iops peak_r_iops,
       r.w_iops peak_w_iops,
       m.peak_rw_iops
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_iops + r.w_iops) = m.peak_rw_iops
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
peak_rw_mbps_per_inst AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_mbps peak_r_mbps,
       r.w_mbps peak_w_mbps,
       m.peak_rw_mbps
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_mbps + r.w_mbps) = m.peak_rw_mbps
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_99_rw_iops_per_inst AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_iops perc_99_r_iops,
       r.w_iops perc_99_w_iops,
       m.perc_99_rw_iops
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_iops + r.w_iops) = m.perc_99_rw_iops
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_99_rw_mbps_per_inst AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_mbps perc_99_r_mbps,
       r.w_mbps perc_99_w_mbps,
       m.perc_99_rw_mbps
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_99_rw_mbps
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_95_rw_iops_per_inst AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_iops perc_95_r_iops,
       r.w_iops perc_95_w_iops,
       m.perc_95_rw_iops
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_iops + r.w_iops) = m.perc_95_rw_iops
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_95_rw_mbps_per_inst AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_mbps perc_95_r_mbps,
       r.w_mbps perc_95_w_mbps,
       m.perc_95_rw_mbps
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_95_rw_mbps
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_90_rw_iops_per_inst AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_iops perc_90_r_iops,
       r.w_iops perc_90_w_iops,
       m.perc_90_rw_iops
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_iops + r.w_iops) = m.perc_90_rw_iops
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_90_rw_mbps_per_inst AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_mbps perc_90_r_mbps,
       r.w_mbps perc_90_w_mbps,
       m.perc_90_rw_mbps
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_90_rw_mbps
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_75_rw_iops_per_inst AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_iops perc_75_r_iops,
       r.w_iops perc_75_w_iops,
       m.perc_75_rw_iops
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_iops + r.w_iops) = m.perc_75_rw_iops
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_75_rw_mbps_per_inst AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_mbps perc_75_r_mbps,
       r.w_mbps perc_75_w_mbps,
       m.perc_75_rw_mbps
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_75_rw_mbps
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_50_rw_iops_per_inst AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_iops perc_50_r_iops,
       r.w_iops perc_50_w_iops,
       m.perc_50_rw_iops
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_iops + r.w_iops) = m.perc_50_rw_iops
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
perc_50_rw_mbps_per_inst AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.instance_number,
       r.r_mbps perc_50_r_mbps,
       r.w_mbps perc_50_w_mbps,
       m.perc_50_rw_mbps
  FROM rw_per_snap_and_inst r,
       rw_max_per_inst m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_50_rw_mbps
   AND r.instance_number = m.instance_number
   AND r.dbid = m.dbid
),
peak_rw_iops_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.r_iops peak_r_iops,
       r.w_iops peak_w_iops,
       m.peak_rw_iops
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_iops + r.w_iops) = m.peak_rw_iops
   AND r.dbid = m.dbid
),
peak_rw_mbps_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.r_mbps peak_r_mbps,
       r.w_mbps peak_w_mbps,
       m.peak_rw_mbps
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_mbps + r.w_mbps) = m.peak_rw_mbps
   AND r.dbid = m.dbid
),
perc_99_rw_iops_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.r_iops perc_99_r_iops,
       r.w_iops perc_99_w_iops,
       m.perc_99_rw_iops
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_iops + r.w_iops) = m.perc_99_rw_iops
   AND r.dbid = m.dbid
),
perc_99_rw_mbps_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.r_mbps perc_99_r_mbps,
       r.w_mbps perc_99_w_mbps,
       m.perc_99_rw_mbps
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_99_rw_mbps
   AND r.dbid = m.dbid
),
perc_95_rw_iops_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.r_iops perc_95_r_iops,
       r.w_iops perc_95_w_iops,
       m.perc_95_rw_iops
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_iops + r.w_iops) = m.perc_95_rw_iops
   AND r.dbid = m.dbid
),
perc_95_rw_mbps_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.r_mbps perc_95_r_mbps,
       r.w_mbps perc_95_w_mbps,
       m.perc_95_rw_mbps
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_95_rw_mbps
   AND r.dbid = m.dbid
),
perc_90_rw_iops_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.r_iops perc_90_r_iops,
       r.w_iops perc_90_w_iops,
       m.perc_90_rw_iops
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_iops + r.w_iops) = m.perc_90_rw_iops
   AND r.dbid = m.dbid
),
perc_90_rw_mbps_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.r_mbps perc_90_r_mbps,
       r.w_mbps perc_90_w_mbps,
       m.perc_90_rw_mbps
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_90_rw_mbps
   AND r.dbid = m.dbid
),
perc_75_rw_iops_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.r_iops perc_75_r_iops,
       r.w_iops perc_75_w_iops,
       m.perc_75_rw_iops
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_iops + r.w_iops) = m.perc_75_rw_iops
   AND r.dbid = m.dbid
),
perc_75_rw_mbps_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.r_mbps perc_75_r_mbps,
       r.w_mbps perc_75_w_mbps,
       m.perc_75_rw_mbps
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_75_rw_mbps
   AND r.dbid = m.dbid
),
perc_50_rw_iops_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.r_iops perc_50_r_iops,
       r.w_iops perc_50_w_iops,
       m.perc_50_rw_iops
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_iops + r.w_iops) = m.perc_50_rw_iops
   AND r.dbid = m.dbid
),
perc_50_rw_mbps_per_cluster AS (
SELECT /*+ &&sq_fact_hints. */
       r.snap_id,
       r.dbid,
       r.r_mbps perc_50_r_mbps,
       r.w_mbps perc_50_w_mbps,
       m.perc_50_rw_mbps
  FROM rw_per_snap_and_cluster r,
       rw_max_per_cluster m
 WHERE (r.r_mbps + r.w_mbps) = m.perc_50_rw_mbps
   AND r.dbid = m.dbid
),
per_instance AS (
SELECT /*+ &&sq_fact_hints. */
       x.dbid,
       x.db_name,
       x.instance_number,
       x.instance_name,
       x.host_name,
       x.peak_rw_iops,
       (SELECT i.peak_r_iops FROM peak_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) peak_r_iops,
       (SELECT i.peak_w_iops FROM peak_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) peak_w_iops,
       x.peak_rw_mbps,       
       (SELECT m.peak_r_mbps FROM peak_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) peak_r_mbps,
       (SELECT m.peak_w_mbps FROM peak_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) peak_w_mbps,
       x.perc_99_rw_iops,
       (SELECT i.perc_99_r_iops FROM perc_99_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_99_r_iops,
       (SELECT i.perc_99_w_iops FROM perc_99_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_99_w_iops,
       x.perc_99_rw_mbps,       
       (SELECT m.perc_99_r_mbps FROM perc_99_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_99_r_mbps,
       (SELECT m.perc_99_w_mbps FROM perc_99_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_99_w_mbps,
       x.perc_95_rw_iops,
       (SELECT i.perc_95_r_iops FROM perc_95_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_95_r_iops,
       (SELECT i.perc_95_w_iops FROM perc_95_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_95_w_iops,
       x.perc_95_rw_mbps,       
       (SELECT m.perc_95_r_mbps FROM perc_95_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_95_r_mbps,
       (SELECT m.perc_95_w_mbps FROM perc_95_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_95_w_mbps,
       x.perc_90_rw_iops,
       (SELECT i.perc_90_r_iops FROM perc_90_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_90_r_iops,
       (SELECT i.perc_90_w_iops FROM perc_90_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_90_w_iops,
       x.perc_90_rw_mbps,       
       (SELECT m.perc_90_r_mbps FROM perc_90_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_90_r_mbps,
       (SELECT m.perc_90_w_mbps FROM perc_90_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_90_w_mbps,
       x.perc_75_rw_iops,
       (SELECT i.perc_75_r_iops FROM perc_75_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_75_r_iops,
       (SELECT i.perc_75_w_iops FROM perc_75_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_75_w_iops,
       x.perc_75_rw_mbps,       
       (SELECT m.perc_75_r_mbps FROM perc_75_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_75_r_mbps,
       (SELECT m.perc_75_w_mbps FROM perc_75_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_75_w_mbps,
       x.perc_50_rw_iops,
       (SELECT i.perc_50_r_iops FROM perc_50_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_50_r_iops,
       (SELECT i.perc_50_w_iops FROM perc_50_rw_iops_per_inst i WHERE i.dbid = x.dbid AND i.instance_number = x.instance_number AND ROWNUM = 1) perc_50_w_iops,
       x.perc_50_rw_mbps,       
       (SELECT m.perc_50_r_mbps FROM perc_50_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_50_r_mbps,
       (SELECT m.perc_50_w_mbps FROM perc_50_rw_mbps_per_inst m WHERE m.dbid = x.dbid AND m.instance_number = x.instance_number AND ROWNUM = 1) perc_50_w_mbps,
       x.avg_rw_iops,
       x.avg_r_iops,
       x.avg_w_iops,
       x.avg_rw_mbps,
       x.avg_r_mbps,
       x.avg_w_mbps
  FROM rw_max_per_inst x
 ORDER BY
       x.dbid,
       x.instance_number
),
per_cluster AS (
SELECT /*+ &&sq_fact_hints. */
       x.dbid,
       x.db_name,
       TO_NUMBER(NULL) instance_number,
       NULL instance_name,
       NULL host_name,
       x.peak_rw_iops,
       (SELECT i.peak_r_iops FROM peak_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) peak_r_iops,
       (SELECT i.peak_w_iops FROM peak_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) peak_w_iops,
       x.peak_rw_mbps,       
       (SELECT m.peak_r_mbps FROM peak_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) peak_r_mbps,
       (SELECT m.peak_w_mbps FROM peak_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) peak_w_mbps,
       x.perc_99_rw_iops,
       (SELECT i.perc_99_r_iops FROM perc_99_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_99_r_iops,
       (SELECT i.perc_99_w_iops FROM perc_99_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_99_w_iops,
       x.perc_99_rw_mbps,       
       (SELECT m.perc_99_r_mbps FROM perc_99_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_99_r_mbps,
       (SELECT m.perc_99_w_mbps FROM perc_99_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_99_w_mbps,
       x.perc_95_rw_iops,
       (SELECT i.perc_95_r_iops FROM perc_95_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_95_r_iops,
       (SELECT i.perc_95_w_iops FROM perc_95_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_95_w_iops,
       x.perc_95_rw_mbps,       
       (SELECT m.perc_95_r_mbps FROM perc_95_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_95_r_mbps,
       (SELECT m.perc_95_w_mbps FROM perc_95_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_95_w_mbps,
       x.perc_90_rw_iops,
       (SELECT i.perc_90_r_iops FROM perc_90_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_90_r_iops,
       (SELECT i.perc_90_w_iops FROM perc_90_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_90_w_iops,
       x.perc_90_rw_mbps,       
       (SELECT m.perc_90_r_mbps FROM perc_90_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_90_r_mbps,
       (SELECT m.perc_90_w_mbps FROM perc_90_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_90_w_mbps,
       x.perc_75_rw_iops,
       (SELECT i.perc_75_r_iops FROM perc_75_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_75_r_iops,
       (SELECT i.perc_75_w_iops FROM perc_75_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_75_w_iops,
       x.perc_75_rw_mbps,       
       (SELECT m.perc_75_r_mbps FROM perc_75_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_75_r_mbps,
       (SELECT m.perc_75_w_mbps FROM perc_75_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_75_w_mbps,
       x.perc_50_rw_iops,
       (SELECT i.perc_50_r_iops FROM perc_50_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_50_r_iops,
       (SELECT i.perc_50_w_iops FROM perc_50_rw_iops_per_cluster i WHERE i.dbid = x.dbid AND ROWNUM = 1) perc_50_w_iops,
       x.perc_50_rw_mbps,       
       (SELECT m.perc_50_r_mbps FROM perc_50_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_50_r_mbps,
       (SELECT m.perc_50_w_mbps FROM perc_50_rw_mbps_per_cluster m WHERE m.dbid = x.dbid AND ROWNUM = 1) perc_50_w_mbps,
       x.avg_rw_iops,
       x.avg_r_iops,
       x.avg_w_iops,
       x.avg_rw_mbps,
       x.avg_r_mbps,
       x.avg_w_mbps
  FROM rw_max_per_cluster x
)
SELECT * FROM per_instance
 UNION ALL
SELECT * FROM per_cluster
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
       snap_id,
       dbid,
       instance_number,
       SUM(CASE WHEN stat_name = ''physical read total IO requests'' THEN value ELSE 0 END) r_reqs,
       SUM(CASE WHEN stat_name IN (''physical write total IO requests'', ''redo writes'') THEN value ELSE 0 END) w_reqs,
       SUM(CASE WHEN stat_name = ''physical read total bytes'' THEN value ELSE 0 END) r_bytes,
       SUM(CASE WHEN stat_name IN (''physical write total bytes'', ''redo size'') THEN value ELSE 0 END) w_bytes
  FROM dba_hist_sysstat
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND instance_number = @instance_number@
   AND stat_name IN (''physical read total IO requests'', ''physical write total IO requests'', ''redo writes'', ''physical read total bytes'', ''physical write total bytes'', ''redo size'')
 GROUP BY
       snap_id,
       dbid,
       instance_number
),
snaps AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       instance_number,
       begin_interval_time,
       end_interval_time,
       ((CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)) * 24 * 60 * 60) elapsed_sec,
       startup_time
  FROM dba_hist_snapshot
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND instance_number = @instance_number@
),
rw_per_snap_and_inst AS (
SELECT /*+ &&sq_fact_hints. ORDERED */
       t1.snap_id,
       t1.dbid,
       t1.instance_number,
       s1.begin_interval_time,
       s1.end_interval_time,
       TO_CHAR(TRUNC(CAST(s1.begin_interval_time AS DATE), ''HH''), ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(TRUNC(CAST(s1.begin_interval_time AS DATE), ''HH'') + (1/24), ''YYYY-MM-DD HH24:MI'') end_time,
       ROUND((t1.r_reqs - t0.r_reqs) / s1.elapsed_sec) r_iops,
       ROUND((t1.w_reqs - t0.w_reqs) / s1.elapsed_sec) w_iops,
       ROUND((t1.r_bytes - t0.r_bytes) / POWER(2, 20) / s1.elapsed_sec) r_mbps,
       ROUND((t1.w_bytes - t0.w_bytes) / POWER(2, 20) / s1.elapsed_sec) w_mbps
  FROM sysstat_io t0,
       sysstat_io t1,
       snaps s0,
       snaps s1
 WHERE t1.snap_id = t0.snap_id + 1
   AND t1.dbid = t0.dbid
   AND t1.instance_number = t0.instance_number
   AND s0.snap_id = t0.snap_id
   AND s0.dbid = t0.dbid
   AND s0.instance_number = t0.instance_number
   AND s1.snap_id = t1.snap_id
   AND s1.dbid = t1.dbid
   AND s1.instance_number = t1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
   AND s1.elapsed_sec > 60 -- ignore snaps too close
),
max_rw_per_hour_and_inst AS ( 
SELECT /*+ &&sq_fact_hints. */
       dbid,
       instance_number,
       begin_time,
       MAX(r_iops + w_iops) rw_iops,
       MAX(r_mbps + w_mbps) rw_mbps
  FROM rw_per_snap_and_inst
 GROUP BY
       dbid,
       instance_number,
       begin_time
),
snap_per_hour_and_inst AS (
SELECT /*+ &&sq_fact_hints. */
       s.dbid,
       s.instance_number,
       s.begin_time,
       MIN(s.snap_id) snap_id
  FROM rw_per_snap_and_inst s,
       max_rw_per_hour_and_inst m
 WHERE s.dbid = m.dbid
   AND s.instance_number = m.instance_number
   AND s.begin_time = m.begin_time
   AND (s.@column2@ + s.@column3@) = m.@column1@
 GROUP BY
       s.dbid,
       s.instance_number,
       s.begin_time
),
max_per_hour_and_inst AS (
SELECT /*+ &&sq_fact_hints. */
       s.snap_id,
       s.dbid,
       s.instance_number,
       s.begin_time,
       s.end_time,
       s.begin_interval_time,
       s.end_interval_time,
       s.r_iops,
       s.w_iops,
       (s.r_iops + s.w_iops) rw_iops,
       s.r_mbps,
       s.w_mbps,
       (s.r_mbps + s.w_mbps) rw_mbps
  FROM rw_per_snap_and_inst s,
       snap_per_hour_and_inst m
 WHERE s.dbid = m.dbid
   AND s.instance_number = m.instance_number
   AND s.begin_time = m.begin_time
   AND s.snap_id = m.snap_id
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
  FROM max_per_hour_and_inst
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

/*****************************************************************************************/


