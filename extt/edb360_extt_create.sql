SPO edb360_repo_create_log.txt;

-- display what it does
SET ECHO ON VER ON TIM ON TIMI ON LONG 32000000 LONGC 2000 PAGES 1000 LIN 1000 TRIMS ON; 

-- constants
DEF tool_repo_days = '31';
-- prefix should be 9 or less characters
DEF tool_repo_prefix = 'edb360_';
-- eadam directory
DEF eadam_dir = 'EADAM';
-- compression
COL tool_access_parameters NEW_V tool_access_parameters;
SELECT CASE WHEN version >= '11' THEN 'ACCESS PARAMETERS (COMPRESSION ENABLED)' END tool_access_parameters FROM v$instance;
-- external table syntax
DEF edb360_extt_syntax = 'ORGANIZATION EXTERNAL (TYPE ORACLE_DATAPUMP DEFAULT DIRECTORY &&eadam_dir. &&tool_access_parameters. LOCATION ('

-- parameter
ACC edb360_repo_user PROMPT 'eDB360 repository user: '

WHENEVER SQLERROR EXIT SQL.SQLCODE;
BEGIN
  IF UPPER(TRIM('&&edb360_repo_user.')) = 'SYS' THEN
    RAISE_APPLICATION_ERROR(-20000, 'SYS cannot be used as repository!');
  END IF;
END;
/
WHENEVER SQLERROR CONTINUE;

-- get dbid
COL edb360_repo_dbid NEW_V edb360_repo_dbid;
SELECT TO_CHAR(dbid) edb360_repo_dbid FROM v$database;

-- get min_snap_id
COL edb360_repo_min_snap_id NEW_V edb360_repo_min_snap_id;
SELECT TO_CHAR(MIN(snap_id)) edb360_repo_min_snap_id FROM dba_hist_snapshot WHERE dbid = &&edb360_repo_dbid. AND CAST(begin_interval_time AS DATE) > TRUNC(SYSDATE) - &&tool_repo_days.;

-- get max_snap_id
COL edb360_repo_max_snap_id NEW_V edb360_repo_max_snap_id;
SELECT TO_CHAR(MAX(snap_id)) edb360_repo_max_snap_id FROM dba_hist_snapshot WHERE dbid = &&edb360_repo_dbid.;

------------------------------------------------------------------------------------------
-- create awr repository. it may error if already exists.
------------------------------------------------------------------------------------------

CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.active_sess_history  &&edb360_extt_syntax.'dba_hist_active_sess_history.dmp' )) AS SELECT * FROM dba_hist_active_sess_history  WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.database_instance    &&edb360_extt_syntax.'dba_hist_database_instance.dmp'   )) AS SELECT * FROM dba_hist_database_instance    WHERE dbid = &&edb360_repo_dbid.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.event_histogram      &&edb360_extt_syntax.'dba_hist_event_histogram.dmp'     )) AS SELECT * FROM dba_hist_event_histogram      WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.ic_client_stats      &&edb360_extt_syntax.'dba_hist_ic_client_stats.dmp'     )) AS SELECT * FROM dba_hist_ic_client_stats      WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.ic_device_stats      &&edb360_extt_syntax.'dba_hist_ic_device_stats.dmp'     )) AS SELECT * FROM dba_hist_ic_device_stats      WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.interconnect_pings   &&edb360_extt_syntax.'dba_hist_interconnect_pings.dmp'  )) AS SELECT * FROM dba_hist_interconnect_pings   WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.memory_resize_ops    &&edb360_extt_syntax.'dba_hist_memory_resize_ops.dmp'   )) AS SELECT * FROM dba_hist_memory_resize_ops    WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.memory_target_advice &&edb360_extt_syntax.'dba_hist_memory_target_advice.dmp')) AS SELECT * FROM dba_hist_memory_target_advice WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.osstat               &&edb360_extt_syntax.'dba_hist_osstat.dmp'              )) AS SELECT * FROM dba_hist_osstat               WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.parameter            &&edb360_extt_syntax.'dba_hist_parameter.dmp'           )) AS SELECT * FROM dba_hist_parameter            WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.pgastat              &&edb360_extt_syntax.'dba_hist_pgastat.dmp'             )) AS SELECT * FROM dba_hist_pgastat              WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.resource_limit       &&edb360_extt_syntax.'dba_hist_resource_limit.dmp'      )) AS SELECT * FROM dba_hist_resource_limit       WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.service_name         &&edb360_extt_syntax.'dba_hist_service_name.dmp'        )) AS SELECT * FROM dba_hist_service_name         WHERE dbid = &&edb360_repo_dbid.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.sga                  &&edb360_extt_syntax.'dba_hist_sga.dmp'                 )) AS SELECT * FROM dba_hist_sga                  WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.sgastat              &&edb360_extt_syntax.'dba_hist_sgastat.dmp'             )) AS SELECT * FROM dba_hist_sgastat              WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.sql_plan             &&edb360_extt_syntax.'dba_hist_sql_plan.dmp'            )) AS SELECT * FROM dba_hist_sql_plan             WHERE dbid = &&edb360_repo_dbid.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.sqlstat              &&edb360_extt_syntax.'dba_hist_sqlstat.dmp'             )) AS SELECT * FROM dba_hist_sqlstat              WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.sqltext              &&edb360_extt_syntax.'dba_hist_sqltext.dmp'             )) AS SELECT * FROM dba_hist_sqltext              WHERE dbid = &&edb360_repo_dbid.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.sys_time_model       &&edb360_extt_syntax.'dba_hist_sys_time_model.dmp'      )) AS SELECT * FROM dba_hist_sys_time_model       WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.sysmetric_history    &&edb360_extt_syntax.'dba_hist_sysmetric_history.dmp'   )) AS SELECT * FROM dba_hist_sysmetric_history    WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.sysmetric_summary    &&edb360_extt_syntax.'dba_hist_sysmetric_summary.dmp'   )) AS SELECT * FROM dba_hist_sysmetric_summary    WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.sysstat              &&edb360_extt_syntax.'dba_hist_sysstat.dmp'             )) AS SELECT * FROM dba_hist_sysstat              WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.system_event         &&edb360_extt_syntax.'dba_hist_system_event.dmp'        )) AS SELECT * FROM dba_hist_system_event         WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.tbspc_space_usage    &&edb360_extt_syntax.'dba_hist_tbspc_space_usage.dmp'   )) AS SELECT * FROM dba_hist_tbspc_space_usage    WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.wr_control           &&edb360_extt_syntax.'dba_hist_wr_control.dmp'          )) AS SELECT * FROM dba_hist_wr_control           WHERE dbid = &&edb360_repo_dbid.;
CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.snapshot             &&edb360_extt_syntax.'dba_hist_snapshot.dmp'            )) AS SELECT * FROM dba_hist_snapshot             WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;

