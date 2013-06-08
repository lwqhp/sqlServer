
----重建数据库索引
----说明：1、重建指定数据库的所有表的索引。


USE HK_ERP_QD --输入数据库名称。

DECLARE @TableName varchar(255) 

DECLARE TableCursor CURSOR FOR 
SELECT table_name FROM information_schema.tables WHERE table_type = 'base table' 

OPEN TableCursor 
FETCH NEXT FROM TableCursor INTO @TableName 


WHILE @@FETCH_STATUS = 0 
BEGIN 
	DBCC DBREINDEX(@TableName,' ',90) 
	FETCH NEXT FROM TableCursor INTO @TableName 
END 
CLOSE TableCursor 
DEALLOCATE TableCursor


--select * from sys.indexes
