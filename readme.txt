EDB360 v1505 (2015-02-23) by Carlos Sierra

EDB360 is a "free to use" tool to perform an initial assessment of a remote system. 
It gives a glance of a database state. It also helps to document any findings.
EDB360 installs nothing. For better results execute connected as SYS or DBA.
It takes around one hour to execute. Output ZIP file can be large (several MBs), so
you may want to execute EDB360 from a system directory with at least 1 GB of free 
space. Best time to execute EDB360 is close to the end of a working day.

Steps
~~~~~
1. Unzip edb360.zip, navigate to the root edb360 directory, and connect as SYS, 
   DBA, or any User with Data Dictionary access:

   $ unzip edb360.zip
   $ cd edb360
   $ sqlplus / as sysdba

2. Execute edb360.sql indicating two input parameters. The first one is to specify if 
   your database is licensed for the Oracle Tuning Pack, the Diagnostics Pack or None 
   [ T | D | N ]. The second parameter indicates up to how many days of history you
   want edb360 to query. Example below specifies Tuning Pack and 31 days of history.
   Actual days of history used depends on retention period. Value used is raised up to
   31 days if history permits.

   SQL> @edb360.sql T 31
   
3. Unzip output edb360_<dbname>_<host>_YYYYMMDD_HH24MI.zip into a directory on your PC

4. Review main html file 0001_edb360_<dbname>_index.html

****************************************************************************************

Notes
~~~~~
1. If you need to execute edb360 against all databases in host use then run_db360.sh:

   $ unzip edb360.zip
   $ cd edb360
   $ sh run_db360.sh

   note: this method requires Oracle Tuning pack license in all databases in such host.

2. If you need to execute only a portion of edb360 (i.e. a column, section or range) use 
   these commands. Notice hidden parameter _o_release can be set to one section (i.e. 3b),
   one column (i.e. 3), a range of sections (i.e. 5c-6b) or range of columns (i.e. 5-7):

   SQL> DEF _o_release = '3b';
   SQL> @edb360.sql T 31
   
   note: valid column range is 1 to 7. 

****************************************************************************************
   
    EDB360 - Enkitec's Oracle Database 360-degree View
    Copyright (C) 2014  Carlos Sierra

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
