

--Top 关键字增强--------------------

use AdventureWorks2012
go

--原Top(n)关键字 返回记录集的前n笔记录
select top(10) * from person.ContactType

--而Sql2008中对top(n)进行了增强，支持参数范围，可用于delete ,update DML语句

declare @num int
set @num=10
select top(@num) * from person.ContactType

--在delete和update语句中使用TOP(n),可实现大数据分块操作，改善大数据量、大访问量的表的并发性,避免日志的快速增长。
declare @dt datetime
set @dt =getdate()
while (select count(*) from person.ContactType where ModifiedDate<@dt)>0
begin 
	update top(5) person.ContactType set ModifiedDate=getdate() where  ModifiedDate<@dt
	waitfor delay '00:00:05'
end

--删除重复记录
while 1=1
begin 
	delete top(1) from person.ContactType
	where name in(
		select name from person.ContactType group by name having count(*)>1
	)
	if @@rowcount =0 return;
end
