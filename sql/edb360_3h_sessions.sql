@@&&edb360_0g.tkprof.sql
DEF section_id = '3h';
DEF section_name = 'Sessions';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&edb360_prefix.','&&section_id.');
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'Sessions Aggregate per Type';
DEF main_table = 'GV$SESSION';
DEF foot = 'Content of &&main_table. is very dynamic. This report just tells state at the time when edb360 was executed.';
BEGIN
  :sql_text := '
SELECT COUNT(*),
       inst_id,
       type,
       server,
       status,
       state,
       failover_type,
       failover_method,
       blocking_session_status
  FROM gv$session
 GROUP BY
       inst_id,
       type,
       server,
       status,
       state,
       failover_type,
       failover_method,
       blocking_session_status
 ORDER BY
       1 DESC, 2, 3, 4, 5, 6, 7, 8, 9
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Sessions Aggregate per User and Type';
DEF main_table = 'GV$SESSION';
DEF foot = 'Content of &&main_table. is very dynamic. This report just tells state at the time when edb360 was executed.';
BEGIN
  :sql_text := '
SELECT COUNT(*),
       username,
       inst_id,
       type,
       server,
       status,
       state,
       failover_type,
       failover_method,
       blocking_session_status
  FROM gv$session
 GROUP BY
       username,
       inst_id,
       type,
       server,
       status,
       state,
       failover_type,
       failover_method,
       blocking_session_status
 ORDER BY
       1 DESC, 2, 3, 4, 5, 6, 7, 8, 9, 10
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Sessions Aggregate per Module and Action';
DEF main_table = 'GV$SESSION';
DEF foot = 'Content of &&main_table. is very dynamic. This report just tells state at the time when edb360 was executed.';
BEGIN
  :sql_text := '
SELECT COUNT(*),
       module,
       action,
       inst_id,
       type,
       server,
       status,
       state,
       failover_type,
       failover_method,
       blocking_session_status
  FROM gv$session
 GROUP BY
       module,
       action,
       inst_id,
       type,
       server,
       status,
       state,
       failover_type,
       failover_method,
       blocking_session_status
 ORDER BY
       1 DESC, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Sessions List';
DEF main_table = 'GV$SESSION';
DEF foot = 'Content of &&main_table. is very dynamic. This report just tells state at the time when edb360 was executed.';
BEGIN
  :sql_text := '
SELECT *
  FROM gv$session
 ORDER BY
       inst_id,
       sid
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Processes List';
DEF main_table = 'GV$PROCESS';
DEF foot = 'Content of &&main_table. is very dynamic. This report just tells state at the time when edb360 was executed.';
BEGIN
  :sql_text := '
SELECT *
  FROM gv$process
 ORDER BY
       inst_id,
       pid,
       spid
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Processes Memory';
DEF main_table = 'GV$PROCESS_MEMORY';
DEF foot = 'Content of &&main_table. is very dynamic. This report just tells state at the time when edb360 was executed.';
BEGIN
  :sql_text := '
SELECT *
  FROM gv$process_memory
 ORDER BY
       inst_id,
       pid,
       serial#,
       category
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Active Sessions (detail)';
DEF main_table = 'GV$SESSION';
BEGIN
  :sql_text := '
SELECT /* active_sessions */ 
       se.*, sq.sql_text
  FROM gv$session se,
       gv$sql sq
 WHERE se.status = ''ACTIVE''
   AND sq.inst_id = se.inst_id
   AND sq.sql_id = se.sql_id
   AND sq.child_number = se.sql_child_number
   AND sq.sql_text NOT LIKE ''SELECT /* active_sessions */%''
 ORDER BY
       se.inst_id, se.sid, se.serial#   
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Active Sessions (more detail)';
DEF main_table = 'GV$SESSION';
BEGIN
  :sql_text := '
-- provided by Frits Hoogland
select /*+ rule as.sql */ a.sid||'',''||a.serial#||'',@''||a.inst_id as sid_serial_inst, 
	d.spid as ospid, 
	substr(a.program,1,19) prog, 
	a.module, a.action, a.client_info,
	''SQL:''||b.sql_id as sql_id, child_number child, plan_hash_value, executions execs,
	(elapsed_time/decode(nvl(executions,0),0,1,executions))/1000000 avg_etime,
	decode(a.plsql_object_id,null,sql_text,(select distinct sqla.object_name||''.''||sqlb.procedure_name from dba_procedures sqla, dba_procedures sqlb where sqla.object_id=a.plsql_object_id and sqlb.object_id = a.plsql_object_id and a.plsql_subprogram_id = sqlb.subprogram_id)) sql_text, 
	(c.wait_time_micro/1000000) wait_s, 
	decode(a.plsql_object_id,null,decode(c.wait_time,0,decode(a.blocking_session,null,c.event,c.event||''> Blocked by (inst:sid): ''||a.final_blocking_instance||'':''||a.final_blocking_session),''ON CPU:SQL''),(select ''ON CPU:PLSQL:''||object_name from dba_objects where object_id=a.plsql_object_id)) as wait_or_cpu
