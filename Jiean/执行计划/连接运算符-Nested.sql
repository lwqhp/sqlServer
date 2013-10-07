

--连接运算符-Nested loops Join

/*
表与表之间的关联，本质就是两表之间的一个循环遍历，sqlServer会对表间的关联进行分析，选择一个折中的循环算法.


sqlserver有三种join方法：Nested Loops Join , Merge Join , Hash Join
这三种方法，没有那一种是永远最好的，但是都有其最适合的上下文，sqlServer会根据两个结果集所基于的表格结构，以及
结果集的大小，选择最合适的连接方法。当然，你也可以在语句里指定join 的方法。

*/

--Nested loops Join
/*
Nested loops 是一种最基本的连接方法,只适用于内表数据集比较小的情况。
算法:对于两张要被 连接在一起的表格，sqlserver选择一张做outer table,另一张做 inner table
*/
USE AdventureWorks
go
SET STATISTICS PROFILE ON 

SELECT * FROM dbo.SalesOrderHeader_test a
INNER LOOP JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID
WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660

SET STATISTICS PROFILE OFF 

/*
	Rows	Executes	StmtText
1	50577	1	SELECT * FROM dbo.SalesOrderHeader_test a  INNER LOOP JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID  WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660
2	50577	1	  |--Parallelism(Gather Streams)
3	50577	4	       |--Nested Loops(Inner Join, OUTER REFERENCES:([Uniq1005], [b].[SalesOrderDetailID], [Expr1007]) WITH UNORDERED PREFETCH)
4	50577	4	            |--Sort(ORDER BY:([b].[SalesOrderDetailID] ASC, [Uniq1005] ASC))
5	50577	4	            |    |--Nested Loops(Inner Join, OUTER REFERENCES:([a].[SalesOrderID], [Expr1006]) WITH UNORDERED PREFETCH)
6	10000	4	            |         |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderHeader_test_CL] AS [a]), SEEK:([a].[SalesOrderID] > (43659) AND [a].[SalesOrderID] < (53660)) ORDERED FORWARD)
7	50577	10000	        |         |--Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetail_test_NCL] AS [b]), SEEK:([b].[SalesOrderID]=[AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderID] as [a].[SalesOrderID]),  WHERE:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderID] as [b].[SalesOrderID]>(43659) AND [AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderID] as [b].[SalesOrderID]<(53660)) ORDERED FORWARD)
8	50577	50577	        |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_cl] AS [b]), SEEK:([b].[SalesOrderDetailID]=[AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetailID] as [b].[SalesOrderDetailID] AND [Uniq1005]=[Uniq1005]) LOOKUP ORDERED FORWARD)

上面例子我们指定的Nested Loops Join 连接，来观察执行计划的优化方案

？第一眼看到Nested Loops运算符，想到什么
答：这是一个外内表连接，外表记录数决定内表的遍历次数

首先，第5行的OUTER REFERENCES,可以看到，sqlserver选择SalesOrderHeader_test作为outer table(外表),而SalesOrderDetail_test作为Inter table(内表)

先在SalesOrderHeader_test上使用聚集索引做一个seek,找出每一条a.SalesOrderID>43659 AND a.SalesOrderID <53660的记录
总共找到Rows=10000条记录。

每找到一条记录，sqlserver都时入inner table ,找能够和它join返回数据的记录 a.saleorderID = b.saleorderID
由于outer table 上有10000条记录符合，所以 inner table 被扫描了Executes=10000次 

分析
Nested Loops Join 算法不需要sqlServer为连接建立另外的数据结构，所以比较省内存空间，也无须使用TempDb的空间。它适用的join 类型是非常广泛的。

？怎么观察这种join算法是否高效呢
答：
首先，看下Nested Loops 的外表是那一个，估算下这个外连接表的记录是否比内联表要多的多，如果是，得找找原因，看看是不是统计信息不准。
因为每找到一笔Outer Table记录，都会扫描一次Inner Table 表，当扫描的次数增多，算法复杂度增加得非常快，总的资源
消耗也会增加得很快。

然后看下对Outer Table的查找，实际返回多少记录数Rows,这也是触发Nested Loops 内联表的扫描次数Executes
如果Inner Table 表被过多的扫描，我们就认为这种Join不是高效的。

？如何优化 Nested Loops Join关联呢
答：
1)尽量的减少OutTer Table 筛选结果，返回尽量少的数据
2)OutTer Table 事先排序好，比如实体表有聚集索引，并在聚集索引上查找，临时表插入按查找条件排好序的记录集，这可以减少Cost的开销。
3）和Inner Table关联检索的字段上要有一个索引，能够支持检索，以避免以每次做整个数据集的扫描。这样即使Inner Table数据集稍微大
一点也没关系 ，否则这种关联是很耗资源的。


*/