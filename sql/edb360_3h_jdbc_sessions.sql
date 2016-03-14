@@&&edb360_0g.tkprof.sql
DEF section_id = '3h';
DEF section_name = 'JDBC Sessions';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'JDBC Connection usage per Module';
DEF main_table = 'GV$SESSION';
BEGIN
  :sql_text := '
-- from monitor_jdbc_conn.sql 
select count(*), module from gv$session 
where program like ''%JDBC%'' 
group by module 
order by 1 DESC, 2
';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'JDBC Connection usage per Process and Module';
DEF main_table = 'GV$SESSION';
BEGIN
  :sql_text := '
-- from monitor_jdbc_conn.sql 
select count(*), process, module from gv$session 
where program like ''%JDBC%'' 
group by process, module 
order by 1 DESC, 2, 3
';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'JDBC Connection usage per JVM';
DEF main_table = 'GV$SESSION';
BEGIN
  :sql_text := '
-- from monitor_jdbc_conn.sql 
select count(*), machine from gv$session 
where program like ''%JDBC%'' 
group by machine 
order by 1 DESC, 2
';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'JDBC Connection usage per JVM Process';
DEF main_table = 'GV$SESSION';
BEGIN
  :sql_text := '
-- from monitor_jdbc_conn.sql 
select count(*), machine, process from gv$session 
where program like ''%JDBC%'' 
group by machine, process 
order by 1 DESC, 2, 3
';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'JDBC Idle connections for more than N hours';
DEF main_table = 'GV$SESSION';
BEGIN
  :sql_text := '
-- from monitor_jdbc_conn.sql 
select TRUNC(last_call_et/3600) hours_idle,count(*)  
from gv$session 
where program like ''%JDBC%''
--and  last_call_et > 3600
and status = ''INACTIVE'' 
group by TRUNC(last_call_et/3600) 
order by 1 DESC
';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'JDBC Idle connections per JVM and Program';
DEF main_table = 'GV$SESSION';
BEGIN
  :sql_text := '
-- from monitor_jdbc_conn.sql 
select TRUNC(last_call_et/3600) hours_idle,machine, program,count(*)  
from gv$session 
where program like ''%JDBC%''
--and  last_call_et > 3600
and status = ''INACTIVE'' 
group by TRUNC(last_call_et/3600),machine, program 
order by 1 DESC,2,3
';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'JDBC Active connections';
DEF main_table = 'GV$SESSION';
BEGIN
  :sql_text := '
-- from monitor_jdbc_conn.sql 
select s.last_call_et last_call_et_secs, 
s.*,  t.sql_text current_sql, t2.sql_text prev_sql 
from gv$session s, gv$sql t, gv$sql t2
where s.inst_id =t.inst_id(+)
and s.sql_address =t.address(+)  
and s.sql_hash_value =t.hash_value(+)
and s.sql_id = t.sql_id(+)
and s.sql_child_number = t.child_number(+)
and s.inst_id =t2.inst_id(+)
and s.prev_sql_addr =t2.address(+)  
and s.prev_hash_value =t2.hash_value(+)
and s.prev_sql_id = t2.sql_id(+)
and s.prev_child_number = t2.child_number(+)
and s.program like ''%JDBC%'' 
and s.status = ''ACTIVE'' 
order by last_call_et DESC
';
END;
/
@@edb360_9a_pre_one.sql       

DEF title = 'JDBC Inactive connections';
DEF main_table = 'GV$SESSION';
BEGIN
  :sql_text := '
-- from monitor_jdbc_conn.sql 
select s.last_call_et last_call_et_secs, 
s.*,  t.sql_text current_sql, t2.sql_text prev_sql 
from gv$session s, gv$sql t, gv$sql t2
where s.inst_id =t.inst_id(+)
and s.sql_address =t.address(+)  
and s.sql_hash_value =t.hash_value(+)
and s.sql_id = t.sql_id(+)
and s.sql_child_number = t.child_number(+)
and s.inst_id =t2.inst_id(+)
and s.prev_sql_addr =t2.address(+)  
and s.prev_hash_value =t2.hash_value(+)
and s.prev_sql_id = t2.sql_id(+)
and s.prev_child_number = t2.child_number(+)
and s.program like ''%JDBC%'' 
and s.status = ''INACTIVE'' 
order by last_call_et DESC
';
END;
/
@@edb360_9a_pre_one.sql       

SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;

