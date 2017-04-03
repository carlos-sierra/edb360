SPO repo_edb360_create_log.txt;

-- display what it does
SET ECHO ON VER ON TIM ON TIMI ON;

-- constants
DEF tool_repo_days = '31';
-- prefix for AWR "dba_hist_" views
DEF tool_prefix_1 = 'dba_hist#';
-- prefix for data dictionary "dba_" views
DEF tool_prefix_2 = 'dba#';
-- prefix for dynamic "gv$" views
DEF tool_prefix_3 = 'gv#';
-- prefix for dynamic "v$" views
DEF tool_prefix_4 = 'v#';

-- parameter
ACC tool_repo_user PROMPT 'tool repository user (i.e. edb360): '

WHENEVER SQLERROR EXIT SQL.SQLCODE;
BEGIN
  IF UPPER(TRIM('&&tool_repo_user.')) = 'SYS' THEN
    RAISE_APPLICATION_ERROR(-20000, 'SYS cannot be used as repository!');
  END IF;
END;
/
WHENEVER SQLERROR CONTINUE;

-- get dbid
COL tool_repo_dbid NEW_V tool_repo_dbid;
SELECT TO_CHAR(dbid) tool_repo_dbid FROM v$database;

-- get min_snap_id
COL tool_repo_min_snap_id NEW_V tool_repo_min_snap_id;
SELECT TO_CHAR(MIN(snap_id)) tool_repo_min_snap_id FROM dba_hist_snapshot WHERE dbid = &&tool_repo_dbid. AND CAST(begin_interval_time AS DATE) > TRUNC(SYSDATE) - &&tool_repo_days.;

-- get max_snap_id
COL tool_repo_max_snap_id NEW_V tool_repo_max_snap_id;
SELECT TO_CHAR(MAX(snap_id)) tool_repo_max_snap_id FROM dba_hist_snapshot WHERE dbid = &&tool_repo_dbid.;

------------------------------------------------------------------------------------------
-- create tool repository. it may error if already exists.
------------------------------------------------------------------------------------------

CREATE TABLE &&tool_repo_user..&&tool_prefix_1.active_sess_history  COMPRESS AS SELECT * FROM dba_hist_active_sess_history  WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.event_histogram      COMPRESS AS SELECT * FROM dba_hist_event_histogram      WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.ic_client_stats      COMPRESS AS SELECT * FROM dba_hist_ic_client_stats      WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.ic_device_stats      COMPRESS AS SELECT * FROM dba_hist_ic_device_stats      WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.interconnect_pings   COMPRESS AS SELECT * FROM dba_hist_interconnect_pings   WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.memory_resize_ops    COMPRESS AS SELECT * FROM dba_hist_memory_resize_ops    WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.memory_target_advice COMPRESS AS SELECT * FROM dba_hist_memory_target_advice WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.osstat               COMPRESS AS SELECT * FROM dba_hist_osstat               WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.parameter            COMPRESS AS SELECT * FROM dba_hist_parameter            WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.pgastat              COMPRESS AS SELECT * FROM dba_hist_pgastat              WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.resource_limit       COMPRESS AS SELECT * FROM dba_hist_resource_limit       WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.seg_stat             COMPRESS AS SELECT * FROM dba_hist_seg_stat             WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.sga                  COMPRESS AS SELECT * FROM dba_hist_sga                  WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.sgastat              COMPRESS AS SELECT * FROM dba_hist_sgastat              WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.sqlstat              COMPRESS AS SELECT * FROM dba_hist_sqlstat              WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.snapshot             COMPRESS AS SELECT * FROM dba_hist_snapshot             WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.sys_time_model       COMPRESS AS SELECT * FROM dba_hist_sys_time_model       WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.sysmetric_history    COMPRESS AS SELECT * FROM dba_hist_sysmetric_history    WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.sysmetric_summary    COMPRESS AS SELECT * FROM dba_hist_sysmetric_summary    WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.sysstat              COMPRESS AS SELECT * FROM dba_hist_sysstat              WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.system_event         COMPRESS AS SELECT * FROM dba_hist_system_event         WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.tbspc_space_usage    COMPRESS AS SELECT * FROM dba_hist_tbspc_space_usage    WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;

CREATE TABLE &&tool_repo_user..&&tool_prefix_1.database_instance    COMPRESS AS SELECT * FROM dba_hist_database_instance    WHERE dbid = &&tool_repo_dbid.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.service_name         COMPRESS AS SELECT * FROM dba_hist_service_name         WHERE dbid = &&tool_repo_dbid.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.sql_plan             COMPRESS AS SELECT * FROM dba_hist_sql_plan             WHERE dbid = &&tool_repo_dbid.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.sqltext              COMPRESS AS SELECT * FROM dba_hist_sqltext              WHERE dbid = &&tool_repo_dbid.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.wr_control           COMPRESS AS SELECT * FROM dba_hist_wr_control           WHERE dbid = &&tool_repo_dbid.;

