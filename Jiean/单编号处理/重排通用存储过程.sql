-- 重排编码的存储过程
CREATE PROC dbo.p_RTaxisCode
	@TableName sysname,    -- 重排编码的表名
	@FieldName sysname,    -- 编码字段名
	@CodeRule varchar(100) -- 以逗号分隔的编码规则,每层编码的长度, 比如 1,2,3,表示有三层编码,第一层长度为 1,第二层长度为 2,第三层长度为 3
AS
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

-- 生成编码重排处理语句
DECLARE
	@sql nvarchar(4000),
	@code_len varchar(20),
	@code_lens varchar(20)
SELECT 
	@FieldName = QUOTENAME(@FieldName),
	@CodeRule= @CodeRule + ',',

	-- 获取一级编码长度
	@code_len = CONVERT(int, LEFT(@CodeRule, CHARINDEX(',', @CodeRule) - 1)),
	@code_lens = @code_len,
	@CodeRule = STUFF(@CodeRule, 1, CHARINDEX(',', @CodeRule), ''),

	-- 生成重排一级编码的 T-SQL 语句
	@sql = N'
	RIGHT(' + CONVERT(varchar(20), POWER(10, @code_len)) + N' + (
				SELECT
					COUNT(DISTINCT ' + @FieldName + N')
				FROM ' + @TableName + N'
				WHERE LEN(' + @FieldName + N') = ' + @code_len + N'
					AND ' + @FieldName+N' <= A.' + @FieldName + N'
			), ' + @code_len + N')'
WHILE @CodeRule > ''
BEGIN
	SELECT 
		@code_len = CONVERT(int, LEFT(@CodeRule, CHARINDEX(',', @CodeRule) - 1)),
		@sql = @sql + N'
	+ CASE
			WHEN LEN(' + @FieldName + N') > ' + @code_lens + N'
				THEN RIGHT(' + CONVERT(varchar(20), POWER(10, @code_len)) + N' + (
							SELECT
								COUNT(DISTINCT ' + @FieldName + N')
							FROM ' + @TableName + N'
							WHERE ' + @FieldName+N' LIKE LEFT(A.' + @FieldName+N', ' 
												+ @code_lens + N') + ' 
												+ QUOTENAME(REPLICATE(N'_', @code_len), N'''')
												+ N'
								AND ' + @FieldName+N' <= A.' + @FieldName + N'
						), ' + @code_len + N')
			ELSE ''''
		END',
		@code_lens = @code_lens + CONVERT(int, @code_len),
		@CodeRule = STUFF(@CodeRule, 1, CHARINDEX(',', @CodeRule), '')
END
EXEC(N'
UPDATE A SET 
	' + @FieldName + N' = ' + @sql + N'
FROM ' + @TableName + N' A
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
UNION ALL     SELECT '601'

-- b. 重排编码
EXEC dbo.p_RTaxisCode
	@TableName = 'dbo.tb',
	@FieldName = 'No',
	@CodeRule = '1,2,3'

-- c. 显示结果
SELECT * FROM dbo.tb
DROP TABLE dbo.tb
