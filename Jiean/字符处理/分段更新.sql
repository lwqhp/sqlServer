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

select dbo.f_SetStr('abc,123,eft',1,'def',',')

declare @split varchar(10) =', '
declare @pos int =2
declare @s varchar(500)='abc, 123, eft'
declare @value varchar(50)='def'
	DECLARE
		@splitlen int,
		@p1 int,--开始点
		@p2 int --结束点

-- 通过循环次数，定位到要修数据的开始和结束点，最后用替换函数搞店

set @splitlen = len(@split+' a')-2
--set @splitlen = len(@split)
set @p1 =1
set @p2 =charindex(@split,@s+@split,1)
while @pos>1  
begin 
	set @pos = @pos-1
	set @p1 = @p2+@splitlen
	set @p2 = charindex(@split,@s+@split,@p1)
	select @splitlen,@p1,@p2
end

select @p1,@p2
select stuff(@s,@p1,@p2-@p1,@value)