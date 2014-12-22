@@edb360_0g_tkprof.sql
DEF files_prefix = '';
SET VER OFF FEED OFF SERVEROUT ON HEAD OFF PAGES 50000 LIN 32767 TRIMS ON TRIM ON TI OFF TIMI OFF ARRAY 100;
DEF section_name = 'SQL Sample';
SPO &&main_report_name..html APP;
PRO <h2 title="Top SQL considering ASH presence for past 1 hr, 4 hrs, 1 day, 7 days and &&history_days. days">&&section_name.</h2>
SPO OFF;

COL hh_mm_ss NEW_V hh_mm_ss NOPRI FOR A8;
SPO 9997_&&common_prefix._top_sql_driver.sql;
DECLARE
  l_count NUMBER := 0;
  PROCEDURE put_line(p_line IN VARCHAR2) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put_line;
  PROCEDURE update_log(p_module IN VARCHAR2) IS
  BEGIN
        put_line('COL hh_mm_ss NEW_V hh_mm_ss NOPRI FOR A8;');
		put_line('SELECT TO_CHAR(SYSDATE, ''HH24:MI:SS'') hh_mm_ss FROM DUAL;');
		put_line('-- update log');
		put_line('SPO &&edb360_log..txt APP;');
		put_line('PRO '||CHR(38)||chr(38)||'hh_mm_ss. '||p_module);
		put_line('SPO OFF;');
  END update_log;
