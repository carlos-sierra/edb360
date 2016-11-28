-- add seq to spool_filename
EXEC :file_seq := :file_seq + 1;
SELECT LPAD(:file_seq, 5, '0')||'_&&spool_filename.' one_spool_filename FROM DUAL;

-- display
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;
SET TERM ON;
SPO &&edb360_log..txt APP;
PRO &&hh_mm_ss. &&section_id. "&&one_spool_filename..xml"
SPO OFF;
SET TERM OFF;

-- update main report
SPO &&edb360_main_report..html APP;
PRO <a href="&&one_spool_filename..xml">xml</a>
SPO OFF;

-- get time t0
EXEC :get_time_t0 := DBMS_UTILITY.get_time;

-- produce report
VAR r CLOB;
DECLARE
  l_ctx DBMS_XMLGEN.ctxhandle;
BEGIN
  l_ctx := DBMS_XMLGEN.NEWCONTEXT('SELECT TO_CHAR(ROWNUM) row_num, v0.* FROM ('||CHR(10)||TRIM(CHR(10) FROM DBMS_LOB.SUBSTR(:sql_text, 32700, 1))||CHR(10)||') v0 WHERE ROWNUM <= &&max_rows.');
  DBMS_XMLGEN.SETNULLHANDLING(l_ctx, DBMS_XMLGEN.NULL_ATTR);
  :r := DBMS_XMLGEN.GETXML(l_ctx);
END;
/

-- spool report
SET HEA OFF;
SET LONG 20000000; 
SET LONGC    2000; 
SPO &&one_spool_filename..xml;
PRINT :r;
SPO OFF;
SET HEA ON;
SET LONG 32000; 
SET LONGC 2000; 

-- get time t1
EXEC :get_time_t1 := DBMS_UTILITY.get_time;

-- update log2
SET HEA OFF;
SPO &&edb360_log2..txt APP;
SELECT TO_CHAR(SYSDATE, '&&edb360_date_format.')||' , '||
       TO_CHAR((:get_time_t1 - :get_time_t0)/100, '999,999,990.00')||'s , rows:'||
       '&&row_num., &&section_id., &&main_table., &&edb360_prev_sql_id., &&edb360_prev_child_number., &&title_no_spaces., xml , &&one_spool_filename..xml'
  FROM DUAL
/
SPO OFF;
SET HEA ON;

-- zip
HOS zip -m &&edb360_main_filename._&&edb360_file_time. &&one_spool_filename..xml >> &&edb360_log3..txt
