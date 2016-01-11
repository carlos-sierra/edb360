----------------------------------------------------------------------------------------
--
-- File name:   resources_requirements_awr.sql
--
-- Purpose:     Collect Database Requirements (CPU, Memory, Disk and IO Perf)
--
-- Author:      Carlos Sierra, Rodrigo Righetti
--
-- Version:     v1601 (2016/01/05)
--
-- Usage:       Collects Requirements from AWR and ASH views on databases with the 
--				Oracle Diagnostics Pack license, it also collect from Statspack starting
--				9i databases up to 12c. 				 
--				 
--              The output of this script can be used to feed a Sizing and Provisioning
--              application.
--
-- Example:     # cd esp_collect
--              # sqlplus / as sysdba
--              SQL> START sql/esp_master.sql
--
--  Notes:      Developed and tested on 12.1.0.2, 11.2.0.4, 11.2.0.3, 10.2.0.4
--             
---------------------------------------------------------------------------------------
--
DEF MAX_DAYS = '365';
SET TERM OFF ECHO OFF FEED OFF VER OFF HEA ON PAGES 100 COLSEP ' ' LIN 32767 TRIMS ON TRIM ON TI OFF TIMI OFF ARRAY 100 NUM 10 SQLBL ON BLO . RECSEP OFF;

-- get host name (up to 30, stop before first '.', no special characters)
COL rr_host_name_short NEW_V rr_host_name_short FOR A30;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST'), 1, 30)) rr_host_name_short FROM DUAL;
SELECT SUBSTR('&&rr_host_name_short.', 1, INSTR('&&rr_host_name_short..', '.') - 1) rr_host_name_short FROM DUAL;
SELECT TRANSLATE('&&rr_host_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') rr_host_name_short FROM DUAL;

-- get collection days
DEF collection_days = '&&MAX_DAYS.';
COL collection_days NEW_V collection_days;
SELECT NVL(TO_CHAR(LEAST(EXTRACT(DAY FROM retention), TO_NUMBER('&&MAX_DAYS.'))), '&&MAX_DAYS.') collection_days FROM dba_hist_wr_control;

ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_SORT = 'BINARY';
ALTER SESSION SET NLS_COMP = 'BINARY';

DEF use_on_10g = '--';
COL use_on_10g NEW_V use_on_10g;
SELECT '' use_on_10g FROM v$instance WHERE version LIKE '10%';

CL COL;
SPO res_requirements_&&rr_host_name_short..txt APP;

/*****************************************************************************************/

COL collection_days FOR A15;
SELECT '&&collection_days.' collection_days FROM DUAL
/

/*****************************************************************************************/

COL startup_time FOR A26;
COL short_host_name FOR A30;

