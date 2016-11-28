DEF edb360_vYYNN = 'v1620';
DEF edb360_vrsn = '&&edb360_vYYNN. (2016-11-23)';
DEF edb360_copyright = ' (c) 2016';

SET TERM OFF;
-- watchdog
VAR edb360_time0 NUMBER;
VAR edb360_max_seconds NUMBER;
EXEC :edb360_time0 := DBMS_UTILITY.GET_TIME;
SELECT 'Tool Execution Hours so far: '||ROUND((DBMS_UTILITY.GET_TIME - :edb360_main_time0) / 100 / 3600, 3) tool_exec_hours FROM DUAL
/
EXEC :edb360_max_seconds := &&edb360_conf_max_hours. * 3600;
COL edb360_bypass NEW_V edb360_bypass;
SELECT '' edb360_bypass FROM DUAL;

-- snaps
SELECT startup_time, dbid, instance_number, COUNT(*) snaps,
       MIN(begin_interval_time) min_time, MAX(end_interval_time) max_time,
       MIN(snap_id) min_snap_id, MAX(snap_id) max_snap_id
  FROM dba_hist_snapshot
 GROUP BY
       startup_time, dbid, instance_number
 ORDER BY
       startup_time, dbid, instance_number
/

COL history_days NEW_V history_days;
-- range: takes at least 31 days and at most as many as actual history, with a default of 31. parameter restricts within that range. 
SELECT TO_CHAR(LEAST(CEIL(SYSDATE - CAST(MIN(begin_interval_time) AS DATE)), GREATEST(31, TO_NUMBER(NVL(TRIM('&&edb360_conf_days.'), '31'))))) history_days FROM dba_hist_snapshot WHERE '&&diagnostics_pack.' = 'Y' AND dbid = (SELECT dbid FROM v$database);
SELECT TO_CHAR(TO_DATE('&&edb360_conf_date_to.', 'YYYY-MM-DD') - TO_DATE('&&edb360_conf_date_from.', 'YYYY-MM-DD') + 1) history_days FROM DUAL WHERE '&&edb360_conf_date_from.' != 'YYYY-MM-DD' AND '&&edb360_conf_date_to.' != 'YYYY-MM-DD';
SELECT '0' history_days FROM DUAL WHERE NVL(TRIM('&&diagnostics_pack.'), 'N') = 'N';
SET TERM OFF;

-- Dates format
DEF edb360_date_format = 'YYYY-MM-DD"T"HH24:MI:SS';
DEF edb360_timestamp_format = 'YYYY-MM-DD"T"HH24:MI:SS.FF';
DEF edb360_timestamp_tz_format = 'YYYY-MM-DD"T"HH24:MI:SS.FFTZH:TZM';

COL edb360_date_from NEW_V edb360_date_from;
COL edb360_date_to NEW_V edb360_date_to;
SELECT CASE '&&edb360_conf_date_from.' WHEN 'YYYY-MM-DD' THEN TO_CHAR(SYSDATE - &&history_days., '&&edb360_date_format.') ELSE '&&edb360_conf_date_from.T00:00:00' END edb360_date_from FROM DUAL;
SELECT CASE '&&edb360_conf_date_to.' WHEN 'YYYY-MM-DD' THEN TO_CHAR(SYSDATE, '&&edb360_date_format.') ELSE '&&edb360_conf_date_to.T23:59:59' END edb360_date_to FROM DUAL;

VAR hist_work_days NUMBER;
VAR hist_days NUMBER;
BEGIN
  :hist_days := ROUND(TO_DATE('&&edb360_date_to.', '&&edb360_date_format.') - TO_DATE('&&edb360_date_from.', '&&edb360_date_format.'));
  :hist_work_days := 0;
  FOR i IN 0 .. :hist_days - 1
  LOOP
    IF TO_CHAR(TO_DATE('&&edb360_date_from.', '&&edb360_date_format.') + i, 'D') BETWEEN TO_NUMBER('&&edb360_conf_work_day_from.') AND TO_NUMBER('&&edb360_conf_work_day_to.') THEN
      :hist_work_days := :hist_work_days + 1;
      dbms_output.put_line((TO_DATE('&&edb360_date_from.', '&&edb360_date_format.') + i)||' '||:hist_work_days);
    END IF;
  END LOOP;
END;
/
PRINT :hist_work_days;
PRINT :hist_days;
COL hist_work_days NEW_V hist_work_days;
SELECT TO_CHAR(:hist_work_days) hist_work_days FROM DUAL;

