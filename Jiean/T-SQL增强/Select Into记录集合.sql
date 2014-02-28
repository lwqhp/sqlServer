

--Select Into记录集合
/*
新表列会继承查询结果集中列的名称，数据类型，是否允许为null,以及identity属性。
不会继承约束，索引，触发器。

select into 是一个大容量(bulk)操作，如果目村数据库不是完整模式，select into 是最小日志记录操作，它比完整
日志记录操作要快很多。

1）用into创建空表头
在where 1=2中，sqlserver不会费力地去物理访问源数据，而是根据表的架构来创建目标表。

2）去掉indetity属性继承
select id+0 as new id into # from tb

3)把存储过程插到表中
select * into target_table
from openquery(服务器，'exec sql') as a
*/