EDB360 is a tool to perform an initial assessment of a remote system. 
It gives a glance of a database state. It also helps to document findings.
Installs nothing. For better results execute connected as SYS or DBA.
It takes several minutes to execute. Output zip file can be large (several megs).

Steps
~~~~~
1. Unzip edb360.zip, navigate to the root edb360 directory, and connect as as SYS, 
   DBA, or any User with Data Dictionary access:

   # cd /home/csierra
   # unzip edb360.zip
   # cd edb360
   # sqlplus / as sysdba

2. Execute edb360.sql indicating two input parameters. The first one is to specify if 
   your database is licensed for the Oracle Tuning Pack, the Diagnostics Pack or None 
   [ T | D | N ]. The second parameter indicates up to how many days of history you
   want edb360 to query (defaults to 31). Example below specifies Tuning Pack and 31 
   days of history.

   SQL> @edb360.sql T 31
   
3. Unzip output edb360_<dbname>_<host>_YYYYMMDD_HH24MI.zip into a directory on your PC

4. Review main html file 0001_edb360_<dbname>_index.html


Notes
~~~~~
1. If you need to execute db360 against all databases in host use then run_db360.sh

2. If you need to execute only one piece of edb360 (i.e. resources) use these 3 commands:

   SQL> @sql/edb360_0b_pre.sql T 31
   SQL> @sql/edb360_1d_resources.sql
   SQL> @sql/edb360_0c_post.sql

3. If you decide to include SQLHC from MOS 1366133.1, be aware that sqlhc.sql uses
   global temporary table plan_table as staging repository, so it has some inserts into
   it and a rollback.