CREATE TABLE &&tool_repo_user..&&tool_prefix_2.2pc_neighbors              COMPRESS AS SELECT * FROM dba_2pc_neighbors             ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.2pc_pending                COMPRESS AS SELECT * FROM dba_2pc_pending               ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.all_tables                 COMPRESS AS SELECT * FROM dba_all_tables                ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.audit_mgmt_config_params   COMPRESS AS SELECT * FROM dba_audit_mgmt_config_params  ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.autotask_client            COMPRESS AS SELECT * FROM dba_autotask_client           ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.autotask_client_history    COMPRESS AS SELECT * FROM dba_autotask_client_history   ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.cons_columns               COMPRESS AS SELECT * FROM dba_cons_columns              ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.constraints                COMPRESS AS SELECT * FROM dba_constraints               ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.data_files                 COMPRESS AS SELECT * FROM dba_data_files                ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.db_links                   COMPRESS AS SELECT * FROM dba_db_links                  ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.extents                    COMPRESS AS SELECT * FROM dba_extents                   ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.external_tables            COMPRESS AS SELECT * FROM dba_external_tables           ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.feature_usage_statistics   COMPRESS AS SELECT * FROM dba_feature_usage_statistics  ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.free_space                 COMPRESS AS SELECT * FROM dba_free_space                ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.high_water_mark_statistics COMPRESS AS SELECT * FROM dba_high_water_mark_statistics;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.ind_columns                COMPRESS AS SELECT * FROM dba_ind_columns               ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.ind_partitions             COMPRESS AS SELECT * FROM dba_ind_partitions            ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.ind_statistics             COMPRESS AS SELECT * FROM dba_ind_statistics            ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.ind_subpartitions          COMPRESS AS SELECT * FROM dba_ind_subpartitions         ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.indexes                    COMPRESS AS SELECT * FROM dba_indexes                   ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.jobs                       COMPRESS AS SELECT * FROM dba_jobs                      ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.jobs_running               COMPRESS AS SELECT * FROM dba_jobs_running              ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.lob_partitions             COMPRESS AS SELECT * FROM dba_lob_partitions            ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.lob_subpartitions          COMPRESS AS SELECT * FROM dba_lob_subpartitions         ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.lobs                       COMPRESS AS SELECT * FROM dba_lobs                      ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.obj_audit_opts             COMPRESS AS SELECT * FROM dba_obj_audit_opts            ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.objects                    COMPRESS AS SELECT * FROM dba_objects                   ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.pdbs                       COMPRESS AS SELECT * FROM dba_pdbs                      ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.priv_audit_opts            COMPRESS AS SELECT * FROM dba_priv_audit_opts           ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.procedures                 COMPRESS AS SELECT * FROM dba_procedures                ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.profiles                   COMPRESS AS SELECT * FROM dba_profiles                  ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.recyclebin                 COMPRESS AS SELECT * FROM dba_recyclebin                ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.registry                   COMPRESS AS SELECT * FROM dba_registry                  ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.registry_hierarchy         COMPRESS AS SELECT * FROM dba_registry_hierarchy        ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.registry_history           COMPRESS AS SELECT * FROM dba_registry_history          ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.registry_sqlpatch          COMPRESS AS SELECT * FROM dba_registry_sqlpatch         ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.role_privs                 COMPRESS AS SELECT * FROM dba_role_privs                ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.roles                      COMPRESS AS SELECT * FROM dba_roles                     ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.rsrc_consumer_group_privs  COMPRESS AS SELECT * FROM dba_rsrc_consumer_group_privs ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.rsrc_consumer_groups       COMPRESS AS SELECT * FROM dba_rsrc_consumer_groups      ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.rsrc_group_mappings        COMPRESS AS SELECT * FROM dba_rsrc_group_mappings       ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.rsrc_io_calibrate          COMPRESS AS SELECT * FROM dba_rsrc_io_calibrate         ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.rsrc_mapping_priority      COMPRESS AS SELECT * FROM dba_rsrc_mapping_priority     ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.rsrc_plan_directives       COMPRESS AS SELECT * FROM dba_rsrc_plan_directives      ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.rsrc_plans                 COMPRESS AS SELECT * FROM dba_rsrc_plans                ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.scheduler_job_log          COMPRESS AS SELECT * FROM dba_scheduler_job_log         ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.scheduler_jobs             COMPRESS AS SELECT * FROM dba_scheduler_jobs            ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.scheduler_windows          COMPRESS AS SELECT * FROM dba_scheduler_windows         ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.scheduler_wingroup_members COMPRESS AS SELECT * FROM dba_scheduler_wingroup_members;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.segments                   COMPRESS AS SELECT * FROM dba_segments                  ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.sequences                  COMPRESS AS SELECT * FROM dba_sequences                 ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.source                     COMPRESS AS SELECT * FROM dba_source                    ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.sql_patches                COMPRESS AS SELECT * FROM dba_sql_patches               ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.sql_plan_baselines         COMPRESS AS SELECT * FROM dba_sql_plan_baselines        ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.sql_plan_dir_objects       COMPRESS AS SELECT * FROM dba_sql_plan_dir_objects      ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.sql_plan_directives        COMPRESS AS SELECT * FROM dba_sql_plan_directives       ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.sql_profiles               COMPRESS AS SELECT * FROM dba_sql_profiles              ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.stat_extensions            COMPRESS AS SELECT * FROM dba_stat_extensions           ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.stmt_audit_opts            COMPRESS AS SELECT * FROM dba_stmt_audit_opts           ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.synonyms                   COMPRESS AS SELECT * FROM dba_synonyms                  ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.sys_privs                  COMPRESS AS SELECT * FROM dba_sys_privs                 ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tab_cols                   COMPRESS AS SELECT * FROM dba_tab_cols                  ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tab_columns                COMPRESS AS SELECT * FROM dba_tab_columns               ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tab_modifications          COMPRESS AS SELECT * FROM dba_tab_modifications         ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tab_partitions             COMPRESS AS SELECT * FROM dba_tab_partitions            ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tab_privs                  COMPRESS AS SELECT * FROM dba_tab_privs                 ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tab_statistics             COMPRESS AS SELECT * FROM dba_tab_statistics            ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tab_subpartitions          COMPRESS AS SELECT * FROM dba_tab_subpartitions         ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tables                     COMPRESS AS SELECT * FROM dba_tables                    ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tablespace_groups          COMPRESS AS SELECT * FROM dba_tablespace_groups         ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tablespaces                COMPRESS AS SELECT * FROM dba_tablespaces               ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.temp_files                 COMPRESS AS SELECT * FROM dba_temp_files                ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.triggers                   COMPRESS AS SELECT * FROM dba_triggers                  ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.ts_quotas                  COMPRESS AS SELECT * FROM dba_ts_quotas                 ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.unused_col_tabs            COMPRESS AS SELECT * FROM dba_unused_col_tabs           ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.users                      COMPRESS AS SELECT * FROM dba_users                     ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.views                      COMPRESS AS SELECT * FROM dba_views                     ;

