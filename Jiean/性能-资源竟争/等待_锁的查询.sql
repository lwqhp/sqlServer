

--关于等待，锁的查询
/*
相关的视图，系统表

系统架构中的表
sys.parations : 系统中每一个表和索引的每个分区占一行（在sqlServer2008是有分区表的概念的，表和索引是按分区
	来组织的，默认是主文件组中的一个分区）。这个视图可以查看表和索引的分区ID
	
锁资源视图
sys.dm_tran_locks : 锁管理器视图，可以查看当前活动请求的锁信息，就是当前活动的，还没有结束的锁资源使用情况	


关于系统资源等待的视图
sys.dm_os_waiting_tasks : 可以查看当前正在等待资源的对象队列相关信息。

关于连接请求的视图
sys.dm_exec_requests : 可以查看当前的每个请求信息


关于查询语句的视图
sys.dm_exec_sql_text : 执行过的sql批处理文本


*/

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

--阻塞觖决方案
/*
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

--自动化侦测和收集阻塞信息
/*
性能监视器
SqlServer ：LOcks
	average wait time 平均等待时间
	lock wait time 锁等待时间

*/

--避免死锁
/*
1，按照相同的时间顺序访问资源
2，减少锁，比如将非聚集索引转换为聚集索引，为select语句使用覆盖索引
3，最小化锁的争用，比如实现行版本控制，降低隔离级别，使用锁提示
*/