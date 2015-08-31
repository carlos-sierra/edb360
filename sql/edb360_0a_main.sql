SPO 00000_readme_first.txt
-- ASH validation
WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET FEED OFF VER OFF ECHO OFF TIMI OFF TIM OFF TERM ON;
PRO
PRO Last analyzed CBO stats on ASH table and partitions
PRO
COL age_days NEW_V age_days FOR A8;
COL table_or_partition FOR A30;
COL locked FOR A6;
COL stale FOR A5;
SELECT NVL(TO_CHAR(TRUNC(SYSDATE - last_analyzed)), 'UNKNOWN') age_days,
       TO_CHAR(last_analyzed, 'YYYY-MM-DD/HH24:MI:SS') last_analyzed,
       CASE WHEN partition_name IS NULL THEN table_name ELSE partition_name END table_or_partition,
       blocks, num_rows, stattype_locked locked, stale_stats stale
  FROM dba_tab_statistics
 WHERE owner = 'SYS'
   AND table_name = 'WRH$_ACTIVE_SESSION_HISTORY'
 ORDER BY
       last_analyzed NULLS LAST
/
PRO
PRO ASH stats are &&age_days. days old.
PRO If older than a month then edb360 may take long to execute.
PRO
ACC kill_me PROMPT 'hit the "return" key to continue, or enter X to exit this session: '
SET TERM OFF;
SELECT 0/0 FROM DUAL WHERE SUBSTR(TRIM(UPPER('&&kill_me.')), 1, 1) = 'X';
SET TERM ON;
PRO
PRO Last DDL on ASH objects
PRO
COL age_days NEW_V age_days FOR A8;
SELECT NVL(TO_CHAR(TRUNC(SYSDATE - last_ddl_time)), 'UNKNOWN') age_days,
       TO_CHAR(last_ddl_time, 'YYYY-MM-DD/HH24:MI:SS') last_ddl_time,
       CASE WHEN subobject_name IS NULL THEN object_name ELSE subobject_name END table_or_partition
  FROM dba_objects
 WHERE owner = 'SYS'
   AND object_name = 'WRH$_ACTIVE_SESSION_HISTORY'
 ORDER BY
       last_ddl_time NULLS LAST
/
PRO
PRO Last DDL on ASH objects is &&age_days. days old.
PRO If older than a month then edb360 may take long to execute.
PRO Ref: MOS 387914.1
PRO
ACC kill_me PROMPT 'hit the "return" key to continue, or enter X to exit this session: '
SET TERM OFF;
SELECT 0/0 FROM DUAL WHERE SUBSTR(TRIM(UPPER('&&kill_me.')), 1, 1) = 'X';
SET TERM ON;
PRO
PRO Percent of inserts into an ASH segment
PRO
COL percent_of_inserts NEW_V percent_of_inserts FOR A7 HEA '% INS';
SELECT NVL(TO_CHAR(CASE WHEN s.num_rows > 0 THEN ROUND(100 * m.inserts / s.num_rows) END), 'UNKNOWN') percent_of_inserts,
       m.inserts, s.num_rows, 
       CASE WHEN m.partition_name IS NULL THEN m.table_name ELSE m.partition_name END table_or_partition,
       TO_CHAR(m.timestamp, 'YYYY-MM-DD/HH24:MI:SS') timestamp
  FROM dba_tab_modifications m,
       dba_tab_statistics s
 WHERE m.table_owner = 'SYS'
   AND m.table_name = 'WRH$_ACTIVE_SESSION_HISTORY'
   AND m.subpartition_name IS NULL
   AND s.owner = 'SYS'
   AND s.table_name = 'WRH$_ACTIVE_SESSION_HISTORY'
   AND NVL(s.partition_name, '-666') = NVL(m.partition_name, '-666')
   AND s.subpartition_name IS NULL
 ORDER BY
       CASE WHEN s.num_rows > 0 THEN ROUND(100 * m.inserts / s.num_rows) END NULLS LAST
/
PRO
PRO Max percent of INSERTs into an ASH segment since stats gathering is &&percent_of_inserts.%
PRO If over 50% then edb360 may take long to execute.
PRO
ACC kill_me PROMPT 'hit the "return" key to continue, or enter X to exit this session: '
SET TERM OFF;
SELECT 0/0 FROM DUAL WHERE SUBSTR(TRIM(UPPER('&&kill_me.')), 1, 1) = 'X';
SET TERM ON;
WHENEVER SQLERROR CONTINUE;
COL age_days CLE;
COL table_or_partition CLE;
COL locked CLE;
COL stale CLE;
COL percent_of_inserts CLE;
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO

-- readme
--SPO 00000_readme_first.txt
PRO
PRO Open and read 00001_edb360_<dbname>_index.html
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO initial log:
PRO
DEF
@@edb360_00_config.sql
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO config log:
PRO
DEF
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO setup log:
PRO
@@edb360_0b_pre.sql
DEF section_id = '0a';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
DEF max_col_number = '7';
DEF column_number = '0';
SPO &&edb360_main_report..html APP;
PRO <table><tr class="main">
PRO <td class="c">1/&&max_col_number.</td>
PRO <td class="c">2/&&max_col_number.</td>
PRO <td class="c">3/&&max_col_number.</td>
PRO <td class="c">4/&&max_col_number.</td>
PRO <td class="c">5/&&max_col_number.</td>
PRO <td class="c">6/&&max_col_number.</td>
PRO <td class="c">7/&&max_col_number.</td>
PRO </tr><tr class="main"><td>
PRO &&edb360_conf_tool_page.<img src="edb360_img.jpg" alt="eDB360" height="123" width="195"></a>
PRO <br>
SPO OFF;

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '1';

