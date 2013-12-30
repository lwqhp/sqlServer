

--数据库分配和一致性检查

--检查数据页和分配情况
/*
检查除了filestream数据之外的所有数据库页和内部结构的分配情况，返回信息数据，其中包括内部页面信息，分区数量
以及页面。在命令最后，报告了所有分配和一致性错误
*/
DBCC CHECKALLOC('test')

--检查结构完整性
DBCC CHECKDB('test')

--检查文件组中表的结构完整性
DBCC CHECKFILEGROUP('fg2')

--检查表和索引视图的数据完整性
DBCC CHECKTABLE('tb')
WITH all_errormsgs

--检查表估计所需要的tempdb空间
DBCC CHECKTABLE('tb')
WITH estimateonly

--检查索引完整性检查

--查看索引id
SELECT index_id,* FROM sys.indexes WHERE object_id=object_id('tb')
AND name = 'IX_tb'

DBCC CHECKTABLE('tb',index_id)
WITH physical_only


--检查表的完整性
/*
报告在指定表和约束中发现的所有checka或外键约束的违反情况，这个命令允许返回违反约束的数据，从而可以修正违反
的约束，但是如果使用了nocheck禁用了约束，那么这个命令也不会捕捉约束违返情况。
*/
DBCC CHECKCONSTRAINTS('tb')

--检查系统表的一致性
DBCC CHECKCATALOG('test')