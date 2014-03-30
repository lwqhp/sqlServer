
/*
在由指定数据分隔符分隔的字符串中，获取第N个数据项的值。
*/
CREATE FUNCTION dbo.f_GetStr(
	@s varchar(8000),      --包含多个数据项的字符串
	@pos int,             --要获取的数据项的位置
	@split varchar(10)     --数据分隔符
)RETURNS varchar(100)
AS
BEGIN
	IF @s IS NULL 
		RETURN(NULL)
	DECLARE
		@splitlen int
	SELECT
		@splitlen = LEN(@split + ' a') - 2
	WHILE @pos > 1 AND CHARINDEX(@split, @s + @split) > 0
		SELECT
			@pos = @pos - 1,
			@s = STUFF(@s, 1, CHARINDEX(@split, @s + @split) + @splitlen, '')
	RETURN(ISNULL(LEFT(@s, CHARINDEX(@split, @s + @split) - 1), ''))
END
GO
