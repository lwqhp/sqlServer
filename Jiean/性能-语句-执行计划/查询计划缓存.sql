

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
SELECT QS.EXECUTION_COUNT, QT. TEXT AS QUERY_TEXT, QT.DBID, DBNAME= DB_NAME (QT.DBID), QT.OBJECTID, 
QS.TOTAL_ROWS, QS.LAST_ROWS, QS.MIN_ROWS, QS.MAX_ROWS 
FROM SYS.DM_EXEC_QUERY_STATS AS QS 
CROSS APPLY SYS.DM_EXEC_SQL_TEXT(QS.SQL_HANDLE) AS QT 
ORDER BY QS.EXECUTION_COUNT DESC 

--前10个I / O密集型查询
SELECT TOP 10 TOTAL_LOGICAL_READS, TOTAL_LOGICAL_WRITES, EXECUTION_COUNT, 
TOTAL_LOGICAL_READS+TOTAL_LOGICAL_WRITES AS [IO_TOTAL], 
QT. TEXT AS QUERY_TEXT, DB_NAME(QT.DBID) AS DATABASE_NAME, QT.OBJECTID AS OBJECT_ID 
FROM SYS.DM_EXEC_QUERY_STATS QS 
CROSS APPLY SYS.DM_EXEC_SQL_TEXT(SQL_HANDLE) QT 
WHERE TOTAL_LOGICAL_READS+TOTAL_LOGICAL_WRITES > 0 
ORDER BY [IO_TOTAL] DESC 