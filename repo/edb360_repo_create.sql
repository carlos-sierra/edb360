SPO edb360_repo_create_log.txt;

-- display what it does
SET ECHO ON VER ON TIM ON TIMI ON;

-- constants
DEF edb360_repo_days = '31';
-- prefix should be 9 or less characters
DEF edb360_repo_prefix = 'edb360_';

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
SELECT TO_CHAR(MIN(snap_id)) edb360_repo_min_snap_id FROM dba_hist_snapshot WHERE dbid = &&edb360_repo_dbid. AND CAST(begin_interval_time AS DATE) > TRUNC(SYSDATE) - &&edb360_repo_days.;

-- get max_snap_id
COL edb360_repo_max_snap_id NEW_V edb360_repo_max_snap_id;
SELECT TO_CHAR(MAX(snap_id)) edb360_repo_max_snap_id FROM dba_hist_snapshot WHERE dbid = &&edb360_repo_dbid.;

------------------------------------------------------------------------------------------
-- create awr repository. it may error if already exists.
------------------------------------------------------------------------------------------

CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.active_sess_history  AS SELECT * FROM dba_hist_active_sess_history  WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.database_instance    AS SELECT * FROM dba_hist_database_instance    WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.event_histogram      AS SELECT * FROM dba_hist_event_histogram      WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.ic_client_stats      AS SELECT * FROM dba_hist_ic_client_stats      WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.ic_device_stats      AS SELECT * FROM dba_hist_ic_device_stats      WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.interconnect_pings   AS SELECT * FROM dba_hist_interconnect_pings   WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.memory_resize_ops    AS SELECT * FROM dba_hist_memory_resize_ops    WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.memory_target_advice AS SELECT * FROM dba_hist_memory_target_advice WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.osstat               AS SELECT * FROM dba_hist_osstat               WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.parameter            AS SELECT * FROM dba_hist_parameter            WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.pgastat              AS SELECT * FROM dba_hist_pgastat              WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.resource_limit       AS SELECT * FROM dba_hist_resource_limit       WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.service_name         AS SELECT * FROM dba_hist_service_name         WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.sga                  AS SELECT * FROM dba_hist_sga                  WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.sgastat              AS SELECT * FROM dba_hist_sgastat              WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.sql_plan             AS SELECT * FROM dba_hist_sql_plan             WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.sqlstat              AS SELECT * FROM dba_hist_sqlstat              WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.sqltext              AS SELECT * FROM dba_hist_sqltext              WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.sys_time_model       AS SELECT * FROM dba_hist_sys_time_model       WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.sysmetric_history    AS SELECT * FROM dba_hist_sysmetric_history    WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.sysmetric_summary    AS SELECT * FROM dba_hist_sysmetric_summary    WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.sysstat              AS SELECT * FROM dba_hist_sysstat              WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.system_event         AS SELECT * FROM dba_hist_system_event         WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.tbspc_space_usage    AS SELECT * FROM dba_hist_tbspc_space_usage    WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.wr_control           AS SELECT * FROM dba_hist_wr_control           WHERE 1 = 2;
CREATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.snapshot             AS SELECT * FROM dba_hist_snapshot             WHERE 1 = 2;

------------------------------------------------------------------------------------------
-- grant select on awr repository to select_catalog_role.
------------------------------------------------------------------------------------------

GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.active_sess_history  TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.database_instance    TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.event_histogram      TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.ic_client_stats      TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.ic_device_stats      TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.interconnect_pings   TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.memory_resize_ops    TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.memory_target_advice TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.osstat               TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.parameter            TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.pgastat              TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.resource_limit       TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.service_name         TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.sga                  TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.sgastat              TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.sql_plan             TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.sqlstat              TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.sqltext              TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.sys_time_model       TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.sysmetric_history    TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.sysmetric_summary    TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.sysstat              TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.system_event         TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.tbspc_space_usage    TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.wr_control           TO SELECT_CATALOG_ROLE;
GRANT SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.snapshot             TO SELECT_CATALOG_ROLE;

------------------------------------------------------------------------------------------
-- use basic compression. no license required.
------------------------------------------------------------------------------------------

ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.active_sess_history  COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.database_instance    COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.event_histogram      COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.ic_client_stats      COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.ic_device_stats      COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.interconnect_pings   COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.memory_resize_ops    COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.memory_target_advice COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.osstat               COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.parameter            COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.pgastat              COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.resource_limit       COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.service_name         COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.sga                  COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.sgastat              COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.sql_plan             COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.sqlstat              COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.sqltext              COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.sys_time_model       COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.sysmetric_history    COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.sysmetric_summary    COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.sysstat              COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.system_event         COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.tbspc_space_usage    COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.wr_control           COMPRESS;
ALTER TABLE &&edb360_repo_user..&&edb360_repo_prefix.snapshot             COMPRESS;

------------------------------------------------------------------------------------------
-- truncate tables. useful to re-upload existing awr repository.
------------------------------------------------------------------------------------------

TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.active_sess_history  ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.database_instance    ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.event_histogram      ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.ic_client_stats      ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.ic_device_stats      ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.interconnect_pings   ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.memory_resize_ops    ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.memory_target_advice ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.osstat               ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.parameter            ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.pgastat              ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.resource_limit       ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.service_name         ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.sga                  ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.sgastat              ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.sql_plan             ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.sqlstat              ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.sqltext              ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.sys_time_model       ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.sysmetric_history    ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.sysmetric_summary    ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.sysstat              ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.system_event         ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.tbspc_space_usage    ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.wr_control           ;
TRUNCATE TABLE &&edb360_repo_user..&&edb360_repo_prefix.snapshot             ;

------------------------------------------------------------------------------------------
-- load awr repository. use direct-path to enable compression.
------------------------------------------------------------------------------------------

INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.active_sess_history  SELECT * FROM dba_hist_active_sess_history  WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.database_instance    SELECT * FROM dba_hist_database_instance    WHERE dbid = &&edb360_repo_dbid.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.event_histogram      SELECT * FROM dba_hist_event_histogram      WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.ic_client_stats      SELECT * FROM dba_hist_ic_client_stats      WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.ic_device_stats      SELECT * FROM dba_hist_ic_device_stats      WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.interconnect_pings   SELECT * FROM dba_hist_interconnect_pings   WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.memory_resize_ops    SELECT * FROM dba_hist_memory_resize_ops    WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.memory_target_advice SELECT * FROM dba_hist_memory_target_advice WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.osstat               SELECT * FROM dba_hist_osstat               WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.parameter            SELECT * FROM dba_hist_parameter            WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.pgastat              SELECT * FROM dba_hist_pgastat              WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.resource_limit       SELECT * FROM dba_hist_resource_limit       WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.service_name         SELECT * FROM dba_hist_service_name         WHERE dbid = &&edb360_repo_dbid.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.sga                  SELECT * FROM dba_hist_sga                  WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.sgastat              SELECT * FROM dba_hist_sgastat              WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.sql_plan             SELECT * FROM dba_hist_sql_plan             WHERE dbid = &&edb360_repo_dbid.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.sqlstat              SELECT * FROM dba_hist_sqlstat              WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.sqltext              SELECT * FROM dba_hist_sqltext              WHERE dbid = &&edb360_repo_dbid.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.sys_time_model       SELECT * FROM dba_hist_sys_time_model       WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.sysmetric_history    SELECT * FROM dba_hist_sysmetric_history    WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.sysmetric_summary    SELECT * FROM dba_hist_sysmetric_summary    WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.sysstat              SELECT * FROM dba_hist_sysstat              WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.system_event         SELECT * FROM dba_hist_system_event         WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.tbspc_space_usage    SELECT * FROM dba_hist_tbspc_space_usage    WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.wr_control           SELECT * FROM dba_hist_wr_control           WHERE dbid = &&edb360_repo_dbid.;
COMMIT;
INSERT /*+ APPEND */ INTO &&edb360_repo_user..&&edb360_repo_prefix.snapshot             SELECT * FROM dba_hist_snapshot             WHERE dbid = &&edb360_repo_dbid. AND snap_id BETWEEN &&edb360_repo_min_snap_id. AND &&edb360_repo_max_snap_id.;
COMMIT;

------------------------------------------------------------------------------------------
-- gather cbo statistics.
------------------------------------------------------------------------------------------

EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.active_sess_history  '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.database_instance    '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.event_histogram      '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.ic_client_stats      '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.ic_device_stats      '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.interconnect_pings   '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.memory_resize_ops    '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.memory_target_advice '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.osstat               '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.parameter            '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.pgastat              '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.resource_limit       '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.service_name         '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.sga                  '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.sgastat              '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.sql_plan             '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.sqlstat              '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.sqltext              '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.sys_time_model       '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.sysmetric_history    '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.sysmetric_summary    '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.sysstat              '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.system_event         '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.tbspc_space_usage    '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.wr_control           '));
EXEC DBMS_STATS.GATHER_TABLE_STATS('&&edb360_repo_user.', TRIM('&&edb360_repo_prefix.snapshot             '));

------------------------------------------------------------------------------------------
-- repository summary
------------------------------------------------------------------------------------------

-- range of dates on repository
SELECT MIN(end_interval_time), MAX(end_interval_time) FROM &&edb360_repo_user..&&edb360_repo_prefix.snapshot;

-- list of repository tables with num_rows and blocks
SELECT table_name, num_rows, blocks FROM dba_tables WHERE owner = UPPER('&&edb360_repo_user.') AND table_name LIKE UPPER('&&edb360_repo_prefix.%') ORDER BY table_name;

-- table count and total rows and blocks
SELECT COUNT(*) tables, SUM(num_rows), SUM(blocks) FROM dba_tables WHERE owner = UPPER('&&edb360_repo_user.') AND table_name LIKE UPPER('&&edb360_repo_prefix.%');

-- edb360 repository size in GBs
SELECT ROUND(MIN(TO_NUMBER(p.value)) * SUM(blocks) / POWER(10,9), 3) repo_size_gb FROM v$parameter p, dba_tables t WHERE p.name = 'db_block_size' AND t.owner = UPPER('&&edb360_repo_user.') AND t.table_name LIKE UPPER('&&edb360_repo_prefix.%');

SPO OFF;