PRO
PRO Database/Instance
PRO ~~~~~~~~~~~~~~~~~
SELECT h.dbid,				
       h.instance_number,	
       h.startup_time,		
       h.version,			
       h.db_name,			
       h.instance_name,
       TRANSLATE(LOWER(SUBSTR(SUBSTR(h.host_name, 1, INSTR(host_name, '.') - 1), 1, 30)),
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_')
       short_host_name,			
       platform_name	
  FROM dba_hist_database_instance h
  	   &&use_on_10g. , (select platform_name from v$database) pname
 WHERE CAST(h.startup_time AS DATE) > SYSDATE - &&collection_days.
 ORDER BY
       h.dbid,				
       h.instance_number,	
       h.startup_time
/

/*****************************************************************************************/
PRO
COL order_by NOPRI;
COL metric FOR A16 HEA "Metric";
COL instance_number FOR 9999 HEA "Inst|Num";
COL on_cpu FOR 999990.0 HEA "Active|Sessions|ON CPU";
COL on_cpu_and_resmgr FOR 9999990.0 HEA "Active|Sessions|ON CPU|or RESMGR";
COL resmgr_cpu_quantum FOR 999999990.0 HEA "Active|Sessions|ON RESMGR|CPU quantum";
COL begin_interval_time FOR A18 HEA "Begin Interval";
COL end_interval_time FOR A18 HEA "End Interval";
COL snap_shots FOR 99999 HEA "Snap|Shots";
COL days FOR 990.0 HEA "Days|Hist";
COL avg_snaps_per_day FOR 990.0 HEA "Avg|Snaps|per|Day";
COL min_sample_time FOR A18 HEA "Begin Interval";
COL max_sample_time FOR A18 HEA "End Interval";
COL samples FOR 9999999 HEA "Samples";
COL hours FOR 9990.0 HEA "Hours|Hist";
PRO
PRO CPU from ASH MEM
PRO ~~~~~~~~~~~~~~~~
WITH 
cpu_per_inst_and_sample AS (
SELECT inst_id,
       sample_id,
       COUNT(*) aas_on_cpu_and_resmgr,
       SUM(CASE session_state WHEN 'ON CPU' THEN 1 ELSE 0 END) aas_on_cpu,
       SUM(CASE event WHEN 'resmgr:cpu quantum' THEN 1 ELSE 0 END) aas_resmgr_cpu_quantum,
       MIN(sample_time) min_sample_time,
       MAX(sample_time) max_sample_time           
  FROM gv$active_session_history
 WHERE (session_state = 'ON CPU' OR event = 'resmgr:cpu quantum')
   AND CAST(sample_time AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       inst_id,
       sample_id
),
cpu_per_inst AS (
SELECT inst_id,
       MIN(min_sample_time)                                                   min_sample_time,
       MAX(max_sample_time)                                                   max_sample_time,
       COUNT(DISTINCT sample_id)                                              samples,        
       MAX(aas_on_cpu_and_resmgr)                                             aas_on_cpu_and_resmgr_max,
       MAX(aas_on_cpu)                                                        aas_on_cpu_max,
       MAX(aas_resmgr_cpu_quantum)                                            aas_resmgr_cpu_quantum_max,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)  aas_on_cpu_and_resmgr_9999,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY aas_on_cpu)             aas_on_cpu_9999,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_9999,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)   aas_on_cpu_and_resmgr_999,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY aas_on_cpu)              aas_on_cpu_999,
       PERCENTILE_DISC(0.999) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum)  aas_resmgr_cpu_quantum_999,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)    aas_on_cpu_and_resmgr_99,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY aas_on_cpu)               aas_on_cpu_99,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum)   aas_resmgr_cpu_quantum_99,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)    aas_on_cpu_and_resmgr_97,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY aas_on_cpu)               aas_on_cpu_97,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum)   aas_resmgr_cpu_quantum_97,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)    aas_on_cpu_and_resmgr_95,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY aas_on_cpu)               aas_on_cpu_95,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum)   aas_resmgr_cpu_quantum_95,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)    aas_on_cpu_and_resmgr_90,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY aas_on_cpu)               aas_on_cpu_90,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum)   aas_resmgr_cpu_quantum_90,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)    aas_on_cpu_and_resmgr_75,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY aas_on_cpu)               aas_on_cpu_75,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum)   aas_resmgr_cpu_quantum_75,
       MEDIAN(aas_on_cpu_and_resmgr)                                          aas_on_cpu_and_resmgr_med,
       MEDIAN(aas_on_cpu)                                                     aas_on_cpu_med,
       MEDIAN(aas_resmgr_cpu_quantum)                                         aas_resmgr_cpu_quantum_med,
       ROUND(AVG(aas_on_cpu_and_resmgr), 1)                                   aas_on_cpu_and_resmgr_avg,
       ROUND(AVG(aas_on_cpu), 1)                                              aas_on_cpu_avg,
       ROUND(AVG(aas_resmgr_cpu_quantum), 1)                                  aas_resmgr_cpu_quantum_avg
  FROM cpu_per_inst_and_sample
 GROUP BY
       inst_id
),
cpu_per_inst_and_perc AS (
SELECT 01 order_by, 'Maximum or peak' metric, inst_id, aas_on_cpu_max  on_cpu, aas_on_cpu_and_resmgr_max  on_cpu_and_resmgr, aas_resmgr_cpu_quantum_max  resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
UNION ALL
SELECT 02 order_by, '99.99th percntl' metric, inst_id, aas_on_cpu_9999 on_cpu, aas_on_cpu_and_resmgr_9999 on_cpu_and_resmgr, aas_resmgr_cpu_quantum_9999 resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
UNION ALL
SELECT 03 order_by, '99.9th percentl' metric, inst_id, aas_on_cpu_999  on_cpu, aas_on_cpu_and_resmgr_999  on_cpu_and_resmgr, aas_resmgr_cpu_quantum_999  resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
UNION ALL
SELECT 04 order_by, '99th percentile' metric, inst_id, aas_on_cpu_99   on_cpu, aas_on_cpu_and_resmgr_99   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_99   resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
UNION ALL
SELECT 05 order_by, '97th percentile' metric, inst_id, aas_on_cpu_97   on_cpu, aas_on_cpu_and_resmgr_97   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_97   resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
UNION ALL
SELECT 06 order_by, '95th percentile' metric, inst_id, aas_on_cpu_95   on_cpu, aas_on_cpu_and_resmgr_95   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_95   resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
UNION ALL
SELECT 07 order_by, '90th percentile' metric, inst_id, aas_on_cpu_90   on_cpu, aas_on_cpu_and_resmgr_90   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_90   resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
UNION ALL
SELECT 08 order_by, '75th percentile' metric, inst_id, aas_on_cpu_75   on_cpu, aas_on_cpu_and_resmgr_75   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_75   resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
UNION ALL
SELECT 09 order_by, 'Median'          metric, inst_id, aas_on_cpu_med  on_cpu, aas_on_cpu_and_resmgr_med  on_cpu_and_resmgr, aas_resmgr_cpu_quantum_med  resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
UNION ALL
SELECT 10 order_by, 'Average'         metric, inst_id, aas_on_cpu_avg  on_cpu, aas_on_cpu_and_resmgr_avg  on_cpu_and_resmgr, aas_resmgr_cpu_quantum_avg  resmgr_cpu_quantum, min_sample_time, max_sample_time, samples FROM cpu_per_inst
),
cpu_per_db_and_perc AS (
SELECT order_by,
       metric,
       TO_NUMBER(NULL) inst_id,
       SUM(on_cpu) on_cpu,
       SUM(on_cpu_and_resmgr) on_cpu_and_resmgr,
       SUM(resmgr_cpu_quantum) resmgr_cpu_quantum,
       MIN(min_sample_time) min_sample_time,
       MAX(max_sample_time) max_sample_time,
       SUM(samples) samples
  FROM cpu_per_inst_and_perc
 GROUP BY
       order_by,
       metric
)
SELECT order_by,
       metric,
       inst_id,
       on_cpu,
       on_cpu_and_resmgr,
       resmgr_cpu_quantum,
       TO_CHAR(CAST(min_sample_time AS DATE), 'YYYY-MM-DD HH24:MI') min_sample_time,
       TO_CHAR(CAST(max_sample_time AS DATE), 'YYYY-MM-DD HH24:MI') max_sample_time,
       samples,
       ROUND((CAST(max_sample_time AS DATE) - CAST(min_sample_time AS DATE)) * 24, 1) hours
  FROM cpu_per_inst_and_perc
 UNION ALL
SELECT order_by,
       metric,
       inst_id,
       on_cpu,
       on_cpu_and_resmgr,
       resmgr_cpu_quantum,
       TO_CHAR(CAST(min_sample_time AS DATE), 'YYYY-MM-DD HH24:MI') min_sample_time,
       TO_CHAR(CAST(max_sample_time AS DATE), 'YYYY-MM-DD HH24:MI') max_sample_time,
       samples,
       ROUND((CAST(max_sample_time AS DATE) - CAST(min_sample_time AS DATE)) * 24, 1) hours
  FROM cpu_per_db_and_perc
 ORDER BY
       order_by,
       inst_id NULLS LAST