-- hidden parameter edb360_sections: report column, or section, or range of columns or range of sections i.e. 3, 3-4, 3a, 3a-4c, 3-4c, 3c-4
VAR edb360_sec_from VARCHAR2(2);
VAR edb360_sec_to   VARCHAR2(2);
BEGIN
  IF LENGTH('&&edb360_sections.') > 5 THEN -- no hidden parameter passed
    :edb360_sec_from := '1a';
    :edb360_sec_to := '9z';
  ELSIF LENGTH('&&edb360_sections.') = 5 AND SUBSTR('&&edb360_sections.', 3, 1) = '-' AND LOWER(SUBSTR('&&edb360_sections.', 1, 2)) BETWEEN '1a' AND '9z' AND LOWER(SUBSTR('&&edb360_sections.', 4, 2)) BETWEEN '1a' AND '9z' THEN -- i.e. 1a-7b
    :edb360_sec_from := LOWER(SUBSTR('&&edb360_sections.', 1, 2));
    :edb360_sec_to := LOWER(SUBSTR('&&edb360_sections.', 4, 2));
  ELSIF LENGTH('&&edb360_sections.') = 4 AND SUBSTR('&&edb360_sections.', 3, 1) = '-' AND LOWER(SUBSTR('&&edb360_sections.', 1, 2)) BETWEEN '1a' AND '9z' AND LOWER(SUBSTR('&&edb360_sections.', 4, 1)) BETWEEN '1' AND '9' THEN -- i.e. 3b-7
    :edb360_sec_from := LOWER(SUBSTR('&&edb360_sections.', 1, 2));
    :edb360_sec_to := LOWER(SUBSTR('&&edb360_sections.', 4, 1))||'z';
  ELSIF LENGTH('&&edb360_sections.') = 4 AND SUBSTR('&&edb360_sections.', 2, 1) = '-' AND LOWER(SUBSTR('&&edb360_sections.', 1, 1)) BETWEEN '1' AND '9' AND LOWER(SUBSTR('&&edb360_sections.', 3, 2)) BETWEEN '1a' AND '9z' THEN -- i.e. 3-5b
    :edb360_sec_from := LOWER(SUBSTR('&&edb360_sections.', 1, 1))||'a';
    :edb360_sec_to := LOWER(SUBSTR('&&edb360_sections.', 3, 2));
  ELSIF LENGTH('&&edb360_sections.') = 3 AND SUBSTR('&&edb360_sections.', 2, 1) = '-' AND LOWER(SUBSTR('&&edb360_sections.', 1, 1)) BETWEEN '1' AND '9' AND LOWER(SUBSTR('&&edb360_sections.', 3, 1)) BETWEEN '1' AND '9' THEN -- i.e. 3-5
    :edb360_sec_from := LOWER(SUBSTR('&&edb360_sections.', 1, 1))||'a';
    :edb360_sec_to := LOWER(SUBSTR('&&edb360_sections.', 3, 1))||'z';
  ELSIF LENGTH('&&edb360_sections.') = 2 AND LOWER(SUBSTR('&&edb360_sections.', 1, 2)) BETWEEN '1a' AND '9z' THEN -- i.e. 7b
    :edb360_sec_from := LOWER(SUBSTR('&&edb360_sections.', 1, 2));
    :edb360_sec_to := :edb360_sec_from;
  ELSIF LENGTH('&&edb360_sections.') = 1 AND LOWER(SUBSTR('&&edb360_sections.', 1, 1)) BETWEEN '1' AND '9' THEN -- i.e. 7
    :edb360_sec_from := LOWER(SUBSTR('&&edb360_sections.', 1, 1))||'a';
    :edb360_sec_to := LOWER(SUBSTR('&&edb360_sections.', 1, 1))||'z';
  ELSE -- wrong use of hidden parameter
    :edb360_sec_from := '1a';
    :edb360_sec_to := '9z';
  END IF;
