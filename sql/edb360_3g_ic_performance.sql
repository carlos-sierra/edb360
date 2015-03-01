@@edb360_0g_tkprof.sql
DEF section_id = '3f';
DEF section_name = 'Interconnect Performance';
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_name.</h2>
SPO OFF;

DEF main_table = 'DBA_HIST_IC_DEVICE_STATS';

DEF chartype = 'LineChart';
DEF stacked = '';
DEF vbaseline = '';

BEGIN
  :sql_text_backup := '
WITH
ic_device_stats AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */
       MAX(h1.snap_id) snap_id,
       h1.instance_number,
       h1.if_name,
       TO_CHAR(s1.begin_interval_time, ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(s1.end_interval_time, ''YYYY-MM-DD HH24:MI'') end_time,
       SUM(h1.bytes_received - h0.bytes_received) bytes_received,
       ROUND(SUM(h1.bytes_received - h0.bytes_received) / POWER(2,20) / 
       ((TO_DATE(TO_CHAR(s1.end_interval_time, ''YYYY-MM-DD HH24:MI''), ''YYYY-MM-DD HH24:MI'') - 
         TO_DATE(TO_CHAR(s1.begin_interval_time, ''YYYY-MM-DD HH24:MI''), ''YYYY-MM-DD HH24:MI'')) * 24 * 3600), 3) mbps_received,
       SUM(h1.packets_received - h0.packets_received) packets_received,
       SUM(h1.receive_errors - h0.receive_errors) receive_errors,
       SUM(h1.receive_dropped - h0.receive_dropped) receive_dropped,
       SUM(h1.receive_buf_or - h0.receive_buf_or) receive_buf_or,
       SUM(h1.receive_frame_err - h0.receive_frame_err) receive_frame_err,
       SUM(h1.bytes_sent - h0.bytes_sent) bytes_sent,
       ROUND(SUM(h1.bytes_sent - h0.bytes_sent) / POWER(2,20) / 
       ((TO_DATE(TO_CHAR(s1.end_interval_time, ''YYYY-MM-DD HH24:MI''), ''YYYY-MM-DD HH24:MI'') - 
         TO_DATE(TO_CHAR(s1.begin_interval_time, ''YYYY-MM-DD HH24:MI''), ''YYYY-MM-DD HH24:MI'')) * 24 * 3600), 3) mbps_sent,
       SUM(h1.packets_sent - h0.packets_sent) packets_sent,
       SUM(h1.send_errors - h0.send_errors) send_errors,
       SUM(h1.sends_dropped - h0.sends_dropped) sends_dropped,
       SUM(h1.send_buf_or - h0.send_buf_or) send_buf_or,
       SUM(h1.send_carrier_lost - h0.send_carrier_lost) send_carrier_lost
  FROM dba_hist_ic_device_stats h0,
       dba_hist_ic_device_stats h1,
       dba_hist_snapshot s0,
       dba_hist_snapshot s1
 WHERE h0.instance_number = @instance_number@
   AND h0.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h0.dbid = &&edb360_dbid.
   AND h1.snap_id = h0.snap_id + 1
   AND h1.dbid = h0.dbid
   AND h1.instance_number = h0.instance_number
   AND h1.if_name = h0.if_name
   AND s0.snap_id = h0.snap_id
   AND s0.dbid = h0.dbid
   AND s0.instance_number = h0.instance_number
   AND s0.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s0.dbid = &&edb360_dbid.
   AND s1.snap_id = h1.snap_id
   AND s1.dbid = h1.dbid
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
   AND s1.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s1.dbid = &&edb360_dbid.
   AND s1.begin_interval_time > (s0.begin_interval_time + (1 / (24 * 60))) /* filter out snaps apart < 1 min */
   AND ((TO_DATE(TO_CHAR(s1.end_interval_time, ''YYYY-MM-DD HH24:MI''), ''YYYY-MM-DD HH24:MI'') -
         TO_DATE(TO_CHAR(s1.begin_interval_time, ''YYYY-MM-DD HH24:MI''), ''YYYY-MM-DD HH24:MI'')) * 24 * 3600) > 0
   AND (h1.bytes_received - h0.bytes_received) >= 0
   AND (h1.packets_received - h0.packets_received) >= 0
   AND (h1.receive_errors - h0.receive_errors) >= 0
   AND (h1.receive_dropped - h0.receive_dropped) >= 0
   AND (h1.receive_buf_or - h0.receive_buf_or) >= 0
   AND (h1.receive_frame_err - h0.receive_frame_err) >= 0
   AND (h1.bytes_sent - h0.bytes_sent) >= 0
   AND (h1.packets_sent - h0.packets_sent) >= 0
   AND (h1.send_errors - h0.send_errors) >= 0
   AND (h1.sends_dropped - h0.sends_dropped) >= 0
   AND (h1.send_buf_or - h0.send_buf_or) >= 0
   AND (h1.send_carrier_lost - h0.send_carrier_lost) >= 0
 GROUP BY
       h1.instance_number,
       h1.if_name,
       TO_CHAR(s1.begin_interval_time, ''YYYY-MM-DD HH24:MI''),
       TO_CHAR(s1.end_interval_time, ''YYYY-MM-DD HH24:MI'')
),
per_cluster AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       begin_time,
       end_time,
       SUM(mbps_sent) mbps_sent,
       SUM(mbps_received) mbps_received,
       SUM(mbps_sent) + SUM(mbps_received) mbps_total,
       SUM(packets_received) packets_received,
       SUM(receive_errors) receive_errors,
       SUM(receive_dropped) receive_dropped,
       SUM(receive_buf_or) receive_buf_or,
       SUM(receive_frame_err) receive_frame_err,
       SUM(packets_sent) packets_sent,
       SUM(send_errors) send_errors,
       SUM(sends_dropped) sends_dropped,
       SUM(send_buf_or) send_buf_or,
       SUM(send_carrier_lost) send_carrier_lost
  FROM ic_device_stats
 GROUP BY
       snap_id,
       begin_time,
       end_time
)
SELECT snap_id
       ,begin_time
       ,end_time
       #column01#
       #column02#
       #column03#
       #column04#
       #column05#
       #column06#
       #column07#
       #column08#
       #column09#
       #column10#
       ,0 dummy_11
       ,0 dummy_12
       ,0 dummy_13
       ,0 dummy_14
       ,0 dummy_15
  FROM per_cluster
 ORDER BY       
       snap_id,
       begin_time
