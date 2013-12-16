

USE AdventureWorks
GO

--书签查找
/*
书签查找，又叫键查找，key lookup ,在一个有非聚集索引和聚集索引的表格中，优化器选择从聚集索引中查找，但查询
所引用的并不在索引中，要读取这些列的值，非聚集索引要通过聚集索引导航到对应的数据行。
这种因非聚集索引不包含查询列而需要每一个都访问一次聚集索引（lookup）来找到对应的数据行叫键查找。

键查找通常都和一个Nestd lookup组成循环，书签查找要求索引页面访问之外的数据页面访问，访问两组页面增加了查询
逻辑读操作次数（可见不是索引越多就越好），而且，如果页面不在内存中，书签查找可能需要在磁盘上的一个随机io操
作来从索引页面跳转到数据页面，还需要必要的cpu能力来汇集这一数据并执行必要的操作。这是因为对于大的表，索引页
面和对应的数据页面通常在磁盘上并不临近。
增加的逻辑读操作和开销较大的特理读操作使书签查找的数据检索操作的开销相当大。
*/
SET STATISTICS PROFILE ON

--一个典型的书签查找
SELECT b.name,AVG(a.LineTotal) 
FROM sales.SalesOrderDetail a
JOIN production.product b ON a.productid = b.ProductID
WHERE a.ProductID=776
GROUP BY a.CarrierTrackingNumber,b.Name
HAVING MAX(OrderQty)>1
ORDER BY MIN(a.linetotal)


/*
非聚集索引更适合返回较小的行集，随着返回的行集越来越大，key lookup的查询开销也会越来越大，最终使优化器放弃
非聚集索引查找，而使用聚集索引扫描。
*/
SELECT * FROM sales.SalesOrderDetail
WHERE ProductID=776

SELECT * FROM sales.SalesOrderDetail
WHERE ProductID=793

SELECT 
NationalIDNumber,hiredate
 FROM HumanResources.Employee a
WHERE a.NationalIDNumber='693168613'


--解决书签查找

/*
1，仅使用一个聚集索引
由于聚集索引的叶子页面和表的数据页面相同，因此，当读取聚集索引键列的值时，数据引擎可以读取其他列的值而不需
要任何导航。但日常项目中聚集索引往往不能修改。

2，使用包含索引
因为包含索引列只存储在非聚集索引的叶子级别上，不会参与索引的排序查找，所以即不增加索引的排序开销，又不需要
再到数据页去查找数据。
*/


SELECT  Nationalidnumber,hiredate 
FROM HumanResources.Employee
WHERE NationalIDNumber=N'693168613'-- nationalidnumber是nvarchar类型，要加N减免类型转换

--包含索引
CREATE NONCLUSTERED INDEX IX_Employee ON HumanResources.Employee(NationalIDNumber) INCLUDE(hiredate)

DROP INDEX IX_Employee on HumanResources.Employee 
/*
3,查询列避开不在范围的字段，使用聚集索引中的字段
因为在有聚集索引的表上，聚集索引键被存储为非聚集索引指向数据的指针，这意味着任何将聚集索引和一组来自非聚集
索引的列作为查询机制，where子句或连接条件的查询都能利用这种覆盖索引
*/

DBCC SHOW_STATISTICS('HumanResources.Employee','AK_employee_nationalIDnumber')
/*
从统计信息可以看到索引的排序，先是自己的非聚集索引nationalDnumber,然后是和聚集索引EmployeeID的排序。
*/

SELECT  NationalIDNumber, EmployeeID
FROM HumanResources.Employee
WHERE NationalIDNumber=N'693168613'

/*
索引连接
索引连接是指使用两个或更多索引之间的一个索引交叉来完全覆盖一个查询，虽然索引连接需要访问多于一个索引，它必
须在所有索引连接中使用的索引上执行逻辑读，它需要比覆盖索引更高的逻加读数量，但是，因为索引连接所用的多个窄索
引能够比宽的覆盖索引服务更多的查询。

1）多个窄索引和宽的覆盖索引相比，可以为更大量的查询提供服务
2）窄索引比宽的覆盖索引需要的维护开销更小
*/

SELECT 
PurchaseOrderID,VendorID,OrderDate
 FROM Purchasing.PurchaseOrderHeader
WHERE VendorID=83 AND OrderDate='2001-05-17 00:00:00.000'

--添加一个非聚集索引
CREATE NONCLUSTERED INDEX IX_PurchaseOrderHeader ON Purchasing.PurchaseOrderHeader(OrderDate)
/*
添加索引后，优化器使用列vendorID上的非聚集索引和新的非聚集索引orderdate来完整地服务于该查询，而不需要触及基本表
*/

