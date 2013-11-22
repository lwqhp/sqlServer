

--Sequence序列
/*
这是sql2012新增的功能，与以往的Identity列不同的是。SequenceNumber是一个与构架绑定的数据库级别的对象，
而不是与具体的表的具体列所绑定。这意味着SequenceNumber带来多表之间共享序列号的遍历之外，还会带来如下不利影响:
1）与Identity列不同的是，Sequence插入表中的序列号可以被Update,除非通过触发器来进行保护
2）与Identity列不同，Sequence有可能插入重复值（对于循环SequenceNumber来说）
3）Sequence仅仅负责产生序列号，并不负责控制如何使用序列号，因此当生成一个序列号被Rollback之后，
Sequence会继续生成下一个号，从而在序列号之间产生间隙。

*/

--创建一个序列
create sequence testSequence
as int
start with 1
increment by 1

--查看序列
select * from sys.sequences

--获取一个序列,序列当前值改变
select next value for testSequence

--使用
create table #test(id int)
go
declare @index int
set @index=0
while @index <=50
begin 
	insert into #test
	select next value for testSequence
	set @index+=1
end

--select * from #test

--重置计数器
alter sequence testSequence
restart with 1