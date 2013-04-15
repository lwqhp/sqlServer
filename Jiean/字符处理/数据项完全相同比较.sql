
/*
比较使用相同数据分隔符的两个字符串中，它们包含的数据项是否完全相同，而数据项的位置可以不同。
*/

CREATE FUNCTION dbo.f_CompareSTR(
	@s1  varchar(8000),  --要比较的第一个字符串
	@s2  varchar(8000),  --要比较的第二个字符串
	@split varchar(10)    --数据分隔符
)RETURNS bit
AS
BEGIN
	IF LEN(@s1) <> LEN(@s2)  -- 长度不一致的不用比较数据项
		RETURN(0)

	DECLARE
		@splitlen int
	SET @splitlen = LEN(@split + 'a') - 2

	-- 分拆参与比较的第一个字符串
	DECLARE @r1 TABLE(
		col varchar(100))
	WHILE CHARINDEX(@split, @s1) > 0
	BEGIN
		INSERT @r1 VALUES(LEFT(@s1, CHARINDEX(@split, @s1) - 1))
		SET @s1 = STUFF(@s1, 1, CHARINDEX(@split, @s1) + @splitlen, '')
	END
	INSERT @r1 VALUES(@s1)

	-- 分拆参与比较的第二个字符串
	DECLARE @r2 TABLE(
		col varchar(100))
	WHILE CHARINDEX(@split, @s2) > 0
	BEGIN
		INSERT @r2 VALUES(LEFT(@s2, CHARINDEX(@split, @s2) - 1))
		SET @s2 = STUFF(@s2, 1, CHARINDEX(@split, @s2) + @splitlen, '')
	END
	INSERT @r2 VALUES(@s2)

	-- JOIN 分拆后的表, 从而判断是否存在不匹配的数据项
	RETURN(
		CASE
			WHEN EXISTS(
					SELECT * 
					FROM @r1 A 
						FULL JOIN @r2 B 
							ON A.col = B.col 
					WHERE A.col IS NULL 
						OR B.col IS NULL)
				THEN 0
			ELSE 1 
		END)
END
GO
