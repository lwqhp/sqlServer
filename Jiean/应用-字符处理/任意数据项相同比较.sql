
/*
比较使用相同数据分隔符的两个字符串中，它们包含的数据项是否至少有一个相同，而数据项的位置可以不同。
*/
CREATE FUNCTION dbo.f_CompareSTR(
	@s1  varchar(8000),  --要比较的第一个字符串
	@s2  varchar(8000),  --要比较的第二个字符串
	@split varchar(10)    --数据分隔符
)RETURNS bit
AS
BEGIN
	DECLARE
		@splitlen int
	SET @splitlen = LEN(@split + 'a') - 2

	-- 分拆参与比较的第一个字符串
	WHILE CHARINDEX(@split, @s1) > 0
	BEGIN
		-- 如果参与比较的第一个字符串中的数据项在第二个字符串中存在, 则直接返回
		IF CHARINDEX(
					@split + LEFT(@s1, CHARINDEX(@split, @s1) - 1) + @split,
					@split + @s2 + @split
				) > 0
			RETURN(1)
		SET @s1 = STUFF(@s1, 1, CHARINDEX(@split, @s1) + @splitlen, '')
	END
	RETURN(
		CASE
			WHEN CHARINDEX(@split + @s1 + @split, @split + @s2 + @split) > 0
				THEN 1
			ELSE 0
		END)
END
GO
