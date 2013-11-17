/*
1.简介：
SQL Server 2005中的窗口函数帮助你迅速查看不同级别的聚合，通过它可以非常方便地累计总数、移动平均值、以及执行其它计算。
窗口函数功能非常强大，使用起来也十分容易。可以使用这个技巧立即得到大量统计值。
窗口是用户指定的一组行。 开窗函数计算从窗口派生的结果集中各行的值。
2.适用范围：
排名开窗函数和聚合开窗函数.
也就是说窗口函数是结合排名开窗函数或者聚合开窗函数一起使用
OVER子句前面必须是排名函数或者是聚合函数 

*/
--建立订单表
create table #SalesOrder(
OrderID int, --订单id
OrderQty decimal(18,2) --数量
)
go
--插入数据
insert into #SalesOrder
select 1,2.0
union all
select 1,1.0
union all
select 1,3.0
union all
select 2,6.0
union all
select 2,1.1
union all
select 3,8.0
union all
select 3,1.1
union all
select 3,7.0
go
--查询得如下结果
select * from #SalesOrder
go

SET STATISTICS PROFILE ON
SET STATISTICS IO ON

select OrderID,OrderQty,
sum(OrderQty) over() as [汇总],
convert(decimal(18,4), OrderQty/sum(OrderQty) over() ) as [每单所占比例],
sum(OrderQty) over(PARTITION BY OrderID) as [分组汇总],
convert(decimal(18,4),OrderQty/sum(OrderQty) over(PARTITION BY OrderID)) as [每单在各组所占比例]
from #SalesOrder
order by OrderID 