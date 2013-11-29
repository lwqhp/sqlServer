-- ���ű���Ĵ洢����
CREATE PROC dbo.p_RTaxisCode
	@TableName sysname,    -- ���ű���ı���
	@FieldName sysname,    -- �����ֶ���
	@CodeRule varchar(100) -- �Զ��ŷָ��ı������,ÿ�����ĳ���, ���� 1,2,3,��ʾ���������,��һ�㳤��Ϊ 1,�ڶ��㳤��Ϊ 2,�����㳤��Ϊ 3
AS
-- �������
IF ISNULL(OBJECTPROPERTY(OBJECT_ID(@TableName), N'IsUserTable'), 0) = 0
BEGIN
	RAISERROR(N'"%s"������,���߲����û���', 16, 1, @TableName)
	RETURN
END

IF NOT EXISTS(
		SELECT * FROM dbo.syscolumns
		WHERE ID = OBJECT_ID(@TableName)
			AND name = @FieldName)
BEGIN
	RAISERROR(N'���� "%s" ���û��� "%s" �в�����', 16, 1, @FieldName, @TableName)
	RETURN	
END

IF ISNULL(@CodeRule, '') = ''
BEGIN
	RAISERROR(N'�����������ַ���', 16, 1)
	RETURN	
END

IF PATINDEX(N'%[^0-9^,]%', @CodeRule) > 0
BEGIN
	RAISERROR(N'��������ַ��� "%s" ��ֻ�ܰ������ֺͶ���(,)', 16, 1, @CodeRule)
	RETURN	
END

-- ���ɱ������Ŵ������
DECLARE
	@sql nvarchar(4000),
	@code_len varchar(20),
	@code_lens varchar(20)
SELECT 
	@FieldName = QUOTENAME(@FieldName),
	@CodeRule= @CodeRule + ',',

	-- ��ȡһ�����볤��
	@code_len = CONVERT(int, LEFT(@CodeRule, CHARINDEX(',', @CodeRule) - 1)),
	@code_lens = @code_len,
	@CodeRule = STUFF(@CodeRule, 1, CHARINDEX(',', @CodeRule), ''),

	-- ��������һ������� T-SQL ���
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


-- ����ʾ��
-- a. �������ݱ�
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

-- b. ���ű���
EXEC dbo.p_RTaxisCode
	@TableName = 'dbo.tb',
	@FieldName = 'No',
	@CodeRule = '1,2,3'

-- c. ��ʾ���
SELECT * FROM dbo.tb
DROP TABLE dbo.tb
