-- 要分页的原始数据
CREATE TABLE tb(
	ID    int			-- 记录编号
		PRIMARY KEY, 
	grade  varchar(10),	-- 类别名称
	uptime datetime		-- 更新时间
)
INSERT tb SELECT 1 , 'a', '2004-12-11'
UNION ALL SELECT 2 , 'b', '2004-12-11'
UNION ALL SELECT 3 , 'c', '2004-12-11'
UNION ALL SELECT 4 , 'a', '2004-12-12'
UNION ALL SELECT 5 , 'c', '2004-12-13'
UNION ALL SELECT 6 , 'c', '2004-12-13'
UNION ALL SELECT 7 , 'a', '2004-12-14'
UNION ALL SELECT 8 , 'a', '2004-12-15'
UNION ALL SELECT 9 , 'b', '2004-12-16'
UNION ALL SELECT 10, 'b', '2004-12-17'
UNION ALL SELECT 11, 'a', '2004-12-17'

-- 分页定义表
CREATE TABLE tb_Page(
	grade   varchar(10)	-- 类别名称,与tb表的grade关联
		PRIMARY KEY,
	Records int,		-- 每页显示的记录数
	Orders  int			-- 在页中的显示顺序
)
INSERT tb_Page SELECT 'c', 2, 1
UNION  ALL     SELECT 'b', 1, 2
UNION  ALL     SELECT 'a', 2, 3
GO

-- 实现分页处理的存储过程
CREATE PROC dbo.p_PageView
	@PageCurrent int = 1  --要显示的当前页码
AS
SET NOCOUNT ON
-- 得到每页需要显示的记录数
DECLARE
	@PageSize int
SELECT
	@PageSize = SUM(Records)
FROM tb_Page
IF ISNULL(@PageSize, 0) < 0
	RETURN

-- 分页显示处理
DECLARE
	@Rows int
-- 获取截止当前页的记录数
SET @Rows = @PageCurrent * @PageSize

-- 获取截止当前页的主键数据
SET ROWCOUNT @Rows
SELECT
	SID = IDENTITY(int, 1, 1),
	ID 
INTO #
FROM(
	SELECT TOP 100 PERCENT
		A.ID 
	FROM tb A
		LEFT JOIN tb_Page B
			ON A.grade = B.grade
	ORDER BY		
		CASE  -- 分页定义表中没有没有定义的分类显示在最后
			WHEN B.grade IS NULL THEN 1
			ELSE 0
		END, 
		((  -- 根据 uptime 从大到小生成当前记录的序号
			SELECT COUNT(*) FROM tb 
			WHERE grade = A.grade 
				AND (
					uptime > A.uptime
					OR uptime = A.uptime AND id >= A.id)
		) - 1) / B.Records, -- 结合 tb_Page 计算当前记录应该在那一页显示, 并据此排序
		B.Orders,					-- 根据 tb_Page 定义的 Orders 顺序显示
		A.uptime DESC, A.ID DESC	-- 同一 grade 的记录根据 uptime 和 id 降序显示
)A
SET ROWCOUNT 0

-- 删除非显示页的主键记录
IF @Rows > @PageSize
BEGIN
	SET @Rows = @Rows - @PageSize
	SET ROWCOUNT @Rows
	DELETE FROM #
	SET ROWCOUNT 0
END
SELECT
	A.*
FROM tb A, # B
WHERE A.ID = B.ID
ORDER BY B.SID
GO

-- 调用
EXEC dbo.p_PageView 2
/*--结果
ID          grade      uptime                                                 
----------- ---------- ---------------------------
3           c          2004-12-11 00:00:00.000
9           b          2004-12-16 00:00:00.000
7           a          2004-12-14 00:00:00.000
4           a          2004-12-12 00:00:00.000
2           b          2004-12-11 00:00:00.000
--*/
GO

-- 删除测试环境
DROP TABLE tb, tb_Page
DROP PROC dbo.p_PageView