

--计划缓存动态视图
/*
除了跟踪，指定语句的分析，唯一能从数据库内部了解语句的历史运行信息，就只有计划缓存了。

sqlserver提供了四个动态视图从不同的角度记录执行计划的运行信息
sys.dm_exec_cached_plans --主要使用的计数，占用的内存量
sys.dm_exec_query_stats --非常详细的记录执行计划的使用信息，含聚合
sys.dm_exec_sql_text() --执行计划文本
sys.dm_exec_query_plan --xml格式显示计划
*/


--查询执行计划中执行时间最长的语句
;WITH tmp AS(
SELECT a.*,SUBSTRING(b.text,(a.statement_start_offset/2)+1,(
	(CASE statement_end_offset 
	WHEN -1 THEN datalength(b.text) 
	ELSE a.statement_end_offset END -a.statement_start_offset)/2)+1) AS statement_text
FROM sys.dm_exec_query_stats a
CROSS APPLY sys.dm_exec_sql_text(a.sql_handle) b
)
SELECT query_hash,
SUM(total_worker_time) / SUM(execution_count) AS "Avg CPU Time",
MIN(statement_text) AS "Statement Text"
FROM tmp
GROUP BY query_hash
ORDER BY 2 DESC 

--返回查询的行计数聚合信息（总行数、最小行数、最大行数和上一次行数）
SELECT qs.execution_count,
    SUBSTRING(qt.text,qs.statement_start_offset/2 +1, 
                 (CASE WHEN qs.statement_end_offset = -1 
                       THEN LEN(CONVERT(nvarchar(max), qt.text)) * 2 
                       ELSE qs.statement_end_offset end -
                            qs.statement_start_offset
                 )/2
             ) AS query_text, 
     qt.dbid, dbname= DB_NAME (qt.dbid), qt.objectid, 
     qs.total_rows, qs.last_rows, qs.min_rows, qs.max_rows
FROM sys.dm_exec_query_stats AS qs 
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt 
WHERE qt.text like '%SELECT%' 
ORDER BY qs.execution_count DESC;

--使用次数和占内存大小
SELECT  TOP 100 usecounts,
    objtype,
    p.size_in_bytes,
    [sql].[text]
FROM sys.dm_exec_cached_plans p
OUTER APPLY sys.dm_exec_sql_text (p.plan_handle) sql
ORDER BY size_in_bytes DESC

--每个查询执行次数
select 
b.text,SUBSTRING(b.text,(a.statement_start_offset/2)+1,(
	(CASE statement_end_offset 
	WHEN -1 THEN datalength(b.text) 
	ELSE a.statement_end_offset END -a.statement_start_offset)/2)+1) AS statement_text,
	execution_count
 from sys.dm_exec_query_stats a
cross apply sys.dm_exec_sql_text(a.sql_handle) b 
order by execution_count desc  

--前10个I / O密集型查询
select 
b.text,SUBSTRING(b.text,(a.statement_start_offset/2)+1,(
	(CASE statement_end_offset 
	WHEN -1 THEN datalength(b.text) 
	ELSE a.statement_end_offset END -a.statement_start_offset)/2)+1) AS statement_text,a.total_logical_writes+a.total_logical_writes,last_logical_writes,min_logical_writes,max_logical_writes,total_logical_reads
,last_logical_reads,min_logical_reads,max_logical_reads,execution_count,total_worker_time,
db_name(b.dbid),object_id(b.objectid) 
from sys.dm_exec_query_stats a
cross apply sys.dm_exec_sql_text(a.sql_handle) b
where a.total_logical_writes+a.total_logical_writes>0
order by 3 desc 

--找出最经常重编译的存储过程
SELECT 
TOP 25 sql_text.text,sql_handle,plan_generation_num,execution_count,dbid,objectid
 FROM sys.dm_exec_query_stats a
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sql_text
WHERE plan_generation_num>1
ORDER BY plan_generation_num DESC 
