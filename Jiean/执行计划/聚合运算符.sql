

--聚合运算符 Aggregation，Concatenation ，parallelism

/*
主要用来计算 sum(),count,max,min等聚合运算，Aggregation分两种

stream aggreation: 将数据集排成一个队列以后做运算

hash aggreation:   类似 hash join ,需要在内存中建一个hash表，才能做运算

Concatenation : 数据合并
两种操作会生成 concatenation运算:union 和union all
union 会产生一个sort排序，把重复的数据去掉

parallelism : 并行的执行计划

观察聚合运算
Aggregate运算，说明此处产生一个聚合运算，是对前一个查找结果的聚合计算，如果前一个索引查找没有包含聚合的字段，
还会有一个排序运算，把需要聚合的字段排序.
当看到parallelism运算符，说明sqlserver使用多处理器并行处理。
*/

SET STATISTICS PROFILE ON 

SELECT SalesOrderID,COUNT(SalesOrderDetailID)
FROM dbo.SalesOrderDetail_test
GROUP BY SalesOrderID

SET STATISTICS PROFILE OFF 

/*
Rows	Executes	StmtText
31474	1	SELECT SalesOrderID,COUNT(SalesOrderDetailID)  FROM dbo.SalesOrderDetail_test  GROUP BY SalesOrderID
0	0	  |--Compute Scalar(DEFINE:([Expr1004]=CONVERT_IMPLICIT(int,[Expr1007],0)))
31474	1	       |--Stream Aggregate(GROUP BY:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderID]) DEFINE:([Expr1007]=Count(*)))
1213170	1	            |--Index Scan(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetail_test_NCL]), ORDERED FORWARD)

将数据集按规则排成一个队列以后做运算，这里是指SalesOrderDetailID
*/

SET STATISTICS PROFILE ON 

SELECT customerID,COUNT(*)
FROM dbo.SalesOrderheader_test
GROUP BY customerID

SET STATISTICS PROFILE OFF 

/*
Rows	Executes	StmtText
19119	1	SELECT customerID,COUNT(*)  FROM dbo.SalesOrderheader_test  GROUP BY customerID
0	0	  |--Compute Scalar(DEFINE:([Expr1003]=CONVERT_IMPLICIT(int,[Expr1006],0)))
19119	1	       |--Hash Match(Aggregate, HASH:([AdventureWorks].[dbo].[SalesOrderHeader_test].[CustomerID]) DEFINE:([Expr1006]=COUNT(*)))
31474	1	            |--Clustered Index Scan(OBJECT:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderHeader_test_CL]))

在SalesOrderHeader_test上按索引扫描，生成一个结果集，再在此Hash表上进行聚合运算
*/

SET STATISTICS PROFILE ON 

SELECT DISTINCT productid,unitprice 
FROM dbo.salesorderdetail_test
WHERE productid = 776
UNION ALL
SELECT DISTINCT productid,unitprice 
FROM dbo.salesorderdetail_test
WHERE productid = 776

SET STATISTICS PROFILE OFF 
/*
Rows	Executes	StmtText
8	1	SELECT DISTINCT productid,unitprice   FROM dbo.salesorderdetail_test  WHERE productid = 776  UNION ALL  SELECT DISTINCT productid,unitprice   FROM dbo.salesorderdetail_test  WHERE productid = 776
8	1	  |--Concatenation
4	1	       |--Sort(DISTINCT ORDER BY:([AdventureWorks].[dbo].[SalesOrderDetail_test].[UnitPrice] ASC))
16	1	       |    |--Parallelism(Gather Streams)
16	4	       |         |--Stream Aggregate(GROUP BY:([AdventureWorks].[dbo].[SalesOrderDetail_test].[UnitPrice]) DEFINE:([AdventureWorks].[dbo].[SalesOrderDetail_test].[ProductID]=ANY([AdventureWorks].[dbo].[SalesOrderDetail_test].[ProductID])))
2280	4	       |              |--Sort(ORDER BY:([AdventureWorks].[dbo].[SalesOrderDetail_test].[UnitPrice] ASC))
2280	4	       |                   |--Clustered Index Scan(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_cl]), WHERE:([AdventureWorks].[dbo].[SalesOrderDetail_test].[ProductID]=(776)))
4	1	       |--Sort(DISTINCT ORDER BY:([AdventureWorks].[dbo].[SalesOrderDetail_test].[UnitPrice] ASC))
15	1	            |--Parallelism(Gather Streams)
15	4	                 |--Stream Aggregate(GROUP BY:([AdventureWorks].[dbo].[SalesOrderDetail_test].[UnitPrice]) DEFINE:([AdventureWorks].[dbo].[SalesOrderDetail_test].[ProductID]=ANY([AdventureWorks].[dbo].[SalesOrderDetail_test].[ProductID])))
2280	4	                      |--Sort(ORDER BY:([AdventureWorks].[dbo].[SalesOrderDetail_test].[UnitPrice] ASC))
2280	4	                           |--Clustered Index Scan(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_cl]), WHERE:([AdventureWorks].[dbo].[SalesOrderDetail_test].[ProductID]=(776)))


*/