END;
/
PRINT edb360_sec_from;
PRINT edb360_sec_to;
COL edb360_0g NEW_V edb360_0g;
COL edb360_1a NEW_V edb360_1a;
COL edb360_1b NEW_V edb360_1b;
COL edb360_1c NEW_V edb360_1c;
COL edb360_1d NEW_V edb360_1d;
COL edb360_1e NEW_V edb360_1e;
COL edb360_1f NEW_V edb360_1f;
COL edb360_1g NEW_V edb360_1g;
COL edb360_2a NEW_V edb360_2a;
COL edb360_2b NEW_V edb360_2b;
COL edb360_2c NEW_V edb360_2c;
COL edb360_2d NEW_V edb360_2d;
COL edb360_3a NEW_V edb360_3a;
COL edb360_3b NEW_V edb360_3b;
COL edb360_3c NEW_V edb360_3c;
COL edb360_3d NEW_V edb360_3d;
COL edb360_3e NEW_V edb360_3e;
COL edb360_3f NEW_V edb360_3f;
COL edb360_3g NEW_V edb360_3g;
COL edb360_3h NEW_V edb360_3h;
COL edb360_3i NEW_V edb360_3i;
COL edb360_4a NEW_V edb360_4a;
COL edb360_4b NEW_V edb360_4b;
COL edb360_4c NEW_V edb360_4c;
COL edb360_4d NEW_V edb360_4d;
COL edb360_4e NEW_V edb360_4e;
COL edb360_4f NEW_V edb360_4f;
COL edb360_4g NEW_V edb360_4g;
COL edb360_4h NEW_V edb360_4h;
COL edb360_4i NEW_V edb360_4i;
COL edb360_4j NEW_V edb360_4j;
COL edb360_5a NEW_V edb360_5a;
COL edb360_5b NEW_V edb360_5b;
COL edb360_5c NEW_V edb360_5c;
COL edb360_5d NEW_V edb360_5d;
COL edb360_5e NEW_V edb360_5e;
COL edb360_5f NEW_V edb360_5f;
COL edb360_5g NEW_V edb360_5g;
COL edb360_6a NEW_V edb360_6a;
COL edb360_6b NEW_V edb360_6b;
COL edb360_6c NEW_V edb360_6c;
COL edb360_6d NEW_V edb360_6d;
COL edb360_6e NEW_V edb360_6e;
COL edb360_6f NEW_V edb360_6f;
COL edb360_6g NEW_V edb360_6g;
COL edb360_6h NEW_V edb360_6h;
COL edb360_6i NEW_V edb360_6i;
COL edb360_6j NEW_V edb360_6j;
COL edb360_6k NEW_V edb360_6k;
COL edb360_6l NEW_V edb360_6l;
COL edb360_7a NEW_V edb360_7a;
COL edb360_7b NEW_V edb360_7b;
COL edb360_7c NEW_V edb360_7c;
SELECT CASE '&&edb360_conf_incl_tkprof.' WHEN 'Y' THEN 'edb360_0g_' ELSE '--' END edb360_0g FROM DUAL;
SELECT CASE WHEN '1a' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_1a_' ELSE '--' END edb360_1a FROM DUAL;
SELECT CASE WHEN '1b' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_1b_' ELSE '--' END edb360_1b FROM DUAL;
SELECT CASE WHEN '1c' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_1c_' ELSE '--' END edb360_1c FROM DUAL;
SELECT CASE WHEN '1d' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_1d_' ELSE '--' END edb360_1d FROM DUAL;
SELECT CASE WHEN '1e' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_1e_' ELSE '--' END edb360_1e FROM DUAL;
SELECT CASE WHEN '1f' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_1f_' ELSE '--' END edb360_1f FROM DUAL;
SELECT CASE WHEN '1g' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_1g_' ELSE '--' END edb360_1g FROM DUAL;
SELECT CASE WHEN '2a' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_2a_' ELSE '--' END edb360_2a FROM DUAL;
SELECT CASE WHEN '2b' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_2b_' ELSE '--' END edb360_2b FROM DUAL;
SELECT CASE WHEN '2c' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_2c_' ELSE '--' END edb360_2c FROM DUAL;
SELECT CASE WHEN '2d' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_2d_' ELSE '--' END edb360_2d FROM DUAL;
SELECT CASE WHEN '3a' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3a_' ELSE '--' END edb360_3a FROM DUAL;
SELECT CASE WHEN '3b' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3b_' ELSE '--' END edb360_3b FROM DUAL;
SELECT CASE WHEN '3c' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3c_' ELSE '--' END edb360_3c FROM DUAL;
SELECT CASE WHEN '3d' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3d_' ELSE '--' END edb360_3d FROM DUAL;
SELECT CASE WHEN '3e' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3e_' ELSE '--' END edb360_3e FROM DUAL;
SELECT CASE WHEN '3f' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3f_' ELSE '--' END edb360_3f FROM DUAL;
SELECT CASE WHEN '3g' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3g_' ELSE '--' END edb360_3g FROM DUAL;
SELECT CASE WHEN '3h' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3h_' ELSE '--' END edb360_3h FROM DUAL;
SELECT CASE WHEN '3i' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_3i_' ELSE '--' END edb360_3i FROM DUAL;
SELECT CASE WHEN '4a' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4a_' ELSE '--' END edb360_4a FROM DUAL;
SELECT CASE WHEN '4b' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4b_' ELSE '--' END edb360_4b FROM DUAL;
SELECT CASE WHEN '4c' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4c_' ELSE '--' END edb360_4c FROM DUAL;
SELECT CASE WHEN '4d' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4d_' ELSE '--' END edb360_4d FROM DUAL;
SELECT CASE WHEN '4e' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4e_' ELSE '--' END edb360_4e FROM DUAL;
SELECT CASE WHEN '4f' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4f_' ELSE '--' END edb360_4f FROM DUAL;
SELECT CASE WHEN '4g' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4g_' ELSE '--' END edb360_4g FROM DUAL;
SELECT CASE WHEN '4h' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4h_' ELSE '--' END edb360_4h FROM DUAL;
SELECT CASE WHEN '4i' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4i_' ELSE '--' END edb360_4i FROM DUAL;
SELECT CASE WHEN '4j' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_4j_' ELSE '--' END edb360_4j FROM DUAL;
SELECT CASE WHEN '5a' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_5a_' ELSE '--' END edb360_5a FROM DUAL;
SELECT CASE WHEN '5b' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_5b_' ELSE '--' END edb360_5b FROM DUAL;
SELECT CASE WHEN '5c' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_5c_' ELSE '--' END edb360_5c FROM DUAL;
SELECT CASE WHEN '5d' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_5d_' ELSE '--' END edb360_5d FROM DUAL;
SELECT CASE WHEN '5e' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_5e_' ELSE '--' END edb360_5e FROM DUAL;
SELECT CASE WHEN '5f' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_5f_' ELSE '--' END edb360_5f FROM DUAL;
SELECT CASE WHEN '5g' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_5g_' ELSE '--' END edb360_5g FROM DUAL;
SELECT CASE WHEN '6a' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6a_' ELSE '--' END edb360_6a FROM DUAL;
SELECT CASE WHEN '6b' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6b_' ELSE '--' END edb360_6b FROM DUAL;
SELECT CASE WHEN '6c' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6c_' ELSE '--' END edb360_6c FROM DUAL;
SELECT CASE WHEN '6d' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6d_' ELSE '--' END edb360_6d FROM DUAL;
SELECT CASE WHEN '6e' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6e_' ELSE '--' END edb360_6e FROM DUAL;
SELECT CASE WHEN '6f' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6f_' ELSE '--' END edb360_6f FROM DUAL;
SELECT CASE WHEN '6g' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6g_' ELSE '--' END edb360_6g FROM DUAL;
SELECT CASE WHEN '6h' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6h_' ELSE '--' END edb360_6h FROM DUAL;
SELECT CASE WHEN '6i' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6i_' ELSE '--' END edb360_6i FROM DUAL;
SELECT CASE WHEN '6j' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6j_' ELSE '--' END edb360_6j FROM DUAL;
SELECT CASE WHEN '6k' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6k_' ELSE '--' END edb360_6k FROM DUAL;
SELECT CASE WHEN '6l' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_6l_' ELSE '--' END edb360_6l FROM DUAL;
SELECT CASE WHEN '7a' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_7a_' ELSE '--' END edb360_7a FROM DUAL;
SELECT CASE WHEN '7b' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_7b_' ELSE '--' END edb360_7b FROM DUAL;
SELECT CASE WHEN '7c' BETWEEN :edb360_sec_from AND :edb360_sec_to THEN 'edb360_7c_' ELSE '--' END edb360_7c FROM DUAL;

