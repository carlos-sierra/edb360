--WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET TERM ON; 
SET VER OFF; 
SET FEED OFF; 
SET ECHO OFF;
SET TIM OFF;
SET TIMI OFF;
CL COL;
COL row_num FOR 9999999 HEA '#' PRI;
-- get dbid
COL edb360_dbid NEW_V edb360_dbid;
SELECT TRIM(TO_CHAR(dbid)) edb360_dbid FROM v$database;

-- parameters
PRO
PRO Parameter 1: 
PRO If your Database is licensed to use the Oracle Tuning pack please enter T.
PRO If you have a license for Diagnostics pack but not for Tuning pack, enter D.
PRO Be aware value N reduces the output content substantially. Avoid N if possible.
PRO
PRO Oracle Pack License? (Tuning, Diagnostics or None) [ T | D | N ] (required)
COL license_pack NEW_V license_pack FOR A1;
SELECT NVL(UPPER(SUBSTR(TRIM('&1.'), 1, 1)), '?') license_pack FROM DUAL;
BEGIN
  IF NOT '&&license_pack.' IN ('T', 'D', 'N') THEN
    RAISE_APPLICATION_ERROR(-20000, 'Invalid Oracle Pack License "&&license_pack.". Valid values are T, D and N.');
  END IF;
END;
/
PRO
SET TERM OFF;
COL diagnostics_pack NEW_V diagnostics_pack FOR A1;
SELECT CASE WHEN '&&license_pack.' IN ('T', 'D') THEN 'Y' ELSE 'N' END diagnostics_pack FROM DUAL;
COL skip_diagnostics NEW_V skip_diagnostics FOR A1;
SELECT CASE WHEN '&&license_pack.' IN ('T', 'D') THEN NULL ELSE 'Y' END skip_diagnostics FROM DUAL;
COL tuning_pack NEW_V tuning_pack FOR A1;
SELECT CASE WHEN '&&license_pack.' = 'T' THEN 'Y' ELSE 'N' END tuning_pack FROM DUAL;
COL skip_tuning NEW_V skip_tuning FOR A1;
SELECT CASE WHEN '&&license_pack.' = 'T' THEN NULL ELSE 'Y' END skip_tuning FROM DUAL;
SET TERM ON;
SELECT 'Be aware value "N" reduces output content substantially. Avoid "N" if possible.' warning FROM dual WHERE '&&license_pack.' = 'N';
BEGIN
  IF '&&license_pack.' = 'N' THEN
    DBMS_LOCK.SLEEP(10); -- sleep few seconds
  END IF;
END;
/
PRO
PRO Parameter 2: Days of History? (default 31)
PRO Use default value of 31 unless you have been instructed otherwise.
PRO
COL history_days NEW_V history_days;
-- range: takes at least 31 days and at most as many as actual history, with a default of 31. parameter restricts within that range. 
SELECT TO_CHAR(LEAST(CEIL(SYSDATE - CAST(MIN(begin_interval_time) AS DATE)), GREATEST(31, TO_NUMBER(NVL(TRIM('&2.'), '31'))))) history_days FROM dba_hist_snapshot WHERE '&&diagnostics_pack.' = 'Y' AND dbid = &&edb360_dbid.;
SELECT '0' history_days FROM DUAL WHERE NVL(TRIM('&&diagnostics_pack.'), 'N') = 'N';

DEF skip_script = 'sql/edb360_0f_skip_script.sql ';

-- get instance number
COL connect_instance_number NEW_V connect_instance_number;
SELECT TO_CHAR(instance_number) connect_instance_number FROM v$instance;

-- get database name (up to 10, stop before first '.', no special characters)
COL database_name_short NEW_V database_name_short FOR A10;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'DB_NAME'), 1, 10)) database_name_short FROM DUAL;
SELECT SUBSTR('&&database_name_short.', 1, INSTR('&&database_name_short..', '.') - 1) database_name_short FROM DUAL;
SELECT TRANSLATE('&&database_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') database_name_short FROM DUAL;

-- get host name (up to 30, stop before first '.', no special characters)
COL host_name_short NEW_V host_name_short FOR A30;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST'), 1, 30)) host_name_short FROM DUAL;
SELECT SUBSTR('&&host_name_short.', 1, INSTR('&&host_name_short..', '.') - 1) host_name_short FROM DUAL;
SELECT TRANSLATE('&&host_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') host_name_short FROM DUAL;

-- get rdbms version
COL db_version NEW_V db_version;
SELECT version db_version FROM v$instance;
DEF skip_10g = '';
COL skip_10g NEW_V skip_10g;
SELECT '--' skip_10g FROM v$instance WHERE version LIKE '10%';

-- get average number of CPUs
COL avg_cpu_count NEW_V avg_cpu_count FOR A3;
SELECT ROUND(AVG(TO_NUMBER(value))) avg_cpu_count FROM gv$system_parameter2 WHERE name = 'cpu_count';

