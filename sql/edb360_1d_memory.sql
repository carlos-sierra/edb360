@@&&edb360_0g.tkprof.sql
DEF section_id = '1d';
DEF section_name = 'Memory';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'SGA';
DEF main_table = 'GV$SGA';
BEGIN
  :sql_text := '
SELECT /*+ RESULT_CACHE */
       inst_id,
       name,
       value,
       CASE 
       WHEN value > POWER(2,50) THEN ROUND(value/POWER(2,50),1)||'' P''
       WHEN value > POWER(2,40) THEN ROUND(value/POWER(2,40),1)||'' T''
       WHEN value > POWER(2,30) THEN ROUND(value/POWER(2,30),1)||'' G''
       WHEN value > POWER(2,20) THEN ROUND(value/POWER(2,20),1)||'' M''
       WHEN value > POWER(2,10) THEN ROUND(value/POWER(2,10),1)||'' K''
       ELSE value||'' B'' END approx
  FROM gv$sga
 ORDER BY
       name,
       inst_id
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'SGA Info';
DEF main_table = 'GV$SGAINFO';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       inst_id,
       name,
       bytes,
       CASE 
       WHEN bytes > POWER(2,50) THEN ROUND(bytes/POWER(2,50),1)||'' P''
       WHEN bytes > POWER(2,40) THEN ROUND(bytes/POWER(2,40),1)||'' T''
       WHEN bytes > POWER(2,30) THEN ROUND(bytes/POWER(2,30),1)||'' G''
       WHEN bytes > POWER(2,20) THEN ROUND(bytes/POWER(2,20),1)||'' M''
       WHEN bytes > POWER(2,10) THEN ROUND(bytes/POWER(2,10),1)||'' K''
       ELSE bytes||'' B'' END approx,
       resizeable
  FROM gv$sgainfo
 ORDER BY
       name,
       inst_id
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'SGA Stat';
DEF main_table = 'GV$SGASTAT';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       pool,
       name,
       inst_id,
       bytes,
       CASE 
       WHEN bytes > POWER(2,50) THEN ROUND(bytes/POWER(2,50),1)||'' P''
       WHEN bytes > POWER(2,40) THEN ROUND(bytes/POWER(2,40),1)||'' T''
       WHEN bytes > POWER(2,30) THEN ROUND(bytes/POWER(2,30),1)||'' G''
       WHEN bytes > POWER(2,20) THEN ROUND(bytes/POWER(2,20),1)||'' M''
       WHEN bytes > POWER(2,10) THEN ROUND(bytes/POWER(2,10),1)||'' K''
       ELSE bytes||'' B'' END approx
  FROM gv$sgastat
 ORDER BY
       pool NULLS FIRST,
       name,
       inst_id
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'PGA Stat';
DEF main_table = 'GV$PGASTAT';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       inst_id,
       name,
       value,
       unit,
       CASE unit WHEN ''bytes'' THEN 
       CASE
       WHEN value > POWER(2,50) THEN ROUND(value/POWER(2,50),1)||'' P''
       WHEN value > POWER(2,40) THEN ROUND(value/POWER(2,40),1)||'' T''
       WHEN value > POWER(2,30) THEN ROUND(value/POWER(2,30),1)||'' G''
       WHEN value > POWER(2,20) THEN ROUND(value/POWER(2,20),1)||'' M''
       WHEN value > POWER(2,10) THEN ROUND(value/POWER(2,10),1)||'' K''
       ELSE value||'' B'' END 
       END approx
  FROM gv$pgastat
 ORDER BY
       name,
       inst_id
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Memory Dynamic Components';
DEF main_table = 'GV$MEMORY_DYNAMIC_COMPONENTS';
BEGIN
  :sql_text := '
-- requested by Rodrigo Righetti
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM gv$memory_dynamic_components

';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Memory Target Advice';
DEF main_table = 'GV$MEMORY_TARGET_ADVICE';
BEGIN
  :sql_text := '
-- requested by Rodrigo Righetti
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM gv$memory_target_advice

';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'SGA Target Advice';
DEF main_table = 'GV$SGA_TARGET_ADVICE';
BEGIN
  :sql_text := '
-- requested by Rodrigo Righetti
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM gv$sga_target_advice

';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'PGA Target Advice';
DEF main_table = 'GV$PGA_TARGET_ADVICE';
BEGIN
  :sql_text := '
-- requested by Rodrigo Righetti
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM gv$pga_target_advice

';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'SQL Workarea Histogram';
DEF main_table = 'GV$SQL_WORKAREA_HISTOGRAM';
BEGIN
  :sql_text := '
-- requested by Dimas Chbane
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM gv$sql_workarea_histogram

';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Memory Resize Operations';
DEF main_table = 'GV$MEMORY_RESIZE_OPS';
BEGIN
  :sql_text := '
-- requested by Rodrigo Righetti
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM gv$memory_resize_ops
 ORDER BY
       inst_id,
       start_time DESC,
       component
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Memory Current Resize Operations';
DEF main_table = 'GV$MEMORY_CURRENT_RESIZE_OPS';
BEGIN
  :sql_text := '
-- requested by Rodrigo Righetti
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM gv$memory_current_resize_ops
 ORDER BY
       inst_id,
       start_time DESC,
       component
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Memory Resize Operations Hist';
DEF main_table = 'DBA_HIST_MEMORY_RESIZE_OPS';
BEGIN
  :sql_text := '
-- requested by Rodrigo Righetti
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM dba_hist_memory_resize_ops
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 ORDER BY
       instance_number,
       start_time DESC,
       component
';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'Memory Target Advice Hist';
DEF main_table = 'DBA_HIST_MEMORY_TARGET_ADVICE';
BEGIN
  :sql_text := '
-- requested by Rodrigo Righetti
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM dba_hist_memory_target_advice
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
 ORDER BY
       instance_number,
       snap_id DESC,
       memory_size,
       memory_size_factor
';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
