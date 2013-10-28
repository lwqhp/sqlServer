

--OLTP和data arehouse 区别
/*
OLTP数据库设计要求：
1，经常运行的语句超过4个表格做join 
如果经常运行的语句要做多张表的join,可以考虑降低数据库设计范式级别，增加一些冗余字段，用空间换取数据库的效率。

*/
--返回最经常运行的100条语句
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
经常更新的表格有超过3个索引
索引太多会影响更新效率
*/
--返回最经常被修改的100个索引
SELECT TOP 100 * FROM sys.dm_db_index_operational_stats(NULL,NULL,NULL,NULL)
ORDER BY leaf_insert_count+leaf_delete_count+leaf_update_count DESC 

/*
语句会做大量i/otable scans range scans
语句缺少合适索引
*/
--返回做i/o数目最多的50语句及它们的执行计划
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
指令等待cpu资源的时间占总时间的百分比，如果超过25%,说明cpu资源紧张。
*/
--计算signal wait 占整 wait时间的百分比
SELECT CONVERT(NUMERIC(5,4),SUM(signal_wait_time_ms)/SUM(wait_time_ms))
FROM sys.dm_os_wait_stats

/*
执行计划重用率<90%
OLTP系统的核心语句，必须有大于95%的执行计划重用率

计数器：SQLServer:SQL Statistics 
Initial Compilations = SQL Compilations/sec-sql re-compilations/sec
执行计划重用率=（batch requests/sec-Initial Compilations）/batch requestes/sec
*/

/*
并行运行的Cxpacket等待状态>5%
首先，并行运行意味着sqlserver在处理一句代价很大的语句，要不就是没有合适的索引，要不就是筛选条件没能筛选掉足够
的记录，使得语句要返回大量的结果，这个在oltp系统里都是不容许的，其次，并行运行会影响oltp系统整体响应速度，
也是不推荐的
*/
--计算cxpacket占整wait时间的百分比
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
oltp系统的操作都比较简单，所以它们不应该要访问太多的数据。如果数据页不能长时间地缓存在内存里，势必会影响性能，
同时也说明了某些语句没有合适的索引。

sqlServer:buffer manager
sqlServer:buffer noder

page life expectancy<50%  经常会下降50%

Memory Grants pending >1
等待内存分配的用户数目，如果大于1,一定有内存压力
SQLServer Memory manager

SQL cache hit ratio <90% 这个值不能长时间地小于90%,否则，常常意味阒有内存压力
SQLServer:Plan Cache

IO
Average Disk Sec/read >20ms 
在没有io压力的情况下，读操作应该在4-8ms以内完成
Physical Disk

Average disk sec/write >20ms
对于像日志文件这样的连续写，应该在1ms以内完成
physical disk

BIg ios table scans range scans >1
语句缺少合适的索引
SQLServer:Access methods full scans/sec 和range scans/sec 比较高

排在前两位的等待状态有下面几个
asynch_io_completion
io_completion
logmgr
writelog
pageiolatch_x
这些等待状态意味着有io等待。

阻塞

阻塞发生频率>2% 
*/
--查询当前数据库上所有用户表格在row lock上发生阻塞的频率
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
阻塞事件报告 30s
在sp_configure "blocked process threshold" 自动报告超过30s的阻塞语句

平均阻塞时间 >100ms 

排在前两位等待状态以这样开头 LCK_M_??
说明系统经常有阻塞

经常有死锁 每小时超过5个
打开trace flag 1204,或者在sqltrace 里跟踪相关的事件。

网络传输
网络有延时，或者应用太频繁地和数据库交互
network interface:output queue length>2
网络不能支持应用和数据库服务器的交互流量

网络带宽用尽
packets outbound disarded
packets outbound errors
packetreceived discarded
packets received errors
由于网络太忙，有packet在传输中丢失 
*/


----Data WareHouse系统---------------------------
/*

数据库设计
对于经常运行的查询它们要做的排序或rid lookup操作用covered indexes来优化
可以建立比较多的索引，最大程度的优化查询速度

尽可能少的碎片<25%
数据页面碎片会增加读取同等数据所要读取的页面数，增加内存和io负荷，要用重建索引的方式严格控制碎片比率。
*/
--返回当前数据库所有碎片率大于25%的索引
DECLARE @dbid INT
SELECT @dbid = DB_ID()
SELECT * FROM sys.dm_db_index_physical_stats(@dbid,NULL,NULL,NULL,NULL)
WHERE avg_fragmentation_in_percent>25
ORDER BY avg_fragmentation_in_percent DESC 

/*
由于会有一些复杂的查询，全表扫描是难免的，但是要注意不要缺少重要的索引
*/
--当前数据库可能缺少的索引
SELECT
d.*,s.avg_total_user_cost,s.avg_user_impact,s.last_user_seek,s.unique_compiles
 FROM sys.dm_db_missing_index_group_stats s
,sys.dm_db_missing_index_groups g
,sys.dm_db_missing_index_details d
WHERE s.group_handle = g.index_group_handle
AND d.index_handle  =g.index_handle
ORDER BY s.avg_user_impact DESC

--推荐建索引的字段
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
指令等待cpu资源的时间占总时间的百分比，如果超过25%,说明cpu资源紧张。

避免执行计划重用 >25%
dw系统里用户发过来的指令量比oltp要少很多，但是每一句都会复杂很多，要做多得多的io动作，所以保证使用最贴切的执行
计划比避免compile要重要得多

并行执行计划应该被广泛使用，cxpacket应该是最常见的等待状态 <10%
 并行执行计划对主要运行复杂查询的dw系统比较合适，如果不是这个等待状态最多，要不就是查询还不够复杂，不用并行就已经
 能达到良好的速度，要不就是系统还有其他瓶颈。
 
 memory grants pending >1
 等待内存分配的用户数目，如果有这样的情况发生，一定有内存压力
 
 page life expenctancy 经常会下降50%
 说明内存很缺，整 体性能受影响，还是要检查一下是不是可以通过建索引来优化
 



总结：
1，dw数据库的表格可以建立多一些索引

2，宁可多做一些recompile，少重用他人的执行计划

3，如果有很大结果集的排序，可以考虑加一个索引来避免

4，对每个sqlserver 认为缺少的索引，都应该加以分析，看看应该怎么解决

5，如果大的扫描是难以避免的，那么数据在磁盘上连续存放对性参会极有帮助，同时要用reindex的方法把碎片降低到最小限度

6，通常情况下，并发执行对dw里的语句会有帮助。
*/