from gv$session a, gv$sql b, gv$session_wait c, gv$process d
where a.status = ''ACTIVE''
and a.username is not null
and a.sql_id = b.sql_id
and a.inst_id = b.inst_id
and a.sid = c.sid
and a.inst_id = c.inst_id
and a.inst_id = d.inst_id
and a.paddr = d.addr
and a.sql_child_number = b.child_number
and sql_text not like ''select /*+ rule as.sql */%'' /* dont show this query */
order by sql_id, sql_child_number
';
END;
/
@@&&skip_10g.edb360_9a_pre_one.sql

DEF title = 'Sessions Waiting';
DEF main_table = 'GV$SESSION';
BEGIN
  :sql_text := '
-- borrowed from orachk
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       inst_id, sid, event,
       ROUND(seconds_in_wait,2)  waiting_seconds,
       ROUND(wait_time/100,2)    waited_seconds, 
       p1,p2,p3, BLOCKING_SESSION 
from gv$session
where event not in
(
  ''SQL*Net message from client'',
  ''SQL*Net message to client'',
  ''rdbms ipc message''
)
and state = ''WAITING''
and username not in &&exclusion_list.
and username not in &&exclusion_list2.
and (seconds_in_wait > 1 OR wait_time > 100)
order by 1, 2
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Session Blockers and Waiters';
DEF abstract = 'Blockers (B) and Waiters (W)<br />';
DEF main_table = 'GV$SESSION_BLOCKERS';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       b.inst_id b_inst_id,
       b.sql_id b_sql_id,
       b.sql_child_number b_child,
       b.sid b_sid,
       b.serial# b_serial#,
       b.process b_process,
       b.machine b_machine,
       b.program b_program,
       b.module b_module,
       b.client_info b_client_info,
       b.client_identifier b_client_identifier,
       b.event b_event,
       TO_CHAR(b.logon_time, ''DD-MON-YY HH24:MI:SS'') b_logon_time,
       TO_CHAR(b.sql_exec_start, ''DD-MON-YY HH24:MI:SS'') b_sql_exec_start, 
       SUBSTR(bs.sql_text, 1, 500) b_sql_text,
       w.inst_id w_inst_id,
       w.sql_id w_sql_id,
       w.sql_child_number w_child,
       w.sid w_sid,
       w.serial# w_serial#,
       w.process w_process,
       w.machine w_machine,
       w.program w_program,
       w.module w_module,
       w.client_info w_client_info,
       w.client_identifier w_client_identifier,
       w.event w_event,
       TO_CHAR(w.logon_time, ''DD-MON-YY HH24:MI:SS'') w_logon_time,
       TO_CHAR(w.sql_exec_start, ''DD-MON-YY HH24:MI:SS'') w_sql_exec_start, 
       SUBSTR(ws.sql_text, 1, 500) w_sql_text
  FROM gv$session_blockers sb,
       gv$session w,
       gv$session b,
       gv$sql ws,
       gv$sql bs
 WHERE w.inst_id = sb.inst_id
   AND w.sid = sb.sid
   AND w.serial# = sb.sess_serial#
   AND b.inst_id = sb.blocker_instance_id
   AND b.sid = sb.blocker_sid
   AND b.serial# = sb.blocker_sess_serial#
   AND ws.inst_id(+) = w.inst_id
   AND ws.sql_id(+) = w.sql_id
   AND ws.child_number(+) = w.sql_child_number
   AND bs.inst_id(+) = b.inst_id
   AND bs.sql_id(+) = b.sql_id
   AND bs.child_number(+) = b.sql_child_number
 ORDER BY
       b.inst_id,
       b.sql_id,
       b.sql_child_number,
       b.sid,
       b.serial#,
       w.inst_id,
       w.sql_id,
       w.sql_child_number,
       w.sid,
       w.serial#
';
END;
/
@@&&skip_10g.edb360_9a_pre_one.sql

DEF title = 'SQL blocking SQL';
DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
BEGIN
  :sql_text := '
