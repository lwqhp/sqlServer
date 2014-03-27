
/*
在生成日期列表时，使用了解“FROM sysobjects a,sysobjects b”,这个主要是用来快速生成多条记录用的，
这里的sysobjects为处理中用到的辅助表，可以是任意有足够记录的表。
使用辅助表一次性插入多条记录，而不是使用循环，其意义在于:SQl server需要通过事务来保证处理要么成功，要么失败,
对于每条SQL语句，sql 都会开启一个内部事务（对用户不可见），所以在sql的处理中，同样的处理，处理过程中的语句越少，
一般也就意味着处理效率可能越高.
*/

--syscolumns 表使用
CREATE TABLE #t(col int)
DECLARE @i int,@dt datetime
SELECT @i=0,@dt=getdate()
WHILE @i<1000
BEGIN
	INSERT #t VALUES(0)
	SET @i = @i+1
END
SELECT datediff(ms,@dt,getdate())
DROP TABLE #t

CREATE TABLE #t(col int)
DECLARE @dt datetime
SET @dt = getdate()
INSERT #t 
SELECT TOP 1000 0 FROM syscolumns s,syscolumns b 
SELECT datediff(ms,@dt,getdate())
DROP TABLE #t


--短日期格式字符型字段

cast(date_start +'00:00:00' AS datetime) <= '2009-09-09 9:9:9'
AND cast(date_end +'23:59:59' AS datetime) >= '2009-9-09 9:9:9'

