CREATE TABLE tb(
	ID int,
	PID int,
	Name nvarchar(10))
INSERT tb SELECT 1, NULL, N'山东省'
UNION ALL SELECT 2, 1   , N'烟台市'
UNION ALL SELECT 4, 2   , N'招远市'
UNION ALL SELECT 3, 1   , N'青岛市'
UNION ALL SELECT 5, NULL, N'四会市'
UNION ALL SELECT 6, 5   , N'清远市'
UNION ALL SELECT 7, 6   , N'小分市'
GO

-- 删除处理触发器(同步删除被删除结点的所有子结点)
CREATE TRIGGER dbo.tr_DeleteNode
ON tb
FOR DELETE
AS
-- 如果没有满足删除条件的记录,直接退出
IF @@ROWCOUNT = 0
	RETURN 

-- 查找所有被删除结点的子结点
DECLARE @t TABLE(
	ID int,
	Level int
)
DECLARE
	@Level int
SET @Level = 1
INSERT @t
SELECT
	A.ID, @Level
FROM tb A, deleted D
WHERE A.PID = D.ID
WHILE @@ROWCOUNT > 0
BEGIN
	SET @Level = @Level + 1

	INSERT @t
	SELECT A.ID, @Level
	FROM tb A, @t B
	WHERE A.PID = B.ID
		AND B.Level = @Level - 1
END
-- 删除结点
DELETE A
FROM tb A, @t B
WHERE A.ID = B.ID
GO

--删除
DELETE FROM tb
WHERE ID IN(2, 3, 5)
SELECT * FROM tb
/*--结果
ID          PID         Name
----------- ----------- ----------
1           NULL        山东省
--*/
GO

-- 删除测试表
DROP TABLE tb