-- get total number of CPUs
COL sum_cpu_count NEW_V sum_cpu_count FOR A3;
SELECT SUM(TO_NUMBER(value)) sum_cpu_count FROM gv$system_parameter2 WHERE name = 'cpu_count';

-- determine if rac or single instance (null means rac)
COL is_single_instance NEW_V is_single_instance FOR A1;
SELECT CASE COUNT(*) WHEN 1 THEN 'Y' END is_single_instance FROM gv$instance;

-- timestamp on filename
COL file_creation_time NEW_V file_creation_time FOR A20;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MI') file_creation_time FROM DUAL;

-- snapshot ranges
SELECT '0' history_days FROM DUAL WHERE TRIM('&&history_days.') IS NULL;
COL tool_sysdate NEW_V tool_sysdate;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') tool_sysdate FROM DUAL;
COL as_of_date NEW_V as_of_date;
SELECT ', as of '||TO_CHAR(SYSDATE, 'Dy Mon DD @HH12:MIAM') as_of_date FROM DUAL;
COL minimum_snap_id NEW_V minimum_snap_id;
SELECT NVL(TO_CHAR(MAX(snap_id)), '0') minimum_snap_id FROM dba_hist_snapshot WHERE '&&diagnostics_pack.' = 'Y' AND dbid = &&edb360_dbid. AND begin_interval_time < SYSDATE - &&history_days.;
SELECT '-1' minimum_snap_id FROM DUAL WHERE TRIM('&&minimum_snap_id.') IS NULL;
COL maximum_snap_id NEW_V maximum_snap_id;
SELECT NVL(TO_CHAR(MAX(snap_id)), '&&minimum_snap_id.') maximum_snap_id FROM dba_hist_snapshot WHERE '&&diagnostics_pack.' = 'Y' AND dbid = &&edb360_dbid.;
SELECT '-1' maximum_snap_id FROM DUAL WHERE TRIM('&&maximum_snap_id.') IS NULL;

