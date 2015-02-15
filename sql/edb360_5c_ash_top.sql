@@edb360_0g_tkprof.sql
DEF section_name = 'Active Session History (ASH) on CPU and Top Wait Events';
SPO &&edb360_main_report..html APP;
PRO <h2>&&section_name.</h2>
SPO OFF;

COL wait_class_01 NEW_V wait_class_01;
COL event_name_01 NEW_V event_name_01;
COL wait_class_02 NEW_V wait_class_02;
COL event_name_02 NEW_V event_name_02;
COL wait_class_03 NEW_V wait_class_03;
COL event_name_03 NEW_V event_name_03;
COL wait_class_04 NEW_V wait_class_04;
COL event_name_04 NEW_V event_name_04;
COL wait_class_05 NEW_V wait_class_05;
COL event_name_05 NEW_V event_name_05;
COL wait_class_06 NEW_V wait_class_06;
COL event_name_06 NEW_V event_name_06;
COL wait_class_07 NEW_V wait_class_07;
COL event_name_07 NEW_V event_name_07;
COL wait_class_08 NEW_V wait_class_08;
COL event_name_08 NEW_V event_name_08;
COL wait_class_09 NEW_V wait_class_09;
COL event_name_09 NEW_V event_name_09;
COL wait_class_10 NEW_V wait_class_10;
COL event_name_10 NEW_V event_name_10;
COL wait_class_11 NEW_V wait_class_11;
COL event_name_11 NEW_V event_name_11;
COL wait_class_12 NEW_V wait_class_12;
COL event_name_12 NEW_V event_name_12;

WITH
events AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */
       h.wait_class,
       h.event event_name,
       COUNT(*) samples
  FROM dba_hist_active_sess_history h,
       dba_hist_snapshot s
 WHERE '&&diagnostics_pack.' = 'Y'
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND h.session_state = 'WAITING'
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
   AND s.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s.dbid = &&edb360_dbid.
 GROUP BY
       h.wait_class,
       h.event
),
ranked AS (
SELECT wait_class, event_name,
       RANK () OVER (ORDER BY samples DESC) wrank
  FROM events
)
SELECT MIN(CASE wrank WHEN 01 THEN wait_class END) wait_class_01,
       MIN(CASE wrank WHEN 01 THEN event_name END) event_name_01,
       MIN(CASE wrank WHEN 02 THEN wait_class END) wait_class_02,
       MIN(CASE wrank WHEN 02 THEN event_name END) event_name_02,
       MIN(CASE wrank WHEN 03 THEN wait_class END) wait_class_03,
       MIN(CASE wrank WHEN 03 THEN event_name END) event_name_03,
       MIN(CASE wrank WHEN 04 THEN wait_class END) wait_class_04,
       MIN(CASE wrank WHEN 04 THEN event_name END) event_name_04,
       MIN(CASE wrank WHEN 05 THEN wait_class END) wait_class_05,
       MIN(CASE wrank WHEN 05 THEN event_name END) event_name_05,
       MIN(CASE wrank WHEN 06 THEN wait_class END) wait_class_06,
       MIN(CASE wrank WHEN 06 THEN event_name END) event_name_06,
       MIN(CASE wrank WHEN 07 THEN wait_class END) wait_class_07,
       MIN(CASE wrank WHEN 07 THEN event_name END) event_name_07,
       MIN(CASE wrank WHEN 08 THEN wait_class END) wait_class_08,
       MIN(CASE wrank WHEN 08 THEN event_name END) event_name_08,
       MIN(CASE wrank WHEN 09 THEN wait_class END) wait_class_09,
       MIN(CASE wrank WHEN 09 THEN event_name END) event_name_09,
       MIN(CASE wrank WHEN 10 THEN wait_class END) wait_class_10,
       MIN(CASE wrank WHEN 10 THEN event_name END) event_name_10,
       MIN(CASE wrank WHEN 11 THEN wait_class END) wait_class_11,
       MIN(CASE wrank WHEN 11 THEN event_name END) event_name_11,
       MIN(CASE wrank WHEN 12 THEN wait_class END) wait_class_12,
       MIN(CASE wrank WHEN 12 THEN event_name END) event_name_12
  FROM ranked
 WHERE wrank < 13;

COL recovery NEW_V recovery;
SELECT CHR(38)||' recovery' recovery FROM DUAL;
-- this above is to handle event "RMAN backup & recovery I/O"

DEF slices = '15';
BEGIN
  :sql_text_backup2 := '