WITH
w AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       h.dbid,
       h.sql_id,
       h.event,
       h.blocking_session,
       h.blocking_session_serial#,
       TRUNC(h.sample_time, ''HH'') sample_hh,
       MIN(h.sample_time) min_sample_time,
       MAX(h.sample_time) max_sample_time,
       COUNT(*) samples,
       RANK() OVER (ORDER BY COUNT(*) DESC NULLS LAST) AS w_rank
  FROM dba_hist_active_sess_history h
 WHERE h.sql_id IS NOT NULL
   AND h.blocking_session IS NOT NULL
   AND h.session_state = ''WAITING''
   AND h.blocking_session_status IN (''VALID'', ''GLOBAL'')
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
 GROUP BY
       h.dbid,
       h.sql_id,
       h.event,
       h.blocking_session,
       h.blocking_session_serial#,
       TRUNC(h.sample_time, ''HH'')
),
b AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */
       w.dbid,
       w.sql_id w_sql_id,
       w.event w_event,
       RANK() OVER (ORDER BY COUNT(*) DESC NULLS LAST) AS b_rank,
       h.sql_id b_sql_id,
       COUNT(*) b_samples
       FROM w, 
            dba_hist_active_sess_history h
 WHERE w.w_rank < 101
   AND h.dbid = w.dbid   
   AND h.session_id = w.blocking_session
   AND h.session_serial# = w.blocking_session_serial#
   AND TRUNC(h.sample_time, ''HH'') = w.sample_hh
   AND h.sample_time BETWEEN w.min_sample_time AND w.max_sample_time
   AND h.sql_id IS NOT NULL
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
 GROUP BY
       w.dbid,
       w.sql_id,
       w.event,
       h.sql_id
),
w2 AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       dbid,
       sql_id w_sql_id,
       event w_event,
       SUM(samples) w_samples,
       MIN(w_rank) w_rank
  FROM w
 GROUP BY
       dbid,
       sql_id,
       event
),
w3 AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       dbid,
       w_sql_id,
       SUM(w_samples) w_samples
  FROM w2
 GROUP BY
       dbid,
       w_sql_id
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       (10 * w2.w_samples) w_seconds,
       w2.w_sql_id,
       w2.w_event,
       (10 * b.b_samples) b_seconds,
       b.b_sql_id,
       (SELECT DBMS_LOB.SUBSTR(s.sql_text, 500) FROM dba_hist_sqltext s WHERE s.sql_id = w2.w_sql_id AND s.dbid = w2.dbid AND ROWNUM = 1) w_sql_text,
       (SELECT DBMS_LOB.SUBSTR(s.sql_text, 500) FROM dba_hist_sqltext s WHERE s.sql_id = b.b_sql_id AND s.dbid = b.dbid AND ROWNUM = 1) b_sql_text        
  FROM w2, b, w3
 WHERE b.dbid = w2.dbid
   AND b.w_sql_id = w2.w_sql_id
   AND b.w_event = w2.w_event
   AND w3.dbid = w2.dbid
   AND w3.w_sql_id = w2.w_sql_id
 ORDER BY
       w3.w_samples DESC,
       w2.w_samples DESC,
       w2.w_sql_id,
       w2.w_event,
       b.b_samples DESC,
       b.b_sql_id
';
END;
/
@@&&skip_diagnostics.edb360_9a_pre_one.sql

column hold_module heading 'Holding Module' 
column hold_action heading 'Holding Action' 
column hold_program heading 'Holding Program' 
column hold_event heading 'Holding Event' 
column wait_event  heading 'Waiting Event'  

DEF title = 'Profile of Blocking Sessions';
DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
BEGIN
  :sql_text := '