-- filename prefix
COL edb360_prefix NEW_V edb360_prefix;
SELECT CASE WHEN :edb360_sec_from = '1a' AND :edb360_sec_to = '9z' THEN 'edb360' ELSE 'edb360_'||:edb360_sec_from||'_'||:edb360_sec_to END edb360_prefix FROM DUAL;

-- esp init
DEF ecr_collection_key = '';

-- dummy
DEF skip_script = 'sql/edb360_0f_skip_script.sql ';

-- get dbid
COL edb360_dbid NEW_V edb360_dbid;
SELECT TRIM(TO_CHAR(dbid)) edb360_dbid FROM v$database;

-- get dbmod
COL edb360_dbmod NEW_V edb360_dbmod;
SELECT LPAD(MOD(dbid,1e6),6,'6') edb360_dbmod FROM v$database;

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

-- get host name (up to 30, stop before first '.', no special characters)
DEF esp_host_name_short = '';
COL esp_host_name_short NEW_V esp_host_name_short FOR A30;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST'), 1, 30)) esp_host_name_short FROM DUAL;
SELECT SUBSTR('&&esp_host_name_short.', 1, INSTR('&&esp_host_name_short..', '.') - 1) esp_host_name_short FROM DUAL;
SELECT TRANSLATE('&&esp_host_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') esp_host_name_short FROM DUAL;

-- get host hash
COL host_hash NEW_V host_hash;
SELECT LPAD(ORA_HASH(SYS_CONTEXT('USERENV', 'SERVER_HOST'),999999),6,'6') host_hash FROM DUAL;

-- get collection date
DEF esp_collection_yyyymmdd = '';
COL esp_collection_yyyymmdd NEW_V esp_collection_yyyymmdd FOR A8;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD') esp_collection_yyyymmdd FROM DUAL;

-- esp init
DEF ecr_collection_key = '';

-- setup
DEF main_table = '';
DEF title = '';
DEF title_no_spaces = '';
DEF title_suffix = '';
-- timestamp on filename
COL edb360_file_time NEW_V edb360_file_time FOR A20;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MI') edb360_file_time FROM DUAL;
DEF common_edb360_prefix = '&&edb360_prefix._&&edb360_dbmod.';
DEF edb360_main_report = '00001_&&common_edb360_prefix._index';
DEF edb360_log = '00002_&&common_edb360_prefix._log';
DEF edb360_log2 = '00003_&&common_edb360_prefix._log2';
DEF edb360_log3 = '00004_&&common_edb360_prefix._log3';
DEF edb360_tkprof = '00005_&&common_edb360_prefix._tkprof';
DEF edb360_main_filename = '&&common_edb360_prefix._&&host_hash.';
DEF edb360_tracefile_identifier = '&&common_edb360_prefix.';
DEF edb360_tar_filename = '00008_&&edb360_main_filename._&&edb360_file_time.';

-- mont info
HOS dcli -g ~/dbs_group -l oracle mount >> &&edb360_log3..txt

-- Exadata
ALTER SESSION SET "_serial_direct_read" = ALWAYS;
ALTER SESSION SET "_small_table_threshold" = 1001;
-- nls
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_DATE_FORMAT = '&&edb360_date_format.';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = '&&edb360_timestamp_format.';
ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = '&&edb360_timestamp_tz_format.';
-- adding to prevent slow access to ASH with non default NLS settings
ALTER SESSION SET NLS_SORT = 'BINARY';
ALTER SESSION SET NLS_COMP = 'BINARY';
-- workaround fairpoint
COL db_vers_ofe NEW_V db_vers_ofe;
SELECT TRIM('.' FROM TRIM('0' FROM version)) db_vers_ofe FROM v$instance;
ALTER SESSION SET optimizer_features_enable = '&&db_vers_ofe.';
-- to work around bug 12672969
ALTER SESSION SET "_optimizer_order_by_elimination_enabled"=false; 
-- workaround Siebel
ALTER SESSION SET optimizer_index_cost_adj = 100;
--ALTER SESSION SET optimizer_dynamic_sampling = 2;
ALTER SESSION SET "_always_semi_join" = CHOOSE;
ALTER SESSION SET "_and_pruning_enabled" = TRUE;
ALTER SESSION SET "_subquery_pruning_enabled" = TRUE;
-- workaround bug 19567916
ALTER SESSION SET "_optimizer_aggr_groupby_elim" = FALSE;
-- workaround nigeria
ALTER SESSION SET "_gby_hash_aggregation_enabled" = TRUE;
ALTER SESSION SET "_hash_join_enabled" = TRUE;
ALTER SESSION SET "_optim_peek_user_binds" = TRUE;
ALTER SESSION SET "_optimizer_skip_scan_enabled" = TRUE;
ALTER SESSION SET "_optimizer_sortmerge_join_enabled" = TRUE;
ALTER SESSION SET cursor_sharing = EXACT;
ALTER SESSION SET db_file_multiblock_read_count = 128;
ALTER SESSION SET optimizer_index_caching = 0;
ALTER SESSION SET optimizer_index_cost_adj = 100;
-- workaround 21150273 and 20465582
ALTER SESSION SET optimizer_dynamic_sampling = 0;
ALTER SESSION SET "_optimizer_dsdir_usage_control"=0;
ALTER SESSION SET "_sql_plan_directive_mgmt_control" = 0;

