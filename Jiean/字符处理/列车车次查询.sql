-- 检查某个车次是否在指定的字符串中(字符串中包含车次信息)
CREATE FUNCTION dbo.f_CompSTR(
	@str  varchar(8000),  --包含车次的字符串
	@find varchar(50)     --要查询的值
)RETURNS bit
AS
BEGIN
	-- 完全匹配的直接返回
	IF @str = @find
		RETURN(1)

	-- 如果查询的数据长度大于被查询数据的长度, 直接返回
	IF LEN(@str) < LEN(@find)
		RETURN(0)

	-- 替换掉车次字符串中的无效数据
	SELECT 
		@str = REPLACE(@str, a, b)
	FROM(
		-- 这个子查询列出了所有无效的字符数据, 每个字符数据一条记录, 可以根据实际需求扩充
		SELECT a = '"', b = ''
	)A

	-- 统一数据分隔符
	SELECT
		@str = REPLACE(@str, a, b)
	FROM(
		-- 这个子查询列出了所有可能出来的数据分隔符, 并统一替换为\
		SELECT a = '(',  b='\' UNION ALL
		SELECT a = ')',  b='\' UNION ALL
		SELECT a = '（', b='\' UNION ALL
		SELECT a = '）', b='\' UNION ALL
		SELECT a = ' ',  b='\' UNION ALL
		SELECT a = '　', b='\' UNION ALL
		SELECT a = '.',  b='\' UNION ALL
		SELECT a = '．', b='\'
	)A

	--分拆比较处理
	DECLARE 
		@s1 varchar(8000),
		@h varchar(100),
		@s varchar(100),
		@l int
	WHILE @str > ''
	BEGIN
		SELECT
			-- 字符串中的第一个数据项
			@s1 = LEFT(@str, CHARINDEX('\', @str + '\') - 1),
			-- 从字符串中去掉第一个数据项(因为当前循环会处理这个数据项)
			@str = STUFF(@str, 1, CHARINDEX('\', @str + '\'), ''),
			-- 数据项中的第一个车次(可以视为对数据项的再次拆分)
			@h = LEFT(@s1, CHARINDEX('/', @s1 + '/') - 1),
			-- 第一个车次的长度
			@l = LEN(@h) + 1

		-- 如果第一个车次就是要查找的数据, 则退出
		IF @h = @find
			RETURN(1)

		-- 检查数据项中的每个车次
		WHILE CHARINDEX('/', @s1 + '/') > 0
		BEGIN
			SELECT 
				-- 取数据项中的第一个车次
				@s = LEFT(@s1, CHARINDEX('/', @s1 + '/') - 1),
				-- 从数据项中移除第一个车次(因为当前循环中会处理这个车次)
				@s1 = STUFF(@s1, 1, CHARINDEX('/', @s1 + '/'), '')

			-- 检查是否完整的车次信息, 如果不是, 将其补充完整(根据第一个车次的信息)
			IF LEN(@s) < @l
				SET @s = STUFF(@h, @l - LEN(@s), 8000, @s)
			-- 确定是否要找的车次, 如果是, 则返回查找结果
			IF @find = @s
				RETURN(1)	
		END
	END
	RETURN(0)
END
GO

-- 使用示例
-- 车次信息记录表
DECLARE @t TABLE(
	col varchar(100))
INSERT @t SELECT '1434/1/2/14'
UNION ALL SELECT '"10653(85707)"'
UNION ALL SELECT '"32608/7(83212/1)"'
UNION ALL SELECT '"50057（)"'
UNION ALL SELECT '"T888（备）"'
UNION ALL SELECT '"21058(81404/3)0"'
UNION ALL SELECT '"22028(80404.10264)"'
UNION ALL SELECT '20037(80303.84006/9)'
UNION ALL SELECT '24031(80410/9'
UNION ALL SELECT '24048(80904)(23118)'
UNION ALL SELECT '22080(80406.83080.10284)'
UNION ALL SELECT '0031(5632  5629. 1434/1/2/14)'

--调用上述函数查询包含车次1434的记录
SELECT * FROM @t 
WHERE dbo. f_CompSTR(col,'1432') = 1
GO

-- 删除测试环境
DROP FUNCTION dbo.f_CompSTR