-- developed by David Kurtz
WITH w AS ( --waiting sessions
	SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
	       /* &&section_id..&&report_sequence. */ 
	dbid, instance_number
        ,       snap_id
	,       sample_id, sample_time
        ,       session_type wait_session_type
        ,       session_id, session_serial#
        ,       sql_id, sql_plan_hash_value, sql_plan_line_id
--simplified program name removing anything after first @ or dot until open a bracket
        ,       regexp_substr(program,''[^\.@]+'',1,1)||'' ''||
                regexp_replace(regexp_substR(regexp_substr(program,''[\.@].+'',1,1),''[\(].+'',1,1),''[[:digit:]]'',''n'',1,0) wait_program 
        ,       module wait_module
        ,       CASE WHEN upper(program) LIKE ''ORACLE%'' 
                     THEN REGEXP_REPLACE(action,''[[:digit:]]+'',''nnn'',1,1)
                     ELSE action END wait_action
        ,       NVL(event,''CPU+CPU wait'')  wait_event
        ,       xid    wait_xid
        ,       blocking_inst_id, blocking_session, blocking_session_serial#
        FROM       dba_hist_active_Sess_history h
        WHERE   blocking_session_status = ''VALID'' --holding a lock
--add dbid/date/snap_id criteria here
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
), x as (
SELECT /*+ &&sq_fact_hints. */ 
       /* &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
       /* &&section_id..&&report_sequence. */       
        w.*
,       h.sample_id hold_sample_id
,       h.sample_time hold_Sample_time
,       h.session_Type hold_session_type
,       CASE WHEN h.sample_id IS NULL THEN ''Idle Blocker''
             ELSE NVL(h.event,''CPU+CPU Wait'') 
        END as   hold_event
,       regexp_substr(h.program,''[^\.@]+'',1,1)||'' ''||
        regexp_replace(regexp_substR(regexp_substr(h.program,''[\.@].+'',1,1),''[\(].+'',1,1),''[[:digit:]]'',''n'',1,0) hold_program
,       h.module hold_module
,       CASE WHEN upper(h.program) LIKE ''ORACLE%'' 
             THEN REGEXP_REPLACE(h.action,''[[:digit:]]+'',''nnn'',1,1)
             ELSE h.action END hold_action
,       h.xid hold_xid
,       CASE WHEN w.blocking_inst_id != w.instance_number THEN ''CI'' END AS ci --cross-instance
FROM    w
        LEFT OUTER JOIN dba_hist_active_Sess_History h --holding session
        ON  h.dbid = w.dbid
        AND h.instance_number = w.blocking_inst_id
        AND h.snap_id = w.snap_id
        AND h.sample_time >= w.sample_time -2/86400
        AND h.sample_time <  w.sample_time +2/86400 --rough match cross instance
        AND (h.sample_id = w.sample_id OR h.instance_number != w.instance_number) --exact match local instance 
        AND h.session_id = w.blocking_Session
        AND h.session_serial# = w.blocking_Session_serial#
--add same dbid/date/snap_id criteria here
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
)
select /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */ hold_program, hold_module, hold_action, wait_event, hold_event
, ci
, sum(10) ash_Secs
from x
group by hold_program, hold_module, hold_action, wait_event, hold_event
, ci
order by ash_Secs desc
';
END;
/
--@@&&skip_diagnostics.edb360_9a_pre_one.sql

column hold_sql_id heading 'Holding|SQL ID'
column hold_sql_plan_hash_value heading 'Holding|SQL Plan|Hash Value'

DEF title = 'Profile of Blocking Sessions with SQL_ID';
DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
BEGIN
  :sql_text := '
-- developed by David Kurtz
WITH w AS ( --waiting sessions
	SELECT /*+ &&sq_fact_hints. &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
	       /* &&section_id..&&report_sequence. */ 
	dbid, instance_number
        ,       snap_id
	,       sample_id, sample_time
        ,       session_type wait_session_type
        ,       session_id, session_serial#
        ,       sql_id, sql_plan_hash_value, sql_plan_line_id
--simplified program name removing anything after first @ or dot until open a bracket
        ,       regexp_substr(program,''[^\.@]+'',1,1) ||'' ''||
                regexp_replace(regexp_substR(regexp_substr(program,''[\.@].+'',1,1),''[\(].+'',1,1),''[[:digit:]]'',''n'',1,0) wait_program 
        ,       CASE WHEN module=program THEN ''[not set]'' ELSE module END as wait_module
        ,       CASE WHEN upper(program) LIKE ''ORACLE%'' OR 1=1 
                     THEN REGEXP_REPLACE(action,''[[:digit:]]+'',''nnn'',1,1)
                     ELSE action END wait_action
        ,       NVL(event,''CPU+CPU wait'')  wait_event
        ,       xid    wait_xid
        ,       blocking_inst_id, blocking_session, blocking_session_serial#
        FROM       dba_Hist_active_Sess_history h
        WHERE   blocking_session_status = ''VALID'' --holding a lock
--add dbid/date/snap_id criteria here
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
), x as (
SELECT  /*+ &&sq_fact_hints. */ 
        /* &&ds_hint. &&ash_hints1. &&ash_hints2. &&ash_hints3. */ 
        /* &&section_id..&&report_sequence. */
      w.*
,       h.sample_id hold_sample_id
,       h.sample_time hold_Sample_time
,       h.session_Type hold_session_type
,       h.sql_id hold_sql_id
,       h.sql_plan_hash_Value hold_sql_plan_hash_Value
,       CASE WHEN h.sample_id IS NULL THEN ''Idle Blocker''
             ELSE NVL(h.event,''CPU+CPU Wait'') 
        END as   hold_event
,       regexp_substr(h.program,''[^\.@]+'',1,1)||'' ''||
        regexp_replace(regexp_substR(regexp_substr(h.program,''[\.@].+'',1,1),''[\(].+'',1,1),''[[:digit:]]'',''n'',1,0) hold_program
,       CASE WHEN h.module=h.program THEN ''[not set]'' ELSE h.module END as hold_module
,       CASE WHEN upper(h.program) LIKE ''ORACLE%'' OR 1=1
             THEN REGEXP_REPLACE(h.action,''[[:digit:]]+'',''nnn'',1,1)
             ELSE h.action END hold_action
,       h.xid hold_xid
,       CASE WHEN w.blocking_inst_id != w.instance_number THEN ''CI'' END AS ci --cross-instance
FROM    w
        LEFT OUTER JOIN dba_Hist_active_Sess_History h --holding session
        ON  h.dbid = w.dbid
        AND h.instance_number = w.blocking_inst_id
        AND h.snap_id = w.snap_id
        AND h.sample_time >= w.sample_time -2/86400
        AND h.sample_time <  w.sample_time +2/86400 --rough match cross instance
        AND (h.sample_id = w.sample_id OR h.instance_number != w.instance_number) --exact match local instance 
        AND h.session_id = w.blocking_Session
        AND h.session_serial# = w.blocking_Session_serial#
--add same dbid/date/snap_id criteria here
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
)
select hold_program, hold_module, hold_action, wait_event, hold_event
, hold_sql_id, hold_sql_plan_hash_value
, sum(10) ash_Secs
from x
group by hold_program, hold_module, hold_action, wait_event, hold_event
, hold_sql_id, hold_sql_plan_hash_value
order by ash_Secs desc
';
END;
/
--@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF title = 'Distributed Transactions awaiting Recovery';
DEF main_table = 'DBA_2PC_PENDING';
BEGIN
  :sql_text := '
-- requested by Milton Quinteros
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM dba_2pc_pending
 ORDER BY
       1, 2
';
END;
/
@@edb360_9a_pre_one.sql

DEF title = 'Connections for Pending Transactions';
DEF main_table = 'DBA_2PC_NEIGHBORS';
BEGIN
  :sql_text := '
-- requested by Milton Quinteros
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       *
  FROM dba_2pc_neighbors
 ORDER BY
       1
';
END;
/
@@edb360_9a_pre_one.sql

BEGIN
 :sql_text_backup := '
WITH
by_instance_and_snap AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.instance_number,	
       s.begin_interval_time,
       s.end_interval_time,
       MAX(r.current_utilization) current_utilization,
       MAX(r.max_utilization) max_utilization
  FROM dba_hist_resource_limit r,
       dba_hist_snapshot s
 WHERE s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
   AND r.snap_id = s.snap_id
   AND r.dbid = s.dbid
   AND r.instance_number = s.instance_number
   AND r.resource_name = ''@resource_name@''
 GROUP BY
       r.snap_id,
       r.instance_number,
       s.begin_interval_time,
       s.end_interval_time
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_interval_time), ''YYYY-MM-DD HH24:MI:SS'') begin_time,
       TO_CHAR(MIN(end_interval_time), ''YYYY-MM-DD HH24:MI:SS'') end_time,
       SUM(current_utilization) current_utilization,
       SUM(max_utilization) max_utilization,
       0 dummy_03,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM by_instance_and_snap
 GROUP BY
       snap_id
 ORDER BY
       snap_id
';
END;				
/

DEF chartype = 'LineChart';
DEF vbaseline = ''; 
DEF stacked = '';
DEF skip_lch = '';
DEF title = 'Processes Time Series';
DEF main_table = 'DBA_HIST_RESOURCE_LIMIT';
DEF vaxis = 'Processes';
DEF tit_01 = 'Current Utilization';
DEF tit_02 = 'Max Utilization';
DEF tit_03 = '';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

EXEC :sql_text := REPLACE(:sql_text_backup, '@resource_name@', 'processes');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF chartype = 'LineChart';
DEF vbaseline = ''; 
DEF stacked = '';
DEF skip_lch = '';
DEF title = 'Sessions Time Series';
DEF main_table = 'DBA_HIST_RESOURCE_LIMIT';
DEF vaxis = 'Sessions';
DEF tit_01 = 'Current Utilization';
DEF tit_02 = 'Max Utilization';
DEF tit_03 = '';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

EXEC :sql_text := REPLACE(:sql_text_backup, '@resource_name@', 'sessions');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF chartype = 'LineChart';
DEF vbaseline = ''; 
DEF stacked = '';
DEF skip_lch = '';
DEF title = 'Parallel Max Servers Time Series';
DEF main_table = 'DBA_HIST_RESOURCE_LIMIT';
DEF vaxis = 'Parallel max servers';
DEF tit_01 = 'Current Utilization';
DEF tit_02 = 'Max Utilization';
DEF tit_03 = '';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

EXEC :sql_text := REPLACE(:sql_text_backup, '@resource_name@', 'parallel_max_servers');
@@&&skip_diagnostics.edb360_9a_pre_one.sql    

BEGIN
 :sql_text := '
WITH
max_resource_limit AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.instance_number,	
       s.begin_interval_time,
       s.end_interval_time,
       r.resource_name,
       MAX(r.current_utilization) current_utilization
  FROM dba_hist_resource_limit r,
       dba_hist_snapshot s
 WHERE s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
   AND r.snap_id = s.snap_id
   AND r.dbid = s.dbid
   AND r.instance_number = s.instance_number
   AND r.resource_name IN (''sessions'', ''processes'', ''parallel_max_servers'')
 GROUP BY
       r.snap_id,
       r.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       r.resource_name
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_interval_time), ''YYYY-MM-DD HH24:MI:SS'') begin_time,
       TO_CHAR(MIN(end_interval_time), ''YYYY-MM-DD HH24:MI:SS'') end_time,
       SUM(CASE resource_name WHEN ''sessions''             THEN current_utilization ELSE 0 END) sessions,
       SUM(CASE resource_name WHEN ''processes''            THEN current_utilization ELSE 0 END) processes,
       SUM(CASE resource_name WHEN ''parallel_max_servers'' THEN current_utilization ELSE 0 END) parallel_max_servers,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM max_resource_limit
 GROUP BY
       snap_id
 ORDER BY
       snap_id
