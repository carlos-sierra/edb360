-- MOS 	Suggestions if Your SYSAUX Tablespace Grows Rapidly or Too Large (Doc ID 1292724.1)
-- awrinfo.txt
DEF report_name = 'awrinfo.txt';
--@?/rdbms/admin/awrinfo.sql  

/* poor performance on SQL g4ar2xvjrgbd4 from awrinfo.sql
select component, bytes/POWER(10,6) as MB, rpad( segment_name || (case when partition_name is null then '' else '.' || partition_name end), 61 ) || ' -' || to_char(awrinfo_util.get_perc_usage( owner, segment_name, segment_type, partition_name), '990') || '%' as segnm_pct_spc_used, segment_type from (select owner, segment_name, partition_name, segment_type, awrinfo_util.get_type(segment_name) as component, bytes, rank() over (partition by awrinfo_util.get_type(segment_name) order by bytes desc,
segment_name asc, partition_name asc) as rnk, sum(bytes) over (partition by awrinfo_util.get_type(segment_name)) as grp_bytes from dba_segments where (segment_name like 'WRH%' or segment_name like 'WRM%') and tablespace_name = 'SYSAUX' and owner = 'SYS') where rnk <= 30 and bytes > 500000 order by grp_bytes desc, component asc, bytes desc
*/