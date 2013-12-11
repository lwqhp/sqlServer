

--死锁的定位和解决

/*
死锁：简单的讲，就是两个事务在执行过程中，都需要获取对方的资源，但其自身又受到了阻塞，而无法释放对方所需的资源。

事务执行所受到的阻碍可能来自：
1,锁资源,申请的锁资源过多，事务时间太长，导致事务间的交互等待。
2，工作线程，因等不到所需的工作线程执行事务，而进行睡眠状态，所占有的资源无法释放。
3，内存，内存不足而造成的等待。
4，并行查询执行的相关资源：当一条语句用多个线程运行时，线程和线程之间可能会发生死锁。

SqlServer死锁机制

SQLServer默认间隔5s定期搜索sqserver里的所有任务，检测到死锁后，数据库引擎通过选择其中一个线程作为死锁牺牲品
来结束死锁。终止线程当前执行的批处理，回滚死锁牺牲品的事务，并将1205错误返回到应用程序。默认回滚开销最小的
事务。

*/


--死锁的定位
/*

搞清楚：连接在那些资源之间产生了死锁。

a,跟踪方法：打开跟踪标志1222
b,SqServer Profiler死锁图形
*/

DBCC TRACEON(1222,-1)
/*
死锁牺牲的进程 ：deadlock victim= spid=
连接进程的来源：clientapp=,hostname=,loginname=

当前正在运行的对象：frame procname=
当前正在运行的语句：sqlhandle=
当前正在运行的批处理 inputbuf

正在申请的资源和类型 waitresource= lockmode=
当前开启了几层事务：transcount=

事务隔离级别：isolationlevel=

死锁资源类型：首句=ridlock
死锁资源内容：fileid= pageid= ..
持有资源进程和类型：ownerid= model=
等待资源进程和类型：waiterid= model=
*/

--SQLServer profiler -> Locks -> Deadlock Graph

--死锁分析解决
/*

1,相同的业务按同一业务逻辑访问资源，当能获取到A资源时，说明其它事务已经释放了A资源并正在访问B资源，
降低多事务并发执时造成交叉访问资源。

2，事务中不能有用户交互

3，保持事务简短并处于一个批处理中，事务执行时间越长，越容易发生阻塞，
事务处于一个批处理中可以最小化事务中的网络通信往返量，减少完成事务和释放锁可能。

4，使用较低的隔离级别
确定事务是否能在较代的隔离级别上运行。使用较低的隔离级别比使用较高的隔离级别持有共享锁的时间更短。

5，调整语句的执行计划，减少锁的申请数目。
比如sqlserver需要扫描整张表才能找到修改的记录，而在扫描的过程中，sqlserver要为读到的每一条记录加锁，如果执行
计划是seek,需要讯的记录数目比较少，申请的锁的数目也会比较少，可能就能避免死锁。
*/

DBCC TRACEON(1222,-1)
GO

USE AdventureWorks
go

SET NOCOUNT ON 
GO
WHILE 1=1
BEGIN 
	BEGIN TRAN 
	UPDATE dbo.Employee_Demo_Heap SET BirthDate=GETDATE() WHERE NationalIDNumber='480951955'
	SELECT * FROM dbo.Employee_Demo_Heap WHERE NationalIDNumber='480951955'
	COMMIT TRAN 
END
/*
在执行批处理时出现错误。错误消息为: 引发类型为“System.OutOfMemoryException”的异常。
*/

--连接二
DBCC TRACEON(1222,-1)
GO

USE AdventureWorks
go

USE AdventureWorks
go

SET NOCOUNT ON 
GO
WHILE 1=1
BEGIN 
	BEGIN TRAN 
	UPDATE dbo.Employee_Demo_Heap SET BirthDate=GETDATE() WHERE NationalIDNumber='407505660'
	SELECT * FROM dbo.Employee_Demo_Heap WHERE NationalIDNumber='407505660'
	COMMIT TRAN 
END
/*
消息 1205，级别 13，状态 45，第 5 行
事务(进程 ID 55)与另一个进程被死锁在 锁 资源上，并且已被选作死锁牺牲品。请重新运行该事务。
*/

