
/*在查询结果中 补充不满足条件，或者是没有发生数据业务的记录*/

--忽略条件限制
/*
where条件筛选会忽略不符合的记录,如果要把没发生作用的数据也统计显示：
group by 分组用 ALL(只有在select语句还包括where子句时，all关键字才有意义)
把查询的限制条件放在字段中，使用case函数做条件处理。

*/
--1)在group by 中用 all

--2)把查询的限制条件放在sum函数中，使用Case 函数做条件处理

select employers,
	sale = sum(
		case when sale_price >=1000 then sale_rice
		else 0
)	
	from orders
	group by employers
	
--派生数据
--在报表中显示没有业务发生过的数据，一般是定义一个包含所有情况的列表，然后与实际数据做left join 得到最终结果.


DECLARE @dept TABLE(id int,name varchar(10))
INSERT INTO @dept SELECT 1,'A部门'
union all 		select 2,'B部门'
UNION all		SELECT 3,'C部门'

declare @employees table(id int,name varchar(10),deptid int)
insert into @employees select 1,'张三',1
union all			select 2,'李四',1
union all			select 3,'王五',2

declare @orders table (id int,employeesid int,sale_price decimal(10,2),date datetime)
insert into @orders select 1,1,100.00,'2005-1-1'
union all		select 2,1,90.00,'2005-3-1'
union all		select 3,2,80.00,'2005-3-1'
union all		select 4,2,90.00,'2005-3-7'
union all		select 5,2,40.00,'2005-4-1'
union all		select 6,2,55.00,'2005-5-7'

select m.[month],d.id,d.name,
sales = sum(o.sale_price)
from @dept d
cross join (
	select [month] =1 union all
	select [month] =2 union all
	select [month] =3 union all
	select [month] =4 union all
	select [month] =5 union all
	select [month] =6
)m
left join @employees e
	on d.id = e.deptid
left join @orders o
	on e.id = o.employeesid
	and o.date>=stuff('2005--1',6,0,m.[month])
	AND o.date<stuff('2005--1',6,0,m.[month]+1)
GROUP BY m.[month],d.id,d.name

