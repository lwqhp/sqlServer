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

-- a. 结点复制处理函数(深度搜索算法)
CREATE FUNCTION dbo.f_CopyNode(
	@ID int,			-- 复制此结点下的所有子结点
	@PID int,			-- 将 @ID 下的所有子结点复制到此结点下面
	@NewID int = NULL	-- 新编码的开始值,如果指定为 NULL,则为表中的最大编码 + 1
)RETURNS @t TABLE(
			OldID int, 
			ID int,
			PID int)
AS
BEGIN
	-- 第一个结点的编号
	IF @NewID IS NULL
		SELECT
			@NewID = COUNT(*) + 1
		FROM tb

	DECLARE CUR_tb CURSOR LOCAL
	FOR
	SELECT -- 要复制结点的第一层结点
		ID
	FROM tb
	WHERE PID = @ID
	OPEN CUR_tb
	FETCH CUR_tb INTO @ID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT @t(
			OldID, ID, PID)
		VALUES(
			@ID, @NewID, @PID)

		-- 查询当前结点的所有子结点
		SET @NewID = @NewID + 1
		IF @@NESTLEVEL < 32 -- 如果递归层数未超过32层(递归最大允许32层)
		BEGIN
			-- 递归查找当前结点的子结点
			DECLARE
				@PID1 int
			SET @PID1 = @NewID - 1
			INSERT @t(
				OldID, ID, PID)
			SELECT * FROM dbo.f_CopyNode(@ID, @PID1, @NewID)
			SET @NewID = @NewID + @@ROWCOUNT  --排序号加上子结点个数
		END

		FETCH CUR_tb INTO @ID
	END
	CLOSE CUR_tb
	DEALLOCATE CUR_tb

	RETURN
END
GO

-- 调用函数将结点 1 下面的所有子结点复制到结点 5 下面
INSERT tb(
	ID, PID, Name)
SELECT
	A.ID, A.PID, B.Name
FROM dbo.f_CopyNode(1, 5, DEFAULT) A, tb B
WHERE A.OldID = B.ID
SELECT * FROM tb
/*--结果
ID          PID         Name
----------- ----------- ----------
1           NULL        山东省
2           1           烟台市
4           2           招远市
3           1           青岛市
5           NULL        四会市
6           5           清远市
7           6           小分市
8           5           烟台市
10          5           青岛市
9           8           招远市
--*/
GO


-- 结点复制处理函数 (广度搜索算法)
CREATE FUNCTION dbo.f_CopyNode(
	@ID int,			-- 复制此结点下的所有子结点
	@PID int,			-- 将 @ID 下的所有子结点复制到此结点下面
	@NewID int = NULL	-- 新编码的开始值，如果指定为 NULL，则为表中的最大编码 + 1
)RETURNS @t TABLE(
			OldID int,
			ID int,
			PID int,
			Level int)
AS
BEGIN
	IF @NewID IS NULL
		SELECT
			@NewID = COUNT(*)
		FROM tb
	ELSE
		SET @NewID = @NewID - 1

	DECLARE
		@Level int
	SET @Level = 1

	-- 要复制结点的第一层结点
	INSERT @t(
		OldID, PID, Level)
	SELECT
		ID, @PID, @Level
	FROM tb
	WHERE PID = @ID

	WHILE @@ROWCOUNT > 0
	BEGIN
		-- 生成结点 ID
		UPDATE @t SET
			@NewID = @NewID + 1,
			ID = @NewID
		WHERE Level = @Level

		-- 第二层及所有子结点
		SET @Level = @Level + 1
		INSERT @t(
			OldID, PID, Level)
		SELECT
			A.ID, B.ID, @Level
		FROM tb A, @t B
		WHERE A.PID = B.OldID
			AND B.Level = @Level - 1
	END
	RETURN
END
GO

-- 删除测试
DROP TABLE tb
DROP FUNCTION dbo.f_CopyNode