------------------------------------------------------------------------------------------
-- create metadata table with ddl commands to create new external tables
------------------------------------------------------------------------------------------

CREATE TABLE &&edb360_repo_user..&&tool_repo_prefix.external_tables_ddl &&edb360_extt_syntax.'&&tool_repo_prefix.external_tables_ddl.dmp' )) 
AS SELECT et.*, DBMS_METADATA.GET_DDL('TABLE', et.table_name, et.owner) dbms_metadata_get_ddl 
FROM dba_external_tables et WHERE et.owner = UPPER('&&edb360_repo_user.') AND et.table_name LIKE UPPER('&&tool_repo_prefix.%');

------------------------------------------------------------------------------------------
-- metadata ddl commands to create new external tables
------------------------------------------------------------------------------------------

SELECT DBMS_METADATA.GET_DDL('TABLE', et.table_name, et.owner) dbms_metadata_get_ddl 
FROM dba_external_tables et WHERE et.owner = UPPER('&&edb360_repo_user.') AND et.table_name LIKE UPPER('&&tool_repo_prefix.%');

------------------------------------------------------------------------------------------
-- grant select on awr repository to select_catalog_role.
------------------------------------------------------------------------------------------

GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.active_sess_history  TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.database_instance    TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.event_histogram      TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.ic_client_stats      TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.ic_device_stats      TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.interconnect_pings   TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.memory_resize_ops    TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.memory_target_advice TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.osstat               TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.parameter            TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.pgastat              TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.resource_limit       TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.service_name         TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.sga                  TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.sgastat              TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.sql_plan             TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.sqlstat              TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.sqltext              TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.sys_time_model       TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.sysmetric_history    TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.sysmetric_summary    TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.sysstat              TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.system_event         TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.tbspc_space_usage    TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.wr_control           TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.snapshot             TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&tool_repo_prefix.external_tables_ddl  TO SELECT_CATALOG_ROLE;

------------------------------------------------------------------------------------------
-- gather cbo statistics.
------------------------------------------------------------------------------------------

EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.active_sess_history  '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.database_instance    '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.event_histogram      '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.ic_client_stats      '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.ic_device_stats      '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.interconnect_pings   '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.memory_resize_ops    '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.memory_target_advice '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.osstat               '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.parameter            '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.pgastat              '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.resource_limit       '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.service_name         '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.sga                  '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.sgastat              '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.sql_plan             '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.sqlstat              '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.sqltext              '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.sys_time_model       '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.sysmetric_history    '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.sysmetric_summary    '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.sysstat              '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.system_event         '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.tbspc_space_usage    '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.wr_control           '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.snapshot             '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&tool_repo_prefix.external_tables_ddl  '));

------------------------------------------------------------------------------------------
-- repository summary
------------------------------------------------------------------------------------------

-- range of dates on repository
SELECT MIN(end_interval_time), MAX(end_interval_time) FROM &&edb360_repo_user..&&tool_repo_prefix.snapshot;

-- list of repository tables with num_rows and blocks
SELECT table_name, num_rows, blocks FROM dba_tables WHERE owner = UPPER('&&edb360_repo_user.') AND table_name LIKE UPPER('&&tool_repo_prefix.%') ORDER BY table_name;

-- table count and total rows and blocks
SELECT COUNT(*) tables, SUM(num_rows), SUM(blocks) FROM dba_tables WHERE owner = UPPER('&&edb360_repo_user.') AND table_name LIKE UPPER('&&tool_repo_prefix.%');

-- edb360 repository size in GBs
SELECT ROUND(MIN(TO_NUMBER(p.value)) * SUM(blocks) / POWER(10,9), 3) repo_size_gb FROM v$parameter p, dba_tables t WHERE p.name = 'db_block_size' AND t.owner = UPPER('&&edb360_repo_user.') AND t.table_name LIKE UPPER('&&tool_repo_prefix.%');

SPO OFF;