';
END;				
/

DEF chartype = 'LineChart';
DEF vbaseline = ''; 
DEF stacked = '';
DEF skip_lch = '';
DEF title = 'Sessions, Processes and Parallel Servers - Time Series1';
DEF main_table = 'DBA_HIST_RESOURCE_LIMIT';
DEF vaxis = 'Count';
DEF tit_01 = 'Sessions';
DEF tit_02 = 'Processes';
DEF tit_03 = 'Parallel Max Servers';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

@@&&skip_diagnostics.edb360_9a_pre_one.sql

BEGIN
 :sql_text := '
WITH
max_resource_limit AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.instance_number,	
       CAST(s.begin_interval_time AS DATE) begin_time,
       CAST(s.end_interval_time AS DATE) end_time,
       r.resource_name metric_name,
       MAX(r.current_utilization) value
  FROM dba_hist_resource_limit r,
       dba_hist_snapshot s
 WHERE s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
   AND r.snap_id = s.snap_id
   AND r.dbid = s.dbid
   AND r.instance_number = s.instance_number
   AND r.resource_name IN (''sessions'', ''processes'', ''parallel_max_servers'')
 GROUP BY
       r.snap_id,
       r.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       r.resource_name
),
max_sysmetric_summary AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number,
       begin_time, 
       end_time,
       metric_name, 
       ROUND(maxval, 3) value
  FROM dba_hist_sysmetric_summary
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND group_id = 2 /* 1 minute intervals */
   AND metric_name IN (''Active Serial Sessions'', ''Active Parallel Sessions'')
   AND maxval >= 0
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_time), ''YYYY-MM-DD HH24:MI:SS'') begin_time,
       TO_CHAR(MIN(end_time), ''YYYY-MM-DD HH24:MI:SS'') end_time,
       SUM(CASE metric_name WHEN ''sessions''                 THEN value ELSE 0 END) sessions,
       SUM(CASE metric_name WHEN ''processes''                THEN value ELSE 0 END) processes,
       SUM(CASE metric_name WHEN ''parallel_max_servers''     THEN value ELSE 0 END) max_parallel_servers,
       SUM(CASE metric_name WHEN ''Active Serial Sessions''   THEN value ELSE 0 END) max_active_serial_sessions,
       SUM(CASE metric_name WHEN ''Active Parallel Sessions'' THEN value ELSE 0 END) max_active_parallel_sessions,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT * FROM max_resource_limit UNION ALL SELECT * FROM max_sysmetric_summary)
 GROUP BY
       snap_id
 ORDER BY
       snap_id
