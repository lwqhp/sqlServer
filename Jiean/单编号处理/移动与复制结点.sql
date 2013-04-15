-- �ƶ����߸��ƽ��
CREATE PROC dbo.p_Move_CopyCode
	@TableName  sysname,		-- �����������ı���
	@FieldName  sysname,		-- �����ֶ���
	@CodeRule   varchar(50),	-- �Զ��ŷָ��ı������ÿ�����ĳ��ȣ����� 1,2,3,��ʾ��������룬��һ�㳤��Ϊ 1���ڶ��㳤��Ϊ 2�������㳤��Ϊ 3
	@Code      varchar(50),		-- Ҫ���ƻ����ƶ��Ľڵ����
	@ParentCode varchar(50),	-- �ƶ����ñ���Ľڵ���
	@IsCopy    bit = 0			-- 0 Ϊ�ƶ�����, ����Ϊ���ƴ���
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

-- a. �����Ʊ�����ӱ������(�������������εı������)
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
	RAISERROR(N'���� "%s" �����ϱ������', 16, 1, @Code)
	RETURN
END
IF @CodeLen_Source IS NOT NULL
	SET @CodeRule_Source = RTRIM(@CodeLen_Source) + ',' + @CodeRule_Source
SET @CodeRule_Source = LEFT(@CodeRule_Source, LEN(@CodeRule_Source) - 1)

-- b. ���ƺ�ı�����ӱ������(�������������εı������)
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
	RAISERROR(N'���� "%s" �����ϱ������', 16, 1, @ParentCode)
	RETURN
END
IF @CodeRule_Destination = ''
BEGIN
	RAISERROR(N'�޷������ݸ��Ƶ�δ������ "%s" ����', 16, 1, @ParentCode)
	RETURN
END
SET @CodeRule_Destination = LEFT(@CodeRule_Destination, LEN(@CodeRule_Destination) - 1)

-- c. �������ת���� T-SQL
DECLARE
	@sql nvarchar(4000)
SET @sql = CASE
			-- ����¾ɱ�����򳤶�û�иı�, ����Ҫ��ת��
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

-- d. ���ƻ����ƶ�����
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
	-- �ƶ���㲻��Ҫ���Ҫ�ƶ��Ľڵ���ظ���
	AND ' + @FieldName + N' NOT LIKE ' + @value_Code + ' + ''%'''
			ELSE N''
		END,
	@sql_move_copy = CASE
			WHEN @IsCopy = 0 THEN N'
	-- �ƶ����Ĳ���
	UPDATE A SET
		' + @FieldName + N' = B.No_New
	FROM ' + @TableName + N' A, # B
	WHERE A.' + @FieldName + N' = B.No_Old
'
			ELSE N'
	-- ���ƽ��Ĳ���
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
-- a. ���Ŀ������Ƿ����
IF NOT EXISTS(
		SELECT * FROM ' + @TableName + N'
		WHERE ' + @FieldName + N' = ' + @value_CodeParent + N')
BEGIN
	RAISERROR(''����Ŀ����벻����'', 16, 1)
	RETURN
END

-- b. ����Ҫ����(���ƶ�)������±���
--BEGIN TRAN
	SELECT
		No_Old = ' + @FieldName + N',
		No_New = ' + @sql + '
	INTO #
	FROM ' + @TableName + N' WITH(XLOCK,TABLOCK)
	WHERE ' + @FieldName + N' LIKE ' + @value_Code + N' + ''%''

-- c. �����븴�Ƶ���Ч��
SELECT
	Error = N''�����ظ�'', *
INTO #check
FROM # A
WHERE EXISTS(
		SELECT * FROM #
		WHERE No_New = A.No_New
			AND No_Old <> A.No_Old)
UNION ALL
SELECT
	Error = N''���ƺ���������б����ظ�'', *
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
	-- ���ƻ����ƶ�����
	' + @sql_move_copy + N'
--	COMMIT TRAN
END
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
UNION ALL     SELECT '606'

-- b. ���ƽ��
EXEC dbo.p_Move_CopyCode
	@TableName = 'tb',
	@FieldName = 'No',
	@CodeRule  = '1,2,3',
	@Code = '305',
	@ParentCode = '1',
	@IsCopy = 1

-- c. ��ʾ���
SELECT * FROM tb
DROP TABLE tb
GO

--DROP PROC dbo.p_Move_CopyCode