CREATE TABLE tb(
	Year int,
	Quarter int,
	Quantity decimal(10,1),
	Price decimal(10,2)
)
INSERT tb SELECT 1990, 1, 1.1, 2.5
UNION ALL SELECT 1990, 1, 1.2, 3.0
UNION ALL SELECT 1990, 2, 1.2, 3.0
UNION ALL SELECT 1990, 1, 1.3, 3.5
UNION ALL SELECT 1990, 2, 1.4, 4.0
UNION ALL SELECT 1991, 1, 2.1, 4.5
UNION ALL SELECT 1991, 2, 2.1, 4.5
UNION ALL SELECT 1991, 2, 2.2, 5.0
UNION ALL SELECT 1991, 1, 2.3, 5.5
UNION ALL SELECT 1991, 1, 2.4, 6.0
GO

-- 查询处理
DECLARE
	@s nvarchar(4000)
-- a. 交叉报表处理代码头
SET @s = N'
SELECT
	Year'

--生成列记录水平显示的处理代码拼接
SELECT
	@s = @s
		+ N', ' + QUOTENAME(N'Q' + CAST(Quarter as varchar) + N'_Amount')
		+ N' = SUM(
				CASE Quarter
					WHEN ' + CAST(Quarter as varchar)
		+ N' THEN Quantity
				END)'
		+ N', ' + QUOTENAME(N'Q' + CAST(Quarter as varchar) + N'_Money')
		+ N' = CONVERT(decimal(10, 2), SUM(
				CASE Quarter
					WHEN ' + CAST(Quarter as varchar)
		+ N' THEN Quantity * Price
				END))'
FROM tb
GROUP BY Quarter
-- 拼接交叉报表处理尾部, 并且执行拼接后的动态SQL语句
EXEC(
	@s + N'
FROM tb
GROUP BY Year
')
/*--结果
Year        Q1_Amount   Q1_Money    Q2_Amount   Q2_Money
----------- ----------- ----------- ----------- ----------
1990        3.6         10.90       2.6         9.20
1991        6.8         36.50       4.3         20.45
--*/
GO

-- 删除示例环境
DROP TABLE tb