';
END;				
/

DEF chartype = 'LineChart';
DEF vbaseline = ''; 
DEF stacked = '';
DEF skip_lch = '';
DEF title = 'Sessions, Processes and Parallel Servers - Time Series2';
DEF main_table = 'DBA_HIST_RESOURCE_LIMIT';
DEF vaxis = 'Count';
DEF tit_01 = 'Sessions';
DEF tit_02 = 'Processes';
DEF tit_03 = 'Max Parallel Servers';
DEF tit_04 = 'Max Active Serial Sessions';
DEF tit_05 = 'Max Active Parallel Sessions';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

@@&&skip_diagnostics.edb360_9a_pre_one.sql


BEGIN
 :sql_text := '
WITH
max_resource_limit AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       r.snap_id,
       r.instance_number,	
       CAST(s.begin_interval_time AS DATE) begin_time,
       CAST(s.end_interval_time AS DATE) end_time,
       r.resource_name metric_name,
       MAX(r.current_utilization) value
  FROM dba_hist_resource_limit r,
       dba_hist_snapshot s
 WHERE s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
   AND r.snap_id = s.snap_id
   AND r.dbid = s.dbid
   AND r.instance_number = s.instance_number
   AND r.resource_name IN (''sessions'', ''processes'', ''parallel_max_servers'')
 GROUP BY
       r.snap_id,
       r.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       r.resource_name
),
max_sysmetric_summary AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       snap_id,
       instance_number,
       begin_time, 
       end_time,
       metric_name, 
       ROUND(maxval, 3) value
  FROM dba_hist_sysmetric_summary
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND group_id = 2 /* 1 minute intervals */
   AND metric_name IN (''Active Serial Sessions'', 
                       ''Active Parallel Sessions'',
                       ''PQ QC Session Count'',
                       ''PQ Slave Session Count'',
                       ''Average Active Sessions'',
                       ''Session Count'')
   AND maxval >= 0
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_time), ''YYYY-MM-DD HH24:MI:SS'') begin_time,
       TO_CHAR(MIN(end_time), ''YYYY-MM-DD HH24:MI:SS'') end_time,
       SUM(CASE metric_name WHEN ''sessions''                 THEN value ELSE 0 END) sessions,
       SUM(CASE metric_name WHEN ''processes''                THEN value ELSE 0 END) processes,
       SUM(CASE metric_name WHEN ''parallel_max_servers''     THEN value ELSE 0 END) max_parallel_servers,
       SUM(CASE metric_name WHEN ''Active Serial Sessions''   THEN value ELSE 0 END) max_active_serial_sessions,
       SUM(CASE metric_name WHEN ''Active Parallel Sessions'' THEN value ELSE 0 END) max_active_parallel_sessions,
       SUM(CASE metric_name WHEN ''PQ QC Session Count''      THEN value ELSE 0 END) max_pq_qc_session_count,
       SUM(CASE metric_name WHEN ''PQ Slave Session Count''   THEN value ELSE 0 END) max_pq_slave_session_count,
       SUM(CASE metric_name WHEN ''Average Active Sessions''  THEN value ELSE 0 END) max_average_active_sessions,
       SUM(CASE metric_name WHEN ''Session Count''            THEN value ELSE 0 END) max_session_count,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT * FROM max_resource_limit UNION ALL SELECT * FROM max_sysmetric_summary)
 GROUP BY
       snap_id
 ORDER BY
       snap_id
