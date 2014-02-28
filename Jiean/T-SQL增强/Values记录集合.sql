
--Values 记录集合--------------------------
/*
values语句是作为一个原子操作来执行的，因此，如果有任何一行没能插入目标表中，整个操作将会失败。
其原理是：在内部要经过一个平展处理，就像insert select 语句一样，使用union all集合运算把单独的各行统一起来。
所以不会有任何性能方面的提升。
*/

use AdventureWorks2012
go

--原Values用于insert into 语句中表示一条记录的数据组合
insert into [Person].[ContactType] 
values('test',getdate())

--而在sql2008中得到增强，可以用以表示一组记录集合,作用和select ..union all相同，且更简洁
insert into [Person].[ContactType]
values('test2',getdate()),
	  ('test3',getdate()),
	  ('test4',getdate())

select * 
from (
	values('test2',getdate()),
		('test3',getdate()),
		('test4',getdate())
) a(name,modifieDate)
inner join [Person].[ContactType]  b on a.name = b.Name


