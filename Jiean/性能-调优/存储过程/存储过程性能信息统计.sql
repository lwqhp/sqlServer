

--存储过程性能信息统计

/*
sys.dm_exec_procedure_stats : 返回缓存存储过程的聚合性能统计信息。
该视图为每个缓存的存储过程计划都返回一行，行的生存期与存储过程保持缓存状态的时间一样长。从缓存中删除存储过程时
也将从该图中删除对应行。
*/

--监控存储过程的执行
SELECT 
p.NAME AS spName
,qs.last_elapsed_time/1000 AS [lastExecTime(ms)]
,(total_elapsed_time/execution_count)/1000 AS [agexectim(ms)]
,min_elapsed_time/1000 AS [minexectime(ms)]
,max_elapsed_time/1000 AS [maxexectime(ms)]
,(total_worker_time/execution_count)/1000 AS [avgcputime(ms)]
,qs.execution_count AS exccount
,qs.cached_time AS lastcachedtime
,(total_logical_writes+total_logical_reads)/execution_count AS avglogicalios
,min_logical_reads AS minlogicalreads
,max_logical_reads AS maxlogicalreads
,min_logical_writes AS minlogicalwrites
,max_logical_writes AS maxlogicalwrites
FROM sys.dm_exec_procedure_stats qs,sys.procedures p
WHERE p.object_id = qs.object_id
ORDER BY [lastexectime(ms)] DESC 

/*
1,每隔一段时间收集一次
2，比对最后执行时间和最大执行时间（或平均执行时间）
*/
