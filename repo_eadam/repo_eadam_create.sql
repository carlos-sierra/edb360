SPO repo_eadam_create_log.txt;

-- display what it does
SET ECHO ON VER ON TIM ON TIMI ON LONG 32000000 LONGC 2000 PAGES 1000 LIN 1000 TRIMS ON; 

-- constants
DEF tool_repo_days = '31';
-- prefix for eadam tables
DEF tool_prefix_0 = 'eadam#';
-- prefix for AWR "dba_hist_" views
DEF tool_prefix_1 = 'dba_hist#';
-- prefix for data dictionary "dba_" views
DEF tool_prefix_2 = 'dba#';
-- prefix for dynamic "gv$" views
DEF tool_prefix_3 = 'gv#';
-- prefix for dynamic "v$" views
DEF tool_prefix_4 = 'v#';
-- eadam directory
DEF eadam_dir = 'EADAM_DIR';
-- compression
COL tool_access_parameters NEW_V tool_access_parameters;
SELECT CASE WHEN version >= '11' THEN 'ACCESS PARAMETERS (COMPRESSION ENABLED)' END tool_access_parameters FROM v$instance;
-- external table syntax
DEF tool_extt_syntax = 'ORGANIZATION EXTERNAL (TYPE ORACLE_DATAPUMP DEFAULT DIRECTORY &&eadam_dir. &&tool_access_parameters. LOCATION ('

-- parameter
ACC tool_repo_user PROMPT 'tool repository user (i.e. eadam): '

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

CREATE TABLE &&tool_repo_user..&&tool_prefix_1.active_sess_history  &&tool_extt_syntax.'dba_hist_active_sess_history.dmp' )) AS SELECT * FROM dba_hist_active_sess_history  WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.event_histogram      &&tool_extt_syntax.'dba_hist_event_histogram.dmp'     )) AS SELECT * FROM dba_hist_event_histogram      WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.ic_client_stats      &&tool_extt_syntax.'dba_hist_ic_client_stats.dmp'     )) AS SELECT * FROM dba_hist_ic_client_stats      WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.ic_device_stats      &&tool_extt_syntax.'dba_hist_ic_device_stats.dmp'     )) AS SELECT * FROM dba_hist_ic_device_stats      WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.interconnect_pings   &&tool_extt_syntax.'dba_hist_interconnect_pings.dmp'  )) AS SELECT * FROM dba_hist_interconnect_pings   WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.memory_resize_ops    &&tool_extt_syntax.'dba_hist_memory_resize_ops.dmp'   )) AS SELECT * FROM dba_hist_memory_resize_ops    WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.memory_target_advice &&tool_extt_syntax.'dba_hist_memory_target_advice.dmp')) AS SELECT * FROM dba_hist_memory_target_advice WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.osstat               &&tool_extt_syntax.'dba_hist_osstat.dmp'              )) AS SELECT * FROM dba_hist_osstat               WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.parameter            &&tool_extt_syntax.'dba_hist_parameter.dmp'           )) AS SELECT * FROM dba_hist_parameter            WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.pgastat              &&tool_extt_syntax.'dba_hist_pgastat.dmp'             )) AS SELECT * FROM dba_hist_pgastat              WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.resource_limit       &&tool_extt_syntax.'dba_hist_resource_limit.dmp'      )) AS SELECT * FROM dba_hist_resource_limit       WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.seg_stat             &&tool_extt_syntax.'dba_hist_seg_stat.dmp'            )) AS SELECT * FROM dba_hist_seg_stat             WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.sga                  &&tool_extt_syntax.'dba_hist_sga.dmp'                 )) AS SELECT * FROM dba_hist_sga                  WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.sgastat              &&tool_extt_syntax.'dba_hist_sgastat.dmp'             )) AS SELECT * FROM dba_hist_sgastat              WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.sqlstat              &&tool_extt_syntax.'dba_hist_sqlstat.dmp'             )) AS SELECT * FROM dba_hist_sqlstat              WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.snapshot             &&tool_extt_syntax.'dba_hist_snapshot.dmp'            )) AS SELECT * FROM dba_hist_snapshot             WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.sys_time_model       &&tool_extt_syntax.'dba_hist_sys_time_model.dmp'      )) AS SELECT * FROM dba_hist_sys_time_model       WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.sysmetric_history    &&tool_extt_syntax.'dba_hist_sysmetric_history.dmp'   )) AS SELECT * FROM dba_hist_sysmetric_history    WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.sysmetric_summary    &&tool_extt_syntax.'dba_hist_sysmetric_summary.dmp'   )) AS SELECT * FROM dba_hist_sysmetric_summary    WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.sysstat              &&tool_extt_syntax.'dba_hist_sysstat.dmp'             )) AS SELECT * FROM dba_hist_sysstat              WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.system_event         &&tool_extt_syntax.'dba_hist_system_event.dmp'        )) AS SELECT * FROM dba_hist_system_event         WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.tbspc_space_usage    &&tool_extt_syntax.'dba_hist_tbspc_space_usage.dmp'   )) AS SELECT * FROM dba_hist_tbspc_space_usage    WHERE dbid = &&tool_repo_dbid. AND snap_id BETWEEN &&tool_repo_min_snap_id. AND &&tool_repo_max_snap_id.;