/
PRO
PRO
PRO CPU from ASH AWR
PRO ~~~~~~~~~~~~~~~~
WITH 
cpu_per_inst_and_sample AS (
SELECT h.snap_id,
       h.dbid,
       h.instance_number,
       h.sample_id,
       COUNT(*) aas_on_cpu_and_resmgr,
       SUM(CASE h.session_state WHEN 'ON CPU' THEN 1 ELSE 0 END) aas_on_cpu,
       SUM(CASE h.event WHEN 'resmgr:cpu quantum' THEN 1 ELSE 0 END) aas_resmgr_cpu_quantum,
       MIN(s.begin_interval_time) begin_interval_time,
       MAX(s.end_interval_time) end_interval_time      
  FROM dba_hist_active_sess_history h,
       dba_hist_snapshot s
 WHERE (h.session_state = 'ON CPU' OR h.event = 'resmgr:cpu quantum')
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND CAST(s.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       h.snap_id,
       h.dbid,
       h.instance_number,
       h.sample_id
),
cpu_per_db_and_inst AS (
SELECT dbid,
       instance_number,
       MIN(begin_interval_time)                                               begin_interval_time,
       MAX(end_interval_time)                                                 end_interval_time,
       COUNT(DISTINCT snap_id)                                                snap_shots,        
       MAX(aas_on_cpu_and_resmgr)                                             aas_on_cpu_and_resmgr_max,
       MAX(aas_on_cpu)                                                        aas_on_cpu_max,
       MAX(aas_resmgr_cpu_quantum)                                            aas_resmgr_cpu_quantum_max,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)  aas_on_cpu_and_resmgr_9999,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY aas_on_cpu)             aas_on_cpu_9999,
       PERCENTILE_DISC(0.9999) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_9999,
       PERCENTILE_DISC(0.9990) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)  aas_on_cpu_and_resmgr_999,
       PERCENTILE_DISC(0.9990) WITHIN GROUP (ORDER BY aas_on_cpu)             aas_on_cpu_999,
       PERCENTILE_DISC(0.9990) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_999,
       PERCENTILE_DISC(0.9900) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)  aas_on_cpu_and_resmgr_99,
       PERCENTILE_DISC(0.9900) WITHIN GROUP (ORDER BY aas_on_cpu)             aas_on_cpu_99,
       PERCENTILE_DISC(0.9900) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_99,
       PERCENTILE_DISC(0.9700) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)  aas_on_cpu_and_resmgr_97,
       PERCENTILE_DISC(0.9700) WITHIN GROUP (ORDER BY aas_on_cpu)             aas_on_cpu_97,
       PERCENTILE_DISC(0.9700) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_97,
       PERCENTILE_DISC(0.9500) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)  aas_on_cpu_and_resmgr_95,
       PERCENTILE_DISC(0.9500) WITHIN GROUP (ORDER BY aas_on_cpu)             aas_on_cpu_95,
       PERCENTILE_DISC(0.9500) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_95,
       PERCENTILE_DISC(0.9000) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)  aas_on_cpu_and_resmgr_90,
       PERCENTILE_DISC(0.9000) WITHIN GROUP (ORDER BY aas_on_cpu)             aas_on_cpu_90,
       PERCENTILE_DISC(0.9000) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_90,
       PERCENTILE_DISC(0.7500) WITHIN GROUP (ORDER BY aas_on_cpu_and_resmgr)  aas_on_cpu_and_resmgr_75,
       PERCENTILE_DISC(0.7500) WITHIN GROUP (ORDER BY aas_on_cpu)             aas_on_cpu_75,
       PERCENTILE_DISC(0.7500) WITHIN GROUP (ORDER BY aas_resmgr_cpu_quantum) aas_resmgr_cpu_quantum_75,
       MEDIAN(aas_on_cpu_and_resmgr)                                          aas_on_cpu_and_resmgr_med,
       MEDIAN(aas_on_cpu)                                                     aas_on_cpu_med,
       MEDIAN(aas_resmgr_cpu_quantum)                                         aas_resmgr_cpu_quantum_med,
       ROUND(AVG(aas_on_cpu_and_resmgr), 1)                                   aas_on_cpu_and_resmgr_avg,
       ROUND(AVG(aas_on_cpu), 1)                                              aas_on_cpu_avg,
       ROUND(AVG(aas_resmgr_cpu_quantum), 1)                                  aas_resmgr_cpu_quantum_avg
  FROM cpu_per_inst_and_sample
 GROUP BY
       dbid,
       instance_number
),
cpu_per_inst_and_perc AS (
SELECT dbid, 01 order_by, 'Maximum or peak' metric, instance_number, aas_on_cpu_max  on_cpu, aas_on_cpu_and_resmgr_max  on_cpu_and_resmgr, aas_resmgr_cpu_quantum_max  resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 02 order_by, '99.99th percntl' metric, instance_number, aas_on_cpu_9999 on_cpu, aas_on_cpu_and_resmgr_9999 on_cpu_and_resmgr, aas_resmgr_cpu_quantum_9999 resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 03 order_by, '99.9th percentl' metric, instance_number, aas_on_cpu_999  on_cpu, aas_on_cpu_and_resmgr_999  on_cpu_and_resmgr, aas_resmgr_cpu_quantum_999  resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 04 order_by, '99th percentile' metric, instance_number, aas_on_cpu_99   on_cpu, aas_on_cpu_and_resmgr_99   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_99   resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 05 order_by, '97th percentile' metric, instance_number, aas_on_cpu_97   on_cpu, aas_on_cpu_and_resmgr_97   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_97   resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 06 order_by, '95th percentile' metric, instance_number, aas_on_cpu_95   on_cpu, aas_on_cpu_and_resmgr_95   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_95   resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 07 order_by, '90th percentile' metric, instance_number, aas_on_cpu_90   on_cpu, aas_on_cpu_and_resmgr_90   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_90   resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 08 order_by, '75th percentile' metric, instance_number, aas_on_cpu_75   on_cpu, aas_on_cpu_and_resmgr_75   on_cpu_and_resmgr, aas_resmgr_cpu_quantum_75   resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 09 order_by, 'Median'          metric, instance_number, aas_on_cpu_med  on_cpu, aas_on_cpu_and_resmgr_med  on_cpu_and_resmgr, aas_resmgr_cpu_quantum_med  resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
UNION ALL
SELECT dbid, 10 order_by, 'Average'         metric, instance_number, aas_on_cpu_avg  on_cpu, aas_on_cpu_and_resmgr_avg  on_cpu_and_resmgr, aas_resmgr_cpu_quantum_avg  resmgr_cpu_quantum, begin_interval_time, end_interval_time, snap_shots FROM cpu_per_db_and_inst
),
cpu_per_db_and_perc AS (
SELECT dbid,
       order_by,
       metric,
       TO_NUMBER(NULL) instance_number,
       SUM(on_cpu) on_cpu,
       SUM(on_cpu_and_resmgr) on_cpu_and_resmgr,
       SUM(resmgr_cpu_quantum) resmgr_cpu_quantum,
       MIN(begin_interval_time) begin_interval_time,
       MAX(end_interval_time) end_interval_time,
       SUM(snap_shots) snap_shots
  FROM cpu_per_inst_and_perc
 GROUP BY
       dbid,
       order_by,
       metric
)
SELECT dbid,
       order_by,
       metric,
       instance_number,
       on_cpu,
       on_cpu_and_resmgr,
       resmgr_cpu_quantum,
       TO_CHAR(CAST(begin_interval_time AS DATE), 'YYYY-MM-DD HH24:MI') begin_interval_time,
       TO_CHAR(CAST(end_interval_time AS DATE), 'YYYY-MM-DD HH24:MI') end_interval_time,
       snap_shots,
       ROUND(CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE), 1) days,
       ROUND(snap_shots / (CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)), 1) avg_snaps_per_day
  FROM cpu_per_inst_and_perc
 UNION ALL
SELECT dbid,
       order_by,
       metric,
       instance_number,
       on_cpu,
       on_cpu_and_resmgr,
       resmgr_cpu_quantum,
       TO_CHAR(CAST(begin_interval_time AS DATE), 'YYYY-MM-DD HH24:MI') begin_interval_time,
       TO_CHAR(CAST(end_interval_time AS DATE), 'YYYY-MM-DD HH24:MI') end_interval_time,
       snap_shots,
       ROUND(CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE), 1) days,
       ROUND(snap_shots / (CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)), 1) avg_snaps_per_day
  FROM cpu_per_db_and_perc
 ORDER BY
       dbid,
       order_by,
       instance_number NULLS LAST