-- tracing script in case it takes long to execute so we can diagnose it
ALTER SESSION SET MAX_DUMP_FILE_SIZE = '1G';
ALTER SESSION SET TRACEFILE_IDENTIFIER = "&&edb360_tracefile_identifier.";
--ALTER SESSION SET STATISTICS_LEVEL = 'ALL';
BEGIN
  IF TO_NUMBER('&&sql_trace_level.') > 0 THEN
    EXECUTE IMMEDIATE 'ALTER SESSION SET EVENTS ''10046 TRACE NAME CONTEXT FOREVER, LEVEL &&sql_trace_level.''';
  END IF;
END;
/
-- esp collection. note: skip if executing for one section
@&&skip_diagnostics.&&edb360_sections.sql/esp_master.sql
SET TERM OFF; 

-- nls (2nd time as esp may change them)
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_DATE_FORMAT = '&&edb360_date_format.';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = '&&edb360_timestamp_format.';
ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = '&&edb360_timestamp_tz_format.';

-- initialization
--COL row_num NEW_V row_num FOR 9999999 HEA '#' PRI;
COL row_num NEW_V row_num HEA '#' PRI;
--COL nbsp NEW_V nbsp;
--SELECT CHR(38)||'nbsp;' nbsp FROM DUAL;

-- get rdbms version
COL db_version NEW_V db_version;
SELECT version db_version FROM v$instance;
DEF skip_10g = '';
COL skip_10g NEW_V skip_10g;
SELECT '--' skip_10g FROM v$instance WHERE version LIKE '10%';
DEF skip_11g = '';
COL skip_11g NEW_V skip_11g;
SELECT '--' skip_11g FROM v$instance WHERE version LIKE '11%';
DEF skip_11r1 = '';
COL skip_11r1 NEW_V skip_11r1;
SELECT '--' skip_11r1 FROM v$instance WHERE version LIKE '11.1%';

-- get average number of CPUs
COL avg_cpu_count NEW_V avg_cpu_count FOR A3;
SELECT ROUND(AVG(TO_NUMBER(value))) avg_cpu_count FROM gv$system_parameter2 WHERE name = 'cpu_count';

-- get total number of CPUs
COL sum_cpu_count NEW_V sum_cpu_count FOR A3;
SELECT SUM(TO_NUMBER(value)) sum_cpu_count FROM gv$system_parameter2 WHERE name = 'cpu_count';

-- get block_size
COL database_block_size NEW_V database_block_size;
SELECT TRIM(TO_NUMBER(value)) database_block_size FROM v$system_parameter2 WHERE name = 'db_block_size';

-- determine if rac or single instance (null means rac)
COL is_single_instance NEW_V is_single_instance FOR A1;
SELECT CASE COUNT(*) WHEN 1 THEN 'Y' END is_single_instance FROM gv$instance;

-- snapshot ranges
SELECT '0' history_days FROM DUAL WHERE TRIM('&&history_days.') IS NULL;
COL tool_sysdate NEW_V tool_sysdate;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDDHH24MISS') tool_sysdate FROM DUAL;
COL between_times NEW_V between_times;
COL between_dates NEW_V between_dates;
SELECT ', between &&edb360_date_from. and &&edb360_date_to.' between_dates FROM DUAL;
COL minimum_snap_id NEW_V minimum_snap_id;
SELECT NVL(TO_CHAR(MIN(snap_id)), '0') minimum_snap_id FROM dba_hist_snapshot WHERE '&&diagnostics_pack.' = 'Y' AND dbid = &&edb360_dbid. AND begin_interval_time > TO_DATE('&&edb360_date_from.', '&&edb360_date_format.');
SELECT '-1' minimum_snap_id FROM DUAL WHERE TRIM('&&minimum_snap_id.') IS NULL;
COL maximum_snap_id NEW_V maximum_snap_id;
SELECT NVL(TO_CHAR(MAX(snap_id)), '&&minimum_snap_id.') maximum_snap_id FROM dba_hist_snapshot WHERE '&&diagnostics_pack.' = 'Y' AND dbid = &&edb360_dbid. AND end_interval_time < TO_DATE('&&edb360_date_to.', '&&edb360_date_format.');
SELECT '-1' maximum_snap_id FROM DUAL WHERE TRIM('&&maximum_snap_id.') IS NULL;

-- ebs
DEF ebs_release = '';
DEF ebs_system_name = '';
COL ebs_release NEW_V ebs_release;
COL ebs_system_name NEW_V ebs_system_name;
SELECT release_name ebs_release, applications_system_name ebs_system_name FROM applsys.fnd_product_groups WHERE ROWNUM = 1;

-- siebel
DEF siebel_schema = '';
DEF siebel_app_ver = '';
COL siebel_schema NEW_V siebel_schema;
COL siebel_app_ver NEW_V siebel_app_ver;
SELECT owner siebel_schema FROM sys.dba_tab_columns WHERE table_name = 'S_REPOSITORY' AND column_name = 'ROW_ID' AND data_type = 'VARCHAR2' AND ROWNUM = 1;
SELECT app_ver siebel_app_ver FROM &&siebel_schema..s_app_ver WHERE ROWNUM = 1;

-- psft
DEF psft_schema = '';
DEF psft_tools_rel = '';
COL psft_schema NEW_V psft_schema;
COL psft_tools_rel NEW_V psft_tools_rel;
SELECT owner psft_schema FROM sys.dba_tab_columns WHERE table_name = 'PSSTATUS' AND column_name = 'TOOLSREL' AND data_type = 'VARCHAR2' AND ROWNUM = 1;
SELECT toolsrel psft_tools_rel FROM &&psft_schema..psstatus WHERE ROWNUM = 1;

