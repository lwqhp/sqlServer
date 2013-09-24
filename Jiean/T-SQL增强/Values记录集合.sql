
--Values 记录集合--------------------------

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