';
END;				
/

DEF chartype = 'LineChart';
DEF vbaseline = ''; 
DEF stacked = '';
DEF skip_lch = '';
DEF title = 'Sessions, Processes and Parallel Servers - Time Series3';
DEF main_table = 'DBA_HIST_RESOURCE_LIMIT';
DEF vaxis = 'Count';
DEF tit_01 = 'Sessions';
DEF tit_02 = 'Processes';
DEF tit_03 = 'Max Parallel Servers';
DEF tit_04 = 'Max Active Serial Sessions';
DEF tit_05 = 'Max Active Parallel Sessions';
DEF tit_06 = 'Max PQ QC Session Count';
DEF tit_07 = 'Max PQ Slave Session Count';
DEF tit_08 = 'Max Average Active Sessions';
DEF tit_09 = 'Max Session Count';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

@@&&skip_diagnostics.edb360_9a_pre_one.sql

BEGIN
 :sql_text := '
WITH
max_resource_limit AS (
SELECT /*+ &&sq_fact_hints. */ /* &&section_id..&&report_sequence. */
       1 branch,
       r.snap_id,
       r.instance_number,	
       CAST(s.begin_interval_time AS DATE) begin_time,
       CAST(s.end_interval_time AS DATE) end_time,
       r.resource_name metric_name,
       MAX(r.current_utilization) value
  FROM dba_hist_resource_limit r,
       dba_hist_snapshot s
 WHERE s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
   AND r.snap_id = s.snap_id
   AND r.dbid = s.dbid
   AND r.instance_number = s.instance_number
   AND r.resource_name IN (''sessions'', ''processes'', ''parallel_max_servers'')
 GROUP BY
       r.snap_id,
       r.instance_number,
       s.begin_interval_time,
       s.end_interval_time,
       r.resource_name
),
max_sysmetric_summary AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       2 branch,
       snap_id,
       instance_number,
       begin_time, 
       end_time,
       metric_name, 
       ROUND(maxval, 3) value
  FROM dba_hist_sysmetric_summary
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND group_id = 2 /* 1 minute intervals */
   AND metric_name IN (''Active Serial Sessions'', 
                       ''Active Parallel Sessions'',
                       ''PQ QC Session Count'',
                       ''PQ Slave Session Count'',
                       ''Average Active Sessions'',
                       ''Session Count'')
   AND maxval >= 0
),
avg_sysmetric_summary AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */ /* &&section_id..&&report_sequence. */
       3 branch,
       snap_id,
       instance_number,
       begin_time, 
       end_time,
       metric_name, 
       ROUND(average, 3) value
  FROM dba_hist_sysmetric_summary
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&edb360_dbid.
   AND group_id = 2 /* 1 minute intervals */
   AND metric_name IN (''Active Serial Sessions'', 
                       ''Active Parallel Sessions'',
                       ''PQ QC Session Count'',
                       ''PQ Slave Session Count'',
                       ''Average Active Sessions'',
                       ''Session Count'')
   AND average >= 0
)
SELECT /*+ &&top_level_hints. */ /* &&section_id..&&report_sequence. */
       snap_id,
       TO_CHAR(MIN(begin_time), ''YYYY-MM-DD HH24:MI:SS'') begin_time,
       TO_CHAR(MIN(end_time), ''YYYY-MM-DD HH24:MI:SS'') end_time,
       SUM(CASE branch WHEN 1 THEN (CASE metric_name WHEN ''sessions''                 THEN value ELSE 0 END) ELSE 0 END) sessions,
       SUM(CASE branch WHEN 1 THEN (CASE metric_name WHEN ''processes''                THEN value ELSE 0 END) ELSE 0 END) processes,
       SUM(CASE branch WHEN 1 THEN (CASE metric_name WHEN ''parallel_max_servers''     THEN value ELSE 0 END) ELSE 0 END) max_parallel_servers,
       SUM(CASE branch WHEN 2 THEN (CASE metric_name WHEN ''Active Serial Sessions''   THEN value ELSE 0 END) ELSE 0 END) max_active_serial_sessions,
       SUM(CASE branch WHEN 2 THEN (CASE metric_name WHEN ''Active Parallel Sessions'' THEN value ELSE 0 END) ELSE 0 END) max_active_parallel_sessions,
       SUM(CASE branch WHEN 2 THEN (CASE metric_name WHEN ''PQ QC Session Count''      THEN value ELSE 0 END) ELSE 0 END) max_pq_qc_session_count,
       SUM(CASE branch WHEN 2 THEN (CASE metric_name WHEN ''PQ Slave Session Count''   THEN value ELSE 0 END) ELSE 0 END) max_pq_slave_session_count,
       SUM(CASE branch WHEN 2 THEN (CASE metric_name WHEN ''Average Active Sessions''  THEN value ELSE 0 END) ELSE 0 END) max_average_active_sessions,
       SUM(CASE branch WHEN 2 THEN (CASE metric_name WHEN ''Session Count''            THEN value ELSE 0 END) ELSE 0 END) max_session_count,
       SUM(CASE branch WHEN 3 THEN (CASE metric_name WHEN ''Active Serial Sessions''   THEN value ELSE 0 END) ELSE 0 END) avg_active_serial_sessions,
       SUM(CASE branch WHEN 3 THEN (CASE metric_name WHEN ''Active Parallel Sessions'' THEN value ELSE 0 END) ELSE 0 END) avg_active_parallel_sessions,
       SUM(CASE branch WHEN 3 THEN (CASE metric_name WHEN ''PQ QC Session Count''      THEN value ELSE 0 END) ELSE 0 END) avg_pq_qc_session_count,
       SUM(CASE branch WHEN 3 THEN (CASE metric_name WHEN ''PQ Slave Session Count''   THEN value ELSE 0 END) ELSE 0 END) avg_pq_slave_session_count,
       SUM(CASE branch WHEN 3 THEN (CASE metric_name WHEN ''Average Active Sessions''  THEN value ELSE 0 END) ELSE 0 END) avg_average_active_sessions,
       SUM(CASE branch WHEN 3 THEN (CASE metric_name WHEN ''Session Count''            THEN value ELSE 0 END) ELSE 0 END) avg_session_count
  FROM (SELECT * FROM max_resource_limit UNION ALL SELECT * FROM max_sysmetric_summary UNION ALL SELECT * FROM avg_sysmetric_summary)
 GROUP BY
       snap_id
 ORDER BY
       snap_id
