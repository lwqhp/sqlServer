

--阻塞
/*

产生阻塞的原因
1，在一个没有索引的表上过量的行锁会导致sqlserver得到一个表锁，从而阻塞其他事务
2，应用程序打开一个事务，关工事务保持打开的时候要求用户进行反馋或者交互。
3，事务begin后查询的数据可能在事务开始之前被引用
4，查询不恰当地使用锁定提示
5，应用程序使用长时间运行的事务，在一个事务中更新了很多行或很多表(把一个大量更新的事务变成多个更新较少
的事务能帮助改善并发性)
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

--死锁
/*
死锁产生的原因
1,应用程序以不同的次序访问表
2，应用程序使用了长时间运行的事务，在一个事务中更新很多行或很多表，这样就增加了行的表面积，从而导致死锁冲突
3,在一些情史下，sqlserver发出了一些行锁，之后它又决定将其升级为表锁，如果这些行在相同的数据页面中，并且两个
会话希望同时在相同的页面升级锁粒度，就会产生死锁。
*/

--死锁写日志追踪

DBCC TRACEON(1222,-1) --开启死锁跟踪标志，写日志
GO
DBCC TRACESTATUS --显示本地和全局会话中活动的跟踪
GO

--一个列锁例子
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

WHILE 1=1
BEGIN 
BEGIN TRAN 
	UPDATE purchasing.vendor SET creditrating=1 WHERE businessentityID = 1494
	UPDATE purchasing.vendor SET creditrating=2 WHERE businessentityID = 1492
COMMIT TRAN 
END

--
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

WHILE 1=1
BEGIN 
BEGIN TRAN 
	UPDATE purchasing.vendor SET creditrating=2 WHERE businessentityID = 1492
	UPDATE purchasing.vendor SET creditrating=1 WHERE businessentityID = 1494
COMMIT TRAN 
END

--关闭标志
DBCC TRACEOFF(1222,-1)
GO
DBCC TRACESTATUS

--设置死锁的优先级
SET DEADLOCK_PRIORITY LOW | NORMAL | High