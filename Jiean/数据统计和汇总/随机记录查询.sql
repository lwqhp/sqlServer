-- 题库表
CREATE TABLE tb(
	ID int             -- 题目ID
		PRIMARY KEY,
	Type int,          -- 题型
	col1 nvarchar(10)  -- 其他需要的字段
)
INSERT tb SELECT 1, 1, N'试题1'
UNION ALL SELECT 2, 1, N'试题2'
UNION ALL SELECT 3, 3, N'试题3'
UNION ALL SELECT 4, 3, N'试题4'
UNION ALL SELECT 5, 3, N'试题5'
UNION ALL SELECT 6, 3, N'试题6'
GO

-- 生成试卷的处理过程
CREATE PROC dbo.p_test
	@试卷份数 int,
	@试题数   varchar(100)  -- 格式: 题型:题目数, 用逗号分隔多个题型:题目数
AS
SET NOCOUNT ON
-- 参数检测
IF ISNULL(@试卷份数, 0) < 1
	RETURN
IF ISNULL(@试题数, '') = ''
	RETURN

-- 分拆题型
DECLARE @tb_type TABLE(
	Type int,
	Nums int
)
DECLARE
	@value varchar(100)
WHILE @试题数 > ''
BEGIN
	SELECT
		-- 取第一个题型和题目数
		@value = LEFT(@试题数, CHARINDEX(',', @试题数 + ',') - 1),
		@试题数 = STUFF(@试题数, 1, CHARINDEX(',', @试题数 + ','), '')

	-- 记录题型和题目数
	INSERT @tb_type(
		Type, Nums)
	SELECT
		LEFT(@value, CHARINDEX(':', @value + ':') - 1),
		STUFF(@value, 1, CHARINDEX(':', @value + ':'), '')
END

-- 使用游标, 为每种题型随机抽取题目
DECLARE @tb_re TABLE(
	GID int IDENTITY,
	Type int,
	ID int)

DECLARE CUR_tb CURSOR LOCAL
FOR
SELECT
	Type,              -- 题型
	Nums * @试卷份数   -- 该题型总共需要取的题目数
FROM @tb_type

DECLARE
	@Type int,
	@Nums int
OPEN CUR_tb
FETCH CUR_tb INTO @Type, @Nums
WHILE @@FETCH_STATUS=0
BEGIN
	-- 抽取指定题型的题目, 直到达到指定的数量
	WHILE @Nums > 0
	BEGIN
		SET ROWCOUNT @Nums   -- 限制最多抽取的记录数
		-- 随机抽取指定题型的题目
		INSERT @tb_re(
			Type, ID)
		SELECT
			@Type, ID
		FROM tb 
		WHERE Type = @Type
		ORDER BY NEWID()

		-- 减少已经抽取的题目数
		SET @Nums = @Nums - @@ROWCOUNT
	END

	FETCH CUR_tb INTO @Type, @Nums
END
CLOSE CUR_tb
DEALLOCATE CUR_tb

--显示结果
SET ROWCOUNT 0
SELECT 
	试卷编号 = (B.gid - B1.gid) / C.Nums + 1,
	A.*
FROM tb A,
	@tb_re B,
	@tb_type C,
	(
		-- 用于计算试卷编号
		SELECT
			Type, gid = MIN(gid)
		FROM @tb_re
		GROUP BY Type
	)B1
WHERE A.ID = B.ID 
	AND B.Type = C.Type
	AND B.Type = B1.Type
ORDER BY 试卷编号, B.gid
GO

--调用
EXEC dbo.p_test 2, '1:1,3:2'
/*--结果之一
试卷编号        ID          Type        col1
----------- ----------- ----------- ----------
1           2           1           试题2
1           5           3           试题5
1           3           3           试题3
2           1           1           试题1
2           4           3           试题4
2           6           3           试题6
--*/
GO

-- 删除测试
DROP PROC dbo.p_test
DROP TABLE tb