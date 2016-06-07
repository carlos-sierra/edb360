EDB360 v1612 (2016-06-07) by Carlos Sierra
~~~~~~~~~~~~
EDB360 is a "free to use" tool to perform an initial assessment of a remote system. 

It gives a glance of a database state. It also helps to document any findings.

EDB360 installs nothing on the database. 

For better results execute connected as DBA or user with access to data dictionary.

EDB360 takes a few hours to execute. 

Output ZIP file can be large (over 100 MBs), so you may want to place and execute EDB360
from a system directory with at least 1 GB of free space. 

Best time to execute EDB360 is close to the end of a working day and let it execute
overnight.

****************************************************************************************

Steps
~~~~~
1. Unzip edb360.zip, navigate to the root edb360-master directory, and connect as DBA, 
   or any user with Data Dictionary access:

   $ unzip edb360-master.zip
   $ cd edb360-master
   $ sqlplus dba_user/dba_pwd

2. Execute edb360.sql passing two parameters.

   Parameter 1: Oracle License Pack (required)
   
   Indicate if your database is licensed for the Oracle Tuning Pack, 
   the Diagnostics Pack or None [ T | D | N ]. Example below specifies Tuning Pack. If 
   both Tuning and Diagnostics pass then T.
   
   Parameter 2: Custom edb360 configuration filename (optional)

   SQL> @edb360.sql T NULL
   
3. Unzip output edb360_<NNNNNN>_<NNNNNN>_YYYYMMDD_HH24MI.zip into a directory on your PC

4. Open and review main html file 00001_edb360_<NNNNNN>_index.html using a browser

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

5. eDB360 needs the following grants

   grant select any dictionary to xxx;
   grant advisor to xxx;
   grant execute on dbms_workload_repository to xxx;
   grant execute on dbms_lock to xxx;

****************************************************************************************

Troubleshooting
~~~~~~~~~~~~~~~
edb360 takes a few hours to execute on a large database. On smaller ones or on Exadata it
may take less than 1hr. In rare cases it may take up to 24 hours or even more. 
If you think edb360 takes too long on your database, the first suspect is usually the 
state of the CBO stats on Tables behind AWR. 
Troubleshooting steps below are for improving performance of edb360 based on known issues.

Steps:

1. Review files 00002_edb360_NNNNNN_log.txt, 00003_edb360_NNNNNN_log2.txt, 
   00004_edb360_NNNNNN_log3.txt and 00005_edb360_NNNNNN_tkprof_sort.txt. 
   First log shows the state of the statistics for AWR Tables. If stats are old then 
   gather them fresh with script edb360-master/sql/gather_stats_wr_sys.sql
   
2. If number of rows on WRH$_ACTIVE_SESSION_HISTORY as per 00002_edb360_NNNNNN_log.txt is
   several millions, then you may not be purging data periodically. 
   There are some known bugs and some blog posts on this regard. Review MOS 387914.1.
   Execute query below to validate ASH age:

       SELECT TRUNC(sample_time, 'MM'), COUNT(*)
         FROM dba_hist_active_sess_history
        GROUP BY TRUNC(sample_time, 'MM')
        ORDER BY TRUNC(sample_time, 'MM')
       /

3. If edb360 version (first line on this readme) is older than 1 month, download and use
   latest version: https://github.com/carlos-sierra/edb360/archive/master.zip

4. If after going through steps 1-3 above, edb360 still takes longer than a few hours, 
   feel free to email author carlos.sierra.usa@gmail.com and provide 4 files from step 1.

****************************************************************************************
   
    EDB360 - Enkitec's Oracle Database 360-degree View
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
