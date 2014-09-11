DEF section_name = 'Active Session History (ASH) on Wait Class';
SPO &&main_report_name..html APP;
PRO <h2>&&section_name.</h2>
SPO OFF;

DEF skip_lch = '';
DEF title = 'AAS Waiting on Administrative per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Administrative''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_administrative');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Application per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Application''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_application');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Cluster per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Cluster''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_cluster');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Commit per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Commit''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_commit');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Concurrency per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Concurrency''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_concurrency');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Configuration per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Configuration''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_configuration');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Idle per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Idle''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_idle');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Network per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Network''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_network');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Other per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Other''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_other');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Queueing per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Queueing''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_queueing');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on Scheduler per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''Scheduler''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_scheduler');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on System IO per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''System I/O''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_system_io');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on User IO per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = ''User I/O''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_user_io');
@@&&skip_diagnostics.edb360_9a_pre_one.sql