';
END;				
/

DEF chartype = 'LineChart';
DEF vbaseline = ''; 
DEF stacked = '';
DEF skip_lch = '';
DEF title = 'Sessions, Processes and Parallel Servers - Time Series4';
DEF main_table = 'DBA_HIST_RESOURCE_LIMIT';
DEF vaxis = 'Count';
DEF tit_01 = 'Sessions';
DEF tit_02 = 'Processes';
DEF tit_03 = 'Max Parallel Servers';
DEF tit_04 = 'Max Active Serial Sessions';
DEF tit_05 = 'Max Active Parallel Sessions';
DEF tit_06 = 'Max PQ QC Session Count';
DEF tit_07 = 'Max PQ Slave Session Count';
DEF tit_08 = 'Max Average Active Sessions';
DEF tit_09 = 'Max Session Count';
DEF tit_10 = 'Avg Active Serial Sessions';
DEF tit_11 = 'Avg Active Parallel Sessions';
DEF tit_12 = 'Avg PQ QC Session Count';
DEF tit_13 = 'Avg PQ Slave Session Count';
DEF tit_14 = 'Avg Average Active Sessions';
DEF tit_15 = 'Avg Session Count';

@@&&skip_diagnostics.edb360_9a_pre_one.sql


SPO &&edb360_main_report..html APP;
PRO </ol>
SPO OFF;

