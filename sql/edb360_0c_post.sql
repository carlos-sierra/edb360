SELECT TO_CHAR(SYSDATE, '&&edb360_date_format.') edb360_time_stamp FROM DUAL;
COL total_hours NEW_V total_hours;
SELECT 'Tool execution hours: '||TO_CHAR(ROUND((:edb360_main_time1 - :edb360_main_time0) / 100 / 3600, 3), '990.000')||'.' total_hours FROM DUAL;
SPO &&edb360_main_report..html APP;
@@edb360_0e_html_footer.sql
SPO OFF;

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- turing trace off
ALTER SESSION SET SQL_TRACE = FALSE;
@@&&edb360_0g.tkprof.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- touch file to update timestamp
SPO 00000_readme_first.txt APP
PRO
PRO end of setup
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
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
UNDEF 1

-- alert log (3 methods) note: prefix of &&edb360_sections. is to bypass lsnr when requesting some section(s)
COL db_name_upper NEW_V db_name_upper;
COL db_name_lower NEW_V db_name_lower;
COL background_dump_dest NEW_V background_dump_dest;
SELECT UPPER(SYS_CONTEXT('USERENV', 'DB_NAME')) db_name_upper FROM DUAL;
SELECT LOWER(SYS_CONTEXT('USERENV', 'DB_NAME')) db_name_lower FROM DUAL;
SELECT value background_dump_dest FROM v$parameter WHERE name = 'background_dump_dest';
HOS &&edb360_sections.cp &&background_dump_dest./alert_&&db_name_upper.*.log . >> &&edb360_log3..txt
HOS &&edb360_sections.cp &&background_dump_dest./alert_&&db_name_lower.*.log . >> &&edb360_log3..txt
HOS &&edb360_sections.cp &&background_dump_dest./alert_&&_connect_identifier..log . >> &&edb360_log3..txt
HOS &&edb360_sections.rename alert_ 00006_&&common_edb360_prefix._alert_ alert_*.log >> &&edb360_log3..txt

-- listener log (last 100K + counts per hour) note: prefix of &&edb360_sections. is to bypass lsnr when requesting some section(s)
HOS &&edb360_sections.lsnrctl show trc_directory | grep trc_directory | awk '{print "HOS cat "$6"/listener.log | fgrep \"establish\" | awk '\''{ print $1\",\"$2 }'\'' | awk -F: '\''{ print \",\"$1 }'\'' | uniq -c > listener_logons.csv"} END {print "HOS sed -i '\''1s/^/COUNT ,DATE,HOUR\\n/'\'' listener_logons.csv"}' > listener_log_driver.sql
HOS &&edb360_sections.lsnrctl show trc_directory | grep trc_directory | awk 'BEGIN {b = "HOS tail -100000000c "; e = " > listener_tail.log"} {print b, $6"/listener.log", e } END {print "HOS zip -m listener_log.zip listener_logons.csv listener_tail.log listener_log_driver.sql"}' >> listener_log_driver.sql
@&&edb360_sections.listener_log_driver.sql
HOS &&edb360_sections.zip -m &&edb360_main_filename._&&edb360_file_time. listener_log.zip >> &&edb360_log3..txt
HOS rm listener_log_driver.sql

-- zip 
HOS zip -m &&edb360_main_filename._&&edb360_file_time. &&common_edb360_prefix._query.sql >> &&edb360_log3..txt
HOS zip -d &&edb360_main_filename._&&edb360_file_time. &&common_edb360_prefix._query.sql >> &&edb360_log3..txt
-- prefix &&edb360_sections. is to bypass alert and opatch when a section is requested
HOS &&edb360_sections.zip -m &&edb360_main_filename._&&edb360_file_time. 00006_&&common_edb360_prefix._alert_*.log >> &&edb360_log3..txt
HOS &&edb360_sections.zip -j 00007_&&common_edb360_prefix._opatch $ORACLE_HOME/cfgtoollogs/opatch/opatch* >> &&edb360_log3..txt
HOS &&edb360_sections.zip -m &&edb360_main_filename._&&edb360_file_time. 00007_&&common_edb360_prefix._opatch.zip >> &&edb360_log3..txt
HOS zip -m &&edb360_main_filename._&&edb360_file_time. &&edb360_log2..txt >> &&edb360_log3..txt
--HOS zip -m &&edb360_main_filename._&&edb360_file_time. awrinfo.txt >> &&edb360_log3..txt
HOS zip -m &&edb360_main_filename._&&edb360_file_time. &&edb360_tkprof._sort.txt >> &&edb360_log3..txt
HOS zip -m &&edb360_main_filename._&&edb360_file_time. &&edb360_log..txt >> &&edb360_log3..txt
HOS zip -m &&edb360_main_filename._&&edb360_file_time. &&edb360_main_report..html >> &&edb360_log3..txt
HOS zip -m &&edb360_main_filename._&&edb360_file_time. 00000_readme_first.txt >> &&edb360_log3..txt
HOS unzip -l &&edb360_main_filename._&&edb360_file_time. >> &&edb360_log3..txt
HOS zip -m &&edb360_main_filename._&&edb360_file_time. &&edb360_log3..txt
SET TERM ON;
