CREATE PROC dbo.p_DeleteCode
	@TableName sysname,			-- 调整编码规则的表名
	@FieldName sysname,			-- 编码字段名
	@CodeRule  varchar(50),		-- 以逗号分隔的编码规则, 每层编码的长度,比如 1,2,3,表示有三层编码,第一层长度为 1,第二层长度为 2,第三层长度为 3
	@Code varchar(50)			-- 要删除的节点编码
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

-- 生成被删除结点的子结点的新编码规则(因为子结点要提升一级)
DECLARE
	@codelen int,
	@codelens int,
	@CodeRule_New varchar(50)
SELECT
	@codelens = LEN(@Code),
	@CodeRule_New = @CodeRule + ','
-- 获取被删除的编码的最后一级的长度, 并生成该编码之后的编码规则
WHILE @CodeRule_New > '' AND @codelens > 0
	SELECT
		@codelen = LEFT(@CodeRule_New, CHARINDEX(',', @CodeRule_New) - 1),
		@CodeRule_New = STUFF(@CodeRule_New, 1, CHARINDEX(',', @CodeRule_New), ''),
		@codelens = @codelens - @codelen

-- 确认要删除的编码是否符合编码规则
IF @codelens <> 0
BEGIN
	RAISERROR(N'编码 "%s" 不符合指定的编码规则 "%s" ', 16, 1, @Code, @CodeRule)
	RETURN
END

-- 生成修改被删除结点子结点编码的新编码规则
SET @CodeRule_New = CASE
			WHEN @CodeRule_New = '' THEN @CodeRule
			-- 将子结点被删除的编码层去掉, 并将随后的层提升一层
			ELSE STUFF(@CodeRule, 
					2 + LEN(@CodeRule) - CHARINDEX(',', REVERSE(@CodeRule) + ',', LEN(@CodeRule_New) + 2),
					0,
					'0,')
		END

-- 得到被删除结点子结点编码更新的 T-SQL
DECLARE
	@sql nvarchar(4000)
SET @sql = dbo.f_ChangeCodeRule(@CodeRule, @CodeRule_New, '', 0, @FieldName)

-- 检查并完成删除处理
DECLARE
	@value_code varchar(50),
	@value_code_child varchar(50)
SELECT
	@value_code = QUOTENAME(@Code, N''''),
	@value_code_child = QUOTENAME(@Code + N'_%', N'''')

EXEC(N'
BEGIN TRAN
-- 将处理后的编码与处理前的编码保存到临时表
SELECT
	No_Old = ' + @FieldName + N',
	No_New = '+ @sql + N'
INTO #
FROM ' + @TableName + N' WITH(XLOCK,TABLOCK)
WHERE ' + @FieldName + N' LIKE ' + @value_code_child + N'

-- 检查更新后的编码是否存在重复
IF EXISTS(
		SELECT No_New FROM #
		GROUP BY No_New
		HAVING COUNT(*)>1)
BEGIN
	SELECT * FROM # A
	WHERE EXISTS(
			SELECT * FROM #
			WHERE No_New = A.No_New
				AND No_Old <> A.No_Old)
	ORDER BY No_New, No_Old

	ROLLBACK TRAN
END
ELSE
-- 检查更新后的编码是否与表中现有的编码重复
IF EXISTS(
		SELECT * FROM ' + @TableName + N' A, # B 
		WHERE A.' + @FieldName + N' <> ' + @value_code + N'
			AND A.' + @FieldName + N' = B.No_New
			AND A.' + @FieldName + N' <> B.No_Old)
BEGIN
	SELECT
		B.*, A.*
	FROM ' + @TableName + N' A, # B 
	WHERE A.' + @FieldName + N' <> ' + @value_code + N'
		AND A.' + @FieldName + N' = B.No_New
		AND A.' + @FieldName + N' <> B.No_Old

	ROLLBACK TRAN
END
ELSE
BEGIN
	-- 如果编码处理后不重复,则更新到编码表中
	DELETE FROM ' + @TableName + N'
	WHERE ' + @FieldName + N' = ' + @value_code + N'

	UPDATE A SET
		' + @FieldName + N' = B.No_New
	FROM ' + @TableName + N' A, # B
	WHERE A.' + @FieldName + N' = B.No_Old

	COMMIT TRAN
END')
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

-- a. 删除结点 305
EXEC dbo.p_DeleteCode
	@TableName = 'dbo.tb',
	@FieldName = 'No',
	@CodeRule  = '1,2,3',
	@Code = '305'

-- b. 删除结点 3
EXEC dbo.p_DeleteCode
	@TableName = 'dbo.tb',
	@FieldName = 'No',
	@CodeRule  = '1,2,3',
	@Code = '3'

-- c. 显示最终结果
SELECT * FROM tb
DROP TABLE tb
GO

--DROP PROC dbo.p_DeleteCode