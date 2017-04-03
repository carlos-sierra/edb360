This eadam repository is only to be used when the state of the awr data is such that
awr_ash_pre_check.sql has determined edb360 would take much longer than 24hrs.

This method uses external tables to host the eadam repository.

****************************************************************************************
                                    Repo Create
****************************************************************************************

1. Logged as oracle, manually create a directory on database server to host the eadam 
   repository. This method uses external tables to materialize the content of several
   views. Owner must be oracle.
   
   # cd ../..
   # cd acfs
   # mkdir eadam

2. Create database directory eadam_dir that points to server directory created on prior 
   step. Be sure the referenced server directory exists on the host system and that it   
   contains at least 10GB of free space.

   # sqlplus / as sysdba
   SQL> create directory eadam_dir as '/acfs/eadam'; <<< directory name must be eadam_dir

3. Manually create a user to own the eadam repository. This user needs no grants and it
   can be locked. For example, create user eadam (any name is valid but sys).
   
   # cd edb360-master
   # sqlplus / as sysdba
   SQL> create user eadam identified by <some_unique_pwd>;

4. Execute repo_eadam/repo_eadam_create.sql connecting as SYS or DBA. Pass as parameter 
   the eadam repository's owner created on prior step.
   
   # cd edb360-master
   # sqlplus / as sysdba
   SQL> @repo_eadam/repo_eadam_create.sql
   tool repository user (i.e. eadam): eadam <<< repository owner

****************************************************************************************
                                    Repo Consume
****************************************************************************************

1. Configure edb360 to access eadam repository instead of base views: either modify
   sql/edb360_00_config.sql or sql/custom_config_01.sql and set tool_repo_user.
   
   DEF tool_repo_user = 'eadam'; <<< must match schema owner from prior steps

2. Execute edb360 as usual. If tool_repo_user was set on sql/edb360_00_config.sql then
   pass nothing (or NULL) on second edb360 parameter. If tool_repo_user was set on 
   sql/custom_config_01.sql then pass custom_config_01.sql as second parameter.

   SQL> @edb360.sql T NULL <<< if tool_repo_user was set on sql/edb360_00_config.sql
   or
   SQL> @edb360.sql T custom_config_01.sql  <<< if set on sql/custom_config_01.sql

****************************************************************************************
                                     Repo Drop
****************************************************************************************

1. Once edb360 completes you can drop the eadam repository, and reset tool_repo_user.

   # cd edb360-master
   # sqlplus / as sysdba
   SQL> @repo_eadam/repo_eadam_drop.sql
   tool repository user: eadam <<< repository owner

2. If no longer needed, remove then files created on directory on database server 
   identified by EADAM directory.

3. You may want to drop last the user who owned the repository.

   # sqlplus / as sysdba
   SQL> drop user eadam cascade; <<< repository owner

****************************************************************************************