CREATE TABLE &&tool_repo_user..&&tool_prefix_1.database_instance    &&tool_extt_syntax.'dba_hist_database_instance.dmp'   )) AS SELECT * FROM dba_hist_database_instance    WHERE dbid = &&tool_repo_dbid.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.service_name         &&tool_extt_syntax.'dba_hist_service_name.dmp'        )) AS SELECT * FROM dba_hist_service_name         WHERE dbid = &&tool_repo_dbid.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.sql_plan             &&tool_extt_syntax.'dba_hist_sql_plan.dmp'            )) AS SELECT * FROM dba_hist_sql_plan             WHERE dbid = &&tool_repo_dbid.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.sqltext              &&tool_extt_syntax.'dba_hist_sqltext.dmp'             )) AS SELECT * FROM dba_hist_sqltext              WHERE dbid = &&tool_repo_dbid.;
CREATE TABLE &&tool_repo_user..&&tool_prefix_1.wr_control           &&tool_extt_syntax.'dba_hist_wr_control.dmp'          )) AS SELECT * FROM dba_hist_wr_control           WHERE dbid = &&tool_repo_dbid.;

CREATE TABLE &&tool_repo_user..&&tool_prefix_2.2pc_neighbors              &&tool_extt_syntax.'dba_2pc_neighbors.dmp'                )) AS SELECT * FROM dba_2pc_neighbors             ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.2pc_pending                &&tool_extt_syntax.'dba_2pc_pending.dmp'                  )) AS SELECT * FROM dba_2pc_pending               ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.all_tables                 &&tool_extt_syntax.'dba_all_tables.dmp'                   )) AS SELECT * FROM dba_all_tables                ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.audit_mgmt_config_params   &&tool_extt_syntax.'dba_audit_mgmt_config_params.dmp'     )) AS SELECT * FROM dba_audit_mgmt_config_params  ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.autotask_client            &&tool_extt_syntax.'dba_autotask_client.dmp'              )) AS SELECT * FROM dba_autotask_client           ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.autotask_client_history    &&tool_extt_syntax.'dba_autotask_client_history.dmp'      )) AS SELECT * FROM dba_autotask_client_history   ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.cons_columns               &&tool_extt_syntax.'dba_cons_columns.dmp'                 )) AS SELECT * FROM dba_cons_columns              ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.constraints                &&tool_extt_syntax.'dba_constraints.dmp'                  )) AS SELECT * FROM dba_constraints               ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.data_files                 &&tool_extt_syntax.'dba_data_files.dmp'                   )) AS SELECT * FROM dba_data_files                ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.db_links                   &&tool_extt_syntax.'dba_db_links.dmp'                     )) AS SELECT * FROM dba_db_links                  ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.extents                    &&tool_extt_syntax.'dba_extents.dmp'                      )) AS SELECT * FROM dba_extents                   ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.external_tables            &&tool_extt_syntax.'dba_external_tables.dmp'              )) AS SELECT * FROM dba_external_tables           ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.feature_usage_statistics   &&tool_extt_syntax.'dba_feature_usage_statistics.dmp'     )) AS SELECT * FROM dba_feature_usage_statistics  ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.free_space                 &&tool_extt_syntax.'dba_free_space.dmp'                   )) AS SELECT * FROM dba_free_space                ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.high_water_mark_statistics &&tool_extt_syntax.'dba_high_water_mark_statistics.dmp'   )) AS SELECT * FROM dba_high_water_mark_statistics;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.ind_columns                &&tool_extt_syntax.'dba_ind_columns.dmp'                  )) AS SELECT * FROM dba_ind_columns               ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.ind_partitions             &&tool_extt_syntax.'dba_ind_partitions.dmp'               )) AS SELECT * FROM dba_ind_partitions            ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.ind_statistics             &&tool_extt_syntax.'dba_ind_statistics.dmp'               )) AS SELECT * FROM dba_ind_statistics            ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.ind_subpartitions          &&tool_extt_syntax.'dba_ind_subpartitions.dmp'            )) AS SELECT * FROM dba_ind_subpartitions         ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.indexes                    &&tool_extt_syntax.'dba_indexes.dmp'                      )) AS SELECT * FROM dba_indexes                   ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.jobs                       &&tool_extt_syntax.'dba_jobs.dmp'                         )) AS SELECT * FROM dba_jobs                      ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.jobs_running               &&tool_extt_syntax.'dba_jobs_running.dmp'                 )) AS SELECT * FROM dba_jobs_running              ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.lob_partitions             &&tool_extt_syntax.'dba_lob_partitions.dmp'               )) AS SELECT * FROM dba_lob_partitions            ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.lob_subpartitions          &&tool_extt_syntax.'dba_lob_subpartitions.dmp'            )) AS SELECT * FROM dba_lob_subpartitions         ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.lobs                       &&tool_extt_syntax.'dba_lobs.dmp'                         )) AS SELECT * FROM dba_lobs                      ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.obj_audit_opts             &&tool_extt_syntax.'dba_obj_audit_opts.dmp'               )) AS SELECT * FROM dba_obj_audit_opts            ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.objects                    &&tool_extt_syntax.'dba_objects.dmp'                      )) AS SELECT * FROM dba_objects                   ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.pdbs                       &&tool_extt_syntax.'dba_pdbs.dmp'                         )) AS SELECT * FROM dba_pdbs                      ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.priv_audit_opts            &&tool_extt_syntax.'dba_priv_audit_opts.dmp'              )) AS SELECT * FROM dba_priv_audit_opts           ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.procedures                 &&tool_extt_syntax.'dba_procedures.dmp'                   )) AS SELECT * FROM dba_procedures                ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.profiles                   &&tool_extt_syntax.'dba_profiles.dmp'                     )) AS SELECT * FROM dba_profiles                  ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.recyclebin                 &&tool_extt_syntax.'dba_recyclebin.dmp'                   )) AS SELECT * FROM dba_recyclebin                ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.registry                   &&tool_extt_syntax.'dba_registry.dmp'                     )) AS SELECT * FROM dba_registry                  ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.registry_hierarchy         &&tool_extt_syntax.'dba_registry_hierarchy.dmp'           )) AS SELECT * FROM dba_registry_hierarchy        ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.registry_history           &&tool_extt_syntax.'dba_registry_history.dmp'             )) AS SELECT * FROM dba_registry_history          ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.registry_sqlpatch          &&tool_extt_syntax.'dba_registry_sqlpatch.dmp'            )) AS SELECT * FROM dba_registry_sqlpatch         ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.role_privs                 &&tool_extt_syntax.'dba_role_privs.dmp'                   )) AS SELECT * FROM dba_role_privs                ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.roles                      &&tool_extt_syntax.'dba_roles.dmp'                        )) AS SELECT * FROM dba_roles                     ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.rsrc_consumer_group_privs  &&tool_extt_syntax.'dba_rsrc_consumer_group_privs.dmp'    )) AS SELECT * FROM dba_rsrc_consumer_group_privs ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.rsrc_consumer_groups       &&tool_extt_syntax.'dba_rsrc_consumer_groups.dmp'         )) AS SELECT * FROM dba_rsrc_consumer_groups      ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.rsrc_group_mappings        &&tool_extt_syntax.'dba_rsrc_group_mappings.dmp'          )) AS SELECT * FROM dba_rsrc_group_mappings       ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.rsrc_io_calibrate          &&tool_extt_syntax.'dba_rsrc_io_calibrate.dmp'            )) AS SELECT * FROM dba_rsrc_io_calibrate         ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.rsrc_mapping_priority      &&tool_extt_syntax.'dba_rsrc_mapping_priority.dmp'        )) AS SELECT * FROM dba_rsrc_mapping_priority     ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.rsrc_plan_directives       &&tool_extt_syntax.'dba_rsrc_plan_directives.dmp'         )) AS SELECT * FROM dba_rsrc_plan_directives      ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.rsrc_plans                 &&tool_extt_syntax.'dba_rsrc_plans.dmp'                   )) AS SELECT * FROM dba_rsrc_plans                ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.scheduler_job_log          &&tool_extt_syntax.'dba_scheduler_job_log.dmp'            )) AS SELECT * FROM dba_scheduler_job_log         ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.scheduler_jobs             &&tool_extt_syntax.'dba_scheduler_jobs.dmp'               )) AS SELECT * FROM dba_scheduler_jobs            ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.scheduler_windows          &&tool_extt_syntax.'dba_scheduler_windows.dmp'            )) AS SELECT * FROM dba_scheduler_windows         ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.scheduler_wingroup_members &&tool_extt_syntax.'dba_scheduler_wingroup_members.dmp'   )) AS SELECT * FROM dba_scheduler_wingroup_members;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.segments                   &&tool_extt_syntax.'dba_segments.dmp'                     )) AS SELECT * FROM dba_segments                  ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.sequences                  &&tool_extt_syntax.'dba_sequences.dmp'                    )) AS SELECT * FROM dba_sequences                 ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.source                     &&tool_extt_syntax.'dba_source.dmp'                       )) AS SELECT * FROM dba_source                    ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.sql_patches                &&tool_extt_syntax.'dba_sql_patches.dmp'                  )) AS SELECT * FROM dba_sql_patches               ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.sql_plan_baselines         &&tool_extt_syntax.'dba_sql_plan_baselines.dmp'           )) AS SELECT * FROM dba_sql_plan_baselines        ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.sql_plan_dir_objects       &&tool_extt_syntax.'dba_sql_plan_dir_objects.dmp'         )) AS SELECT * FROM dba_sql_plan_dir_objects      ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.sql_plan_directives        &&tool_extt_syntax.'dba_sql_plan_directives.dmp'          )) AS SELECT * FROM dba_sql_plan_directives       ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.sql_profiles               &&tool_extt_syntax.'dba_sql_profiles.dmp'                 )) AS SELECT * FROM dba_sql_profiles              ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.stat_extensions            &&tool_extt_syntax.'dba_stat_extensions.dmp'              )) AS SELECT * FROM dba_stat_extensions           ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.stmt_audit_opts            &&tool_extt_syntax.'dba_stmt_audit_opts.dmp'              )) AS SELECT * FROM dba_stmt_audit_opts           ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.synonyms                   &&tool_extt_syntax.'dba_synonyms.dmp'                     )) AS SELECT * FROM dba_synonyms                  ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.sys_privs                  &&tool_extt_syntax.'dba_sys_privs.dmp'                    )) AS SELECT * FROM dba_sys_privs                 ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tab_cols                   &&tool_extt_syntax.'dba_tab_cols.dmp'                     )) AS SELECT * FROM dba_tab_cols                  ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tab_columns                &&tool_extt_syntax.'dba_tab_columns.dmp'                  )) AS SELECT * FROM dba_tab_columns               ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tab_modifications          &&tool_extt_syntax.'dba_tab_modifications.dmp'            )) AS SELECT * FROM dba_tab_modifications         ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tab_partitions             &&tool_extt_syntax.'dba_tab_partitions.dmp'               )) AS SELECT * FROM dba_tab_partitions            ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tab_privs                  &&tool_extt_syntax.'dba_tab_privs.dmp'                    )) AS SELECT * FROM dba_tab_privs                 ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tab_statistics             &&tool_extt_syntax.'dba_tab_statistics.dmp'               )) AS SELECT * FROM dba_tab_statistics            ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tab_subpartitions          &&tool_extt_syntax.'dba_tab_subpartitions.dmp'            )) AS SELECT * FROM dba_tab_subpartitions         ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tables                     &&tool_extt_syntax.'dba_tables.dmp'                       )) AS SELECT * FROM dba_tables                    ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tablespace_groups          &&tool_extt_syntax.'dba_tablespace_groups.dmp'            )) AS SELECT * FROM dba_tablespace_groups         ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.tablespaces                &&tool_extt_syntax.'dba_tablespaces.dmp'                  )) AS SELECT * FROM dba_tablespaces               ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.temp_files                 &&tool_extt_syntax.'dba_temp_files.dmp'                   )) AS SELECT * FROM dba_temp_files                ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.triggers                   &&tool_extt_syntax.'dba_triggers.dmp'                     )) AS SELECT * FROM dba_triggers                  ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.ts_quotas                  &&tool_extt_syntax.'dba_ts_quotas.dmp'                    )) AS SELECT * FROM dba_ts_quotas                 ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.unused_col_tabs            &&tool_extt_syntax.'dba_unused_col_tabs.dmp'              )) AS SELECT * FROM dba_unused_col_tabs           ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.users                      &&tool_extt_syntax.'dba_users.dmp'                        )) AS SELECT * FROM dba_users                     ;
CREATE TABLE &&tool_repo_user..&&tool_prefix_2.views                      &&tool_extt_syntax.'dba_views.dmp'                        )) AS SELECT * FROM dba_views                     ;

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
-- create metadata table with ddl commands to create new external tables
------------------------------------------------------------------------------------------

EXEC DBMS_METADATA.SET_TRANSFORM_PARAM(DBMS_METADATA.SESSION_TRANSFORM, 'SQLTERMINATOR', TRUE);

CREATE TABLE &&tool_repo_user..&&tool_prefix_0.external_tables      &&tool_extt_syntax.'external_tables_eadam.dmp'        )) AS SELECT et.*, DBMS_METADATA.GET_DDL('TABLE', table_name, owner) dbms_metadata_get_ddl FROM dba_external_tables et WHERE owner = UPPER('&&tool_repo_user.') 
AND (table_name LIKE UPPER('&&tool_prefix_1.%') OR table_name LIKE UPPER('&&tool_prefix_2.%') OR table_name LIKE UPPER('&&tool_prefix_3.%') OR table_name LIKE UPPER('&&tool_prefix_4.%'));

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

------------------------------------------------------------------------------------------
-- metadata ddl commands to create new external tables (for script)
------------------------------------------------------------------------------------------

SPO eadam_external_tables_ddl.sql;
SELECT dbms_metadata_get_ddl FROM &&tool_repo_user..&&tool_prefix_0.external_tables;
SPO OFF;