

--连接运算符-Hash Join

/*
Hash Join:利用哈希算法作匹配的连接算法，哈希算法分两步，“bulid”和“Probe” 
在 BULID阶段，sqlserver选择两个要做join 的数据集中的一个，根据记录的值 建立起一张在内存中的hash表，
然后在probe阶段，sqlserver选 择另外一个数据集，将里面的记录值依次带入，找出符合条件，返回可以做连接的行

特点
1,算法复杂度就是分别遍历两的数据集集各一遍
2，不需要数据集事先按照面什么顺序排序，也不要求上面有索引
3，可以比较容易地升级成使用多处理器的并行执行计划


*/
USE AdventureWorks
go

SET STATISTICS PROFILE ON 

SELECT * FROM dbo.SalesOrderHeader_test a
INNER Hash JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID
WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660

SET STATISTICS PROFILE OFF 

/*
	Rows	Executes	StmtText
1	50577	1	SELECT * FROM dbo.SalesOrderHeader_test a  INNER Hash JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID  WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660
2	50577	1	  |--Parallelism(Gather Streams)
3	50577	4	       |--Hash Match(Inner Join, HASH:([a].[SalesOrderID])=([b].[SalesOrderID]))
4	10000	4	            |--Parallelism(Repartition Streams, Hash Partitioning, PARTITION COLUMNS:([a].[SalesOrderID]))
5	10000	4	            |    |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderHeader_test_CL] AS [a]), SEEK:([a].[SalesOrderID] > (43659) AND [a].[SalesOrderID] < (53660)) ORDERED FORWARD)
6	50577	4	            |--Parallelism(Repartition Streams, Hash Partitioning, PARTITION COLUMNS:([b].[SalesOrderID]))
7	50577	4	                 |--Clustered Index Scan(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_cl] AS [b]), WHERE:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderID] as [b].[SalesOrderID]>(43659) AND [AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderID] as [b].[SalesOrderID]<(53660)))

上面例子我们指定了 Hash JOIN 连接，来观察执行计划的优化方案

？第一眼看到Hash Loops运算符，想到什么
答：这是一个两表哈希连接，各遍历两边数据集，大数据集，缺少索引

从第5行和第7行运算可以看出，Hash算法分别按条件遍历了两边的数据集，一个返回10000,一个返回50577
然后在 Hash Match 阶段(Probe) ，选择另外一个数据集，将里面的记录值依次带入，找出符合条件，返回可以做连接的行

？如何观察Merge Join连接是否高效
答：
Hash算法是比较折中的一种算法，是在Sqlserver输入不优化（join的数据集比较大，或上面没有合适的索引）的时候一种不得已选择。
主要观察执行计划对两边结果集的查找方案。

？如何优化Merge Join连接
答：
hash join是比较耗资源的算法，在做join之前，要先在内存里建立一张hash表，建立过程需示cpu资源，hash需要用内存
或tempdb存放，而join的过程也要使用cpu资源来计算 （probe）,建议还是尽量降低join输入的数据集的大小，配以合适
的索引，引导sqlserver尽量使用nested loop或merge来join
*/

