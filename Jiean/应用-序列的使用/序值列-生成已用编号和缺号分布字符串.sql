-- 生成已用编号分布字符串的函数
CREATE FUNCTION dbo.f_GetStrSeries(
	@col1 varchar(10)
)RETURNS varchar(8000)
AS
BEGIN
	DECLARE
		@re varchar(8000),
		@pid int
	SELECT
		@re = '',
		@pid = -1  -- 将初始编号的前一个编号设置为 -1, 这样可以处理初始编号 1(假设初始编号为1)
	SELECT
		@re = CASE
				-- 不需要处理连续编号
				WHEN col2 = @pid + 1 THEN @re
			ELSE @re
				+ CASE 
					-- 判断连续编号是否只有一个(例如 1, 2, 4, 6 中的 4), 如果是, 则不处理
					WHEN RIGHT(@re, CHARINDEX(',', REVERSE(@re) + ',') - 1) = @pid THEN ''
					-- 如果是多个连续编号的结束编号, 则加上结束编号
					ELSE CAST(- @pid as varchar)
				END
				+ ',' + CAST(col2 as varchar) 
			END,
		@pid = col2
	FROM tb
	WHERE col1 = @col1
	ORDER BY col2
	RETURN(
		STUFF(@re, 1, 2, '')
		+ CASE 
			WHEN RIGHT(@re, CHARINDEX(',', REVERSE(@re)+ ',') - 1) = @pid THEN ''
			ELSE CAST(- @pid as varchar)
		END)
END
GO

--生成缺号分布字符串的函数
CREATE FUNCTION dbo.f_GetStrNSeries(
@col1 varchar(10)
)RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE
		@re varchar(8000),
		@pid int
	SELECT
		@re = '',
		@pid = 0
	SELECT
		@re = CASE 
				-- 不需要处理连续编号
				WHEN col2 = @pid + 1 THEN @re
				ELSE @re + ','
					-- 缺号的开始编号(上一条记录的编号 + 1)
					+ CAST(@pid + 1 as varchar)
					-- 如果缺号的结束编号与开始编号一致, 则不处理, 否则加上缺号的结束编号
					+ CASE
						WHEN @pid + 1 = col2 - 1 THEN ''
						ELSE CAST(1 - col2 as varchar)
					END
				END,
		@pid = col2
	FROM tb
	WHERE col1 = @col1
	ORDER BY col2
	RETURN(STUFF(@re, 1, 1, ''))
END
GO

--调用测试
--测试数据
CREATE TABLE tb(
	col1 varchar(10),
	col2 int)
INSERT tb SELECT 'a', 2
UNION ALL SELECT 'a', 3
UNION ALL SELECT 'a', 5
UNION ALL SELECT 'a', 8
UNION ALL SELECT 'a', 9
UNION ALL SELECT 'b', 1
UNION ALL SELECT 'b', 5
UNION ALL SELECT 'b', 6
UNION ALL SELECT 'b', 7

SELECT * FROM dbo.tb
--查询
SELECT 
	col1,
	col2_Series = dbo.f_GetStrSeries(col1),
	col2_Series = dbo.f_GetStrNSeries(col1)
FROM tb
GROUP BY col1
/*--结果
col1       col2_Series       col2_Series 
-------------- ------------------------ --------------
a          2-3,5,8-9        1,4,6-7
b          1,5-7           2-4
--*/
GO

-- 删除测试
DROP TABLE tb
DROP FUNCTION dbo.f_GetStrSeries, dbo.f_GetStrNSeries