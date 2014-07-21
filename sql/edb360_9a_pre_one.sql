-- setup
SET VER OFF FEED OFF ECHO OFF;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') time_stamp FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;
SELECT REPLACE(TRANSLATE('&&title.',
'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789 ''`~!@#$%^*()-_=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz0123456789_'), '__', '_') title_no_spaces FROM DUAL;
SELECT REPLACE('&&common_prefix._&&column_number._&&title_no_spaces.', '$', 's') spool_filename FROM DUAL;
SET HEA OFF TERM ON;

-- log
SPO &&edb360_log..txt APP;
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO &&hh_mm_ss. col:&&column_number.of&&max_col_number. "&&section_name."
PRO &&hh_mm_ss. &&title.&&title_suffix.

-- count
PRINT sql_text;
PRO &&hh_mm_ss. col:&&column_number.of&&max_col_number.. Computing COUNT(*)...
EXEC :row_count := 0;
EXEC :sql_text_display := TRIM(CHR(10) FROM :sql_text)||';';
SET TIMI ON SERVEROUT ON;
BEGIN
  --:sql_text_display := TRIM(CHR(10) FROM :sql_text)||';';
  BEGIN
    --EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ('||CHR(10)||TRIM(CHR(10) FROM :sql_text)||CHR(10)||')' INTO :row_count;
    EXECUTE IMMEDIATE 'SELECT COUNT(*) FROM ('||CHR(10)||TRIM(CHR(10) FROM DBMS_LOB.SUBSTR(:sql_text, 32700, 1))||CHR(10)||')' INTO :row_count;
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE(DBMS_LOB.SUBSTR(SQLERRM));
  END;
  DBMS_OUTPUT.PUT_LINE(TRIM(TO_CHAR(:row_count))||' rows selected.'||CHR(10));
END;
/
SET TIMI OFF SERVEROUT OFF;
PRO
SET TERM OFF;
COL row_count NEW_V row_count NOPRI;
SELECT TRIM(TO_CHAR(:row_count)) row_count FROM DUAL;
SPO OFF;
HOS zip -q &&main_compressed_filename._&&file_creation_time. &&edb360_log..txt

-- spools query
SPO &&common_prefix._query.sql;
SELECT 'SELECT ROWNUM row_num, v0.* FROM ('||CHR(10)||TRIM(CHR(10) FROM :sql_text)||CHR(10)||') v0 WHERE ROWNUM <= &&max_rows.' FROM DUAL;
SPO OFF;
SET HEA ON;
GET &&common_prefix._query.sql

-- update main report
SPO &&main_report_name..html APP;
PRO <li title="&&main_table.">&&title. <small><em>(&&row_count.)</em></small>
SPO OFF;
HOS zip -q &&main_compressed_filename._&&file_creation_time. &&main_report_name..html

-- execute one sql
@@&&skip_html.&&html_reports.edb360_9b_one_html.sql
@@&&skip_text.&&text_reports.edb360_9c_one_text.sql
@@&&skip_csv.&&csv_files.edb360_9d_one_csv.sql
@@&&skip_lch.&&chrt_reports.edb360_9e_one_line_chart.sql
@@&&skip_pch.&&chrt_reports.edb360_9f_one_pie_chart.sql
EXEC :sql_text := NULL;
COL row_num FOR 9999999 HEA '#' PRI;
DEF abstract = '';
DEF abstract2 = '';
DEF foot = '';
DEF foot2 = '';
DEF max_rows = '&&def_max_rows.';
DEF skip_html = '';
DEF skip_text = '';
DEF skip_csv = '';
DEF skip_lch = 'Y';
DEF skip_pch = 'Y';
DEF title_suffix = '';
DEF haxis = '&&db_version. dbname:&&database_name_short. host:&&host_name_short. (avg cpu_count: &&avg_cpu_count.)';

-- update main report
SPO &&main_report_name..html APP;
PRO </li>
SPO OFF;
HOS zip -q &&main_compressed_filename._&&file_creation_time. &&main_report_name..html
