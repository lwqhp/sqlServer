--测试资料
CREATE TABLE tb(
	ID1 char(2) NOT NULL,
	ID2 char(4) NOT NULL,
	col int,
	PRIMARY KEY(
		ID1, ID2))
INSERT tb SELECT 'aa', '0001', 1
UNION ALL SELECT 'aa', '0003', 2
UNION ALL SELECT 'aa', '0004', 3
UNION ALL SELECT 'bb', '0005', 4
UNION ALL SELECT 'bb', '0006', 5
UNION ALL SELECT 'cc', '0007', 6
UNION ALL SELECT 'cc', '0009', 7
GO

--重排编号处理
UPDATE A SET
	ID2 = RIGHT(
			10000 + (
				SELECT COUNT(*) FROM tb
				WHERE ID1 = A.ID1
					AND ID2 <= A.ID2),
			4)
FROM tb A
SELECT * FROM tb
/*--结果
ID1  ID2  col
---- ---- ----------- 
aa   0001 1
aa   0002 2
aa   0003 3

bb   0001 4
bb   0002 5

cc   0001 6
cc   0002 7
--*/
GO

-- 删除测试环境
DROP TABLE tb



--使用临时表实现编号重排----------------------

CREATE TABLE tb(
	ID1 char(2) NOT NULL,
	ID2 char(4) NOT NULL,
	col int,
	PRIMARY KEY(
		ID1, ID2))
INSERT tb SELECT 'aa', '0001', 1
UNION ALL SELECT 'aa', '0003', 2
UNION ALL SELECT 'aa', '0004', 3
UNION ALL SELECT 'bb', '0005', 4
UNION ALL SELECT 'bb', '0006', 5
UNION ALL SELECT 'cc', '0007', 6
UNION ALL SELECT 'cc', '0009', 7
GO

SELECT * FROM dbo.tb
-- 重排编号处理
-- a. 根据要重排编号的顺序生成带标识列的临时表
SELECT
	ID = IDENTITY(int,0,1),
	*
INTO # FROM tb
ORDER BY ID1, ID2

-- 更新临时表, 以重排编号
UPDATE A SET
	ID2 = RIGHT(10001 + b1.ID - b2.ID, 4)
FROM tb A
	INNER JOIN # B1
		ON A.ID1 = B1.ID1
			AND A.ID2 = B1.ID2
	INNER JOIN(
		-- 临时表中, 每组ID1 对应的标识列最小值(通过每条记录的标识列值减去这个最小值, 即为该记录在这组ID1 中的序号(从开始))
		SELECT
			ID1, 
			ID = MIN(ID)
		FROM #
		GROUP BY ID1
	)B2
		ON B1.ID1 = B2.ID1
DROP TABLE #
SELECT * FROM tb
/*--结果
ID1  ID2  col
---- ---- ----------- 
aa   0001 1
aa   0002 2
aa   0003 3
bb   0001 4
bb   0002 5
cc   0001 6
cc   0002 7
--*/
GO

-- 删除测试
DROP TABLE tb