

--条件表达式运算对性能的影响
/*
filter 运算位置
常见的几个表格做连扫,同时又有一些where子句filter掉一些记录。那么是先filter掉记录，再做连接好呢，还是先做连接，
再filter呢？一般来讲，先filter掉一些记录，使得做连接的记录集小一点，会大大降低连接的消耗。


*/

select count(b.ProductID) from SalesOrderHeader_test a
inner join SalesOrderDetail_test b on a.SalesOrderID = b.SalesOrderID
inner join production.Product p on b.productid = p.productid
where p.productid between 758 and 800
option(maxdop 1)
go

select count(b.ProductID) from SalesOrderHeader_test a
inner join SalesOrderDetail_test b on a.SalesOrderID = b.SalesOrderID
inner join production.Product p on b.productid = p.productid
where (p.productid/2) between 380 and 400
option(maxdop 1)
GO

/*
从第一句看出，虽然只有一个where子句p.productid between 758 and 800,但是在执行计划里可以看到有两个filter动作：一个在saleorderdetial_test
上，另一个在product上，这是因为sqlserver发现这两张表将要通过b.productid = p.productid作连接，所以在product上的条件，同样会造合
在saleorderdetail_test上，这样，sqlServer先在salesorderdetail_test上做一个filter,结果集就小得多，再作join

而第二个语句只作了一次filter,因为(p.productid/2) between 380 and 400这样的语句没办法作用在SalesOrderDetail_test上.使得filter动作
只发生在product上，没有发生在salesorderdetail_test上，所以salesorderheader_test和saleorderdetail_test做连接的时候，结果集要大一些。

*/