';
END;
/

DEF vaxis = 'IC Traffic (MBPS)';
DEF tit_01 = 'MBPS Total';
DEF tit_02 = 'MBPS Sent';
DEF tit_03 = 'MBPS Received';
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

EXEC :sql_text_backup2 := REPLACE(:sql_text_backup,  '#column01#', ', mbps_total');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column02#', ', mbps_sent');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column03#', ', mbps_received');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column04#', ',0 dummy_04');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column05#', ',0 dummy_05');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column06#', ',0 dummy_06');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column07#', ',0 dummy_07');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column08#', ',0 dummy_08');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column09#', ',0 dummy_09');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column10#', ',0 dummy_10');

DEF skip_lch = '';
DEF title = 'Interconnect Traffic for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', 'h0.instance_number');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'Interconnect Traffic for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'Interconnect Traffic for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'Interconnect Traffic for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'Interconnect Traffic for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'Interconnect Traffic for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'Interconnect Traffic for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'Interconnect Traffic for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'Interconnect Traffic for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql


DEF vaxis = 'IC Device Statistics';
DEF tit_01 = 'Packets Received';
DEF tit_02 = 'Packets Sent';
DEF tit_03 = 'Receive Errors';
DEF tit_04 = 'Receive Dropped';
DEF tit_05 = 'Receive Buffer Overruns';
DEF tit_06 = 'Receive Frame Error';
DEF tit_07 = 'Send Errors';
DEF tit_08 = 'Sends Dropped';
DEF tit_09 = 'Send Buffer Overruns';
DEF tit_10 = 'Send Carrier Lost';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

EXEC :sql_text_backup2 := REPLACE(:sql_text_backup,  '#column01#', ', packets_received');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column02#', ', packets_sent');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column03#', ', receive_errors');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column04#', ', receive_dropped');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column05#', ', receive_buf_or');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column06#', ', receive_frame_err');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column07#', ', send_errors');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column08#', ', sends_dropped');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column09#', ', send_buf_or');
EXEC :sql_text_backup2 := REPLACE(:sql_text_backup2, '#column10#', ', send_carrier_lost');

DEF skip_lch = '';
DEF title = 'IC Device Statistics summary for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', 'h0.instance_number');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'IC Device Statistics summary for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'IC Device Statistics summary for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'IC Device Statistics summary for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'IC Device Statistics summary for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'IC Device Statistics summary for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'IC Device Statistics summary for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'IC Device Statistics summary for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'IC Device Statistics summary for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = 'Y';

/****************************************************************************************/

BEGIN
  :sql_text_backup := '
