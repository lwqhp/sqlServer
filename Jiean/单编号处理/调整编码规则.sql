-- 生成编码规则调到的 编码更新  T-SQL 
CREATE FUNCTION dbo.f_ChangeCodeRule(
	@CodeRule_Old  varchar(50),		-- 以逗号分隔的旧的编码规则, 每层编码的长度. 比如 1, 2, 3, 表示有三层编码,第一层长度为 1, 第二层长度为 2, 第三层长度为 3
	@CodeRule_New varchar(50),		-- 以逗号分隔的旧的编码规则, 如果某个层次的编码长度为 0, 表示删除该层编码
	@CharFill       char(1),		-- 扩充编码时,填充的字符
	@Position       int,			-- 为 0, 从编码的最前面开始压缩或者填充, 为 -1 或者大于旧编码的长度, 从最后一位开始处理, 为其他值, 从指定的位置后开始处理
	@FieldName     sysname			-- 编码字段名
)RETURNS nvarchar(4000)
AS
BEGIN
	IF ISNULL(@CharFill, '') = ''
		SET @CharFill = '0'

	-- 将编码规则拆分为表
	-- a. 拆分旧的编码规则
	DECLARE @tb_Code_Old TABLE(
		ID int IDENTITY,
		CodeLen int,
		CodeLens int,
		Code nvarchar(200))
	DECLARE
		@CodeLen int,
		@CodeLens varchar(20)
	SELECT
		@CodeRule_Old = @CodeRule_Old + ',',
		@CodeLens = 1
	WHILE @CodeRule_Old > ''
	BEGIN
		SELECT
			@CodeLen = LEFT(@CodeRule_Old, CHARINDEX(',', @CodeRule_Old) - 1),
			@CodeRule_Old = STUFF(@CodeRule_Old, 1, CHARINDEX(',', @CodeRule_Old),  '')
		INSERT @tb_Code_Old(
			CodeLen, CodeLens, Code)
		VALUES(
			@CodeLen, @CodeLens,
			-- 取当前层次编码的 T-SQL 语句
			N'SUBSTRING(' + @FieldName + N', ' + RTRIM(@CodeLens) + N', ' + RTRIM(@CodeLen) + N')')
		SET @CodeLens = @CodeLens + CONVERT(int, @CodeLen)
	END

	-- b. 拆分新的编码规则
	DECLARE @tb_Code_New TABLE(
		ID int IDENTITY,
		CodeLen int)

	SET @CodeRule_New = @CodeRule_New + ','
	WHILE @CodeRule_New > ''
	BEGIN
		INSERT @tb_Code_New(
			CodeLen)
		VALUES(
			LEFT(@CodeRule_New, CHARINDEX(',', @CodeRule_New) - 1))
		SET @CodeRule_New = STUFF(@CodeRule_New, 1, CHARINDEX(',', @CodeRule_New), '')
	END

	-- 生成编号规则修改处理语句
	DECLARE
		@sql nvarchar(4000)
	SET @sql = N''
	SELECT
		@sql = @sql
				+ CASE 
					WHEN N.CodeLen = 0 THEN ''  -- 新编码长度为 0, 表示去掉这段编码
					ELSE N'
		+ CASE
				-- 不包含当前层次编码的记录不需要处理
				WHEN LEN(' + @FieldName + N') < ' + CAST(O.CodeLens as varchar) + N'
					THEN '''' 
				ELSE ' 
						+ CASE
							WHEN N.CodeLen = O.CodeLen THEN O.Code  --新旧编码长度相同时不需要处理
							WHEN N.CodeLen > O.CodeLen
								THEN CASE   -- 扩充编码长度的处理, 根据 @Position 和旧编码长度决定编码的填充位置
										WHEN @Position = -1 OR @Position >= O.CodeLen
										THEN O.Code + N' + ' + QUOTENAME(REPLICATE(@CharFill,N.CodeLen - O.CodeLen), N'''')
										ELSE N'STUFF(' + O.Code + N', ' + CAST(@Position + 1 as varchar)
												+ N', 0, ' + QUOTENAME(REPLICATE(@CharFill, N.CodeLen - O.CodeLen), N'''')
												+ N')'
									END
							ELSE CASE		-- 收缩编码长度的处理, 根据 @Position 和新编码长度决定编码的截取位置
									WHEN @Position = -1 OR @Position > N.CodeLen
									THEN N'LEFT(' + O.Code + N',' + CAST(N.CodeLen as varchar) + N')'
									ELSE N'STUFF(' + O.Code + N', ' + CAST(@Position + 1 as varchar)
											+ N', ' + CAST(O.CodeLen - N.CodeLen as varchar)
											+ N', '''')'
								END
							END
					+ N'
			END'
				END
	FROM @tb_Code_Old O, @tb_Code_New N
	WHERE O.ID = N.ID

	RETURN(
		STUFF(@sql, CHARINDEX(N'+', @sql), 1, N''))
END
GO



-- 调整编码规则的存储过程(需要与前面的函数配合使用)
CREATE PROC dbo.p_ChangeCodeRule
	@TableName    sysname,			-- 调整编码规则的表名
	@FieldName    sysname,			-- 编码字段名
	@CodeRule_Old varchar(50),		-- 以逗号分隔的旧的编码规则,每层编码的长度,比如 1, 2, 3, 表示有三层编码,第一层长度为 1, 第二层长度为 2, 第三层长度为 3
	@CodeRule_New varchar(50),		-- 以逗号分隔的旧的编码规则,如果某个层次的编码长度为 0,表示删除该层编码
	@CharFill     char(1) = '0',	-- 扩充编码时,填充的字符
	@Position     int = 0			-- 为 0, 从编码的最前面开始压缩或者填充,为 -1 或者大于旧编码的长度, 从最后一位开始处理,为其他值,从指定的位置后开始处理
AS
-- 参数检查
IF ISNULL(OBJECTPROPERTY(OBJECT_ID(@TableName), N'IsUserTable'), 0) = 0
BEGIN
	RAISERROR(N'"%s" 不存在,或者不是用户表',16, 1, @TableName)
	RETURN
END

IF NOT EXISTS(
		SELECT * FROM dbo.syscolumns
		WHERE ID = OBJECT_ID(@TableName)
			AND name = @FieldName)
BEGIN
	RAISERROR(N'列名 "%s" 在用户表 "%s" 中不存在',16, 1, @FieldName, @TableName)
	RETURN	
END

IF ISNULL(@CodeRule_Old, '') = '' 
	OR ISNULL(@CodeRule_New, '') = '' 
BEGIN
	RAISERROR(N'必须编码规则字符串', 16, 1)
	RETURN	
END

IF PATINDEX(N'%[^0-9^,]%', @CodeRule_Old) > 0
BEGIN
	RAISERROR(N'编码规则字符串 "%s" 中只能包含数字和逗号(,)', 16, 1, @CodeRule_Old)
	RETURN	
END
IF PATINDEX(N'%[^0-9^,]%', @CodeRule_New) > 0
BEGIN
	RAISERROR(N'编码规则字符串 "%s" 中只能包含数字和逗号(,)', 16, 1, @CodeRule_New)
	RETURN	
END

-- 调用函数 dbo.f_ChangeCodeRule 得到编码处理的 T-SQL 语句
DECLARE
	@s nvarchar(4000)
SET @s = dbo.f_ChangeCodeRule(@CodeRule_Old, @CodeRule_New, @CharFill, @Position, @FieldName)

-- 更新编码规则
EXEC(N'
BEGIN TRAN
-- 将处理后的编码与处理前的编码保存到临时表
SELECT 
	No_Old = ' + @FieldName + N',
	No_New = ' + @s + N'
INTO #
FROM ' + @TableName + N' WITH(XLOCK, TABLOCK)
-- 检查更新后的编码是否存在重复
IF EXISTS(
		SELECT 
			No_New
		FROM #
		GROUP BY No_New
		HAVING COUNT(*) > 1)
BEGIN
	-- 如果重复, 则显示会产生生理的编码
	SELECT * FROM # A
	WHERE EXISTS(
			SELECT * FROM #
			WHERE No_New = A.No_New
				AND No_Old <> A.No_Old)
	ORDER BY No_New, No_Old

	ROLLBACK TRAN
END
ELSE
BEGIN
	-- 如果编码处理后不重复, 则更新到编码表中
	UPDATE A SET
		' + @FieldName + N' = B.No_New
	FROM ' + @TableName + N' A, # B
	WHERE A.' + @FieldName + N' = B.No_Old

	COMMIT TRAN
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
UNION ALL     SELECT '305101'
UNION ALL     SELECT '6'
UNION ALL     SELECT '601'

-- b.1 调整编码规则 - 会导致重复
EXEC dbo.p_ChangeCodeRule
	@TableName = N'dbo.tb',
	@FieldName = N'No',
	@CodeRule_Old = '1,2,3',
	@CodeRule_New = N'3,2,2',
	@CharFill = '0',
	@Position = 0

-- b.2 调整编码规则 - 不会导致重复
EXEC dbo.p_ChangeCodeRule
	@TableName = N'dbo.tb',
	@FieldName = N'No',
	@CodeRule_Old = '1,2,3',
	@CodeRule_New = N'3,2,2',
	@CharFill = '0',
	@Position = 1

-- c. 显示结果
SELECT * FROM dbo.tb
DROP TABLE dbo.tb
GO

DROP PROC dbo.p_ChangeCodeRule
DROP FUNCTION dbo.f_ChangeCodeRule