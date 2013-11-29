
/*
要求统主计列COL中每个数据项的出现的个数和出现过记录的记录数。
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
select * from tb
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

select * from #

--select data=substring(a.col,b.id,charindex(',',a.col+',',b.id)-b.id), 
--	show_count=count(0),
--	row_count=count(distinct a.id)
--from tb a ,# b
--where b.id<=len(a.col) and substring(','+a.col,b.id,1) = ','
--group by substring(a.col,b.id,charindex(',',a.col+',',b.id)-b.id)

--统计处理
SELECT
	data = SUBSTRING(A.col, B.ID, CHARINDEX(',', A.col + ',', B.ID) - B.ID),
	row_count = COUNT(DISTINCT A.ID),
	data_numbers = COUNT(*)
FROM tb A, # B
WHERE b.ID <= LEN(A.col)
	AND SUBSTRING(',' + A.col, B.ID, 1) =	','
GROUP BY SUBSTRING(A.col, B.ID, CHARINDEX(',', A.col + ',', B.ID) - B.ID)
DROP TABLE #
GO

-- 删除测试数据
DROP TABLE tb
