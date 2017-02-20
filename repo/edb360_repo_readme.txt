edb360 does not require a repository to function since it reads its data out of the awr
repository directly (actually from a subset of dba_hist_ views).

This edb360 repository is only to be used when the state of the awr data is such that
awr_ash_pre_check.sql has determined edb360 would take much longer than 24hrs.

****************************************************************************************

Steps
~~~~~
1. Manually create a user to own the edb360 repository. This user needs no grants and it
   can be locked. Be sure default table space for this user has at least 5GB of spare
   space. For example, create user edb360 (any name is valid but sys).
   
   # cd edb360-master
   # sqlplus / as sysdba
   SQL> create user edb360 identified by some_unique_pwd;
   SQL> alter user edb360 quota unlimited on users;     <<< or designated tablespace

2. Execute repo/edb360_repo_create.sql connecting as SYS or DBA. Pass as parameter the
   edb360 repository's owner manually (user created on prior step).
   
   # cd edb360-master
   # sqlplus / as sysdba
   SQL> @repo/edb360_repo_create.sql
   eDB360 repository user: edb360       <<< user edb360 owns repository in this example

3. Configure edb360 to access edb360 repository instead of dba_hist_ views: either modify
   sql/edb360_00_config.sql or sql/custom_config_01.sql and set edb360_repo_user.
   
   DEF edb360_repo_user = 'edb360';     <<< must match schema owner from prior steps

4. Execute edb360 as usual. If edb360_repo_user was set on sql/edb360_00_config.sql then
   pass nothing (or NULL) on second edb360 parameter. If edb360_repo_user was set on 
   sql/custom_config_01.sql then pass custom_config_01.sql as second parameter.

   SQL> @edb360.sql T NULL      <<< if edb360_repo_user was set on sql/edb360_00_config.sql
   or
   SQL> @edb360.sql T custom_config_01.sql  <<< if set on sql/custom_config_01.sql

5. Once edb360 completes you can drop the edb360 repository, and reset edb360_repo_user.

   # cd edb360-master
   # sqlplus / as sysdba
   SQL> @repo/edb360_repo_drop.sql
   eDB360 repository user: edb360       <<< user edb360 owns repository in this example

****************************************************************************************