BEGIN
  FOR i IN (SELECT sql_id, times_on_top, samples
			  FROM (
			SELECT sql_id, 
				   COUNT(*) times_on_top, 
				   SUM(samples) samples
			  FROM (
			SELECT /*+ &&sq_fact_hints. */ sql_id, samples
			  FROM (
			SELECT /*+ &&sq_fact_hints. */
			       sql_id,
				   COUNT(*) samples
			  FROM gv$active_session_history
			 WHERE '&&diagnostics_pack.' = 'Y'
			   AND CAST(sample_time AS DATE) BETWEEN TO_DATE('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - (1 / 24) AND TO_DATE('&&tool_sysdate.', 'YYYYMMDDHH24MISS') -- for past 1 hour
			   AND sql_id IS NOT NULL
			 GROUP BY
				   sql_id
			 ORDER BY
				   2 DESC
			)
			 WHERE ROWNUM < 17
			 UNION ALL
			SELECT /*+ &&sq_fact_hints. */ sql_id, samples
			  FROM (
			SELECT /*+ &&sq_fact_hints. &&ds_hint. */
			       ash.sql_id,
				   COUNT(*) samples
			  FROM dba_hist_active_sess_history ash,
				   dba_hist_snapshot snp
			 WHERE '&&diagnostics_pack.' = 'Y'
			   AND ash.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
			   AND ash.sql_id IS NOT NULL
			   AND snp.snap_id = ash.snap_id
			   AND snp.dbid = ash.dbid
			   AND snp.instance_number = ash.instance_number
			   AND CAST(snp.end_interval_time AS DATE) BETWEEN TO_DATE('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - (4 / 24) AND TO_DATE('&&tool_sysdate.', 'YYYYMMDDHH24MISS') -- for past 4 hours
			 GROUP BY 
				   ash.sql_id
			 ORDER BY
				   2 DESC
			)
			 WHERE ROWNUM < 17
			 UNION ALL
			SELECT /*+ &&sq_fact_hints. */ sql_id, samples
			  FROM (
			SELECT /*+ &&sq_fact_hints. &&ds_hint. */
			       ash.sql_id,
				   COUNT(*) samples
			  FROM dba_hist_active_sess_history ash,
				   dba_hist_snapshot snp
			 WHERE '&&diagnostics_pack.' = 'Y'
			   AND ash.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
			   AND ash.sql_id IS NOT NULL
			   AND snp.snap_id = ash.snap_id
			   AND snp.dbid = ash.dbid
			   AND snp.instance_number = ash.instance_number
			   AND CAST(snp.end_interval_time AS DATE) BETWEEN TO_DATE('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - 1 AND TO_DATE('&&tool_sysdate.', 'YYYYMMDDHH24MISS') -- for past 1 day
			 GROUP BY 
				   ash.sql_id
			 ORDER BY
				   2 DESC
			)
			 WHERE ROWNUM < 17
			 UNION ALL
			SELECT /*+ &&sq_fact_hints. */ sql_id, samples
			  FROM (
			SELECT /*+ &&sq_fact_hints. &&ds_hint. */
			       ash.sql_id,
				   COUNT(*) samples
			  FROM dba_hist_active_sess_history ash,
				   dba_hist_snapshot snp
			 WHERE '&&diagnostics_pack.' = 'Y'
			   AND ash.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
			   AND ash.sql_id IS NOT NULL
			   AND snp.snap_id = ash.snap_id
			   AND snp.dbid = ash.dbid
			   AND snp.instance_number = ash.instance_number
			   AND CAST(snp.end_interval_time AS DATE) BETWEEN TO_DATE('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - 7 AND TO_DATE('&&tool_sysdate.', 'YYYYMMDDHH24MISS') -- for past 7 days
			 GROUP BY 
				   ash.sql_id
			 ORDER BY
				   2 DESC
			)
			 WHERE ROWNUM < 17
			 UNION ALL
			SELECT /*+ &&sq_fact_hints. */ sql_id, samples
			  FROM (
			SELECT /*+ &&sq_fact_hints. &&ds_hint. */
			       ash.sql_id,
				   COUNT(*) samples
			  FROM dba_hist_active_sess_history ash,
				   dba_hist_snapshot snp
			 WHERE '&&diagnostics_pack.' = 'Y'
			   AND ash.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
			   AND ash.sql_id IS NOT NULL
			   AND snp.snap_id = ash.snap_id
			   AND snp.dbid = ash.dbid
			   AND snp.instance_number = ash.instance_number
			   AND CAST(snp.end_interval_time AS DATE) BETWEEN TO_DATE('&&tool_sysdate.', 'YYYYMMDDHH24MISS') - 7 AND TO_DATE('&&tool_sysdate.', 'YYYYMMDDHH24MISS') -- for past 7 work days
               AND TO_CHAR(CAST(snp.end_interval_time AS DATE), 'D') BETWEEN '2' AND '6' /* between Monday and Friday */
               AND TO_CHAR(CAST(snp.end_interval_time AS DATE), 'HH24') BETWEEN '0800' AND '1900' /* between 8AM to 7PM */
			 GROUP BY 
				   ash.sql_id
			 ORDER BY
				   2 DESC
			)
			 WHERE ROWNUM < 17
			 UNION ALL
			SELECT /*+ &&sq_fact_hints. */ sql_id, samples
			  FROM (
			SELECT /*+ &&sq_fact_hints. &&ds_hint. */
			       ash.sql_id,
				   COUNT(*) samples
			  FROM dba_hist_active_sess_history ash,
				   dba_hist_snapshot snp
			 WHERE '&&diagnostics_pack.' = 'Y'
			   AND ash.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id. -- for past &&history_days. days (implicit on range of snaps)
			   AND ash.sql_id IS NOT NULL
			   AND snp.snap_id = ash.snap_id
			   AND snp.dbid = ash.dbid
			   AND snp.instance_number = ash.instance_number
			 GROUP BY 
				   ash.sql_id
			 ORDER BY
				   2 DESC
			)
			 WHERE ROWNUM < 17
			)
			 GROUP BY
				   sql_id
			 ORDER BY
				   times_on_top * samples DESC
			)
			WHERE ROWNUM < 17)
  LOOP
    l_count := l_count + 1;
    put_line('COL hh_mm_ss NEW_V hh_mm_ss NOPRI FOR A8;');
    put_line('SELECT TO_CHAR(SYSDATE, ''HH24:MI:SS'') hh_mm_ss FROM DUAL;');
    put_line('-- update log');
    put_line('SPO &&edb360_log..txt APP;');
    put_line('PRO');
    put_line('PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
    put_line('PRO');
    put_line('PRO rank:'||l_count||' sql_id:'||i.sql_id);
    put_line('SPO OFF;');
    put_line('HOS zip -q &&main_compressed_filename._&&file_creation_time. &&edb360_log..txt');
    put_line('-- update main report');
    put_line('SPO &&main_report_name..html APP;');
    put_line('PRO <li title="PLANX(16), SQLMON(12), SQLASH(8) and SQLHC(4)">'||i.sql_id);
    put_line('HOS zip -q &&main_compressed_filename._&&file_creation_time. &&main_report_name..html');
    put_line('SPO OFF;');
    IF l_count <= 16 THEN
      update_log('PLANX');
      put_line('@@sql/planx.sql &&diagnostics_pack. '||i.sql_id);
      put_line('-- update main report');
      put_line('SPO &&main_report_name..html APP;');
      put_line('PRO <a href="planx_'||i.sql_id||'_'||CHR(38)||chr(38)||'current_time..txt">planx(text)</a>');
      put_line('SPO OFF;');
      put_line('-- zip');
      put_line('HOS zip -mq &&main_compressed_filename._&&file_creation_time. planx_'||i.sql_id||'_'||CHR(38)||chr(38)||'current_time..txt');
      put_line('HOS zip -q &&main_compressed_filename._&&file_creation_time. &&main_report_name..html');
    END IF;
    IF l_count <= 12 AND '&&skip_10g.' IS NULL AND '&&skip_diagnostics.' IS NULL AND '&&skip_tuning.' IS NULL THEN
      update_log('SQLMON');
      put_line('@@sql/sqlmon.sql &&tuning_pack. '||i.sql_id);
      put_line('-- update main report');
      put_line('SPO &&main_report_name..html APP;');
      put_line('PRO <a href="sqlmon_'||i.sql_id||'_'||CHR(38)||chr(38)||'current_time..zip">sqlmon(zip)</a>');
      put_line('SPO OFF;');
      put_line('-- zip');
      put_line('HOS zip -mq &&main_compressed_filename._&&file_creation_time. sqlmon_'||i.sql_id||'_'||CHR(38)||chr(38)||'current_time..zip');
      put_line('HOS zip -q &&main_compressed_filename._&&file_creation_time. &&main_report_name..html');
    END IF;
    IF l_count <= 8 AND '&&skip_diagnostics.' IS NULL THEN
      update_log('SQLASH');
      put_line('@@sql/sqlash.sql &&diagnostics_pack. '||i.sql_id);
      put_line('-- update main report');
      put_line('SPO &&main_report_name..html APP;');
      put_line('PRO <a href="sqlash_'||i.sql_id||'.zip">sqlash(zip)</a>');
      put_line('SPO OFF;');
      put_line('-- zip');
      put_line('HOS zip -mq &&main_compressed_filename._&&file_creation_time. sqlash_'||i.sql_id||'.zip');
      put_line('HOS zip -q &&main_compressed_filename._&&file_creation_time. &&main_report_name..html');
    END IF;
    IF l_count <= 4 THEN
      update_log('SQLHC');
      put_line('@@sql/sqlhc.sql &&license_pack. '||i.sql_id);
      put_line('-- update main report');
      put_line('SPO &&main_report_name..html APP;');
      put_line('PRO <a href="'||CHR(38)||chr(38)||'files_prefix..zip">sqlhc(zip)</a>');
      put_line('SPO OFF;');
      put_line('-- zip');
      put_line('HOS zip -mq &&main_compressed_filename._&&file_creation_time. '||CHR(38)||chr(38)||'files_prefix..zip');
      put_line('HOS zip -q &&main_compressed_filename._&&file_creation_time. &&main_report_name..html');
    END IF;
    put_line('-- update main report');
    put_line('SPO &&main_report_name..html APP;');
    put_line('PRO </li>');
    put_line('SPO OFF;');
    put_line('HOS zip -q &&main_compressed_filename._&&file_creation_time. &&main_report_name..html');
  END LOOP;
END;
/
SPO OFF;
@@edb360_0g_tkprof.sql
@9997_&&common_prefix._top_sql_driver.sql;
SET SERVEROUT OFF HEAD ON PAGES &&def_max_rows.;
HOS zip -mq &&main_compressed_filename._&&file_creation_time. 9997_&&common_prefix._top_sql_driver.sql
SET HEA ON LIN 32767 NEWP NONE PAGES &&def_max_rows. LONG 32000 LONGC 2000 WRA ON TRIMS ON TRIM ON TI OFF TIMI OFF ARRAY 100 NUM 20 SQLBL ON BLO . RECSEP OFF;
CL COL;
COL row_num FOR 9999999 HEA '#' PRI;


