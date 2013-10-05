
/*
sql中的条件，循环方式
*/

--循环一个表
 WHILE CHARINDEX(@split,@s)>0
 --返回受上一语句影响的行数。
 WHILE @@ROWCOUNT >0

SET @id = SELECT TOP 1 id FROM #
WHILE (@id IS NOT NULL)
BEGIN
	
	DELETE # FROM id = @id
	SET @id = NULL
	SET @id = SELECT TOP 1 id FROM #
END 

--利用自增ID比较来循环表，类似游标

SELECT TOP 1 val FROM tb
WHILE @val IS NOT NULL
BEGIN
	SELECT TOP 1 @id = id,@val = val FROM tb WHERE id>@id ORDER BY id
	
END


--条件判断

IF EXISTS(@id)
IF @id IS NOT NULL 
BEGIN
	
END