------------------------------------------------------------------------------------------
-- grant select on repository table to select_catalog_role and gather cbo stats
------------------------------------------------------------------------------------------

BEGIN
  FOR i IN (SELECT owner, table_name FROM dba_tables WHERE owner = UPPER('&&tool_repo_user.') AND (table_name LIKE UPPER('&&tool_prefix_1.%') OR table_name LIKE UPPER('&&tool_prefix_2.%') OR table_name LIKE UPPER('&&tool_prefix_3.%') OR table_name LIKE UPPER('&&tool_prefix_4.%')))
  LOOP
    EXECUTE IMMEDIATE 'GRANT SELECT ON '||i.owner||'.'||i.table_name||' TO SELECT_CATALOG_ROLE';
    DBMS_STATS.GATHER_TABLE_STATS('&&tool_repo_user.',i.table_name);
  END LOOP;
END;
/

------------------------------------------------------------------------------------------
-- repository summary
------------------------------------------------------------------------------------------

-- range of dates on repository
SELECT MIN(end_interval_time), MAX(end_interval_time) FROM &&tool_repo_user..&&tool_prefix_1.snapshot;

-- list of repository tables with num_rows and blocks
SELECT table_name, num_rows, blocks FROM dba_tables WHERE owner = UPPER('&&tool_repo_user.') 
AND (table_name LIKE UPPER('&&tool_prefix_1.%') OR table_name LIKE UPPER('&&tool_prefix_2.%') OR table_name LIKE UPPER('&&tool_prefix_3.%') OR table_name LIKE UPPER('&&tool_prefix_4.%'))
ORDER BY table_name;

-- table count and total rows and blocks
SELECT COUNT(*) tables, SUM(num_rows), SUM(blocks) FROM dba_tables WHERE owner = UPPER('&&tool_repo_user.') 
AND (table_name LIKE UPPER('&&tool_prefix_1.%') OR table_name LIKE UPPER('&&tool_prefix_2.%') OR table_name LIKE UPPER('&&tool_prefix_3.%') OR table_name LIKE UPPER('&&tool_prefix_4.%'));

-- repository size in GBs
SELECT ROUND(MIN(TO_NUMBER(p.value)) * SUM(blocks) / POWER(10,9), 3) repo_size_gb FROM v$parameter p, dba_tables t WHERE p.name = 'db_block_size' AND t.owner = UPPER('&&tool_repo_user.') 
AND (table_name LIKE UPPER('&&tool_prefix_1.%') OR table_name LIKE UPPER('&&tool_prefix_2.%') OR table_name LIKE UPPER('&&tool_prefix_3.%') OR table_name LIKE UPPER('&&tool_prefix_4.%'));

SPO OFF;