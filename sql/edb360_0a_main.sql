@@edb360_0b_pre.sql
DEF max_col_number = '7';
DEF column_number = '0';
SPO &&main_report_name..html APP;
PRO <table><tr>
PRO <td class="c">1/&&max_col_number.</td>
PRO <td class="c">2/&&max_col_number.</td>
PRO <td class="c">3/&&max_col_number.</td>
PRO <td class="c">4/&&max_col_number.</td>
PRO <td class="c">5/&&max_col_number.</td>
PRO <td class="c">6/&&max_col_number.</td>
PRO <td class="c">7/&&max_col_number.</td>
PRO </tr><tr><td>
PRO
SPO OFF;

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '1';

@@edb360_1a_configuration.sql
@@edb360_1b_security.sql
@@edb360_1c_memory.sql
@@edb360_1d_resources.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '2';

SPO &&main_report_name..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@edb360_2a_admin.sql
@@edb360_2b_storage.sql
@@edb360_2c_asm.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '3';

SPO &&main_report_name..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@edb360_3a_resource_mgm.sql
@@edb360_3b_plan_stability.sql
@@edb360_3c_cbo_stats.sql
@@edb360_3d_performance.sql
@@&&skip_diagnostics.edb360_3e_os_stats.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '4';

SPO &&main_report_name..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@&&skip_diagnostics.edb360_4a_sga_stats.sql
@@&&skip_diagnostics.edb360_4b_pga_stats.sql
@@&&skip_diagnostics.edb360_4c_mem_stats.sql
@@&&skip_diagnostics.edb360_4d_time_model.sql
@@&&skip_diagnostics.&&skip_10g.edb360_4e_io_waits.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '5';

SPO &&main_report_name..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@&&skip_diagnostics.edb360_5a_ash.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '6';

SPO &&main_report_name..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@&&skip_diagnostics.edb360_6a_ash_top.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

DEF column_number = '7';

SPO &&main_report_name..html APP;
PRO
PRO </td><td>
PRO
SPO OFF;

@@&&skip_diagnostics.edb360_7a_awrrpt.sql
@@&&skip_diagnostics.edb360_7b_addmrpt.sql
@@&&skip_diagnostics.edb360_7c_ashrpt.sql
@@&&skip_diagnostics.edb360_7d_sql_sample.sql

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- log footer
SPO &&edb360_log..txt APP;
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
DEF;
PRO
PRO end log
SPO OFF;

-- main footer
SPO &&main_report_name..html APP;
PRO
PRO </td></tr></table>
SPO OFF;
@@edb360_0c_post.sql