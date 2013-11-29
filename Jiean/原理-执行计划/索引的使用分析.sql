
--索引的使用分析

/*
Table Scan : 表扫描，表明正在处理的表格没有聚集索引，sqlServer正在扫描整张表。
Clustered Index Scan : 聚集索引扫描，表明sqlServer 正在扫描一张有聚集索引的表格，但是也是整表扫描。
Index Scan : 索引扫描，表明SqlServer 正在扫描一个非聚集索引。由于非聚集索引上一般只会有一小部份字段，所以这里
	虽然也是扫描，但是代价会比整表扫描要小很多。
Clustered Index Seek 和 Index Seek ：聚集索引查找和非聚集索引查找，表明 Sqlserver 正在利用索引结果检索目标数据，
	如果结果集只占表格总数量的一小部份，Seek 会比Scan 便宜很多，索引就起到了提高性能的作用。	
*/

USE AdventureWorks
GO

CREATE INDEX salesorderdetail_test_Ncl_price ON salesorderdetail_test(UnitPrice)

SET STATISTICS PROFILE ON 

SELECT salesorderID,salesOrderDetailID,unitPrice 
FROM dbo.SalesOrderDetail_test WITH(INDEX(salesorderdetail_test_Ncl_price))--指定使用非聚集索引
WHERE unitPrice>200

SET STATISTICS PROFILE OFF


/*
|--Nested Loops(Inner Join, OUTER REFERENCES:([Uniq1002], [AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetailID], [Expr1004]) WITH UNORDERED PREFETCH)
    |--Sort(ORDER BY:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetailID] ASC, [Uniq1002] ASC))
    |    |--Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_Ncl_price]), SEEK:([AdventureWorks].[dbo].[SalesOrderDetail_test].[UnitPrice] > ($200.0000)) ORDERED FORWARD)
    |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_cl]), SEEK:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetailID]=[AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetailID] AND [Uniq1002]=[Uniq1002]) LOOKUP ORDERED FORWARD)
    
? 为什么指定了非聚集索引，但执行计划里还有聚集索引的使用

答：因为非聚集索引，实际有两个值,为每一次记录存储一份"非聚集索引索引键值"和一份"聚集索引索引键的值"（没有聚集索引，则是RID值）
非聚集索引的叶级索引值页指向聚聚索引的值。没有话则是数据行的ID值。

?解释 Nested Loops -- Index Seek --Clustered Index Seek 嵌套循环"Bookmark Lookup"

答：条件使用了非聚集索引查找，但返回的字段有不存索引中的，所以先在非聚集索引上找到所有unitprice大于200的记录,
然后再根据salesorderdetialid 的值和聚集索引Nested Loops嵌套循环 ,找到存储在聚集索引上的详细数据，这个过程称为"Bookmark Lookup"

|--Clustered Index Scan(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_cl]), WHERE:([AdventureWorks].[dbo].[SalesOrderDetail_test].[UnitPrice]>($200.0000)))
       
*/

------------------------------------------------------------------------------------------
SELECT a.SalesOrderID,a.OrderDate,a.CustomerID,b.SalesOrderDetailID,b.ProductID,b.OrderQty,b.UnitPrice 
FROM dbo.SalesOrderHeader_test a
INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b.SalesOrderID
WHERE a.SalesOrderID = 43659


/*
|--Nested Loops(Inner Join)
   |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderHeader_test_CL] AS [a]), SEEK:([a].[SalesOrderID]=(43659)) ORDERED FORWARD)
   |--Nested Loops(Inner Join, OUTER REFERENCES:([Uniq1005], [b].[SalesOrderDetailID]))
        |--Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetail_test_NCL] AS [b]), SEEK:([b].[SalesOrderID]=(43659)) ORDERED FORWARD)
        |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_cl] AS [b]), SEEK:([b].[SalesOrderDetailID]=[AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetailID] as [b].[SalesOrderDetailID] AND [Uniq1005]=[Uniq1005]) LOOKUP ORDERED FORWARD)


条件是SalesOrderID = 43659,因为两表关联是a.SalesOrderID = b.SalesOrderID,且SalesOrderDetail_test在SalesOrderID上有索引,
所以执行计划先在SalesOrderDetail_test上按非聚集索引查找SalesOrderID = 43659,再跟据返回的字段和聚集索引关联，找到其它的字段。

而SalesOrderHeader_test 在SalesOrderID上有聚集索引，所以直接使用了聚集索引查找

然后把两个结果集关联(嵌套循环)，返回最终结果集.
*/

------------------------------------------------------------------------------------------
SELECT a.SalesOrderID,a.OrderDate,a.CustomerID,b.SalesOrderID 
FROM dbo.SalesOrderHeader_test a
INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b.SalesOrderID
WHERE a.SalesOrderID = 43659

/*
|--Nested Loops(Inner Join)
   |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderHeader_test_CL] AS [a]), SEEK:([a].[SalesOrderID]=(43659)) ORDERED FORWARD)
   |--Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetail_test_NCL] AS [b]), SEEK:([b].[SalesOrderID]=(43659)) ORDERED FORWARD)

这条sql语句去掉了SalesOrderDetail_test 返回字段中不在非聚集索引中的列
可以看到，因为返回的字段包含在了非聚集索引中，所以通过索引查找即可返回相应的字段，不再需要通过聚集索引关联循环查找其它字段。
*/