-- 移动或者复制结点
CREATE PROC dbo.p_Move_CopyCode
	@TableName  sysname,		-- 调整编码规则的表名
	@FieldName  sysname,		-- 编码字段名
	@CodeRule   varchar(50),	-- 以逗号分隔的编码规则，每层编码的长度，比如 1,2,3,表示有三层编码，第一层长度为 1，第二层长度为 2，第三层长度为 3
	@Code      varchar(50),		-- 要复制或者移动的节点编码
	@ParentCode varchar(50),	-- 移动到该编码的节点下
	@IsCopy    bit = 0			-- 0 为移动处理, 否则为复制处理
AS
SET NOCOUNT ON
-- 参数检查
IF ISNULL(OBJECTPROPERTY(OBJECT_ID(@TableName), N'IsUserTable'), 0) = 0
BEGIN
	RAISERROR(N'"%s"不存在,或者不是用户表', 16, 1, @TableName)
	RETURN
END

IF NOT EXISTS(
		SELECT * FROM dbo.syscolumns
		WHERE ID = OBJECT_ID(@TableName)
			AND name = @FieldName)
BEGIN
	RAISERROR(N'列名 "%s" 在用户表 "%s" 中不存在', 16, 1, @FieldName, @TableName)
	RETURN	
END

IF ISNULL(@CodeRule, '') = ''
BEGIN
	RAISERROR(N'必须编码规则字符串', 16, 1)
	RETURN	
END

IF PATINDEX(N'%[^0-9^,]%', @CodeRule) > 0
BEGIN
	RAISERROR(N'编码规则字符串 "%s" 中只能包含数字和逗号(,)', 16, 1, @CodeRule)
	RETURN	
END

-- a. 待复制编码的子编码规则(不包含父编码层次的编码规则)
DECLARE
	@CodeRule_Source varchar(50),
	@CodeLen_Source int,
	@CodeLens_Source int
SELECT
	@CodeRule_Source = @CodeRule + ',',
	@CodeLens_Source = LEN(@Code)
WHILE @CodeRule_Source > '' AND @CodeLens_Source > 0
	SELECT
		@CodeLen_Source = LEFT(@CodeRule_Source, CHARINDEX(',', @CodeRule_Source) - 1),
		@CodeRule_Source = STUFF(@CodeRule_Source, 1, CHARINDEX(',', @CodeRule_Source), ''),
		@CodeLens_Source = @CodeLens_Source - @CodeLen_Source
IF @CodeLens_Source <> 0
BEGIN
	RAISERROR(N'编码 "%s" 不符合编码规则', 16, 1, @Code)
	RETURN
END
IF @CodeLen_Source IS NOT NULL
	SET @CodeRule_Source = RTRIM(@CodeLen_Source) + ',' + @CodeRule_Source
SET @CodeRule_Source = LEFT(@CodeRule_Source, LEN(@CodeRule_Source) - 1)

-- b. 复制后的编码的子编码规则(不包含父编码层次的编码规则)
DECLARE
	@CodeRule_Destination varchar(50),
	@CodeLen_Destination int,
	@CodeLens_Destination int
SELECT
	@CodeRule_Destination = @CodeRule + ',',
	@CodeLens_Destination = LEN(@ParentCode)
WHILE @CodeRule_Destination > '' AND @CodeLens_Destination > 0
	SELECT
		@CodeLen_Destination = LEFT(@CodeRule_Destination, CHARINDEX(',', @CodeRule_Destination) - 1),
		@CodeRule_Destination = STUFF(@CodeRule_Destination, 1, CHARINDEX(',', @CodeRule_Destination), ''),
		@CodeLens_Destination = @CodeLens_Destination - @CodeLen_Destination
IF @CodeLens_Destination <> 0
BEGIN
	RAISERROR(N'编码 "%s" 不符合编码规则', 16, 1, @ParentCode)
	RETURN
END
IF @CodeRule_Destination = ''
BEGIN
	RAISERROR(N'无法将数据复制到未级编码 "%s" 下面', 16, 1, @ParentCode)
	RETURN
END
SET @CodeRule_Destination = LEFT(@CodeRule_Destination, LEN(@CodeRule_Destination) - 1)

-- c. 编码规则转换的 T-SQL
DECLARE
	@sql nvarchar(4000)
