

--解析执行计划的执行顺序

USE AdventureWorks
go

SET STATISTICS PROFILE ON 

SELECT a.SalesOrderID,a.OrderDate,a.CustomerID,b.SalesOrderDetailID,b.ProductID,b.OrderQty,b.UnitPrice 
FROM dbo.SalesOrderHeader_test a
INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b.SalesOrderID
WHERE a.SalesOrderID = 43659

SET STATISTICS PROFILE OFF 

/*
SELECT a.SalesOrderID,a.OrderDate,a.CustomerID,b.SalesOrderDetailID,b.ProductID,b.OrderQty,b.UnitPrice   FROM dbo.SalesOrderHeader_test a  INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b.SalesOrderID  WHERE a.SalesOrderID = 43659
  |--Nested Loops(Inner Join)
       |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderHeader_test_CL] AS [a]), SEEK:([a].[SalesOrderID]=(43659)) ORDERED FORWARD)
       |--Nested Loops(Inner Join, OUTER REFERENCES:([Uniq1005], [b].[SalesOrderDetailID]))
            |--Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetail_test_NCL] AS [b]), SEEK:([b].[SalesOrderID]=(43659)) ORDERED FORWARD)
            |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_cl] AS [b]), SEEK:([b].[SalesOrderDetailID]=[AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetailID] as [b].[SalesOrderDetailID] AND [Uniq1005]=[Uniq1005]) LOOKUP ORDERED FORWARD)

执行计划显树结构，下一层分支逮属于上一层子句，执行从最底层开始，在xml图中，是从最右边往左，从下往上开始

首先执行第6，5行的index seek和clustered index seek 
的此之上，将两个结果集用嵌套循环的方式连接起来，4，得到结果，和执行第3行，在salesorderheader_test 上作culustered index seek 并列为一层
2层是一个嵌套循环，说明sqlserver 是使用的嵌套循环把两个结果集合并起来。

首先salesorderheader_test 在salesorderID上有聚集索引，sqlserver可以直接找到salesorderID=43659,然后把它的几个字
段取出，是一个culustered index seek

而salesorderdetail_test在salesorderID上的是非聚集索引，返回的值不能宛全被非聚集索引所包含，所以先用非聚找到
salesorderID=43659记录，再要据指针和聚集索引做nested loops的连接，把所有的字段值取出来。
*/