-- setup
DEF tool_vrsn = 'v1417 (2014-11-10)';
DEF prefix = 'edb360';
DEF sql_trace_level = '8';
DEF main_table = '';
DEF title = '';
DEF title_no_spaces = '';
DEF title_suffix = '';
DEF common_prefix = '&&prefix._&&database_name_short.';
DEF main_report_name = '0001_&&common_prefix._index';
DEF edb360_log = '0002_&&common_prefix._log';
DEF edb360_tkprof = '0003_&&common_prefix._tkprof';
DEF main_compressed_filename = '&&common_prefix._&&host_name_short.';
DEF edb360_log2 = '0004_&&common_prefix._log2';
DEF edb360_tracefile_identifier = '&&common_prefix.';
DEF copyright = ' (c) 2014';
DEF top_level_hints = 'NO_MERGE';
DEF sq_fact_hints = 'MATERIALIZE NO_MERGE';
DEF def_max_rows = '10000';
DEF max_rows = '1e4';
DEF exclusion_list = "(''ANONYMOUS'',''APEX_030200'',''APEX_040000'',''APEX_SSO'',''APPQOSSYS'',''CTXSYS'',''DBSNMP'',''DIP'',''EXFSYS'',''FLOWS_FILES'',''MDSYS'',''OLAPSYS'',''ORACLE_OCM'',''ORDDATA'',''ORDPLUGINS'',''ORDSYS'',''OUTLN'',''OWBSYS'')";
DEF exclusion_list2 = "(''SI_INFORMTN_SCHEMA'',''SQLTXADMIN'',''SQLTXPLAIN'',''SYS'',''SYSMAN'',''SYSTEM'',''TRCANLZR'',''WMSYS'',''XDB'',''XS$NULL'')";
COL exclusion_list_single_quote NEW_V exclusion_list_single_quote;
COL exclusion_list2_single_quote NEW_V exclusion_list2_single_quote;
SELECT REPLACE('&&exclusion_list.', '''''', '''') exclusion_list_single_quote FROM DUAL;
SELECT REPLACE('&&exclusion_list2.', '''''', '''') exclusion_list2_single_quote FROM DUAL;
DEF skip_html = '';
DEF skip_text = '';
DEF skip_csv = '';
DEF skip_lch = 'Y';
DEF skip_pch = 'Y';
DEF skip_all = '';
DEF abstract = '';
DEF abstract2 = '';
DEF foot = '';
DEF sql_text = '';
DEF chartype = '';
DEF stacked = '';
DEF haxis = '&&db_version. dbname:&&database_name_short. host:&&host_name_short. (avg cpu_count: &&avg_cpu_count.)';
DEF vaxis = '';
DEF vbaseline = '';
DEF tit_01 = '';
DEF tit_02 = '';
DEF tit_03 = '';
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
DEF wait_class_01 = '';
DEF event_name_01 = '';
DEF wait_class_02 = '';
DEF event_name_02 = '';
DEF wait_class_03 = '';
DEF event_name_03 = '';
DEF wait_class_04 = '';
DEF event_name_04 = '';
DEF wait_class_05 = '';
DEF event_name_05 = '';
DEF wait_class_06 = '';
DEF event_name_06 = '';
DEF wait_class_07 = '';
DEF event_name_07 = '';
DEF wait_class_08 = '';
DEF event_name_08 = '';
DEF wait_class_09 = '';
DEF event_name_09 = '';
DEF wait_class_10 = '';
DEF event_name_10 = '';
DEF wait_class_11 = '';
DEF event_name_11 = '';
DEF wait_class_12 = '';
DEF event_name_12 = '';
DEF exadata = '';
DEF max_col_number = '1';
DEF column_number = '1';
COL recovery NEW_V recovery;
SELECT CHR(38)||' recovery' recovery FROM DUAL;
-- this above is to handle event "RMAN backup & recovery I/O"
COL skip_html NEW_V skip_html;
COL skip_text NEW_V skip_text;
COL skip_csv NEW_V skip_csv;
COL skip_lch NEW_V skip_lch;
COL skip_pch NEW_V skip_pch;
COL skip_all NEW_V skip_all;
COL dummy_01 NOPRI;
COL dummy_02 NOPRI;
COL dummy_03 NOPRI;
COL dummy_04 NOPRI;
COL dummy_05 NOPRI;
COL dummy_06 NOPRI;
COL dummy_07 NOPRI;
COL dummy_08 NOPRI;
COL dummy_09 NOPRI;
COL dummy_10 NOPRI;
COL dummy_11 NOPRI;
COL dummy_12 NOPRI;
COL dummy_13 NOPRI;
COL dummy_14 NOPRI;
COL dummy_15 NOPRI;
COL time_stamp NEW_V time_stamp FOR A20;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') time_stamp FROM DUAL;
COL hh_mm_ss NEW_V hh_mm_ss FOR A8;
COL title_no_spaces NEW_V title_no_spaces;
COL spool_filename NEW_V spool_filename;
COL one_spool_filename NEW_V one_spool_filename;
VAR row_count NUMBER;
VAR sql_text CLOB;
VAR sql_text_backup CLOB;
VAR sql_text_backup2 CLOB;
VAR sql_text_display CLOB;
VAR file_seq NUMBER;
EXEC :file_seq := 5;
VAR get_time_t0 NUMBER;
VAR get_time_t1 NUMBER;
-- Exadata
ALTER SESSION SET "_serial_direct_read" = ALWAYS;
ALTER SESSION SET "_small_table_threshold" = 1001;
-- nls
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD/HH24:MI:SS';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD/HH24:MI:SS.FF';
ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = 'YYYY-MM-DD/HH24:MI:SS.FF TZH:TZM';
-- adding to prevent slow access to ASH with non default NLS settings
ALTER SESSION SET NLS_SORT = 'BINARY';
ALTER SESSION SET NLS_COMP = 'BINARY';
-- tracing script in case it takes long to execute so we can diagnose it
ALTER SESSION SET MAX_DUMP_FILE_SIZE = '1G';
ALTER SESSION SET TRACEFILE_IDENTIFIER = "&&edb360_tracefile_identifier.";
--ALTER SESSION SET STATISTICS_LEVEL = 'ALL';
ALTER SESSION SET EVENTS '10046 TRACE NAME CONTEXT FOREVER, LEVEL &&sql_trace_level.';
SET TERM OFF; 
SET HEA ON; 
SET LIN 32767; 
SET NEWP NONE; 
SET PAGES &&def_max_rows.; 
SET LONG 32000; 
SET LONGC 2000; 
SET WRA ON; 
SET TRIMS ON; 
SET TRIM ON; 
SET TI OFF; 
SET TIMI OFF; 
SET ARRAY 100; 
SET NUM 20; 
SET SQLBL ON; 
SET BLO .; 
SET RECSEP OFF;

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- log header
SPO &&edb360_log..txt;
PRO begin log
PRO
DEF;
SPO OFF;

-- main header
SPO &&main_report_name..html;
@@edb360_0d_html_header.sql
PRO </head>
PRO <body>
PRO <h1><a href="http://www.enkitec.com" target="_blank">Enkitec</a>: DataBase 360-degree view <em>(<a href="http://www.enkitec.com/products/edb360" target="_blank">edb360</a>)</em></h1>
PRO
PRO <pre>
PRO dbname:&&database_name_short. version:&&db_version. host:&&host_name_short. license:&&license_pack. days:&&history_days. today:&&time_stamp.
PRO </pre>
PRO
SPO OFF;

-- zip
HOS zip -jq &&main_compressed_filename._&&file_creation_time. js/sorttable.js

--WHENEVER SQLERROR CONTINUE;