SET @sql = CASE
			-- 如果新旧编码规则长度没有改变, 则不需要做转换
			WHEN @CodeRule_Destination LIKE @CodeRule_Source + '%'
					OR @CodeRule_Source LIKE @CodeRule_Destination + '%'
				THEN 'STUFF(' + @FieldName + ', 1, ' + RTRIM(LEN(@Code) - @CodeLen_Source) + ', ' 
							+ QUOTENAME(@ParentCode, N'''') + ')'
			ELSE QUOTENAME(@ParentCode, N'''') + ' + '
					+ dbo.f_ChangeCodeRule(
							@CodeRule_Source, 
							@CodeRule_Destination,
							'',
							0,
							'STUFF(' + @FieldName + ', 1, ' + RTRIM(LEN(@Code) - @CodeLen_Source) + ', '''')')
		END

-- d. 复制或者移动操作
DECLARE
	@value_Code varchar(50),
	@value_CodeParent varchar(50),
	@where_ignore_copy nvarchar(4000),
	@sql_move_copy nvarchar(4000)
SELECT
	@value_Code = QUOTENAME(@Code, ''''),
	@value_CodeParent = QUOTENAME(@ParentCode, ''''),
	@where_ignore_copy = CASE
			WHEN @IsCopy = 0 THEN N'
	-- 移动结点不需要检查要移动的节点的重复性
	AND ' + @FieldName + N' NOT LIKE ' + @value_Code + ' + ''%'''
			ELSE N''
		END,
	@sql_move_copy = CASE
			WHEN @IsCopy = 0 THEN N'
	-- 移动结点的操作
	UPDATE A SET
		' + @FieldName + N' = B.No_New
	FROM ' + @TableName + N' A, # B
	WHERE A.' + @FieldName + N' = B.No_Old
'
			ELSE N'
	-- 复制结点的操作
	SELECT
		*
	INTO #copy
	FROM ' + @TableName + N'
	WHERE ' + @FieldName + N' LIKE ' + @value_Code + ' + ''%''
	UPDATE A SET
		' + @FieldName + N' = B.No_New
	FROM #copy A, # B
	WHERE A.' + @FieldName + N' = B.No_Old
	INSERT ' + @TableName + N' SELECT * FROM #copy
'
		END

EXEC(N'
-- a. 检查目标编码是否存在
IF NOT EXISTS(
		SELECT * FROM ' + @TableName + N'
		WHERE ' + @FieldName + N' = ' + @value_CodeParent + N')
BEGIN
	RAISERROR(''复制目标编码不存在'', 16, 1)
	RETURN
END

-- b. 生成要复制(或移动)编码的新编码
--BEGIN TRAN
	SELECT
		No_Old = ' + @FieldName + N',
		No_New = ' + @sql + '
	INTO #
	FROM ' + @TableName + N' WITH(XLOCK,TABLOCK)
	WHERE ' + @FieldName + N' LIKE ' + @value_Code + N' + ''%''

-- c. 检查编码复制的有效性
SELECT
	Error = N''编码重复'', *
INTO #check
FROM # A
WHERE EXISTS(
		SELECT * FROM #
		WHERE No_New = A.No_New
			AND No_Old <> A.No_Old)
UNION ALL
SELECT
	Error = N''复制后与表中现有编码重复'', *
FROM # A
WHERE EXISTS(
		SELECT * FROM ' + @TableName + N'
		WHERE ' + @FieldName + N' = A.No_New
			' + @where_ignore_copy + N'
		)
IF @@ROWCOUNT > 0
BEGIN 
	SELECT * FROM #check
--ROLLBACK TRAN
END
ELSE
BEGIN
	-- 复制或者移动编码
	' + @sql_move_copy + N'
--	COMMIT TRAN
END
')
GO


-- 调用示例
-- a. 测试数据表
CREATE TABLE dbo.tb(
	No varchar(10))
INSERT dbo.tb SELECT '1'
UNION ALL     SELECT '3'
UNION ALL     SELECT '302'
UNION ALL     SELECT '305'
UNION ALL     SELECT '305001'
UNION ALL     SELECT '305005'
UNION ALL     SELECT '6'
UNION ALL     SELECT '606'

-- b. 复制结点
EXEC dbo.p_Move_CopyCode
	@TableName = 'tb',
	@FieldName = 'No',
	@CodeRule  = '1,2,3',
	@Code = '305',
	@ParentCode = '1',
	@IsCopy = 1

-- c. 显示结果
SELECT * FROM tb
DROP TABLE tb
GO

--DROP PROC dbo.p_Move_CopyCode