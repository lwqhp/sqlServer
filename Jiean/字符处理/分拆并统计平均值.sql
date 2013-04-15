
/*
要求统计列COL中每个数据项的列NUM平均值，对于每条记录各数据项的NUM值，需要根据数据项的多少业分配NUM。
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

-- 统计方法 A
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
-- a. 分拆数据到临时表
SELECT 
	A.num,
	A.ID,
	gid = b.ID,  -- 每个数据项在字符串中的开始位置
	data = SUBSTRING(A.col, B.ID, CHARINDEX(',', A.col + ',', B.ID) - B.ID)
INTO #t FROM tb A, # B
WHERE b.ID <= LEN(A.col)
	AND SUBSTRING(',' + A.col, B.ID,1) = ','

SELECT
	A.data,
	AVG_num = CAST(
			-- 计算各个数据项的平均值
			AVG(
				-- 计算每个数据项在其所在记录中应该分配的值
				CASE 
					-- 每一个数据项, 使用总数 - 其他数据项已经分配的数据之和做为该条记录该数据项的值
					WHEN A.gid = 1 THEN A.num - CAST(A.num as float) / B.cnt * (B.cnt - 1)
					ELSE CAST(A.num as float) / B.cnt END
			) as decimal(10,2))
FROM #t A,
	(   -- 每条记录的数据项个数
		SELECT
			ID,
			cnt = COUNT(*)
		FROM #t
		GROUP BY ID
	)B
WHERE A.ID = B.ID
GROUP BY A.data
DROP TABLE #, #t
GO


-- 统计方法 B
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

SELECT
	data,
	AVG_num = CAST(
			-- 计算各个数据项的平均值
			AVG(
				-- 计算每个数据项在其所在记录中应该分配的值
				CASE 
					-- 每一个数据项, 使用总数 - 其他数据项已经分配的数据之和做为该条记录该数据项的值
					WHEN gid = 1 THEN num - CAST(num as float) / cnt * (cnt - 1)
					ELSE CAST(num as float) / cnt END
			) as decimal(10,2))
FROM(
	SELECT
		a.num,
		gid=b.ID,  -- 每个数据项在字符串中的开始位置
		data = SUBSTRING(A.col, B.ID, CHARINDEX(',', A.col + ',', B.ID) - B.ID),
		-- 每条记录的数据项数目
		cnt = LEN(A.col) - LEN(REPLACE(A.col, ',', '')) + 1
	FROM tb A, # B
	WHERE b.ID <= LEN(A.col)
		AND SUBSTRING(',' + A.col, B.ID,1) = ','
)A
GROUP BY data
DROP TABLE #
GO

-- 删除测试数据
DROP TABLE tb