/

/*****************************************************************************************/
PRO
COL mem_gb FOR 99990.0 HEA "Mem GB";
COL sga_gb FOR 99990.0 HEA "SGA GB";
COL pga_gb FOR 99990.0 HEA "PGA GB";
PRO
PRO Memory from AWR
PRO ~~~~~~~~~~~~~~~
WITH mem_per_inst_and_snap AS (
SELECT s.snap_id,
       s.dbid,
       s.instance_number,
       SUM(g.value) sga_bytes,
       MAX(p.value) pga_bytes,
       SUM(g.value) + MAX(p.value) mem_bytes,
       MIN(s.begin_interval_time) begin_interval_time,
       MAX(s.end_interval_time) end_interval_time      
  FROM dba_hist_snapshot s,
       dba_hist_sga g,
       dba_hist_pgastat p
 WHERE CAST(s.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
   AND g.snap_id = s.snap_id
   AND g.dbid = s.dbid
   AND g.instance_number = s.instance_number
   AND p.snap_id = s.snap_id
   AND p.dbid = s.dbid
   AND p.instance_number = s.instance_number
   AND p.name = 'total PGA allocated'
 GROUP BY
       s.snap_id,
       s.dbid,
       s.instance_number
),
mem_per_db_and_inst AS (
SELECT dbid,
       instance_number,
       MIN(begin_interval_time)                                begin_interval_time,
       MAX(end_interval_time)                                  end_interval_time,
       COUNT(DISTINCT snap_id)                                 snap_shots,        
       MAX(mem_bytes)                                          mem_bytes_max,
       MAX(sga_bytes)                                          sga_bytes_max,
       MAX(pga_bytes)                                          pga_bytes_max,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY mem_bytes) mem_bytes_99,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY sga_bytes) sga_bytes_99,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY pga_bytes) pga_bytes_99,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY mem_bytes) mem_bytes_97,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY sga_bytes) sga_bytes_97,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY pga_bytes) pga_bytes_97,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY mem_bytes) mem_bytes_95,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY sga_bytes) sga_bytes_95,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY pga_bytes) pga_bytes_95,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY mem_bytes) mem_bytes_90,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY sga_bytes) sga_bytes_90,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY pga_bytes) pga_bytes_90,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY mem_bytes) mem_bytes_75,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY sga_bytes) sga_bytes_75,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY pga_bytes) pga_bytes_75,
       MEDIAN(mem_bytes)                                       mem_bytes_med,
       MEDIAN(sga_bytes)                                       sga_bytes_med,
       MEDIAN(pga_bytes)                                       pga_bytes_med,
       ROUND(AVG(mem_bytes), 1)                                mem_bytes_avg,
       ROUND(AVG(sga_bytes), 1)                                sga_bytes_avg,
       ROUND(AVG(pga_bytes), 1)                                pga_bytes_avg
  FROM mem_per_inst_and_snap
 GROUP BY
       dbid,
       instance_number
),
mem_per_inst_and_perc AS (
SELECT dbid, 01 order_by, 'Maximum or peak' metric, instance_number, mem_bytes_max mem_bytes, sga_bytes_max sga_bytes, pga_bytes_max pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
 UNION ALL
SELECT dbid, 02 order_by, '99th percentile' metric, instance_number, mem_bytes_99  mem_bytes, sga_bytes_99  sga_bytes, pga_bytes_99  pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
 UNION ALL
SELECT dbid, 03 order_by, '97th percentile' metric, instance_number, mem_bytes_97  mem_bytes, sga_bytes_97  sga_bytes, pga_bytes_97  pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
 UNION ALL
SELECT dbid, 04 order_by, '95th percentile' metric, instance_number, mem_bytes_95  mem_bytes, sga_bytes_95  sga_bytes, pga_bytes_95  pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
 UNION ALL
SELECT dbid, 05 order_by, '90th percentile' metric, instance_number, mem_bytes_90  mem_bytes, sga_bytes_90  sga_bytes, pga_bytes_90  pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
 UNION ALL
SELECT dbid, 06 order_by, '75th percentile' metric, instance_number, mem_bytes_75  mem_bytes, sga_bytes_75  sga_bytes, pga_bytes_75  pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
 UNION ALL
SELECT dbid, 07 order_by, 'Median'          metric, instance_number, mem_bytes_med mem_bytes, sga_bytes_med sga_bytes, pga_bytes_med pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
 UNION ALL
SELECT dbid, 08 order_by, 'Average'         metric, instance_number, mem_bytes_avg mem_bytes, sga_bytes_avg sga_bytes, pga_bytes_avg pga_bytes, begin_interval_time, end_interval_time, snap_shots FROM mem_per_db_and_inst
),
mem_per_db_and_perc AS (
SELECT dbid,
       order_by,
       metric,
       TO_NUMBER(NULL) instance_number,
       SUM(mem_bytes) mem_bytes,
       SUM(sga_bytes) sga_bytes,
       SUM(pga_bytes) pga_bytes,
       MIN(begin_interval_time) begin_interval_time,
       MAX(end_interval_time) end_interval_time,
       SUM(snap_shots) snap_shots
  FROM mem_per_inst_and_perc
 GROUP BY
       dbid,
       order_by,
       metric
)
SELECT dbid,
       order_by,
       metric,
       instance_number,
       ROUND(mem_bytes / POWER(2, 30), 1) mem_gb,
       ROUND(sga_bytes / POWER(2, 30), 1) sga_gb,
       ROUND(pga_bytes / POWER(2, 30), 1) pga_gb,
       TO_CHAR(CAST(begin_interval_time AS DATE), 'YYYY-MM-DD HH24:MI') begin_interval_time,
       TO_CHAR(CAST(end_interval_time AS DATE), 'YYYY-MM-DD HH24:MI') end_interval_time,
       snap_shots,
       ROUND(CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE), 1) days,
       ROUND(snap_shots / (CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)), 1) avg_snaps_per_day
  FROM mem_per_inst_and_perc
 UNION ALL
SELECT dbid,
       order_by,
       metric,
       instance_number,
       ROUND(mem_bytes / POWER(2, 30), 1) mem_gb,
       ROUND(sga_bytes / POWER(2, 30), 1) sga_gb,
       ROUND(pga_bytes / POWER(2, 30), 1) pga_gb,
       TO_CHAR(CAST(begin_interval_time AS DATE), 'YYYY-MM-DD HH24:MI') begin_interval_time,
       TO_CHAR(CAST(end_interval_time AS DATE), 'YYYY-MM-DD HH24:MI') end_interval_time,
       snap_shots,
       ROUND(CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE), 1) days,
       ROUND(snap_shots / (CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)), 1) avg_snaps_per_day
  FROM mem_per_db_and_perc
 ORDER BY
       dbid,
       order_by,
       instance_number NULLS LAST
