CREATE PROC dbo.p_DeleteCode
	@TableName sysname,			-- �����������ı���
	@FieldName sysname,			-- �����ֶ���
	@CodeRule  varchar(50),		-- �Զ��ŷָ��ı������, ÿ�����ĳ���,���� 1,2,3,��ʾ���������,��һ�㳤��Ϊ 1,�ڶ��㳤��Ϊ 2,�����㳤��Ϊ 3
	@Code varchar(50)			-- Ҫɾ���Ľڵ����
AS
SET NOCOUNT ON
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

-- ���ɱ�ɾ�������ӽ����±������(��Ϊ�ӽ��Ҫ����һ��)
DECLARE
	@codelen int,
	@codelens int,
	@CodeRule_New varchar(50)
SELECT
	@codelens = LEN(@Code),
	@CodeRule_New = @CodeRule + ','
-- ��ȡ��ɾ���ı�������һ���ĳ���, �����ɸñ���֮��ı������
WHILE @CodeRule_New > '' AND @codelens > 0
	SELECT
		@codelen = LEFT(@CodeRule_New, CHARINDEX(',', @CodeRule_New) - 1),
		@CodeRule_New = STUFF(@CodeRule_New, 1, CHARINDEX(',', @CodeRule_New), ''),
		@codelens = @codelens - @codelen

-- ȷ��Ҫɾ���ı����Ƿ���ϱ������
IF @codelens <> 0
BEGIN
	RAISERROR(N'���� "%s" ������ָ���ı������ "%s" ', 16, 1, @Code, @CodeRule)
	RETURN
END

-- �����޸ı�ɾ������ӽ�������±������
SET @CodeRule_New = CASE
			WHEN @CodeRule_New = '' THEN @CodeRule
			-- ���ӽ�㱻ɾ���ı����ȥ��, �������Ĳ�����һ��
			ELSE STUFF(@CodeRule, 
					2 + LEN(@CodeRule) - CHARINDEX(',', REVERSE(@CodeRule) + ',', LEN(@CodeRule_New) + 2),
					0,
					'0,')
		END

-- �õ���ɾ������ӽ�������µ� T-SQL
DECLARE
	@sql nvarchar(4000)
SET @sql = dbo.f_ChangeCodeRule(@CodeRule, @CodeRule_New, '', 0, @FieldName)

-- ��鲢���ɾ������
DECLARE
	@value_code varchar(50),
	@value_code_child varchar(50)
SELECT
	@value_code = QUOTENAME(@Code, N''''),
	@value_code_child = QUOTENAME(@Code + N'_%', N'''')

EXEC(N'
BEGIN TRAN
-- �������ı����봦��ǰ�ı��뱣�浽��ʱ��
SELECT
	No_Old = ' + @FieldName + N',
	No_New = '+ @sql + N'
INTO #
FROM ' + @TableName + N' WITH(XLOCK,TABLOCK)
WHERE ' + @FieldName + N' LIKE ' + @value_code_child + N'

-- �����º�ı����Ƿ�����ظ�
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
-- �����º�ı����Ƿ���������еı����ظ�
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
	-- ������봦����ظ�,����µ��������
	DELETE FROM ' + @TableName + N'
	WHERE ' + @FieldName + N' = ' + @value_code + N'

	UPDATE A SET
		' + @FieldName + N' = B.No_New
	FROM ' + @TableName + N' A, # B
	WHERE A.' + @FieldName + N' = B.No_Old

	COMMIT TRAN
END')
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
UNION ALL     SELECT '606'

-- a. ɾ����� 305
EXEC dbo.p_DeleteCode
	@TableName = 'dbo.tb',
	@FieldName = 'No',
	@CodeRule  = '1,2,3',
	@Code = '305'

-- b. ɾ����� 3
EXEC dbo.p_DeleteCode
	@TableName = 'dbo.tb',
	@FieldName = 'No',
	@CodeRule  = '1,2,3',
	@Code = '3'

-- c. ��ʾ���ս��
SELECT * FROM tb
DROP TABLE tb
GO

--DROP PROC dbo.p_DeleteCode