@@&&edb360_1a.configuration.sql
@@&&edb360_1b.security.sql
@@&&edb360_1c.audit.sql
@@&&edb360_1d.memory.sql
@@&&edb360_1e.resources.sql
@@&&edb360_1f.resources_statspack.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '2';

SPO &&edb360_main_report..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@&&edb360_2a.admin.sql
@@&&edb360_2b.storage.sql
@@&&edb360_2c.asm.sql
@@&&edb360_2d.rman.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '3';

SPO &&edb360_main_report..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@&&edb360_3a.resource_mgm.sql
@@&&edb360_3b.plan_stability.sql
@@&&edb360_3c.cbo_stats.sql
@@&&edb360_3d.performance.sql
@@&&skip_diagnostics.&&edb360_3e.os_stats.sql
@@&&is_single_instance.&&skip_diagnostics.&&edb360_3f.ic_latency.sql
@@&&is_single_instance.&&skip_diagnostics.&&edb360_3g.ic_performance.sql
@@&&edb360_3h.jdbc_sessions.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '4';

SPO &&edb360_main_report..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@&&skip_diagnostics.&&edb360_4a.sga_stats.sql
@@&&skip_diagnostics.&&edb360_4b.pga_stats.sql
@@&&skip_diagnostics.&&edb360_4c.mem_stats.sql
@@&&skip_diagnostics.&&edb360_4d.time_model.sql
@@&&skip_diagnostics.&&edb360_4e.time_model_comp.sql
@@&&skip_diagnostics.&&skip_10g.&&edb360_4f.io_waits.sql
@@&&skip_diagnostics.&&skip_10g.&&edb360_4g.io_waits_top.sql
@@&&edb360_4h.parallel_execution.sql
@@&&skip_diagnostics.&&edb360_4i.sysmetric_history.sql
@@&&skip_diagnostics.&&edb360_4j.sysmetric_summary.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '5';

SPO &&edb360_main_report..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@&&skip_diagnostics.&&edb360_5a.ash.sql
@@&&skip_diagnostics.&&edb360_5b.ash_wait.sql
@@&&skip_diagnostics.&&edb360_5c.ash_top.sql
@@&&skip_diagnostics.&&edb360_5d.sysstat.sql
@@&&skip_diagnostics.&&edb360_5e.sysstat_exa.sql
@@&&skip_diagnostics.&&edb360_5f.sysstat_current.sql
@@&&skip_diagnostics.&&edb360_5g.exadata.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '6';

SPO &&edb360_main_report..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@&&skip_diagnostics.&&edb360_6a.ash_class.sql
@@&&skip_diagnostics.&&edb360_6b.ash_event.sql
@@&&skip_diagnostics.&&edb360_6c.ash_sql.sql
@@&&skip_diagnostics.&&edb360_6d.ash_sql_ts.sql
@@&&skip_diagnostics.&&edb360_6e.ash_programs.sql
@@&&skip_diagnostics.&&edb360_6f.ash_modules.sql
@@&&skip_diagnostics.&&edb360_6g.ash_users.sql
@@&&skip_diagnostics.&&edb360_6h.ash_plsql.sql
@@&&skip_diagnostics.&&edb360_6i.ash_objects.sql
@@&&skip_diagnostics.&&edb360_6j.ash_services.sql
@@&&skip_diagnostics.&&edb360_6k.ash_phv.sql
@@&&skip_diagnostics.&&skip_10g.&&edb360_6l.ash_signature.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '7';

SPO &&edb360_main_report..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@&&skip_diagnostics.&&edb360_7a.rpt.sql
@@&&skip_diagnostics.&&edb360_7b.sql_sample.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- log footer
SPO &&edb360_log..txt APP;
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
DEF;
PRO Parameters
COL sid FOR A40;
COL name FOR A40;
COL value FOR A50;
COL display_value FOR A50;
COL update_comment NOPRI;
SELECT *
  FROM v$spparameter
 WHERE isspecified = 'TRUE'
 ORDER BY
       name,
       sid,
       ordinal;
COL sid CLE;
COL name CLE;
COL value CLE;
COL display_value CLE;
COL update_comment CLE;
SHOW PARAMETERS;
PRO
SELECT (DBMS_UTILITY.GET_TIME - :edb360_time0) / 100 elapsed_seconds FROM DUAL;
PRO
PRO end log
SPO OFF;

-- main footer
SPO &&edb360_main_report..html APP;
PRO
PRO </td></tr></table>
SPO OFF;
@@edb360_0c_post.sql
EXEC DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);

-- list of generated files
--HOS unzip -l &&edb360_main_filename._&&edb360_file_time. >> &&edb360_log3..txt