/

/*****************************************************************************************/
PRO
COL file_type FOR A10 HEA "File Type";
COL disk_tb FOR 999,990.0 HEA "Disk TB";
COL display FOR A10 HEA "Disk Space";
PRO
PRO Disk Space
PRO ~~~~~~~~~~
WITH 
sizes AS (
SELECT 'Data' file_type,
       SUM(bytes) bytes
  FROM v$datafile
 UNION ALL
SELECT 'Temp' file_type,
       SUM(bytes) bytes
  FROM v$tempfile
 UNION ALL
SELECT 'Log' file_type,
       SUM(bytes) * MAX(members) bytes
  FROM v$log
 UNION ALL
SELECT 'Control' file_type,
       SUM(block_size * file_size_blks) bytes
  FROM v$controlfile
),
dbsize AS (
SELECT 'Total' file_type,
       SUM(bytes) bytes
  FROM sizes
)
SELECT s.file_type,
       ROUND(s.bytes/POWER(2,40),1) disk_tb,
       CASE 
       WHEN s.bytes > POWER(2,50) THEN ROUND(s.bytes/POWER(2,50),1)||' PB'
       WHEN s.bytes > POWER(2,40) THEN ROUND(s.bytes/POWER(2,40),1)||' TB'
       WHEN s.bytes > POWER(2,30) THEN ROUND(s.bytes/POWER(2,30),1)||' GB'
       WHEN s.bytes > POWER(2,20) THEN ROUND(s.bytes/POWER(2,20),1)||' MB'
       WHEN s.bytes > POWER(2,10) THEN ROUND(s.bytes/POWER(2,10),1)||' KB'
       WHEN s.bytes > 0 THEN s.bytes||' B' END display
  FROM sizes s
 UNION ALL
SELECT s.file_type,
       ROUND(s.bytes/POWER(2,40),1) disk_tb,
       CASE 
       WHEN s.bytes > POWER(2,50) THEN ROUND(s.bytes/POWER(2,50),1)||' PB'
       WHEN s.bytes > POWER(2,40) THEN ROUND(s.bytes/POWER(2,40),1)||' TB'
       WHEN s.bytes > POWER(2,30) THEN ROUND(s.bytes/POWER(2,30),1)||' GB'
       WHEN s.bytes > POWER(2,20) THEN ROUND(s.bytes/POWER(2,20),1)||' MB'
       WHEN s.bytes > POWER(2,10) THEN ROUND(s.bytes/POWER(2,10),1)||' KB'
       WHEN s.bytes > 0 THEN s.bytes||' B' END display
  FROM dbsize s
/

