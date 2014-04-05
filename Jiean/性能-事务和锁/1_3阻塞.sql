

--阻塞
/*

产生阻塞的原因
1，在一个没有索引的表上过量的行锁会导致sqlserver得到一个表锁，从而阻塞其他事务
2，应用程序打开一个事务，关工事务保持打开的时候要求用户进行反馋或者交互。
3，事务begin后查询的数据可能在事务开始之前被引用
4，查询不恰当地使用锁定提示
5，应用程序使用长时间运行的事务，在一个事务中更新了很多行或很多表(把一个大量更新的事务变成多个更新较少
的事务能帮助改善并发性)

--阻塞觖决方案

1，优化阻塞和被阻塞的spid所执行的查询
2,减低隔离级别
3，分区争用的数据
	分区表数据把数据进行水平分割到不同的分区，这使用事务可以在单独的分区上并发执行，不会互相阻塞。这些单独
	的分区被作为查询，更新和插入的一个单元，sqlserver只分割存储和访问。
4，在争用的数据上使用覆盖索引

减少阻塞的建议
1，保持短的事务
2，在一个事务中执行最少的步骤、逻辑
3，不在要事务中执行大开销的外部活动，如发送感谳邮件或执行最终用户驱动的活动
4，使用索引优化查询
5，按照要求他建索引以确保系统中查谒的最优性能
6，避免在频繁更新的列上使用聚集索引，更新聚集索引列要求在聚集索引和非聚集索引上的锁
7，考虑使覆盖索引以服务被阻塞的seelct语句
8，考虑分区争用的表
9，使用查询超进来控制失控的查询
10，避免因为低劣的错误处理例 程开应用逻辑导致事务范围失控
11，使用set xact_abort on避免事务中出现错误时保持打开
12，在执行包含事务的sql批或者存储过程这后从客户端错误句柄catch 执行if @@trancount>0 rollback
13，使用所南非的最低隔离级别
14，使用默认隔离级别
15，考虑使用行版本控制帮助减少争用。


*/

--查询阻塞信息
SELECT  blocking_session_id, --主动阻塞进进程
wait_duration_ms,--阻塞时间
session_id --被阻塞进程
FROM sys.dm_os_waiting_tasks
WHERE blocking_session_id IS NOT NULL


--进程相关执行语句
SELECT b.text FROM sys.dm_exec_connections a
CROSS APPLY sys.dm_exec_sql_text(a.most_recent_sql_handle) b
WHERE a.session_id = 54

--杀掉进程
KILL 54 WITH statusonly

--设置语句等待锁释放的时长
SET LOCK_TIMEOUT 1000 --1秒

SELECT 
a.request_session_id AS waitingSessionID
, b.blocking_session_id AS blockingSessionID
,b.resource_description
,b.wait_type
,b.wait_duration_ms
,DB_NAME(a.resource_database_id) AS databaseName
,a.resource_associated_entity_id AS waitingAssociatedEntity
,a.resource_type AS waitingRequestType
,a.request_type AS waitingRequestType
,d.text AS waitingTsql
,g.request_type blockingRequestType
,f.text AS blockingTsql
FROM sys.dm_tran_locks a
INNER JOIN sys.dm_os_waiting_tasks b ON a.lock_owner_address = b.resource_address
INNER JOIN sys.dm_exec_requests c ON c.session_id = a.request_session_id
CROSS APPLY sys.dm_exec_sql_text(c.sql_handle) d
LEFT JOIN sys.dm_exec_requests e ON e.session_id = b.blocking_session_id
OUTER APPLY sys.dm_exec_sql_text(e.sql_handle) f
LEFT JOIN sys.dm_tran_locks g ON e.session_id = g.request_session_id



--sqltrace跟踪方式
--设置阻塞报告阈值
SET sp_configure 'blocked process threshold',5
RECONFIGURE;

--启用脚本trace ,Error and Wairnings --blocked rocess Report



--自动化侦测和收集阻塞信息
/*
性能监视器
SqlServer ：Locks
	average wait time 平均等待时间
	lock wait time 锁等待时间

*/



