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