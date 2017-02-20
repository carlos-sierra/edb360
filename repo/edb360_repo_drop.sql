SPO edb360_repo_drop_log.txt;

-- display what it does
SET ECHO ON VER ON TIM ON TIMI ON;

-- constants
DEF edb360_repo_prefix = 'edb360_';

-- list of repository owners
SELECT owner FROM dba_tables WHERE table_name = UPPER('&&edb360_repo_prefix.')||'SNAPSHOT';

-- parameter
ACC edb360_repo_user PROMPT 'eDB360 repository user: '

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

------------------------------------------------------------------------------------------
-- revoke select on awr repository from select_catalog_role.
------------------------------------------------------------------------------------------

REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.active_sess_history  FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.database_instance    FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.event_histogram      FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.ic_client_stats      FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.ic_device_stats      FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.interconnect_pings   FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.memory_resize_ops    FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.memory_target_advice FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.osstat               FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.parameter            FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.pgastat              FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.resource_limit       FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.service_name         FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.sga                  FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.sgastat              FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.sql_plan             FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.sqlstat              FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.sqltext              FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.sys_time_model       FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.sysmetric_history    FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.sysmetric_summary    FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.sysstat              FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.system_event         FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.tbspc_space_usage    FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.wr_control           FROM SELECT_CATALOG_ROLE;
REVOKE SELECT ON &&edb360_repo_user..&&edb360_repo_prefix.snapshot             FROM SELECT_CATALOG_ROLE;

------------------------------------------------------------------------------------------
-- drop awr repository.
------------------------------------------------------------------------------------------

DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.active_sess_history  ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.database_instance    ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.event_histogram      ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.ic_client_stats      ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.ic_device_stats      ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.interconnect_pings   ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.memory_resize_ops    ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.memory_target_advice ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.osstat               ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.parameter            ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.pgastat              ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.resource_limit       ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.service_name         ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.sga                  ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.sgastat              ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.sql_plan             ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.sqlstat              ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.sqltext              ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.sys_time_model       ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.sysmetric_history    ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.sysmetric_summary    ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.sysstat              ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.system_event         ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.tbspc_space_usage    ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.wr_control           ;
DROP TABLE &&edb360_repo_user..&&edb360_repo_prefix.snapshot             ;

SPO OFF;