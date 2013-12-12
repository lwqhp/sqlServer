

--�ƻ����涯̬��ͼ
/*
���˸��٣�ָ�����ķ�����Ψһ�ܴ����ݿ��ڲ��˽�������ʷ������Ϣ����ֻ�мƻ������ˡ�

sqlserver�ṩ���ĸ���̬��ͼ�Ӳ�ͬ�ĽǶȼ�¼ִ�мƻ���������Ϣ
sys.dm_exec_cached_plans --��Ҫʹ�õļ�����ռ�õ��ڴ���
sys.dm_exec_query_stats --�ǳ���ϸ�ļ�¼ִ�мƻ���ʹ����Ϣ�����ۺ�
sys.dm_exec_sql_text() --ִ�мƻ��ı�
sys.dm_exec_query_plan --xml��ʽ��ʾ�ƻ�
*/


--��ѯִ�мƻ���ִ��ʱ��������
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

--���ز�ѯ���м����ۺ���Ϣ������������С�����������������һ��������
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

--ʹ�ô�����ռ�ڴ��С
SELECT  TOP 100 usecounts,
    objtype,
    p.size_in_bytes,
    [sql].[text]
FROM sys.dm_exec_cached_plans p
OUTER APPLY sys.dm_exec_sql_text (p.plan_handle) sql
ORDER BY size_in_bytes DESC

--ÿ����ѯִ�д���
SELECT QS.EXECUTION_COUNT, QT. TEXT AS QUERY_TEXT, QT.DBID, DBNAME= DB_NAME (QT.DBID), QT.OBJECTID, 
QS.TOTAL_ROWS, QS.LAST_ROWS, QS.MIN_ROWS, QS.MAX_ROWS 
FROM SYS.DM_EXEC_QUERY_STATS AS QS 
CROSS APPLY SYS.DM_EXEC_SQL_TEXT(QS.SQL_HANDLE) AS QT 
ORDER BY QS.EXECUTION_COUNT DESC 

--ǰ10��I / O�ܼ��Ͳ�ѯ
SELECT TOP 10 TOTAL_LOGICAL_READS, TOTAL_LOGICAL_WRITES, EXECUTION_COUNT, 
TOTAL_LOGICAL_READS+TOTAL_LOGICAL_WRITES AS [IO_TOTAL], 
QT. TEXT AS QUERY_TEXT, DB_NAME(QT.DBID) AS DATABASE_NAME, QT.OBJECTID AS OBJECT_ID 
FROM SYS.DM_EXEC_QUERY_STATS QS 
CROSS APPLY SYS.DM_EXEC_SQL_TEXT(SQL_HANDLE) QT 
WHERE TOTAL_LOGICAL_READS+TOTAL_LOGICAL_WRITES > 0 
ORDER BY [IO_TOTAL] DESC 