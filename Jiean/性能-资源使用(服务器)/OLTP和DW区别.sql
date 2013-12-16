

--OLTP��data arehouse ����
/*
OLTP���ݿ����Ҫ��
1���������е���䳬��4�������join 
����������е����Ҫ�����ű��join,���Կ��ǽ������ݿ���Ʒ�ʽ��������һЩ�����ֶΣ��ÿռ任ȡ���ݿ��Ч�ʡ�

*/
--����������е�100�����
SELECT TOP 100 
cp.cacheobjtype,
cp.usecounts,
cp.size_in_bytes,
qs.statement_start_offset,
qs.statement_end_offset,
qt.dbid,
qt.objectid,
SUBSTRING(qt.text,qs.statement_start_offset/2,(CASE WHEN qs.statement_end_offset=-1 THEN LEN(convert(NVARCHAR(max),qt.text))*2 ELSE qs.statement_end_offset END -qs.statement_start_offset)/2) AS statement
FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
INNER JOIN sys.dm_exec_cached_plans AS cp ON qs.plan_handle=cp.plan_handle
WHERE cp.plan_handle = qs.plan_handle
AND cp.usecounts>4
ORDER BY dbid,usecounts DESC 

/*
�������µı���г���3������
����̫���Ӱ�����Ч��
*/
--����������޸ĵ�100������
SELECT TOP 100 * FROM sys.dm_db_index_operational_stats(NULL,NULL,NULL,NULL)
ORDER BY leaf_insert_count+leaf_delete_count+leaf_update_count DESC 

/*
����������i/otable scans range scans
���ȱ�ٺ�������
*/
--������i/o��Ŀ����50��估���ǵ�ִ�мƻ�
SELECT TOP 50 
(total_logical_reads/execution_count) AS avg_logical_reads,
(total_logical_writes/execution_count) AS avg_logical_writes,
(total_physical_reads/execution_count) AS avg_phys_reads,
execution_count,
statement_start_offset,statement_end_offset,
SUBSTRING(sql_text.text,statement_start_offset/2,
(CASE WHEN (statement_end_offset-statement_start_offset)/2<=0 
	THEN 64000 
	ELSE (statement_end_offset-statement_start_offset)/2 END)) AS exec_statement,
sql_text.text,
plan_text.*
 FROM sys.dm_exec_query_stats
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sql_text
CROSS APPLY sys.dm_exec_query_plan(plan_handle) AS plan_text
ORDER BY (total_logical_reads+total_logical_writes)/execution_count DESC

/*
signal waits >25%
ָ��ȴ�cpu��Դ��ʱ��ռ��ʱ��İٷֱȣ��������25%,˵��cpu��Դ���š�
*/
--����signal wait ռ�� waitʱ��İٷֱ�
SELECT CONVERT(NUMERIC(5,4),SUM(signal_wait_time_ms)/SUM(wait_time_ms))
FROM sys.dm_os_wait_stats

/*
ִ�мƻ�������<90%
OLTPϵͳ�ĺ�����䣬�����д���95%��ִ�мƻ�������

��������SQLServer:SQL Statistics 
Initial Compilations = SQL Compilations/sec-sql re-compilations/sec
ִ�мƻ�������=��batch requests/sec-Initial Compilations��/batch requestes/sec
*/

/*
�������е�Cxpacket�ȴ�״̬>5%
���ȣ�����������ζ��sqlserver�ڴ���һ����ۺܴ����䣬Ҫ������û�к��ʵ�������Ҫ������ɸѡ����û��ɸѡ���㹻
�ļ�¼��ʹ�����Ҫ���ش����Ľ���������oltpϵͳ�ﶼ�ǲ�����ģ���Σ��������л�Ӱ��oltpϵͳ������Ӧ�ٶȣ�
Ҳ�ǲ��Ƽ���
*/
--����cxpacketռ��waitʱ��İٷֱ�
DECLARE @cxpacker BIGINT
DECLARE @sumwaits BIGINT
SELECT @cxpacker =wait_time_ms
FROM sys.dm_os_wait_stats
WHERE wait_type='cxpacket'

SELECT @sumwaits = SUM(wait_time_ms)
FROM sys.dm_os_wait_stats
SELECT CONVERT(NUMERIC(5,4),@cxpacker/@sumwaits)

/*
page life expectancy <300sec
oltpϵͳ�Ĳ������Ƚϼ򵥣��������ǲ�Ӧ��Ҫ����̫������ݡ��������ҳ���ܳ�ʱ��ػ������ڴ���Ʊػ�Ӱ�����ܣ�
ͬʱҲ˵����ĳЩ���û�к��ʵ�������

sqlServer:buffer manager
sqlServer:buffer noder

page life expectancy<50%  �������½�50%

Memory Grants pending >1
�ȴ��ڴ������û���Ŀ���������1,һ�����ڴ�ѹ��
SQLServer Memory manager

SQL cache hit ratio <90% ���ֵ���ܳ�ʱ���С��90%,���򣬳�����ζ�����ڴ�ѹ��
SQLServer:Plan Cache

IO
Average Disk Sec/read >20ms 
��û��ioѹ��������£�������Ӧ����4-8ms�������
Physical Disk

Average disk sec/write >20ms
��������־�ļ�����������д��Ӧ����1ms�������
physical disk

BIg ios table scans range scans >1
���ȱ�ٺ��ʵ�����
SQLServer:Access methods full scans/sec ��range scans/sec �Ƚϸ�

����ǰ��λ�ĵȴ�״̬�����漸��
asynch_io_completion
io_completion
logmgr
writelog
pageiolatch_x
��Щ�ȴ�״̬��ζ����io�ȴ���

����

��������Ƶ��>2% 
*/
--��ѯ��ǰ���ݿ��������û������row lock�Ϸ���������Ƶ��
DECLARE @dbid INT
SELECT @dbid = DB_ID()

