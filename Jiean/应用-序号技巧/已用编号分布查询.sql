--测试数据
CREATE TABLE tb(
	col1 varchar(10),
	col2 int)
INSERT tb SELECT 'a', 2
UNION ALL SELECT 'a', 3
UNION ALL SELECT 'a', 6
UNION ALL SELECT 'a', 7
UNION ALL SELECT 'a', 8
UNION ALL SELECT 'b', 3
UNION ALL SELECT 'b', 5
UNION ALL SELECT 'b', 6
UNION ALL SELECT 'b', 7
GO

-- 已用编号分布查询 - 临时表法
-- a. 开始编号
SELECT
	id = IDENTITY(int),
	col1,
	col2
INTO #1
FROM tb A
WHERE NOT EXISTS(
		SELECT * FROM tb
		WHERE col1 = A.col1
			AND col2 = A.col2 - 1)

-- b. 结束编号
SELECT
	id = IDENTITY(int),
	col2
INTO #2
FROM tb A
WHERE NOT EXISTS(
		SELECT * FROM tb
		WHERE col1 = A.col1
			AND col2 = A.col2 + 1)

-- c. 查询结果
SELECT
	A.col1, 
	start_col2 = A.col2,
	end_col2 = B.col2
FROM #1 A, #2 B
WHERE A.id = B.id
DROP TABLE #1, #2
/*--结果
col1       start_col2  end_col2    
---------- ----------- ----------- 
a          2           3
a          6           8
b          3           3
b          5           7
--*/
GO


-- 已用编号分布查询 - 子查询法
SELECT
	col1,
	start_col2 = col2,
	end_col2=(
			SELECT
				-- 最小一个结束编号即为当前记录开始编号之后的结束编号
				MIN(col2)
			FROM tb AA
			WHERE col1 = A.col1
				-- 开始编号之后的结束编号
				AND col2 >= A.col2
				AND NOT EXISTS(
						SELECT * FROM tb
						WHERE col1 = AA.col1
							AND col2 = AA.col2 + 1))
FROM tb A
WHERE NOT EXISTS( -- 筛选出开始编号的记录
		SELECT * FROM tb
		WHERE col1 = A.col1
			AND col2 = A.col2 - 1)
GO

-- 删除测试环境
DROP TABLE tb
