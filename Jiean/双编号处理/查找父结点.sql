-- 测试数据
CREATE TABLE tb(
	ID char(3),
	PID char(3),
	Name nvarchar(10)
)
INSERT tb SELECT '001', NULL , N'山东省'
UNION ALL SELECT '002', '001', N'烟台市'
UNION ALL SELECT '004', '002', N'招远市'
UNION ALL SELECT '003', '001', N'青岛市'
UNION ALL SELECT '005', NULL , N'四会市'
UNION ALL SELECT '006', '005', N'清远市'
UNION ALL SELECT '007', '006', N'小分市'
GO

-- A. 查询指定结点及其所有子结点的函数
CREATE FUNCTION dbo.f_Cid(
	@ID char(3)
)RETURNS @t_Level TABLE(
	ID char(3),
	Level int)
AS
BEGIN
	DECLARE
		@Level int
	SET @Level = 1
	INSERT @t_Level
	SELECT
		@ID, @Level
	WHILE @@ROWCOUNT > 0
	BEGIN
		SET @Level = @Level + 1
		INSERT @t_Level
		SELECT
			A.ID, @Level
		FROM tb A, @t_Level B
		WHERE A.PID = B.ID
			AND B.Level = @Level - 1
	END
	RETURN
END
GO

-- 调用函数查询 002 及其所有子结点
SELECT 
	A.*
FROM tb A, dbo.f_Cid('002') B
WHERE A.ID = B.ID
/*--结果
ID   PID  Name
---- ---- ----------
002  001  烟台市
004  002  招远市
--*/
GO


-- B. 查询指定结点及其所有父结点的函数(多父结点)
CREATE FUNCTION dbo.f_Pid(
	@ID char(3)
)RETURNS @t_Level TABLE(
	ID char(3),
	Level int)
AS
BEGIN
	DECLARE
		@Level int
	SET @Level = 1
	INSERT @t_Level
	SELECT
		@ID, @Level
	WHILE @@ROWCOUNT > 0
	BEGIN
		SET @Level = @Level + 1
		INSERT @t_Level
		SELECT
			A.PID, @Level
		FROM tb A, @t_Level B
		WHERE A.ID = B.ID
			AND B.Level = @Level - 1
	END
	RETURN
END
GO


-- C. 查询指定结点及其所有父结点的函数(单父结点)
CREATE FUNCTION dbo.f_Pid_Single(
	@ID char(3))
RETURNS @t_Level TABLE(
	ID char(3))
AS
BEGIN
	INSERT @t_Level
	SELECT @ID

	SELECT
		@ID = PID
	FROM tb
	WHERE ID = @ID
		AND PID IS NOT NULL
	WHILE @@ROWCOUNT > 0
	BEGIN
		INSERT @t_Level
		SELECT
			@ID

		SELECT
			@ID = PID
		FROM tb
		WHERE ID = @ID
			AND PID IS NOT NULL
	END
	RETURN
END
GO


-- 删除测试
DROP TABLE tb
DROP FUNCTION dbo.f_Cid, dbo.f_Pid, dbo.f_Pid_Single