CREATE TABLE tb(
	Item varchar(10),
	Color varchar(10),
	Quantity int
)
INSERT tb SELECT 'Table', 'Blue',   124
UNION ALL SELECT 'Table', 'Red',    60
UNION ALL SELECT 'Table', 'Red',    99
UNION ALL SELECT 'Table', 'Green',  120
UNION ALL SELECT 'Table', 'Green',  110
UNION ALL SELECT 'Chair', 'Yellow', 101
UNION ALL SELECT 'Chair', 'Yellow', 131
UNION ALL SELECT 'Chair', 'Red',    90
UNION ALL SELECT 'Chair', 'White',  55
GO

-- a. 生成分组信息临时表
SELECT 
	Item, Color,
	No = 0
INTO # FROM tb
GROUP BY Item, Color
ORDER BY Item, Color

select * from #

-- b. 生成各组 Item 的 Color 序号
DECLARE
	@Notem varchar(10),
	@No varchar(10)
UPDATE # SET 
	@No = CASE
			WHEN @Notem = Item THEN @No + 1
			ELSE 1
		END,
	No = @No,
	@Notem = Item

-- c. 生成交叉数据报表处理语句
/*
有点意思：转换两列数据到行.
使用序号确定转成的列数，按列数循环，先拼接出每列的列转行的语句
最后用union ll把各行合并在一起。
*/

DECLARE
	@sql_Color nvarchar(4000),
	@sql_Quantity nvarchar(4000),
	@fd nvarchar(4000)
SELECT
	@sql_Color = N'',
	@sql_Quantity = N'',
	@fd = N'',
	@No = MAX(No) --转列数
FROM #
GROUP BY Item

WHILE @No > 0
	SELECT 
		@fd = N', '
			+ QUOTENAME(N'col' + @No) + N' = ' + QUOTENAME(@No)
			+ @fd,
		@sql_Color = @sql_Color + N',
	' + QUOTENAME(@No) + N' = MAX(
							CASE No 
								WHEN ' + @No + N' THEN Color
							END)',
		@sql_Quantity = @sql_Quantity + N',
	' + QUOTENAME(@No) + N' = CONVERT(varchar, SUM(
							CASE B.No
								WHEN ' + @No + N' THEN A.Quantity
							END))',
		@No = @No - 1


EXEC(N'
SELECT
	Item = Item ' + @fd + '
FROM(
	SELECT
		Item ' + @sql_Color + ',
		s = 0
	FROM #
	GROUP BY Item
	UNION ALL
	SELECT
		A.Item ' + @sql_Quantity + ',
		s = 1 
	FROM tb A, # B
	WHERE A.Item = B.Item
		AND A.Color = B.Color
	GROUP BY A.Item
)A
ORDER BY Item, s
')
DROP TABLE #
/*--结果
Item       col1     col2     col3
---------- -------- -------- --------
Chair      Red      White    Yellow
Chair      90       55       232
Table      Blue     Green    Red
Table      124      230      159
--*/
GO

-- 删除测试
DROP TABLE tb
