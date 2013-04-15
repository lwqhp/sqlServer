
/*
根据理ID分组，将每组ID的列COL中的第条记录都共有的数据项提取出来，重新组合为一条记录。
*/
-- 示例数据
CREATE TABLE tb(
	ID int,
	col varchar(50))
INSERT tb SELECT 1,'1,2,3,4'
UNION ALL SELECT 1,'1,3,4'
UNION ALL SELECT 1,'1,4'
UNION ALL SELECT 2,'11,3,4'
UNION ALL SELECT 2,'1,33,4'
UNION ALL SELECT 3,'1,3,4'
GO

-- 合并数据项的处理函数
CREATE FUNCTION dbo.f_mergSTR(
	@ID int
)RETURNS varchar(50)
AS
BEGIN
	DECLARE @t TABLE(
		ID int IDENTITY,
		b bit)
	--分拆处理辅助表,由于列col的最大宽度为50,所以只需要1到50的分拆辅助记录
	INSERT @t(
		b)
	SELECT TOP 50
		0 
	FROM dbo.syscolumns A, dbo.syscolumns B

	DECLARE
		@r varchar(50)
	SET @r = ''
	SELECT
		-- 合并处理后的数据项
		@r = @r + ',' + s
	FROM(
		-- 分拆字符串
		SELECT
			s = SUBSTRING(A.col, B.ID, CHARINDEX(',', A.col + ',', B.ID) - B.ID)
		FROM tb A, @t B
		WHERE a.ID = @ID
			AND b.ID <= LEN(A.col) 
			AND SUBSTRING(',' + A.col, B.ID, 1) = ','
		GROUP BY SUBSTRING(A.col, B.ID, CHARINDEX(',', A.col + ',', B.ID) - B.ID)
		-- 如果分拆后的数据项的个数与该组记录数相同, 则数据数据项在该组的所有记录中存在, 则保留此记录
		HAVING COUNT(*) = (SELECT COUNT(*) FROM tb WHERE ID = @ID)
	)A
	ORDER BY s -- 排序生成的结果中的数据项位置(如果要按数字排序, 则需要做数据类型转换)

	RETURN(STUFF(@r, 1, 1, ''))
END
GO

--调用用户定义实现交交集查询
SELECT
	ID,
	col = dbo.f_mergStr(ID)
FROM tb
GROUP BY ID
GO

-- 删除示例对象
DROP TABLE tb
DROP FUNCTION dbo.f_mergSTR