/*
分析：
10/19/2013 11:26:39,spid7s,未知,Recovery is complete. This is an informational message only. No user action is required.
--等待资源者：process4c2bc8，他需要一个更新锁，
10/19/2013 11:26:32,spid15s,未知,waiter id=process4c2bc8 mode=U requestType=wait
10/19/2013 11:26:32,spid15s,未知,waiter-list
--这个锁资源的持有者：process4c3288，因为process4c2bc8正在执行update语句，所以在相应资源上申请排它锁，这是正常的。
10/19/2013 11:26:32,spid15s,未知,owner id=process4c3288 mode=X
10/19/2013 11:26:32,spid15s,未知,owner-list
--另一个锁资源
10/19/2013 11:26:32,spid15s,未知,ridlock fileid=1 pageid=25268 dbid=11 objectname=AdventureWorks.dbo.Employee_Demo_Heap id=lock8016cd00 mode=X associatedObjectId=72057594056212480
--等待资源者：process4c3288，他需要一个共享锁，因为他正在做查找
10/19/2013 11:26:32,spid15s,未知,waiter id=process4c3288 mode=S requestType=wait
10/19/2013 11:26:32,spid15s,未知,waiter-list --资源的等待列表
--这个锁资源的持有者：process4c2bc8，因为process4c2bc8正在执行update语句，所以在相应资源上申请排它锁，这是正常的。
10/19/2013 11:26:32,spid15s,未知,owner id=process4c2bc8 mode=X
10/19/2013 11:26:32,spid15s,未知,owner-list --资源的持有列表
--个锁资源，有锁的类型，定位信息
10/19/2013 11:26:32,spid15s,未知,ridlock fileid=1 pageid=25268 dbid=11 objectname=AdventureWorks.dbo.Employee_Demo_Heap id=lock82bb2e80 mode=X associatedObjectId=72057594056212480
10/19/2013 11:26:32,spid15s,未知,resource-list  --进程的资源列表
10/19/2013 11:26:32,spid15s,未知,END
10/19/2013 11:26:32,spid15s,未知,COMMIT TRAN
10/19/2013 11:26:32,spid15s,未知,SELECT * FROM dbo.Employee_Demo_Heap WHERE NationalIDNumber='480951955'
10/19/2013 11:26:32,spid15s,未知,UPDATE dbo.Employee_Demo_Heap SET BirthDate=GETDATE() WHERE NationalIDNumber='480951955'
10/19/2013 11:26:32,spid15s,未知,BEGIN TRAN
10/19/2013 11:26:32,spid15s,未知,BEGIN
10/19/2013 11:26:32,spid15s,未知,WHILE 1=1
10/19/2013 11:26:32,spid15s,未知,inputbuf  --正在执行的批处理语句块
--进程process4c2bc8
10/19/2013 11:26:32,spid15s,未知,UPDATE dbo.Employee_Demo_Heap SET BirthDate=GETDATE() WHERE NationalIDNumber='480951955'
10/19/2013 11:26:32,spid15s,未知,frame procname=adhoc line=4 stmtstart=68 stmtend=248 sqlhandle=0x020000002249792bd6df8d0c4302e643f5e19ac75c120d98
10/19/2013 11:26:32,spid15s,未知,ployee_Demo_Heap] set [BirthDate] = getdate()  WHERE [NationalIDNumber]=@1
10/19/2013 11:26:32,spid15s,未知,frame procname=adhoc line=4 stmtstart=68 stmtend=248 sqlhandle=0x02000000d73369359211ac96306bd966df7c5eee1da649d1
10/19/2013 11:26:32,spid15s,未知,executionStack
--这是第二个进程process4c2bc8
10/19/2013 11:26:32,spid15s,未知,process id=process4c2bc8 taskpriority=0 logused=208 waitresource=RID: 11:1:25268:37 waittime=2901 ownerId=2286 transactionname=user_transaction lasttranstarted=2013-10-19T11:26:29.897 XDES=0x8513b730 lockMode=U schedulerid=3 kpid=5916 status=suspended spid=59 sbid=0 ecid=0 priority=0 trancount=2 lastbatchstarted=2013-10-19T11:26:15.850 lastbatchcompleted=2013-10-19T11:26:15.850 clientapp=Microsoft SQL Server Management Studio - 查询 hostname=IF-PC hostpid=5856 loginname=sa isolationlevel=read committed (2) xactid=2286 currentdb=11 lockTimeout=4294967295 clientoption1=673187936 clientoption2=390200
10/19/2013 11:26:32,spid15s,未知,END
10/19/2013 11:26:32,spid15s,未知,COMMIT TRAN
10/19/2013 11:26:32,spid15s,未知,SELECT * FROM dbo.Employee_Demo_Heap WHERE NationalIDNumber='407505660'
10/19/2013 11:26:32,spid15s,未知,UPDATE dbo.Employee_Demo_Heap SET BirthDate=GETDATE() WHERE NationalIDNumber='407505660'
10/19/2013 11:26:32,spid15s,未知,BEGIN TRAN
10/19/2013 11:26:32,spid15s,未知,BEGIN
10/19/2013 11:26:32,spid15s,未知,WHILE 1=1
10/19/2013 11:26:32,spid15s,未知,inputbuf  --正在执行的批处理语句块
--process4c3288进程正在执行的语句
10/19/2013 11:26:32,spid15s,未知,SELECT * FROM dbo.Employee_Demo_Heap WHERE NationalIDNumber='407505660'
10/19/2013 11:26:32,spid15s,未知,frame procname=adhoc line=5 stmtstart=250 stmtend=396 sqlhandle=0x02000000fbe0ea1f49dd2abfd1de3ffc4db9389fa280ce66
10/19/2013 11:26:32,spid15s,未知,frame procname=adhoc line=5 stmtstart=250 stmtend=396 sqlhandle=0x02000000b20f3208a03c7d075c98490a478482075a345313
10/19/2013 11:26:32,spid15s,未知,executionStack
--第一个process4c3288进程，这里可以查看到进程的所有相关信息
10/19/2013 11:26:32,spid15s,未知,process id=process4c3288 taskpriority=0 logused=208 waitresource=RID: 11:1:25268:30 waittime=2900 ownerId=2285 transactionname=user_transaction lasttranstarted=2013-10-19T11:26:29.300 XDES=0x8513ae80 lockMode=S schedulerid=3 kpid=7868 status=suspended spid=56 sbid=0 ecid=0 priority=0 trancount=1 lastbatchstarted=2013-10-19T11:26:29.087 lastbatchcompleted=2013-10-19T11:26:29.087 clientapp=Microsoft SQL Server Management Studio - 查询 hostname=IF-PC hostpid=5856 loginname=sa isolationlevel=read committed (2) xactid=2285 currentdb=11 lockTimeout=4294967295 clientoption1=673187936 clientoption2=390200
10/19/2013 11:26:32,spid15s,未知,process-list --进程列表
10/19/2013 11:26:32,spid15s,未知,deadlock victim=process4c3288 --作为死锁的牺牲品ID
10/19/2013 11:26:32,spid15s,未知,deadlock-list  --死锁列表

从日志中可以看出，process4c3288的一个事务执行完更新语句后，接着执行一条查询语句，但是在对查询的记录申请共享锁
的时候，遇到了另一个正在更新事务，他在上面有排它锁，所以他进行了等待，而这个等待造成了自己上一句更新的排它锁不能释放。

同时，另一个事务需要更新语句，需在对查询的记录申请更新锁，当读到上一个事务的排它锁时进入了等待。至此，两个进程进入了等待对方的死循环中。

？从语句的条件来讲，两个事务都是在更新不同的记录，为什么需要去别的记录上申请共享锁和更新锁呢
原因为两条语句都没有合适的索引，从面采用了table scan表扫描，在所有经过的记录上都要申请共享锁和更新锁，那么他们就会有出现互相等待的可能。
根据墨菲定律：任何有可能发生的事情，那他就一定会发生。

解决思路：
1，调整索引，以调整执行计划，减少锁的申请数目，从而消除死锁。

2，使用nolock，让select 语句不要申请S锁，减少锁的数目

3，升级锁的粒度，将死锁转化为一个阻塞问题。

4，使用快照隔离级别
*/

