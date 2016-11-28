@@&&edb360_0g.tkprof.sql
DEF section_id = '2c';
DEF section_name = 'Automatic Storage Management (ASM)';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'ASM Attributes';
DEF main_table = 'V$ASM_ATTRIBUTE';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$asm_attribute
 ORDER BY
       1, 2
';
END;
/
@@&&skip_10g.edb360_9a_pre_one.sql

DEF title = 'ASM Client';
DEF main_table = 'V$ASM_CLIENT';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$asm_client
 ORDER BY
       1, 2
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'ASM Template';
DEF main_table = 'V$ASM_TEMPLATE';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$asm_template
 ORDER BY
       1, 2
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'ASM Disk Group';
DEF main_table = 'V$ASM_DISKGROUP';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$asm_diskgroup
 ORDER BY
       1, 2
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'ASM Disk Group Stat';
DEF main_table = 'V$ASM_DISKGROUP_STAT';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$asm_diskgroup_stat
 ORDER BY
       1, 2
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'ASM Disk';
DEF main_table = 'V$ASM_DISK';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$asm_disk
 ORDER BY
       1, 2
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'ASM Disk Stat';
DEF main_table = 'V$ASM_DISK_STAT';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$asm_disk_stat
 ORDER BY
       1, 2
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'ASM Disk IO Stats';
DEF main_table = 'GV$ASM_DISK_IOSTAT';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM gv$asm_disk_iostat
 ORDER BY
       1, 2, 3, 4, 5
';
END;
/
@@&&skip_10g.edb360_9a_pre_one.sql

DEF title = 'ASM File';
DEF main_table = 'V$ASM_FILE';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM v$asm_file
';
END;
/
@@edb360_9a_pre_one.sql

-- special addition from MOS 1551288.1
-- add seq to spool_filename
EXEC :file_seq := :file_seq + 1;
SELECT '&&common_edb360_prefix._&&section_id._'||LPAD(:file_seq, 5, '0')||'_failure_diskgroup_space_reserve_requirements' one_spool_filename FROM DUAL;
SPO &&one_spool_filename..txt
@@ck_free_17.sql
SPO OFF
HOS zip -m &&edb360_main_filename._&&edb360_file_time. &&one_spool_filename..txt >> &&edb360_log3..txt
-- update main report
SPO &&edb360_main_report..html APP;
PRO <li title="V$ASM_DISKGROUP">DISK and CELL Failure Diskgroup Space Reserve Requirements
PRO <a href="&&one_spool_filename..txt">text</a>
PRO </li>
SPO OFF;
HOS zip &&edb360_main_filename._&&edb360_file_time. &&edb360_main_report..html >> &&edb360_log3..txt
-- report sequence
EXEC :repo_seq := :repo_seq + 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;
