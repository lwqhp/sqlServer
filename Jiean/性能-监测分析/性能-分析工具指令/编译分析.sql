

--编译分析
SET STATISTICS TIME ON 
/*
解释：
	CPU时间(cpu Time) :指的是在这一步，sqlServer所花的纯cpu时间是多少，也就是说，语句花了多少cpu资源。
	占用时间(elapsed time) : 一步一共用了多少时间，就也是语句运行的时间长短。
	
	
*/
--在独立环境下观察单个语句的编译原始情况---------------------------------------

USE AdventureWorks
go
DBCC DROPCLEANBUFFERS --清除buffer pool里的所有缓存的数据
DBCC freeproccache --清除buffer pool里的所有缓存的执行计划
go

SET STATISTICS TIME ON 
SET NOCOUNT ON 
DROP PROC longcompile
GO
ALTER PROC longcompile (@i INT ) 
AS
--PRINT 1
--PRINT 14
DECLARE @cmd VARCHAR(max)
--PRINT 2
DECLARE @j INT
--PRINT 3
SET @J =0
--PRINT 4
SET @cmd  ='
	select * from dbo.SalesOrderHeader_test a
	INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b.SalesOrderID
	INNER JOIN Production.Product p ON b.ProductID = p.ProductID
	WHERE a.SalesOrderID IN(43659'
	PRINT 5
	
WHILE @j<@i
BEGIN
PRINT 33
SET @cmd = @cmd +','+STR(@j+43659)
SET @j=@j+1
END
PRINT 9
SET @cmd=@cmd + ')'
PRINT @cmd
EXEC(@cmd)
PRINT 11
go
--PRINT 12
longcompile 1
--PRINT 13
SET STATISTICS TIME OFF 

/*
分析：

sql server分析和编译时间：这是语句的编译时间，由于编译主要是CPU的运算，所以一般cpu time 和Elapsed Time 是差不多的，如果
相差比较大，就有必要看看sql server 在系统资源上有没有瓶颈。
注：第一个编译时间是sqlBatch的编译时间，第二个编译时间是存储过程的编译时间。

sql server执行时间：这是语句的真正执行时间，占用时间包括了cpu时间和其它i/o操作，i/o等待，或者是阻塞等待时间。
DECLARE 语句没有执行时间
EXEC(@cmd) 会产生分析编译时间和两次执行时间，一次是里面语句的执行时间，一次是外面exce 的执行时间，他们之间的区别在
	占用时间的io等待上。
*/

--在应用环境下观察语句的分析编译情况---------------------------------------

/*
在应用环境下观察需要用到SQL Trace。主要通过比较某些事件开始时间点之间的间隔，算出当时的编译时间。

一个SQL批处理(Batch)块的编译时间，等于其SQL:BatchStarting 事件的开始时间，减去其第一条语句的SQL:StmtStarting事件开始时间（因为sqlServer
是先编译整个Batch,然后再开始运行第一句。）如果两个时间相等，说明是执行计划重用，或者编译时间可以忽略不计。

一个stored procedure 的编译时间，等于调用它的statement的SQL:StmtStarting 事件开始时间（或者是RPC:starting时间）减去其第一条
语句SP：StmtStarting 的开始时间(因为Sqlserver是先编译整理个SP，然后再运行第一句)。如果两个时间相等，说明是执行计划重用，或者编译时间可以忽略不计。
启用SP:CacheInsert事件，可以看到存储过程是否发生了编译。

如果是动态语句，在Batch或SP编译的时候 假不会包含它的编译时间，它的编译时间发生在它真正运行之前，
也就是exec 指令和真正的语句这两个sp:stmtstarting事件之间

exec(@cmd)的Duration时间减去@cmd的Duration时间(这个时间不包含编译时间)=exec(@cmd)的动态编译时间
exec(@cmd)的开始时间减去@cmd的开始时间=exec(@cmd)的动态编译时间


*/

/*
--?优化编译时间过长的语句
答：
如果你发现语句性能问题和编译有关，需考虑的方向有：
1）检查语句本身是否过于复杂，长度太长，可以把一句话折成几句更简单的语句，或者用temp table 代替大的in子句

2)检查语句使用的表格上是不是有太多的索引，索引越多，sqlserver要评估的执行计划就越多，花的时间越长，。
3）引导sqlserver尽量多重用执行计划，减少编译
*/