--测试数据
CREATE TABLE tb(
	col1 varchar(10),
	col2 int)
INSERT tb SELECT 'a', 2
UNION ALL SELECT 'a', 3
UNION ALL SELECT 'a', 6
UNION ALL SELECT 'a', 7
UNION ALL SELECT 'a', 8
UNION ALL SELECT 'b', 1
UNION ALL SELECT 'b', 5
UNION ALL SELECT 'b', 6
UNION ALL SELECT 'b', 7
GO

--缺号分布查询
SELECT
	A.col1,
	start_col2 = A.col2 + 1,
	end_col2 = (
				-- 缺号开始记录的后一条记录编号 - 1, 即为缺号的结束编号
				SELECT
					MIN(col2) - 1
				FROM tb AA
				WHERE col1 = A.col1
					AND col2 > A.col2 )
FROM(
	SELECT
		col1, col2
	FROM tb
	UNION ALL -- 为每组编号补充查询起始编号是否缺号的辅助记录
	SELECT DISTINCT 
		col1, 0
	FROM tb
)A
	INNER JOIN(
		-- 每组数据的最大记录肯定没有后续编号, 但它不能算缺号, 因此要将其去掉
		SELECT
			col1,
			col2 = MAX(col2)
		FROM tb
		GROUP BY col1
	)B
		ON A.col1 = B.col1
			AND A.col2 < B.col2
WHERE NOT EXISTS(
		-- 筛选出每条没有后续编号的记录, 它的编号 + 1 即为缺号的开始编号
		SELECT * FROM tb
		WHERE col1 = A.col1
			AND col2 = A.col2 + 1)
ORDER BY A.col1, start_col2
/*--结果
col1       start_col2  end_col2    
-------------- -------------- ----------- 
a          1           1
a          4           5
b          2           4
--*/
GO

-- 删除测试数据
DROP TABLE tb