WITH
events AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */
       SUBSTR(TRIM(h.sql_id||'' ''||h.program||'' ''||
       CASE h.module WHEN h.program THEN NULL ELSE h.module END), 1, 128) source,
       h.dbid,
       COUNT(*) samples
  FROM dba_hist_active_sess_history h,
       dba_hist_snapshot s
 WHERE @filter_predicate@
   AND h.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND h.dbid = &&edb360_dbid.
   AND s.snap_id = h.snap_id
   AND s.dbid = h.dbid
   AND s.instance_number = h.instance_number
 GROUP BY
       h.sql_id,
       h.program,
       h.module,
       h.dbid
 ORDER BY
       3 DESC
),
total AS (
SELECT SUM(samples) samples,
       SUM(CASE WHEN ROWNUM > &&slices. THEN samples ELSE 0 END) others
  FROM events
)
SELECT e.source,
       e.samples,
       ROUND(100 * e.samples / t.samples, 1) percent,
       (SELECT DBMS_LOB.SUBSTR(s.sql_text, 1000) FROM dba_hist_sqltext s WHERE s.sql_id = SUBSTR(e.source, 1, 13) AND s.dbid = e.dbid AND ROWNUM = 1) sql_text
  FROM events e,
       total t
 WHERE ROWNUM <= &&slices.
   AND ROUND(100 * e.samples / t.samples, 1) > 0.1
 UNION ALL
SELECT ''Others'',
       others samples,
       ROUND(100 * others / samples, 1) percent,
       NULL sql_text
  FROM total
 WHERE others > 0
   AND ROUND(100 * others / samples, 1) > 0.1
';
END;
/

DEF skip_lch = '';
DEF title = 'AAS on CPU per Instance';
DEF abstract = 'Average Active Sessions (AAS) on CPU'
DEF vaxis = 'Average Active Sessions (AAS) on CPU (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'session_state = ''ON CPU''');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS on CPU per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.session_state = ''ON CPU''');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_01. "&&event_name_01." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_01. "&&event_name_01."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_01. "&&event_name_01." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_01.'') AND event = TRIM(''&&event_name_01.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_01. "&&event_name_01." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_01.'') AND h.event = TRIM(''&&event_name_01.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_02. "&&event_name_02." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_02. "&&event_name_02."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_02. "&&event_name_02." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_02.'') AND event = TRIM(''&&event_name_02.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_02. "&&event_name_02." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_02.'') AND h.event = TRIM(''&&event_name_02.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_03. "&&event_name_03." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_03. "&&event_name_03."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_03. "&&event_name_03." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_03.'') AND event = TRIM(''&&event_name_03.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_03. "&&event_name_03." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_03.'') AND h.event = TRIM(''&&event_name_03.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_04. "&&event_name_04." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_04. "&&event_name_04."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_04. "&&event_name_04." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_04.'') AND event = TRIM(''&&event_name_04.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_04. "&&event_name_04." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_04.'') AND h.event = TRIM(''&&event_name_04.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_05. "&&event_name_05." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_05. "&&event_name_05."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_05. "&&event_name_05." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_05.'') AND event = TRIM(''&&event_name_05.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_05. "&&event_name_05." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_05.'') AND h.event = TRIM(''&&event_name_05.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_06. "&&event_name_06." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_06. "&&event_name_06."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_06. "&&event_name_06." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_06.'') AND event = TRIM(''&&event_name_06.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_06. "&&event_name_06." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_06.'') AND h.event = TRIM(''&&event_name_06.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_07. "&&event_name_07." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_07. "&&event_name_07."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_07. "&&event_name_07." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_07.'') AND event = TRIM(''&&event_name_07.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_07. "&&event_name_07." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_07.'') AND h.event = TRIM(''&&event_name_07.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_08. "&&event_name_08." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_08. "&&event_name_08."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_08. "&&event_name_08." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_08.'') AND event = TRIM(''&&event_name_08.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_08. "&&event_name_08." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_08.'') AND h.event = TRIM(''&&event_name_08.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_09. "&&event_name_09." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_09. "&&event_name_09."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_09. "&&event_name_09." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_09.'') AND event = TRIM(''&&event_name_09.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_09. "&&event_name_09." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_09.'') AND h.event = TRIM(''&&event_name_09.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_10. "&&event_name_10." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_10. "&&event_name_10."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_10. "&&event_name_10." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_10.'') AND event = TRIM(''&&event_name_10.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_10. "&&event_name_10." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_10.'') AND h.event = TRIM(''&&event_name_10.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_11. "&&event_name_11." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_11. "&&event_name_11."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_11. "&&event_name_11." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_11.'') AND event = TRIM(''&&event_name_11.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_11. "&&event_name_11." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_11.'') AND h.event = TRIM(''&&event_name_11.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AAS Waiting on &&wait_class_12. "&&event_name_12." per Instance';
DEF abstract = 'Average Active Sessions (AAS) Waiting on &&wait_class_12. "&&event_name_12."'
DEF vaxis = 'Average Active Sessions (AAS) Waiting on &&wait_class_12. "&&event_name_12." (stacked)';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'wait_class = TRIM(''&&wait_class_12.'') AND event = TRIM(''&&event_name_12.'')');
EXEC :sql_text := REPLACE(:sql_text, '@column_name@', 'aas_total');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

DEF skip_pch = '';
DEF title = 'AAS Waiting on &&wait_class_12. "&&event_name_12." per Source';
EXEC :sql_text := REPLACE(:sql_text_backup2, '@filter_predicate@', 'h.wait_class = TRIM(''&&wait_class_12.'') AND h.event = TRIM(''&&event_name_12.'')');
@@&&skip_diagnostics.edb360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';
