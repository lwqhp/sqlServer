-- 更新字符串中指定位置的数据项
CREATE FUNCTION dbo.f_SetStr(
	@s varchar(8000),      --包含数据项的字符串
	@pos int,                --要更新的数据项的段
	@value varchar(100),   --更新后的值
	@split varchar(10)     --数据分隔符
)RETURNS varchar(8000)
AS
BEGIN
	DECLARE
		@splitlen int,
		@p1 int,
		@p2 int
	SELECT
		@splitlen = LEN(@split + 'a') - 2,
		@p1 = 1,
		@p2 = CHARINDEX(@split, @s + @split) -- 第一个分隔符的位置
	WHILE @pos > 1 AND @p1 <= @p2            -- 循环直到第 @pos 个数据项, 或者是找不到新的分隔符
		SELECT
			@pos = @pos - 1,
			@p1 = @p2 + @splitlen + 1,
			@p2 = CHARINDEX(@split, @s + @split, @p1)
	RETURN(
		CASE
			-- 如果找到指定位置的数据项, 则更新
			WHEN @p1 <= @p2 THEN STUFF(@s, @p1, @p2 - @p1, @value)
			ELSE @s
		END
	)
END
GO
