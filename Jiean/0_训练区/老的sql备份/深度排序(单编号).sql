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

-- 深度排序显示处理
-- 生成每个结点的编码累计(相当于单编号法的编码)
DECLARE @t_Level TABLE(
	ID char(3),
	Level int,
	Sort varchar(8000)
)
DECLARE
	@Level int
SET @Level = 0
INSERT @t_Level(
	ID, Level, Sort)
SELECT
	ID, @Level, ID
FROM @t
WHERE PID IS NULL
WHILE @@ROWCOUNT > 0
BEGIN
	SET @Level = @Level + 1
	INSERT @t_Level(
		ID, Level, Sort)
	 SELECT
		A.ID, @Level, B.Sort + A.ID
	FROM @t A, @t_Level B
	WHERE A.PID = B.ID
		AND B.Level = @Level - 1
END

-- 显示结果
SELECT
	A.*
FROM @t A, @t_Level B
WHERE A.ID = B.ID
ORDER BY B.Sort
/*--结果
ID   PID  Name
---- ---- ----------
001  NULL 山东省
002  001  烟台市
004  002  招远市
003  001  青岛市
005  NULL 四会市
006  005  清远市
007  006  小分市
--*/

-- 显示层次型结果
SELECT
	SPACE(B.Level * 2) + N'|-- ' + A.Name
FROM @t A, @t_Level B
WHERE A.ID = B.ID
ORDER BY B.Sort
/*--结果
|-- 山东省
  |-- 烟台市
    |-- 招远市
  |-- 青岛市
|-- 四会市
  |-- 清远市
    |-- 小分市
--*/