-- inclusion config determine skip flags
COL edb360_skip_html NEW_V edb360_skip_html;
COL edb360_skip_xml NEW_V edb360_skip_xml;
COL edb360_skip_text NEW_V edb360_skip_text;
COL edb360_skip_csv  NEW_V edb360_skip_csv;
COL edb360_skip_line NEW_V edb360_skip_line;
COL edb360_skip_pie  NEW_V edb360_skip_pie;
COL edb360_skip_bar  NEW_V edb360_skip_bar;
COL edb360_skip_metadata  NEW_V edb360_skip_metadata;
SELECT CASE '&&edb360_conf_incl_html.'     WHEN 'N' THEN '--' END edb360_skip_html     FROM DUAL;
SELECT CASE '&&edb360_conf_incl_xml.'      WHEN 'N' THEN '--' END edb360_skip_xml      FROM DUAL;
SELECT CASE '&&edb360_conf_incl_text.'     WHEN 'N' THEN '--' END edb360_skip_text     FROM DUAL;
SELECT CASE '&&edb360_conf_incl_csv.'      WHEN 'N' THEN '--' END edb360_skip_csv      FROM DUAL;
SELECT CASE '&&edb360_conf_incl_line.'     WHEN 'N' THEN '--' END edb360_skip_line     FROM DUAL;
SELECT CASE '&&edb360_conf_incl_pie.'      WHEN 'N' THEN '--' END edb360_skip_pie      FROM DUAL;
SELECT CASE '&&edb360_conf_incl_bar.'      WHEN 'N' THEN '--' END edb360_skip_bar      FROM DUAL;
SELECT CASE '&&edb360_conf_incl_metadata.' WHEN 'N' THEN '--' END edb360_skip_metadata FROM DUAL;

-- inclusion of some diagnostics from memory (not from history)
COL edb360_skip_ash_mem NEW_V edb360_skip_ash_mem;
COL edb360_skip_sql_mon NEW_V edb360_skip_sql_mon;
COL edb360_skip_stat_mem NEW_V edb360_skip_stat_mem;
COL edb360_skip_px_mem NEW_V edb360_skip_px_mem;
SELECT CASE '&&edb360_conf_incl_ash_mem.' WHEN 'N' THEN '--' END edb360_skip_ash_mem FROM DUAL;
SELECT CASE '&&edb360_conf_incl_sql_mon.' WHEN 'N' THEN '--' END edb360_skip_sql_mon FROM DUAL;
SELECT CASE '&&edb360_conf_incl_stat_mem.' WHEN 'N' THEN '--' END edb360_skip_stat_mem FROM DUAL;
SELECT CASE '&&edb360_conf_incl_px_mem.' WHEN 'N' THEN '--' END edb360_skip_px_mem FROM DUAL;

