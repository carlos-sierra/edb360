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