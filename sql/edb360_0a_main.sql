-- time zero for edb360 (begin)
VAR edb360_main_time0 NUMBER;
EXEC :edb360_main_time0 := DBMS_UTILITY.GET_TIME;

SPO 00000_readme_first.txt
-- initial validation
PRO If eDB360 disconnects right after this message it means the user executing it
PRO owns a table called PLAN_TABLE that is not the Oracle seeded GTT plan table
PRO owned by SYS (PLAN_TABLE$ table with a PUBLIC synonym PLAN_TABLE).
PRO eDB360 requires the Oracle seeded PLAN_TABLE, consider dropping the one in this schema.
WHENEVER SQLERROR EXIT;
DECLARE
 is_plan_table_in_usr_schema NUMBER; 
 l_version v$instance.version%TYPE;
BEGIN
 SELECT COUNT(*)
   INTO is_plan_table_in_usr_schema
   FROM user_tables
  WHERE table_name = 'PLAN_TABLE';
  -- user has a physical table called PLAN_TABLE, abort
  IF is_plan_table_in_usr_schema > 0 THEN
    RAISE_APPLICATION_ERROR(-20100, 'PLAN_TABLE physical table present in user schema.');
  END IF;
  SELECT version INTO l_version FROM v$instance;
  IF SUBSTR(l_version, 1, 2) != SUBSTR('&&_o_release.', 1, 2) THEN
    RAISE_APPLICATION_ERROR(-20101, 'Set configuration parameter "edb360_sections" on sql/edb360_00_config.sql instead.');
  END IF;
END;
/
WHENEVER SQLERROR CONTINUE;

-- parameters
PRO
PRO Parameter 1: 
PRO If your Database is licensed to use the Oracle Tuning pack please enter T.
PRO If you have a license for Diagnostics pack but not for Tuning pack, enter D.
PRO If you have both Tuning and Diagnostics packs, enter T.
PRO Be aware value N reduces the output content substantially. Avoid N if possible.
PRO
PRO Oracle Pack License? (Tuning, Diagnostics or None) [ T | D | N ] (required)
COL license_pack NEW_V license_pack FOR A1;
SELECT NVL(UPPER(SUBSTR(TRIM('&1.'), 1, 1)), '?') license_pack FROM DUAL;
WHENEVER SQLERROR EXIT SQL.SQLCODE;
BEGIN
  IF NOT '&&license_pack.' IN ('T', 'D', 'N') THEN
    RAISE_APPLICATION_ERROR(-20000, 'Invalid Oracle Pack License "&&license_pack.". Valid values are T, D and N.');
  END IF;
END;
/
WHENEVER SQLERROR CONTINUE;
PRO
PRO Parameter 2:
PRO Name of an optional custom configuration file executed right after 
PRO sql/edb360_00_config.sql. If such file name is provided, then corresponding file
PRO should exist under edb360-master/sql. Filename is case sensitivive and its existence
PRO is not validated. Example: custom_config_01.sql
PRO If no custom configuration file is needed, simply hit the "return" key.
PRO
PRO Custom configuration filename? (optional)
COL custom_config_filename NEW_V custom_config_filename;
SELECT NVL(TRIM('&2.'), 'NULL') custom_config_filename FROM DUAL;
HOS ls -lat sql/&&custom_config_filename.
HOS more sql/&&custom_config_filename.
SET TERM OFF;

-- ash verification
DEF edb360_date_format = 'YYYY-MM-DD"T"HH24:MI:SS';
@@&&ash_validation.edb360_0h_ash_validation.sql
@@edb360_0i_awr_info.sql
SPO 00000_readme_first.txt APP
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
PRO custom configuration filename: "&&custom_config_filename."
PRO
@@&&custom_config_filename.
-- links
DEF edb360_conf_tool_page = '<a href="http://carlos-sierra.net/edb360-an-oracle-database-360-degree-view/" target="_blank">';
DEF edb360_conf_all_pages_icon = '<a href="http://carlos-sierra.net/edb360-an-oracle-database-360-degree-view/" target="_blank"><img src="edb360_img.jpg" alt="eDB360" height="47" width="50" /></a>';
DEF edb360_conf_all_pages_logo = '';
DEF edb360_conf_google_charts = '<script type="text/javascript" src="https://www.google.com/jsapi"></script>';
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
PRO &&edb360_conf_tool_page.<img src="edb360_img.jpg" alt="eDB360" height="234" width="248" /></a>
PRO <br />
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
SELECT ROUND((DBMS_UTILITY.GET_TIME - :edb360_time0) / 100 / 3600, 3) elapsed_hours FROM DUAL;
PRO
PRO end log
SPO OFF;

-- main footer
SPO &&edb360_main_report..html APP;
PRO
PRO </td></tr></table>
SPO OFF;
-- time one for edb360 (end)
VAR edb360_main_time1 NUMBER;
EXEC :edb360_main_time1 := DBMS_UTILITY.GET_TIME;
@@edb360_0c_post.sql
EXEC DBMS_APPLICATION_INFO.SET_MODULE(NULL,NULL);

