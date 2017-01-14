edb360 v1702 (2017-01-13) by Carlos Sierra
~~~~~~~~~~~~
edb360 is a "free to use" tool to perform an initial assessment of a remote system. 

It gives a glance of an Oracle database state. It also helps to document any findings.

eDB360 works on Oracle 10g to 12c databases. eDB360 works on Linus and UNIX systems. 
For Windows systems you may want to install first UNIX Utilities (UnxUtils) and a zip 
program, else a few OS commands may not properly work.

edb360 installs nothing on the database. 

For better results execute connected as DBA or user with access to data dictionary.

edb360 takes up to 24 hours to execute. 

Output ZIP file can be large (over 100 MBs), so you may want to place and execute edb360
from a system directory with at least 1 GB of free space. 

Best time to execute edb360 is overnight or over a weekend.

Before executing edb360 please perform a pre-check of ASH on AWR by reviewing output of 
included script edb360-master/sql/awr_ash_pre_check.sql.

****************************************************************************************

Steps
~~~~~
1. Unzip edb360-master.zip, navigate to the root edb360-master directory, and connect as 
   DBA, or any user with access to the Data Dictionary:

   $ unzip edb360-master.zip
   $ cd edb360-master
   $ sqlplus <dba_user>/<dba_pwd>

2. Execute sql/awr_ash_pre_check.sql and review output, specially last page. Then decide
   if continuing with edb360 (step 3 below) or remediate first findings reported.

3. Execute edb360.sql passing two parameters either inline or when asked.

   Parameter 1: Oracle License Pack (required)
   
   Indicate if your database is licensed for the Oracle Tuning Pack, 
   the Diagnostics Pack or None [ T | D | N ]. Example below specifies Tuning Pack. If 
   both Tuning and Diagnostics pass then T.
   
   Parameter 2: Custom edb360 configuration filename (optional)

   note: This parameter is for advanced users, thus a NULL value is common.

   Execution sample:

   SQL> @edb360.sql T NULL
   
4. Unzip output edb360_<NNNNNN>_<NNNNNN>_YYYYMMDD_HH24MI.zip into a directory on your PC

5. Open and review main html file 00001_edb360_<NNNNNN>_index.html using a browser

****************************************************************************************

Notes
~~~~~
1. If you need to execute edb360 against all databases in host use then run_db360.sh:

   $ unzip edb360-master.zip
   $ cd edb360-master
   $ sh run_db360.sh

   note: this method requires Oracle Tuning pack license in all databases in such host.

2. If you need to generate edb360 for a range of dates other than last 31 days; or change
   default "working hours" between 7:30AM and 7:30PM; or suppress an output format such as
   text or csv; set a custom configuration file based on edb360_00_config.sql.
   
3. How to find the license pack option that you have installed?

   select value from v$parameter where name = 'control_management_pack_access';

4. How to find how many days are kept in the AWR repository?

   select retention from DBA_HIST_WR_CONTROL;

5. edb360 needs the following grants when executed as user xxx

   grant select any dictionary to xxx;
   grant advisor to xxx;
   grant execute on dbms_workload_repository to xxx;
   grant execute on dbms_lock to xxx;

****************************************************************************************

Troubleshooting
~~~~~~~~~~~~~~~
edb360 takes up to 24 hours to execute on a large database. On smaller ones or on Exadata
it may take a few hours or less. In rare cases it may require even more than 24 hrs.

If you think edb360 takes too long on your database, the first suspect is usually the 
state of the CBO stats on Tables behind AWR. Validate with sql/awr_ash_pre_check.sql.

Troubleshooting steps below are for improving performance of edb360 based on known issues.

Steps:

1. Refer to https://carlos-sierra.net/2016/11/23/edb360-takes-long-to-execute/

2. If edb360 version (first line on this readme) is older than 1 month, download and use
   latest version: https://github.com/carlos-sierra/edb360/archive/master.zip

3. If after going through steps above, edb360 still takes longer than a few hours, feel 
   free to email author carlos.sierra.usa@gmail.com and provide files from step 1.

****************************************************************************************
   
    edb360 - Enkitec's Oracle Database 360-degree View
    Copyright (C) 2016  Carlos Sierra

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

****************************************************************************************
