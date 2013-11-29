CREATE PROC dbo.p_VerifyData
	@TableName     sysname,		-- 要校验树形数据的表
	@CodeField      sysname,	-- 编码字段名
	@ParentCodeField sysname	-- 上级编码字段名
AS
SET NOCOUNT ON
-- 参数检查
IF ISNULL(OBJECTPROPERTY(OBJECT_ID(@TableName), N'IsUserTable'), 0) = 0
BEGIN
	RAISERROR(N'"%s" 不存在,或者不是用户表', 16, 1, @TableName)
	RETURN
END
IF NOT EXISTS(
		SELECT * FROM dbo.syscolumns
		WHERE ID = OBJECT_ID(@TableName)
			AND name = @CodeField)
BEGIN
	RAISERROR(N'列 "%s" 在用户表 "%s "中不存在', 16, 1, @CodeField, @TableName)
	RETURN	
END
IF NOT EXISTS(
		SELECT * FROM dbo.syscolumns
		WHERE ID = OBJECT_ID(@TableName)
			AND name = @ParentCodeField)
BEGIN
	RAISERROR(N'列 "%s" 在用户表 "%s" 中不存在', 16, 1, @ParentCodeField, @TableName)
	RETURN	
END

-- 数据检查
EXEC(N'
-- 检查导致循环的结点
DECLARE
	@Level int
SET @Level = 1
SELECT
	ID, PID,
	Path = CAST(ID as varchar(8000)),
	Level = @Level
INTO #
FROM(-- 列出所有父结点不是根结点的数据(使用子查询是防止编码列为 IDENTITY 列时,导致后面的插入处理出错)
	SELECT
		ID = A.' + @CodeField + N',
		PID = A.' + @ParentCodeField + N' 
	FROM ' + @TableName + N' A, ' + @TableName + N' B
	WHERE A.' + @ParentCodeField + N' = B.' + @CodeField + N'
		AND B.' + @ParentCodeField + N' IS NOT NULL
)A
WHILE @@ROWCOUNT > 0
BEGIN
	SET @Level = @Level + 1
	INSERT #(
		ID, PID, Path, Level)
	SELECT
		A.' + @CodeField + N',
		B.PID,
		CAST(A.' + @CodeField + N' as varchar(8000)) + ''>'' + B.Path,
		@Level
	FROM ' + @TableName + N' A, # B
	WHERE A.' + @ParentCodeField + N' = B.ID
		AND B.Level = @Level - 1
		AND B.ID <> B.PID
END

-- 显示结果
SELECT
	' + @CodeField + N',
	Description = N''父结点无效'' 
FROM ' + @TableName + N' A
WHERE ' + @ParentCodeField + N' IS NOT NULL
	AND NOT EXISTS(
			SELECT * FROM ' + @TableName + N'
			WHERE ' + @CodeField + N' = A.' + @ParentCodeField + N')
UNION ALL -- 显示产生循环的结点
SELECT
	ID,
	N''循环:'' + Path + ''>'' + CAST(ID as varchar(8000))
FROM #
WHERE ID = PID
')
GO
