
/*
要求统计列COL中每个数据项的列NUM之和，如果一个数据项在一条记录中出现我次，则只统计一次。
*/
-- 测试数据
CREATE TABLE tb(
	ID int,
	col varchar(50),
	num int)
INSERT tb SELECT 1, 'aa,bb,cc', 10
UNION ALL SELECT 2, 'aa,aa,bb', 20
UNION ALL SELECT 3, 'aa,aa,bb', 20
UNION ALL SELECT 4, 'dd,ccc,c', 30
UNION ALL SELECT 5, 'ddaa,ccc', 40
UNION ALL SELECT 6, 'eee,ee,c', 50
GO

-- 分拆处理需要的辅助表的记录数(由于是直接处理,所以根据col1列中最大的数据长度来创建)
DECLARE
	@len int
SELECT TOP 1
	@len = LEN(col) + 1
FROM tb
ORDER BY LEN(col) DESC

-- 如果没有要分拆的数据项, 则直接退出
IF ISNULL(@len,1) = 1
	RETURN

-- 分拆辅助表
SET ROWCOUNT @len
SELECT
	ID = IDENTITY(int, 1, 1)
INTO # FROM dbo.syscolumns A, dbo.syscolumns B
ALTER TABLE # ADD
	PRIMARY KEY(
		ID)
SET ROWCOUNT 0

--统计处理
SELECT 
	data,
	SUM_num = SUM(num)
FROM(
	SELECT DISTINCT
		data = SUBSTRING(A.col, B.ID, CHARINDEX(',', A.col + ',', B.ID) - B.ID),
		A.num,
		A.ID
	FROM tb A, # B
	WHERE B.ID <= LEN(A.col)
		AND SUBSTRING(',' + A.col, B.ID, 1) = ','
)A
GROUP BY data
DROP TABLE #
GO

-- 删除测试数据
DROP TABLE tb