DEF top_level_hints = ' NO_MERGE ';
DEF sq_fact_hints = ' MATERIALIZE NO_MERGE ';
DEF ds_hint = ' DYNAMIC_SAMPLING(4) ';
DEF ash_hints1 = ' FULL(h.ash) FULL(h.evt) FULL(h.sn) USE_HASH(h.sn h.ash h.evt) ';
DEF ash_hints2 = ' FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn) FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.ash) FULL(h.INT$DBA_HIST_ACT_SESS_HISTORY.evt) ';
DEF ash_hints3 = ' USE_HASH(h.INT$DBA_HIST_ACT_SESS_HISTORY.sn h.INT$DBA_HIST_ACT_SESS_HISTORY.ash h.INT$DBA_HIST_ACT_SESS_HISTORY.evt) ';
DEF def_max_rows = '10000';
DEF max_rows = '1e4';
DEF exclusion_list = "(''ANONYMOUS'',''APEX_030200'',''APEX_040000'',''APEX_SSO'',''APPQOSSYS'',''CTXSYS'',''DBSNMP'',''DIP'',''EXFSYS'',''FLOWS_FILES'',''MDSYS'',''OLAPSYS'',''ORACLE_OCM'',''ORDDATA'',''ORDPLUGINS'',''ORDSYS'',''OUTLN'',''OWBSYS'')";
DEF exclusion_list2 = "(''SI_INFORMTN_SCHEMA'',''SQLTXADMIN'',''SQLTXPLAIN'',''SYS'',''SYSMAN'',''SYSTEM'',''TRCANLZR'',''WMSYS'',''XDB'',''XS$NULL'',''PERFSTAT'',''STDBYPERF'')";
COL exclusion_list_single_quote NEW_V exclusion_list_single_quote;
COL exclusion_list2_single_quote NEW_V exclusion_list2_single_quote;
SELECT REPLACE('&&exclusion_list.', '''''', '''') exclusion_list_single_quote FROM DUAL;
SELECT REPLACE('&&exclusion_list2.', '''''', '''') exclusion_list2_single_quote FROM DUAL;
DEF skip_html = '';
DEF skip_text = '';
DEF skip_csv = '';
DEF skip_lch = 'Y';
DEF skip_pch = 'Y';
DEF skip_bch = 'Y';
DEF skip_all = '';
DEF abstract = '';
DEF abstract2 = '';
DEF foot = '';
--DEF sql_text = '';
COL sql_text FOR A100;
DEF chartype = '';
DEF stacked = '';
DEF haxis = '&&db_version. dbmod:&&edb360_dbmod. host:&&host_hash. (avg cpu_count: &&avg_cpu_count.)';
DEF vaxis = '';
DEF vbaseline = '';
COL tit_01 NEW_V tit_01;
COL tit_02 NEW_V tit_02;
COL tit_03 NEW_V tit_03;
COL tit_04 NEW_V tit_04;
COL tit_05 NEW_V tit_05;
COL tit_06 NEW_V tit_06;
COL tit_07 NEW_V tit_07;
COL tit_08 NEW_V tit_08;
COL tit_09 NEW_V tit_09;
COL tit_10 NEW_V tit_10;
COL tit_11 NEW_V tit_11;
COL tit_12 NEW_V tit_12;
COL tit_13 NEW_V tit_13;
COL tit_14 NEW_V tit_14;
COL tit_15 NEW_V tit_15;
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
COL skip_bch NEW_V skip_bch;
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
COL edb360_time_stamp NEW_V edb360_time_stamp FOR A20;
DEF total_hours = '';
SELECT TO_CHAR(SYSDATE, '&&edb360_date_format.') edb360_time_stamp FROM DUAL;
COL hh_mm_ss NEW_V hh_mm_ss FOR A8;
COL title_no_spaces NEW_V title_no_spaces;
COL spool_filename NEW_V spool_filename;
COL one_spool_filename NEW_V one_spool_filename;
COL report_sequence NEW_V report_sequence;
--VAR row_count NUMBER;
VAR sql_text CLOB;
VAR sql_text_backup CLOB;
VAR sql_text_backup2 CLOB;
VAR sql_text_display CLOB;
VAR file_seq NUMBER;
EXEC :file_seq := 8;
VAR repo_seq NUMBER;
EXEC :repo_seq := 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;
VAR get_time_t0 NUMBER;
VAR get_time_t1 NUMBER;
DEF current_time = '';
COL edb360_tuning_pack_for_sqlmon NEW_V edb360_tuning_pack_for_sqlmon;
COL skip_sqlmon_exec NEW_V skip_sqlmon_exec;
COL edb360_sql_text_100 NEW_V edb360_sql_text_100;
DEF exact_matching_signature = '';
DEF force_matching_signature = '';
—- this gives you two level of “indirection”, aka it goes into PL/SQL that dumps a script that is later on executed 
—- I use this for bar charts on sqld360
DEF wait_class_colors = 'CASE wait_class WHEN ''''''''CPU'''''''' THEN ''''''''34CF27'''''''' WHEN ''''''''Scheduler'''''''' THEN ''''''''9FFA9D'''''''' WHEN ''''''''User I/O'''''''' THEN ''''''''0252D7'''''''' WHEN ''''''''System I/O'''''''' THEN ''''''''1E96DD'''''''' ';
DEF wait_class_colors2 = ' WHEN ''''''''Concurrency'''''''' THEN ''''''''871C12'''''''' WHEN ''''''''Application'''''''' THEN ''''''''C42A05'''''''' WHEN ''''''''Commit'''''''' THEN ''''''''EA6A05'''''''' WHEN ''''''''Configuration'''''''' THEN ''''''''594611''''''''  ';
DEF wait_class_colors3 = ' WHEN ''''''''Administrative'''''''' THEN ''''''''75763E''''''''  WHEN ''''''''Network'''''''' THEN ''''''''989779'''''''' WHEN ''''''''Other'''''''' THEN ''''''''F571A0'''''''' ';
DEF wait_class_colors4 = ' WHEN ''''''''Cluster'''''''' THEN ''''''''CEC3B5'''''''' WHEN ''''''''Queueing'''''''' THEN ''''''''C6BAA5'''''''' ELSE ''''''''000000'''''''' END';
—- I use this for bar charts on edb360
DEF wait_class_colors = " CASE wait_class WHEN ''ON CPU'' THEN ''34CF27'' WHEN ''Scheduler'' THEN ''9FFA9D'' WHEN ''User I/O'' THEN ''0252D7'' WHEN ''System I/O'' THEN ''1E96DD'' ";
DEF wait_class_colors2 = " WHEN ''Concurrency'' THEN ''871C12'' WHEN ''Application'' THEN ''C42A05'' WHEN ''Commit'' THEN ''EA6A05'' WHEN ''Configuration'' THEN ''594611''  ";
DEF wait_class_colors3 = " WHEN ''Administrative'' THEN ''75763E''  WHEN ''Network'' THEN ''989779'' WHEN ''Other'' THEN ''F571A0'' ";
DEF wait_class_colors4 = " WHEN ''Cluster'' THEN ''CEC3B5'' WHEN ''Queueing'' THEN ''C6BAA5'' ELSE ''000000'' END ";
—-this one gives you one level of indirection indirection AND it builds the string in the way the line charts needs it (color: ‘#FFFFFF’) 
DEF wait_class_colors_s = 'CASE wait_class WHEN ''''CPU'''' THEN ''''color: ''''''''#34CF27'''''''''''' WHEN ''''Scheduler'''' THEN ''''color: ''''''''#9FFA9D'''''''''''' WHEN ''''User I/O'''' THEN ''''color: ''''''''#0252D7'''''''''''' WHEN ''''System I/O'''' THEN ''''color: ''''''''#1E96DD'''''''''''' ';
DEF wait_class_colors2_s = ' WHEN ''''Concurrency'''' THEN ''''color: ''''''''#871C12'''''''''''' WHEN ''''Application'''' THEN ''''color: ''''''''#C42A05'''''''''''' WHEN ''''Commit'''' THEN ''''color: ''''''''#EA6A05'''''''''''' WHEN ''''Configuration'''' THEN ''''color: ''''''''#594611''''''''''''  ';
DEF wait_class_colors3_s = ' WHEN ''''Administrative'''' THEN ''''color: ''''''''#75763E''''''''''''  WHEN ''''Network'''' THEN ''''color: ''''''''#989779'''''''''''' WHEN ''''Other'''' THEN ''''color: ''''''''#F571A0'''''''''''' ';
DEF wait_class_colors4_s = ' WHEN ''''Cluster'''' THEN ''''color: ''''''''#CEC3B5'''''''''''' WHEN ''''Queueing'''' THEN ''''color: ''''''''#C6BAA5'''''''''''' ELSE ''''color: ''''''''#000000'''''''''''' END';
--
COL series_01 NEW_V series_01; 
COL series_02 NEW_V series_02; 
COL series_03 NEW_V series_03; 
COL series_04 NEW_V series_04; 
COL series_05 NEW_V series_05; 
COL series_06 NEW_V series_06; 
COL series_07 NEW_V series_07; 
COL series_08 NEW_V series_08; 
COL series_09 NEW_V series_09; 
COL series_10 NEW_V series_10; 
COL series_11 NEW_V series_11; 
COL series_12 NEW_V series_12; 
COL series_13 NEW_V series_13; 
COL series_14 NEW_V series_14; 
COL series_15 NEW_V series_15; 
DEF series_01 = ''
DEF series_02 = ''
DEF series_03 = ''
DEF series_04 = ''
DEF series_05 = ''
DEF series_06 = ''
DEF series_07 = ''
DEF series_08 = ''
DEF series_09 = ''
DEF series_10 = ''
DEF series_11 = ''
DEF series_12 = ''
DEF series_13 = ''
DEF series_14 = ''
DEF series_15 = ''

-- get udump directory path
COL edb360_udump_path NEW_V edb360_udump_path FOR A500;
SELECT value||DECODE(INSTR(value, '/'), 0, '\', '/') edb360_udump_path FROM v$parameter2 WHERE name = 'user_dump_dest';
SELECT value||DECODE(INSTR(value, '/'), 0, '\', '/') edb360_udump_path FROM v$diag_info WHERE name = 'Diag Trace';

-- get pid
COL edb360_spid NEW_V edb360_spid FOR A5;
SELECT TO_CHAR(spid) edb360_spid FROM v$session s, v$process p WHERE s.sid = SYS_CONTEXT('USERENV', 'SID') AND p.addr = s.paddr;

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
SET ARRAY 1000; 
SET NUM 20; 
SET SQLBL ON; 
SET BLO .; 
SET RECSEP OFF;
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
DEF
SELECT 'Tool Execution Hours so far: '||ROUND((DBMS_UTILITY.GET_TIME - :edb360_main_time0) / 100 / 3600, 3) tool_exec_hours FROM DUAL
/
SPO OFF;

-- log header
SPO &&edb360_log..txt;
PRO begin log
PRO
SELECT 'Tool Execution Hours so far: '||ROUND((DBMS_UTILITY.GET_TIME - :edb360_main_time0) / 100 / 3600, 3) tool_exec_hours FROM DUAL
/
HOS ps -ef 
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
SELECT 'Tool Execution Hours so far: '||ROUND((DBMS_UTILITY.GET_TIME - :edb360_main_time0) / 100 / 3600, 3) tool_exec_hours FROM DUAL
/
SPO OFF;

-- processes
SET TERM ON;
HOS ps -ef >> &&edb360_log3..txt

-- main header
SPO &&edb360_main_report..html;
@@edb360_0d_html_header.sql
PRO </head>
PRO <body>

PRO <h1><em>&&edb360_conf_tool_page.eDB360</a></em> &&edb360_vYYNN.: 360-degree comprehensive report on an Oracle database &&edb360_conf_all_pages_logo.</h1>
PRO
PRO <pre>
--PRO version:&&db_version. dbmod:&&edb360_dbmod. host:&&host_hash. license:&&license_pack. days:&&history_days. This report covers the time interval between &&edb360_date_from. and &&edb360_date_to. Timestamp: &&edb360_time_stamp.
PRO License:&&license_pack.. This report covers the time interval between &&edb360_date_from. and &&edb360_date_to.. Days:&&history_days.. Timestamp:&&edb360_time_stamp..
PRO </pre>
PRO
SPO OFF;

-- ash
HOS zip -m &&edb360_main_filename._&&edb360_file_time. awr_ash_pre_check_*.txt >> &&edb360_log3..txt
HOS zip -m &&edb360_main_filename._&&edb360_file_time. verify_stats_wr_sys_*.txt >> &&edb360_log3..txt
-- osw
--HOS zip -r osw_&&esp_host_name_short..zip `ps -ef | grep OSW | grep FM | awk -F 'OSW' '{print $2}' | cut -f 3 -d ' '`
--HOS zip -mT &&edb360_main_filename._&&edb360_file_time. osw_&&esp_host_name_short..zip
-- zip esp into main
HOS zip -m &&edb360_main_filename._&&edb360_file_time. escp_output_&&esp_host_name_short._&&esp_collection_yyyymmdd..zip >> &&edb360_log3..txt
-- zip other files
HOS zip -m &&edb360_main_filename._&&edb360_file_time. 00000_readme_first.txt >> &&edb360_log3..txt
HOS zip -j &&edb360_main_filename._&&edb360_file_time. js/sorttable.js >> &&edb360_log3..txt
HOS zip -j &&edb360_main_filename._&&edb360_file_time. js/edb360_img.jpg >> &&edb360_log3..txt
HOS zip -j &&edb360_main_filename._&&edb360_file_time. js/edb360_favicon.ico >> &&edb360_log3..txt