SELECT 
dbid=database_id,objectname = OBJECT_NAME(s.object_id)
,indexname = i.name,i.index_id
,row_lock_count,row_lock_wait_count
,[block%]=CAST(100.0*row_lock_wait_count/(1+row_lock_count) AS NUMERIC(15,2))
,row_lock_wait_in_ms
,[avg row lock waits in ms]=CAST(1.0*row_lock_wait_in_ms/(1+row_lock_wait_count) AS NUMERIC(15,2))
FROM sys.dm_db_index_operational_stats(@dbid,NULL,NULL,NULL) s,sys.indexes i
WHERE OBJECTPROPERTY(s.object_id,'isusertable')=1
AND i.object_id = s.object_id
AND i.index_id = s.index_id
ORDER BY row_lock_wait_count DESC 

/*
�����¼����� 30s
��sp_configure "blocked process threshold" �Զ����泬��30s���������

ƽ������ʱ�� >100ms 

����ǰ��λ�ȴ�״̬��������ͷ LCK_M_??
˵��ϵͳ����������

���������� ÿСʱ����5��
��trace flag 1204,������sqltrace �������ص��¼���

���紫��
��������ʱ������Ӧ��̫Ƶ���غ����ݿ⽻��
network interface:output queue length>2
���粻��֧��Ӧ�ú����ݿ�������Ľ�������

��������þ�
packets outbound disarded
packets outbound errors
packetreceived discarded
packets received errors
��������̫æ����packet�ڴ����ж�ʧ 
*/


----Data WareHouseϵͳ---------------------------
/*

���ݿ����
���ھ������еĲ�ѯ����Ҫ���������rid lookup������covered indexes���Ż�
���Խ����Ƚ϶�����������̶ȵ��Ż���ѯ�ٶ�

�������ٵ���Ƭ<25%
����ҳ����Ƭ�����Ӷ�ȡͬ��������Ҫ��ȡ��ҳ�����������ڴ��io���ɣ�Ҫ���ؽ������ķ�ʽ�ϸ������Ƭ���ʡ�
*/
--���ص�ǰ���ݿ�������Ƭ�ʴ���25%������
DECLARE @dbid INT
SELECT @dbid = DB_ID()
SELECT * FROM sys.dm_db_index_physical_stats(@dbid,NULL,NULL,NULL,NULL)
WHERE avg_fragmentation_in_percent>25
ORDER BY avg_fragmentation_in_percent DESC 

/*
���ڻ���һЩ���ӵĲ�ѯ��ȫ��ɨ��������ģ�����Ҫע�ⲻҪȱ����Ҫ������
*/
--��ǰ���ݿ����ȱ�ٵ�����
SELECT
d.*,s.avg_total_user_cost,s.avg_user_impact,s.last_user_seek,s.unique_compiles
 FROM sys.dm_db_missing_index_group_stats s
,sys.dm_db_missing_index_groups g
,sys.dm_db_missing_index_details d
WHERE s.group_handle = g.index_group_handle
AND d.index_handle  =g.index_handle
ORDER BY s.avg_user_impact DESC

--�Ƽ����������ֶ�
DECLARE @handle INT
SELECT @handle = d.index_handle
FROM sys.dm_db_missing_index_group_stats s
,sys.dm_db_missing_index_groups g
,sys.dm_db_missing_index_details d
WHERE s.group_handle = g.index_group_handle
AND d.index_handle =g.index_handle
SELECT * FROM sys.dm_db_missing_index_columns(@handle)
ORDER BY column_id

/*
signal waits >25%
ָ��ȴ�cpu��Դ��ʱ��ռ��ʱ��İٷֱȣ��������25%,˵��cpu��Դ���š�

����ִ�мƻ����� >25%
dwϵͳ���û���������ָ������oltpҪ�ٺܶ࣬����ÿһ�䶼�Ḵ�Ӻܶ࣬Ҫ����ö��io���������Ա�֤ʹ�������е�ִ��
�ƻ��ȱ���compileҪ��Ҫ�ö�

����ִ�мƻ�Ӧ�ñ��㷺ʹ�ã�cxpacketӦ��������ĵȴ�״̬ <10%
 ����ִ�мƻ�����Ҫ���и��Ӳ�ѯ��dwϵͳ�ȽϺ��ʣ������������ȴ�״̬��࣬Ҫ�����ǲ�ѯ���������ӣ����ò��о��Ѿ�
 �ܴﵽ���õ��ٶȣ�Ҫ������ϵͳ��������ƿ����
 
 memory grants pending >1
 �ȴ��ڴ������û���Ŀ����������������������һ�����ڴ�ѹ��
 
 page life expenctancy �������½�50%
 ˵���ڴ��ȱ���� ��������Ӱ�죬����Ҫ���һ���ǲ��ǿ���ͨ�����������Ż�
 



�ܽ᣺
1��dw���ݿ�ı����Խ�����һЩ����

2�����ɶ���һЩrecompile�����������˵�ִ�мƻ�

3������кܴ����������򣬿��Կ��Ǽ�һ������������

4����ÿ��sqlserver ��Ϊȱ�ٵ���������Ӧ�ü��Է���������Ӧ����ô���

5��������ɨ�������Ա���ģ���ô�����ڴ�����������Ŷ��ԲλἫ�а�����ͬʱҪ��reindex�ķ�������Ƭ���͵���С�޶�

6��ͨ������£�����ִ�ж�dw��������а�����
*/