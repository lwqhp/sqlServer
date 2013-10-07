

--连接运算符-Merge Join

/*
Merge Join 是一种两两比对的关联。它要求两个数据集必须是先排序好的，这也是使用Merge连接的前提条件

首先，从两边的数据集中各取各一个值，比较一下，如果相等，就把这两行连接起来返回，如果不相等，就把小的那个值丢掉，
按顺序取下一个更大的。两边的数据集有一边遍历结束，整个join 的过程就结束了。
所以，整个算法最大遍历的次数 就是大的那个数据集里的记录数量，这在大数据集关联，是非常有优势的。

mary-to-mary：
Merge Join只能以“值相等”为条件的连接，如果数据集可能有重复的数据，merge join 要采用mary-to-mary这种很费资源
连接方式。如果数据集1有两个或者多个记录值相等，sqlserver就必肌得把数据集2里找描过的数据暂时建立一个数据结构存放起来
，万一数据集1里的下一个记录还是这个值，那还有用，这个临时的数据结构称为 worktable 会被 放在tempdb 或者内存里。


*/
USE AdventureWorks
go

DROP INDEX SalesOrderHeader_test_CL ON SalesOrderHeader_test
CREATE CLUSTERED  INDEX SalesOrderHeader_test_CL ON SalesOrderHeader_test(SalesOrderID)

SET STATISTICS PROFILE ON 

SELECT COUNT(b.SalesOrderID) FROM dbo.SalesOrderHeader_test a
INNER MERGE JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID
WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660

SET STATISTICS PROFILE OFF 

/*
	TotalSubtreeCost	Rows	Executes	StmtText
1	2.177477	1	1	SELECT COUNT(b.SalesOrderID) FROM dbo.SalesOrderHeader_test a  INNER MERGE JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID  WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660
2	2.177477	0	0	  |--Compute Scalar(DEFINE:([Expr1006]=CONVERT_IMPLICIT(int,[globalagg1008],0)))
3	2.177477	1	1	       |--Stream Aggregate(DEFINE:([globalagg1008]=SUM([partialagg1007])))
4	2.177475	4	1	            |--Parallelism(Gather Streams)
5	2.148973	4	4	                 |--Stream Aggregate(DEFINE:([partialagg1007]=Count(*)))
6	2.133881	50577	4	                      |--Merge Join(Inner Join, MANY-TO-MANY MERGE:([a].[SalesOrderID])=([b].[SalesOrderID]), RESIDUAL:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderID] as [a].[SalesOrderID]=[AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderID] as [b].[SalesOrderID]))
7	0.2880782	10000	4	                           |--Parallelism(Repartition Streams, Hash Partitioning, PARTITION COLUMNS:([a].[SalesOrderID]), ORDER BY:([a].[SalesOrderID] ASC))
8	0.1975928	10000	4	                           |    |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderHeader_test_CL] AS [a]), SEEK:([a].[SalesOrderID] > (43659) AND [a].[SalesOrderID] < (53660)) ORDERED FORWARD)
9	0.4232679	50577	4	                           |--Parallelism(Repartition Streams, Hash Partitioning, PARTITION COLUMNS:([b].[SalesOrderID]), ORDER BY:([b].[SalesOrderID] ASC))
10	0.0813826	50577	4	                                |--Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetail_test_NCL] AS [b]), SEEK:([b].[SalesOrderID] > (43659) AND [b].[SalesOrderID] < (53660)) ORDERED FORWARD)

上面例子我们指定了 MERGE JOIN 连接，来观察执行计划的优化方案

？第一眼看到MERGE Loops运算符，想到什么
答：这是一个两表平行关联连接，都有排序，是否有唯一性，遍历次数为最大表记录数。

 
首先， 从第6行 Merge Join，可以看出两个结果集是以SalesOrderID进行关联比较
在SalesOrderHeader_test的SalesOrderID上有聚集索引，所以第8行直接使用了聚集索引排序.

第10行说明执行计划找到一个排序索引，所以用了这个非聚集索引查找。

由于第一个数据集的SalesOrderID索引不是一个唯一索引，触发MANY-TO-MANY 连接

(注：如果最终select 返回的字段不在索引里，则这里会有所不同，执行计划会采用SalesOrderDetail_test的聚集索引SalesOrderDetailID)，
索引扫描需要的字段。
|--Parallelism(Repartition Streams, Hash Partitioning, PARTITION COLUMNS:([b].[SalesOrderID]))
  |--Clustered Index Scan(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_cl] AS [b]), WHERE:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderID] as [b].[SalesOrderID]>(43659) AND [AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderID] as [b].[SalesOrderID]<(53660)))



？如何观察Merge Join连接是否高效
答：
首先看是否出现Sort运算符，它通常是因为关联的字段没有排序而折中的采用其它算法后出现的，这里就是折中的通过SalesOrderDetailID聚集索引
去扫描SalesOrderID字段，然后再按SalesOrderID排序，从TotalSubtreeCost看出索引扫描点用很大的Cost.

然后再看Merge Join 有没有使用了mary-to-mary，这说明第一个结果集不能确定是唯一的。

？如何优化Merge Join连接
答：
1)两个结果集在关联前，必须在关联字段上有排序。
2）保证第一个结果集为unique的聚集索引
*/

--把SalesOrderID 改为唯一聚集索引
DROP INDEX SalesOrderHeader_test_CL ON SalesOrderHeader_test
CREATE UNIQUE CLUSTERED INDEX SalesOrderHeader_test_CL  ON SalesOrderHeader_test(SalesOrderID)

SET STATISTICS PROFILE ON 

SELECT COUNT(b.SalesOrderID) FROM dbo.SalesOrderHeader_test a
INNER MERGE JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID
WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660

SET STATISTICS PROFILE OFF   
/*
TotalSubtreeCost	Rows	Executes	StmtText
0.4796984	1	1	SELECT COUNT(b.SalesOrderID) FROM dbo.SalesOrderHeader_test a  INNER MERGE JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID  WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660
0.4796984	0	0	  |--Compute Scalar(DEFINE:([Expr1005]=CONVERT_IMPLICIT(int,[Expr1008],0)))
0.4796984	1	1	       |--Stream Aggregate(DEFINE:([Expr1008]=Count(*)))
0.4495145	50577	1	            |--Merge Join(Inner Join, MERGE:([a].[SalesOrderID])=([b].[SalesOrderID]), RESIDUAL:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderID] as [a].[SalesOrderID]=[AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderID] as [b].[SalesOrderID]))
0.2024309	10000	1	                 |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderHeader_test_CL] AS [a]), SEEK:([a].[SalesOrderID] > (43659) AND [a].[SalesOrderID] < (53660)) ORDERED FORWARD)
0.1092698	50577	1	                 |--Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetail_test_NCL] AS [b]), SEEK:([b].[SalesOrderID] > (43659) AND [b].[SalesOrderID] < (53660)) ORDERED FORWARD)

可以看到Merge Join没有使用mary-to-mary运算，计算成本也减少了1.6843665 Cost=2.133881-0.4495145=1.6843665
*/
