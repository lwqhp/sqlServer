-- 测试数据
DECLARE @t TABLE(
	ID char(3),
	PID char(3),
	Name nvarchar(10))
INSERT @t SELECT '001', NULL , N'山东省'
UNION ALL SELECT '002', '001', N'烟台市'
UNION ALL SELECT '004', '002', N'招远市'
UNION ALL SELECT '003', '001', N'青岛市'
UNION ALL SELECT '005', NULL , N'四会市'
UNION ALL SELECT '006', '005', N'清远市'
UNION ALL SELECT '007', '006', N'小分市'

-- 广度排序显示处理
-- 生成每个节点的层次数据
DECLARE @t_Level TABLE(
	ID char(3),
	Level int
)
DECLARE
	@Level int
SET @Level = 0
INSERT @t_Level
SELECT
	ID, @Level
FROM @t
WHERE PID IS NULL  -- 第一层结点
WHILE @@ROWCOUNT > 0  --  循环生成所有结点的层次
BEGIN
	SET @Level = @Level + 1
	INSERT @t_Level
	SELECT A.ID, @Level
	FROM @t A, @t_Level B
	WHERE A.PID = B.ID
		AND B.Level = @Level - 1
END

-- 显示结果
SELECT
	A.*
FROM @t A, @t_Level B
WHERE A.ID = B.ID
ORDER BY B.Level, B.ID
/*--结果
ID   PID  Name
---- ---- ----------
001  NULL 山东省
005  NULL 四会市
002  001  烟台市
003  001  青岛市
006  005  清远市
004  002  招远市
007  006  小分市
--*/
