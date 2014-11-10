SPO &&main_report_name..html APP;
@@edb360_0e_html_footer.sql
SPO OFF;

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- turing trace off
ALTER SESSION SET SQL_TRACE = FALSE;

-- get udump directory path
COL edb360_udump_path NEW_V edb360_udump_path FOR A500;
SELECT value||DECODE(INSTR(value, '/'), 0, '\', '/') edb360_udump_path FROM v$parameter2 WHERE name = 'user_dump_dest';

-- get pid
COL edb360_spid NEW_V edb360_spid FOR A5;
SELECT TO_CHAR(spid) edb360_spid FROM v$session s, v$process p WHERE s.sid = SYS_CONTEXT('USERENV', 'SID') AND p.addr = s.paddr;

-- tkprof for trace from execution of tool in case someone reports slow performance in tool
HOS tkprof &&edb360_udump_path.*ora_&&edb360_spid._&&edb360_tracefile_identifier..trc &&edb360_tkprof._sort.txt sort=prsela exeela fchela

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- readme
SPO 0000_readme_first.txt
PRO 1. Unzip &&main_compressed_filename._&&file_creation_time..zip into a directory
PRO 2. Review &&main_report_name..html
SPO OFF;

-- cleanup
SET HEA ON; 
SET LIN 80; 
SET NEWP 1; 
SET PAGES 14; 
SET LONG 80; 
SET LONGC 80; 
SET WRA ON; 
SET TRIMS OFF; 
SET TRIM OFF; 
SET TI OFF; 
SET TIMI OFF; 
SET ARRAY 15; 
SET NUM 10; 
SET NUMF ""; 
SET SQLBL OFF; 
SET BLO ON; 
SET RECSEP WR;
UNDEF 1 2 3 4 5 6

-- alert log (3 methods)
COL db_name_upper NEW_V db_name_upper;
COL db_name_lower NEW_V db_name_lower;
COL background_dump_dest NEW_V background_dump_dest;
SELECT UPPER(SYS_CONTEXT('USERENV', 'DB_NAME')) db_name_upper FROM DUAL;
SELECT LOWER(SYS_CONTEXT('USERENV', 'DB_NAME')) db_name_lower FROM DUAL;
SELECT value background_dump_dest FROM v$parameter WHERE name = 'background_dump_dest';
HOS cp &&background_dump_dest./alert_&&db_name_upper.*.log .
HOS cp &&background_dump_dest./alert_&&db_name_lower.*.log .
HOS cp &&background_dump_dest./alert_&&_connect_identifier..log .
HOS rename alert_ 0005_&&common_prefix._alert_ alert_*.log

-- zip 
HOS zip -mq &&main_compressed_filename._&&file_creation_time. &&common_prefix._query.sql
HOS zip -dq &&main_compressed_filename._&&file_creation_time. &&common_prefix._query.sql
HOS zip -mq &&main_compressed_filename._&&file_creation_time. 0005_&&common_prefix._alert_*.log
HOS zip -mq &&main_compressed_filename._&&file_creation_time. &&edb360_log2..txt
HOS zip -mq &&main_compressed_filename._&&file_creation_time. &&edb360_tkprof._sort.txt
HOS zip -mq &&main_compressed_filename._&&file_creation_time. &&edb360_log..txt
HOS zip -mq &&main_compressed_filename._&&file_creation_time. &&main_report_name..html
HOS zip -mq &&main_compressed_filename._&&file_creation_time. 0000_readme_first.txt 
HOS unzip -l &&main_compressed_filename._&&file_creation_time.
SET TERM ON;