SELECT /*+ &&top_level_hints. */
       TO_CHAR(s1.begin_interval_time, ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(s1.end_interval_time, ''YYYY-MM-DD HH24:MI'') end_time,
       h1.if_name,
       ROUND(SUM(h1.bytes_received - h0.bytes_received) / POWER(2,20) / 
       ((TO_DATE(TO_CHAR(s1.end_interval_time, ''YYYY-MM-DD HH24:MI''), ''YYYY-MM-DD HH24:MI'') - 
         TO_DATE(TO_CHAR(s1.begin_interval_time, ''YYYY-MM-DD HH24:MI''), ''YYYY-MM-DD HH24:MI'')) * 24 * 3600), 3) +
       ROUND(SUM(h1.bytes_sent - h0.bytes_sent) / POWER(2,20) / 
       ((TO_DATE(TO_CHAR(s1.end_interval_time, ''YYYY-MM-DD HH24:MI''), ''YYYY-MM-DD HH24:MI'') - 
        TO_DATE(TO_CHAR(s1.begin_interval_time, ''YYYY-MM-DD HH24:MI''), ''YYYY-MM-DD HH24:MI'')) * 24 * 3600), 3) mbps_total,
       ROUND(SUM(h1.bytes_received - h0.bytes_received) / POWER(2,20) / 
       ((TO_DATE(TO_CHAR(s1.end_interval_time, ''YYYY-MM-DD HH24:MI''), ''YYYY-MM-DD HH24:MI'') - 
         TO_DATE(TO_CHAR(s1.begin_interval_time, ''YYYY-MM-DD HH24:MI''), ''YYYY-MM-DD HH24:MI'')) * 24 * 3600), 3) mbps_received,
       ROUND(SUM(h1.bytes_sent - h0.bytes_sent) / POWER(2,20) / 
       ((TO_DATE(TO_CHAR(s1.end_interval_time, ''YYYY-MM-DD HH24:MI''), ''YYYY-MM-DD HH24:MI'') - 
        TO_DATE(TO_CHAR(s1.begin_interval_time, ''YYYY-MM-DD HH24:MI''), ''YYYY-MM-DD HH24:MI'')) * 24 * 3600), 3) mbps_sent,
       SUM(h1.packets_sent - h0.packets_sent) + SUM(h1.packets_received - h0.packets_received) packets_total,
       SUM(h1.packets_received - h0.packets_received) packets_received,
       SUM(h1.packets_sent - h0.packets_sent) packets_sent,
       SUM(h1.bytes_received - h0.bytes_received) bytes_received,
       SUM(h1.receive_errors - h0.receive_errors) receive_errors,
       SUM(h1.receive_dropped - h0.receive_dropped) receive_dropped,
       SUM(h1.receive_buf_or - h0.receive_buf_or) receive_buf_or,
       SUM(h1.receive_frame_err - h0.receive_frame_err) receive_frame_err,
       SUM(h1.bytes_sent - h0.bytes_sent) bytes_sent,
       SUM(h1.send_errors - h0.send_errors) send_errors,
       SUM(h1.sends_dropped - h0.sends_dropped) sends_dropped,
       SUM(h1.send_buf_or - h0.send_buf_or) send_buf_or,
       SUM(h1.send_carrier_lost - h0.send_carrier_lost) send_carrier_lost
  FROM dba_hist_ic_device_stats h0,
       dba_hist_ic_device_stats h1,
       dba_hist_snapshot s0,
       dba_hist_snapshot s1
 WHERE h0.instance_number = @instance_number@
   AND h0.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h0.dbid = &&edb360_dbid.
   AND h1.snap_id = h0.snap_id + 1
   AND h1.dbid = h0.dbid
   AND h1.instance_number = h0.instance_number
   AND h1.if_name = h0.if_name
   AND s0.snap_id = h0.snap_id
   AND s0.dbid = h0.dbid
   AND s0.instance_number = h0.instance_number
   AND s0.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s0.dbid = &&edb360_dbid.
   AND s1.snap_id = h1.snap_id
   AND s1.dbid = h1.dbid
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
   AND s1.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s1.dbid = &&edb360_dbid.
   AND s1.begin_interval_time > (s0.begin_interval_time + (1 / (24 * 60))) /* filter out snaps apart < 1 min */
   AND ((TO_DATE(TO_CHAR(s1.end_interval_time, ''YYYY-MM-DD HH24:MI''), ''YYYY-MM-DD HH24:MI'') -
         TO_DATE(TO_CHAR(s1.begin_interval_time, ''YYYY-MM-DD HH24:MI''), ''YYYY-MM-DD HH24:MI'')) * 24 * 3600) > 0
   AND (h1.bytes_received - h0.bytes_received) >= 0
   AND (h1.packets_received - h0.packets_received) >= 0
   AND (h1.receive_errors - h0.receive_errors) >= 0
   AND (h1.receive_dropped - h0.receive_dropped) >= 0
   AND (h1.receive_buf_or - h0.receive_buf_or) >= 0
   AND (h1.receive_frame_err - h0.receive_frame_err) >= 0
   AND (h1.bytes_sent - h0.bytes_sent) >= 0
   AND (h1.packets_sent - h0.packets_sent) >= 0
   AND (h1.send_errors - h0.send_errors) >= 0
   AND (h1.sends_dropped - h0.sends_dropped) >= 0
   AND (h1.send_buf_or - h0.send_buf_or) >= 0
   AND (h1.send_carrier_lost - h0.send_carrier_lost) >= 0
 GROUP BY
       TO_CHAR(s1.begin_interval_time, ''YYYY-MM-DD HH24:MI''),
       TO_CHAR(s1.end_interval_time, ''YYYY-MM-DD HH24:MI''),
       h1.if_name
 ORDER BY
       TO_CHAR(s1.begin_interval_time, ''YYYY-MM-DD HH24:MI'') DESC,
       TO_CHAR(s1.end_interval_time, ''YYYY-MM-DD HH24:MI'') DESC,
       h1.if_name
';
END;
/

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'IC Device Statistics details for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'IC Device Statistics details for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'IC Device Statistics details for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'IC Device Statistics details for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'IC Device Statistics details for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'IC Device Statistics details for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'IC Device Statistics details for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'IC Device Statistics details for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.&&skip_diagnostics.edb360_9a_pre_one.sql