/*****************************************************************************************/
PRO
PRO
PRO IO Throughput
PRO ~~~~~~~~~~~~~
WITH
sysstat_io AS (
SELECT h.snap_id,
       h.dbid,
       h.instance_number,
       SUM(CASE WHEN h.stat_name = 'physical read total IO requests' THEN value ELSE 0 END) r_reqs,
       SUM(CASE WHEN h.stat_name IN ('physical write total IO requests', 'redo writes') THEN value ELSE 0 END) w_reqs,
       SUM(CASE WHEN h.stat_name = 'physical read total bytes' THEN value ELSE 0 END) r_bytes,
       SUM(CASE WHEN h.stat_name IN ('physical write total bytes', 'redo size') THEN value ELSE 0 END) w_bytes
  FROM dba_hist_sysstat h,
       dba_hist_snapshot s
 WHERE h.stat_name IN ('physical read total IO requests', 'physical write total IO requests', 'redo writes', 'physical read total bytes', 'physical write total bytes', 'redo size')
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND CAST(s.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       h.snap_id,
       h.dbid,
       h.instance_number
),
io_per_inst_and_snap_id AS (
SELECT h1.dbid,
       h1.instance_number,
       h1.snap_id,
       (h1.r_reqs - h0.r_reqs) r_reqs,
       (h1.w_reqs - h0.w_reqs) w_reqs,
       (h1.r_bytes - h0.r_bytes) r_bytes,
       (h1.w_bytes - h0.w_bytes) w_bytes,
       (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 elapsed_sec,
       CAST(s1.begin_interval_time AS DATE) begin_interval_time,
       CAST(s1.end_interval_time AS DATE) end_interval_time        
  FROM sysstat_io h0,
       dba_hist_snapshot s0,
       sysstat_io h1,
       dba_hist_snapshot s1
 WHERE CAST(s0.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
   AND s0.snap_id = h0.snap_id
   AND s0.dbid = h0.dbid
   AND s0.instance_number = h0.instance_number
   AND h1.snap_id = h0.snap_id + 1
   AND h1.dbid = h0.dbid
   AND h1.instance_number = h0.instance_number
   AND CAST(s1.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
   AND s1.snap_id = h1.snap_id
   AND s1.dbid = h1.dbid
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.dbid = s0.dbid
   AND s1.instance_number = s0.instance_number
   AND s1.startup_time = s0.startup_time
),
io_per_snap_id AS (
SELECT dbid,
       snap_id,
       SUM(r_reqs) r_reqs,
       SUM(w_reqs) w_reqs,
       SUM(r_bytes) r_bytes,
       SUM(w_bytes) w_bytes,
       AVG(elapsed_sec) elapsed_sec,
       MIN(begin_interval_time) begin_interval_time,
       MAX(end_interval_time) end_interval_time
  FROM io_per_inst_and_snap_id
 GROUP BY
       dbid,
       snap_id
),
io_per_inst AS (
SELECT dbid,
       instance_number,
       MIN(begin_interval_time) begin_interval_time,
       MAX(end_interval_time) end_interval_time,
       COUNT(DISTINCT snap_id) snap_shots,        
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
       ROUND(MEDIAN((r_reqs + w_reqs) / elapsed_sec)) rw_iops_med,
       ROUND(MEDIAN(r_reqs / elapsed_sec)) r_iops_med,
       ROUND(MEDIAN(w_reqs / elapsed_sec)) w_iops_med,
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
       ROUND(MEDIAN((r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_med,
       ROUND(MEDIAN(r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_med,
       ROUND(MEDIAN(w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_med,
       ROUND(AVG((r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_avg,
       ROUND(AVG(r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_avg,
       ROUND(AVG(w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_avg
  FROM io_per_inst_and_snap_id
 WHERE elapsed_sec > 60 -- ignore snaps too close
 GROUP BY
       dbid,
       instance_number
),
io_per_cluster AS ( -- combined
SELECT dbid,
       TO_NUMBER(NULL) instance_number,
       MIN(begin_interval_time) begin_interval_time,
       MAX(end_interval_time) end_interval_time,
       COUNT(DISTINCT snap_id) snap_shots,        
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
       ROUND(MEDIAN((r_reqs + w_reqs) / elapsed_sec)) rw_iops_med,
       ROUND(MEDIAN(r_reqs / elapsed_sec)) r_iops_med,
       ROUND(MEDIAN(w_reqs / elapsed_sec)) w_iops_med,
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
       ROUND(MEDIAN((r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_med,
       ROUND(MEDIAN(r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_med,
       ROUND(MEDIAN(w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_med,
       ROUND(AVG((r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec)) rw_mbps_avg,
       ROUND(AVG(r_bytes / POWER(2, 20) / elapsed_sec)) r_mbps_avg,
       ROUND(AVG(w_bytes / POWER(2, 20) / elapsed_sec)) w_mbps_avg
  FROM io_per_snap_id
 WHERE elapsed_sec > 60 -- ignore snaps too close
 GROUP BY
       dbid
),
io_per_inst_or_cluster AS (
SELECT dbid, 01 order_by, 'Maximum or peak' metric, instance_number, rw_iops_peak rw_iops, r_iops_peak r_iops, w_iops_peak w_iops, rw_mbps_peak rw_mbps, r_mbps_peak r_mbps, w_mbps_peak w_mbps, begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 02 order_by, '99.9th percentl' metric, instance_number, rw_iops_999 rw_iops,  r_iops_999 r_iops,  w_iops_999 w_iops,  rw_mbps_999 rw_mbps,  r_mbps_999 r_mbps,  w_mbps_999 w_mbps,  begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 03 order_by, '99th percentile' metric, instance_number, rw_iops_99 rw_iops,   r_iops_99 r_iops,   w_iops_99 w_iops,   rw_mbps_99 rw_mbps,   r_mbps_99 r_mbps,   w_mbps_99 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 04 order_by, '97th percentile' metric, instance_number, rw_iops_97 rw_iops,   r_iops_97 r_iops,   w_iops_97 w_iops,   rw_mbps_97 rw_mbps,   r_mbps_97 r_mbps,   w_mbps_97 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 05 order_by, '95th percentile' metric, instance_number, rw_iops_95 rw_iops,   r_iops_95 r_iops,   w_iops_95 w_iops,   rw_mbps_95 rw_mbps,   r_mbps_95 r_mbps,   w_mbps_95 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 06 order_by, '90th percentile' metric, instance_number, rw_iops_90 rw_iops,   r_iops_90 r_iops,   w_iops_90 w_iops,   rw_mbps_90 rw_mbps,   r_mbps_90 r_mbps,   w_mbps_90 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 07 order_by, '75th percentile' metric, instance_number, rw_iops_75 rw_iops,   r_iops_75 r_iops,   w_iops_75 w_iops,   rw_mbps_75 rw_mbps,   r_mbps_75 r_mbps,   w_mbps_75 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 08 order_by, 'Median'          metric, instance_number, rw_iops_med rw_iops,  r_iops_med r_iops,  w_iops_med w_iops,  rw_mbps_med rw_mbps,  r_mbps_med r_mbps,  w_mbps_med w_mbps,  begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 09 order_by, 'Average'         metric, instance_number, rw_iops_avg rw_iops,  r_iops_avg r_iops,  w_iops_avg w_iops,  rw_mbps_avg rw_mbps,  r_mbps_avg r_mbps,  w_mbps_avg w_mbps,  begin_interval_time, end_interval_time, snap_shots FROM io_per_inst
 UNION ALL
SELECT dbid, 01 order_by, 'Maximum or peak' metric, instance_number, rw_iops_peak rw_iops, r_iops_peak r_iops, w_iops_peak w_iops, rw_mbps_peak rw_mbps, r_mbps_peak r_mbps, w_mbps_peak w_mbps, begin_interval_time, end_interval_time, snap_shots FROM io_per_cluster
 UNION ALL
SELECT dbid, 02 order_by, '99.9th percentl' metric, instance_number, rw_iops_999 rw_iops,  r_iops_999 r_iops,  w_iops_999 w_iops,  rw_mbps_999 rw_mbps,  r_mbps_999 r_mbps,  w_mbps_999 w_mbps,  begin_interval_time, end_interval_time, snap_shots FROM io_per_cluster
 UNION ALL
SELECT dbid, 03 order_by, '99th percentile' metric, instance_number, rw_iops_99 rw_iops,   r_iops_99 r_iops,   w_iops_99 w_iops,   rw_mbps_99 rw_mbps,   r_mbps_99 r_mbps,   w_mbps_99 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_cluster
 UNION ALL
SELECT dbid, 04 order_by, '97th percentile' metric, instance_number, rw_iops_97 rw_iops,   r_iops_97 r_iops,   w_iops_97 w_iops,   rw_mbps_97 rw_mbps,   r_mbps_97 r_mbps,   w_mbps_97 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_cluster
 UNION ALL
SELECT dbid, 05 order_by, '95th percentile' metric, instance_number, rw_iops_95 rw_iops,   r_iops_95 r_iops,   w_iops_95 w_iops,   rw_mbps_95 rw_mbps,   r_mbps_95 r_mbps,   w_mbps_95 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_cluster
 UNION ALL
SELECT dbid, 06 order_by, '90th percentile' metric, instance_number, rw_iops_90 rw_iops,   r_iops_90 r_iops,   w_iops_90 w_iops,   rw_mbps_90 rw_mbps,   r_mbps_90 r_mbps,   w_mbps_90 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_cluster
 UNION ALL
SELECT dbid, 07 order_by, '75th percentile' metric, instance_number, rw_iops_75 rw_iops,   r_iops_75 r_iops,   w_iops_75 w_iops,   rw_mbps_75 rw_mbps,   r_mbps_75 r_mbps,   w_mbps_75 w_mbps,   begin_interval_time, end_interval_time, snap_shots FROM io_per_cluster
 UNION ALL
SELECT dbid, 08 order_by, 'Median'          metric, instance_number, rw_iops_med rw_iops,  r_iops_med r_iops,  w_iops_med w_iops,  rw_mbps_med rw_mbps,  r_mbps_med r_mbps,  w_mbps_med w_mbps,  begin_interval_time, end_interval_time, snap_shots FROM io_per_cluster
 UNION ALL
SELECT dbid, 09 order_by, 'Average'         metric, instance_number, rw_iops_avg rw_iops,  r_iops_avg r_iops,  w_iops_avg w_iops,  rw_mbps_avg rw_mbps,  r_mbps_avg r_mbps,  w_mbps_avg w_mbps,  begin_interval_time, end_interval_time, snap_shots FROM io_per_cluster
)
SELECT dbid,
       metric,
       instance_number,
       rw_iops,
       r_iops,
       w_iops,
       rw_mbps,
       r_mbps,
       w_mbps,
       TO_CHAR(CAST(begin_interval_time AS DATE), 'YYYY-MM-DD HH24:MI') begin_interval_time,
       TO_CHAR(CAST(end_interval_time AS DATE), 'YYYY-MM-DD HH24:MI') end_interval_time,
       snap_shots,
       ROUND(CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE), 1) days,
       ROUND(snap_shots / (CAST(end_interval_time AS DATE) - CAST(begin_interval_time AS DATE)), 1) avg_snaps_per_day
  FROM io_per_inst_or_cluster
 ORDER BY
       dbid,
       order_by,
       instance_number NULLS LAST
/

/*****************************************************************************************/

COL db_time_secs HEA "DB Time|Secs";
COL u_io_secs HEA "User I/O|Secs";
COL dbfsr_secs HEA "db file|scattered read|Secs";
COL dpr_secs HEA "direct path read|Secs";
COL s_io_secs HEA "System I/O|Secs";
COL commt_secs HEA "Commit|Secs";
COL lfpw_secs HEA "log file|parallel write|Secs";
COL u_io_perc HEA "User I/O|Perc";
COL dbfsr_perc HEA "db file|scattered read|Perc";
COL dpr_perc HEA "direct path read|Perc";
COL s_io_perc HEA "System I/O|Perc";
COL commt_perc HEA "Commit|Perc";
COL lfpw_perc HEA "log file|parallel write|Perc";

PRO
PRO
PRO Relevant Time Composition
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~
WITH 
db_time AS (
SELECT snap_id,
       dbid,
       instance_number,
       stat_name,
       value - LAG(value) OVER (PARTITION BY dbid, instance_number, stat_name ORDER BY snap_id) value
  FROM dba_hist_sys_time_model
 WHERE stat_name = 'DB time'
),
system_event_detail AS (
SELECT snap_id,
       dbid,
       instance_number,
       wait_class,
       SUM(time_waited_micro) time_waited_micro
  FROM dba_hist_system_event
 WHERE wait_class IN ('User I/O', 'System I/O', 'Commit')
 GROUP BY
       dbid,
       instance_number,
       wait_class,
       snap_id
),
system_event AS (
SELECT snap_id,
       dbid,
       instance_number,
       wait_class,
       time_waited_micro - LAG(time_waited_micro) OVER (PARTITION BY dbid, instance_number, wait_class ORDER BY snap_id) time_waited_micro
  FROM system_event_detail
),
system_wait AS (
SELECT snap_id,
       dbid,
       instance_number,
       event_name,
       time_waited_micro - LAG(time_waited_micro) OVER (PARTITION BY dbid, instance_number, event_name ORDER BY snap_id) time_waited_micro
  FROM dba_hist_system_event
 WHERE event_name IN ('db file scattered read', 'direct path read', 'log file parallel write')
),
time_components AS (
SELECT d.snap_id,
       d.dbid,
       d.instance_number,
       d.value db_time,
       e1.time_waited_micro u_io_time,
       e2.time_waited_micro s_io_time,
       e3.time_waited_micro commt_time,
       w1.time_waited_micro dbfsr_time,
       w2.time_waited_micro dpr_time,
       w3.time_waited_micro lfpw_time
  FROM db_time d,
       system_event e1,
       system_event e2,
       system_event e3,
       system_wait w1,
       system_wait w2,
       system_wait w3
 WHERE d.value >= 0
   AND e1.snap_id = d.snap_id
   AND e1.dbid = d.dbid
   AND e1.instance_number = d.instance_number
   AND e1.wait_class = 'User I/O'
   AND e1.time_waited_micro >= 0
   AND e2.snap_id = d.snap_id
   AND e2.dbid = d.dbid
   AND e2.instance_number = d.instance_number
   AND e2.wait_class = 'System I/O'
   AND e2.time_waited_micro >= 0
   AND e3.snap_id = d.snap_id
   AND e3.dbid = d.dbid
   AND e3.instance_number = d.instance_number
   AND e3.wait_class = 'Commit'
   AND e3.time_waited_micro >= 0
   AND w1.snap_id = d.snap_id
   AND w1.dbid = d.dbid
   AND w1.instance_number = d.instance_number
   AND w1.event_name = 'db file scattered read'
   AND w1.time_waited_micro >= 0
   AND w2.snap_id = d.snap_id
   AND w2.dbid = d.dbid
   AND w2.instance_number = d.instance_number
   AND w2.event_name = 'direct path read'
   AND w2.time_waited_micro >= 0
   AND w3.snap_id = d.snap_id
   AND w3.dbid = d.dbid
   AND w3.instance_number = d.instance_number
   AND w3.event_name = 'log file parallel write'
   AND w3.time_waited_micro >= 0
),
by_inst_and_hh AS (
SELECT MIN(t.snap_id) snap_id,
       t.dbid,
       t.instance_number,
       TRUNC(CAST(s.end_interval_time AS DATE), 'HH') end_time,
       SUM(db_time) db_time,
       SUM(u_io_time) u_io_time,
       SUM(dbfsr_time) dbfsr_time,
       SUM(dpr_time) dpr_time,
       SUM(s_io_time) s_io_time,
       SUM(commt_time) commt_time,
       SUM(lfpw_time) lfpw_time
  FROM time_components t,
       dba_hist_snapshot s
 WHERE s.snap_id = t.snap_id
   AND s.dbid = t.dbid
   AND s.instance_number = t.instance_number
   AND CAST(s.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       t.dbid,
       t.instance_number,
       TRUNC(CAST(s.end_interval_time AS DATE), 'HH')
),
by_hh AS (
SELECT MIN(snap_id) snap_id,
       dbid,
       end_time,
       SUM(db_time) db_time,
       SUM(u_io_time) u_io_time,
       SUM(dbfsr_time) dbfsr_time,
       SUM(dpr_time) dpr_time,
       SUM(s_io_time) s_io_time,
       SUM(commt_time) commt_time,
       SUM(lfpw_time) lfpw_time
  FROM by_inst_and_hh
 GROUP BY
       dbid,
       end_time
)
SELECT ROUND(SUM(db_time) / 1e6, 2) db_time_secs,
       ROUND(SUM(u_io_time) / 1e6, 2) u_io_secs,
       ROUND(SUM(dbfsr_time) / 1e6, 2) dbfsr_secs,
       ROUND(SUM(dpr_time) / 1e6, 2) dpr_secs,
       ROUND(SUM(s_io_time) / 1e6, 2) s_io_secs,
       ROUND(SUM(commt_time) / 1e6, 2) commt_secs,
       ROUND(SUM(lfpw_time) / 1e6, 2) lfpw_secs,
       ROUND(100 * SUM(u_io_time) / SUM(db_time), 2) u_io_perc,
       ROUND(100 * SUM(dbfsr_time) / SUM(db_time), 2) dbfsr_perc,
       ROUND(100 * SUM(dpr_time) / SUM(db_time), 2) dpr_perc,
       ROUND(100 * SUM(s_io_time) / SUM(db_time), 2) s_io_perc,
       ROUND(100 * SUM(commt_time) / SUM(db_time), 2) commt_perc,
       ROUND(100 * SUM(lfpw_time) / SUM(db_time), 2) lfpw_perc
  FROM by_hh
/
WITH 
db_time AS (
SELECT snap_id,
       dbid,
       instance_number,
       stat_name,
       value - LAG(value) OVER (PARTITION BY dbid, instance_number, stat_name ORDER BY snap_id) value
  FROM dba_hist_sys_time_model
 WHERE stat_name = 'DB time'
),
system_event_detail AS (
SELECT snap_id,
       dbid,
       instance_number,
       wait_class,
       SUM(time_waited_micro) time_waited_micro
  FROM dba_hist_system_event
 WHERE wait_class IN ('User I/O', 'System I/O', 'Commit')
 GROUP BY
       dbid,
       instance_number,
       wait_class,
       snap_id
),
system_event AS (
SELECT snap_id,
       dbid,
       instance_number,
       wait_class,
       time_waited_micro - LAG(time_waited_micro) OVER (PARTITION BY dbid, instance_number, wait_class ORDER BY snap_id) time_waited_micro
  FROM system_event_detail
),
system_wait AS (
SELECT snap_id,
       dbid,
       instance_number,
       event_name,
       time_waited_micro - LAG(time_waited_micro) OVER (PARTITION BY dbid, instance_number, event_name ORDER BY snap_id) time_waited_micro
  FROM dba_hist_system_event
 WHERE event_name IN ('db file scattered read', 'direct path read', 'log file parallel write')
),
time_components AS (
SELECT d.snap_id,
       d.dbid,
       d.instance_number,
       d.value db_time,
       e1.time_waited_micro u_io_time,
       e2.time_waited_micro s_io_time,
       e3.time_waited_micro commt_time,
       w1.time_waited_micro dbfsr_time,
       w2.time_waited_micro dpr_time,
       w3.time_waited_micro lfpw_time
  FROM db_time d,
       system_event e1,
       system_event e2,
       system_event e3,
       system_wait w1,
       system_wait w2,
       system_wait w3
 WHERE d.value >= 0
   AND e1.snap_id = d.snap_id
   AND e1.dbid = d.dbid
   AND e1.instance_number = d.instance_number
   AND e1.wait_class = 'User I/O'
   AND e1.time_waited_micro >= 0
   AND e2.snap_id = d.snap_id
   AND e2.dbid = d.dbid
   AND e2.instance_number = d.instance_number
   AND e2.wait_class = 'System I/O'
   AND e2.time_waited_micro >= 0
   AND e3.snap_id = d.snap_id
   AND e3.dbid = d.dbid
   AND e3.instance_number = d.instance_number
   AND e3.wait_class = 'Commit'
   AND e3.time_waited_micro >= 0
   AND w1.snap_id = d.snap_id
   AND w1.dbid = d.dbid
   AND w1.instance_number = d.instance_number
   AND w1.event_name = 'db file scattered read'
   AND w1.time_waited_micro >= 0
   AND w2.snap_id = d.snap_id
   AND w2.dbid = d.dbid
   AND w2.instance_number = d.instance_number
   AND w2.event_name = 'direct path read'
   AND w2.time_waited_micro >= 0
   AND w3.snap_id = d.snap_id
   AND w3.dbid = d.dbid
   AND w3.instance_number = d.instance_number
   AND w3.event_name = 'log file parallel write'
   AND w3.time_waited_micro >= 0
),
by_inst_and_hh AS (
SELECT MIN(t.snap_id) snap_id,
       t.dbid,
       t.instance_number,
       TRUNC(CAST(s.end_interval_time AS DATE), 'HH') end_time,
       SUM(db_time) db_time,
       SUM(u_io_time) u_io_time,
       SUM(dbfsr_time) dbfsr_time,
       SUM(dpr_time) dpr_time,
       SUM(s_io_time) s_io_time,
       SUM(commt_time) commt_time,
       SUM(lfpw_time) lfpw_time
  FROM time_components t,
       dba_hist_snapshot s
 WHERE s.snap_id = t.snap_id
   AND s.dbid = t.dbid
   AND s.instance_number = t.instance_number
   AND CAST(s.begin_interval_time AS DATE) > SYSDATE - &&collection_days.
 GROUP BY
       t.dbid,
       t.instance_number,
       TRUNC(CAST(s.end_interval_time AS DATE), 'HH')
),
by_hh AS (
SELECT MIN(snap_id) snap_id,
       dbid,
       end_time,
       SUM(db_time) db_time,
       SUM(u_io_time) u_io_time,
       SUM(dbfsr_time) dbfsr_time,
       SUM(dpr_time) dpr_time,
       SUM(s_io_time) s_io_time,
       SUM(commt_time) commt_time,
       SUM(lfpw_time) lfpw_time
  FROM by_inst_and_hh
 GROUP BY
       dbid,
       end_time
)
SELECT snap_id,
       dbid,
       TO_CHAR(end_time - (1/24), 'YYYY-MM-DD HH24:MI') begin_time,
       TO_CHAR(end_time, 'YYYY-MM-DD HH24:MI') end_time,
       ROUND(db_time / 1e6, 2) db_time_secs,
       ROUND(u_io_time / 1e6, 2) u_io_secs,
       ROUND(dbfsr_time / 1e6, 2) dbfsr_secs,
       ROUND(dpr_time / 1e6, 2) dpr_secs,
       ROUND(s_io_time / 1e6, 2) s_io_secs,
       ROUND(commt_time / 1e6, 2) commt_secs,
       ROUND(lfpw_time / 1e6, 2) lfpw_secs,
       ROUND(100 * u_io_time / db_time, 2) u_io_perc,
       ROUND(100 * dbfsr_time / db_time, 2) dbfsr_perc,
       ROUND(100 * dpr_time / db_time, 2) dpr_perc,
       ROUND(100 * s_io_time / db_time, 2) s_io_perc,
       ROUND(100 * commt_time / db_time, 2) commt_perc,
       ROUND(100 * lfpw_time / db_time, 2) lfpw_perc
  FROM by_hh
 ORDER BY
       snap_id,
       dbid,
       end_time
/

/*****************************************************************************************/

SPO OFF;
SET TERM ON ECHO OFF FEED ON VER ON HEA ON PAGES 14 COLSEP ' ' LIN 80 TRIMS OFF TRIM ON TI OFF TIMI OFF ARRAY 15 NUM 10 SQLBL OFF BLO ON RECSEP WR;










