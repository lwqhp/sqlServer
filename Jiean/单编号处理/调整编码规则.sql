-- ���ɱ����������� �������  T-SQL 
CREATE FUNCTION dbo.f_ChangeCodeRule(
	@CodeRule_Old  varchar(50),		-- �Զ��ŷָ��ľɵı������, ÿ�����ĳ���. ���� 1, 2, 3, ��ʾ���������,��һ�㳤��Ϊ 1, �ڶ��㳤��Ϊ 2, �����㳤��Ϊ 3
	@CodeRule_New varchar(50),		-- �Զ��ŷָ��ľɵı������, ���ĳ����εı��볤��Ϊ 0, ��ʾɾ���ò����
	@CharFill       char(1),		-- �������ʱ,�����ַ�
	@Position       int,			-- Ϊ 0, �ӱ������ǰ�濪ʼѹ���������, Ϊ -1 ���ߴ��ھɱ���ĳ���, �����һλ��ʼ����, Ϊ����ֵ, ��ָ����λ�ú�ʼ����
	@FieldName     sysname			-- �����ֶ���
)RETURNS nvarchar(4000)
AS
BEGIN
	IF ISNULL(@CharFill, '') = ''
		SET @CharFill = '0'

	-- �����������Ϊ��
	-- a. ��־ɵı������
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
			-- ȡ��ǰ��α���� T-SQL ���
			N'SUBSTRING(' + @FieldName + N', ' + RTRIM(@CodeLens) + N', ' + RTRIM(@CodeLen) + N')')
		SET @CodeLens = @CodeLens + CONVERT(int, @CodeLen)
	END

	-- b. ����µı������
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

	-- ���ɱ�Ź����޸Ĵ������
	DECLARE
		@sql nvarchar(4000)
	SET @sql = N''
	SELECT
		@sql = @sql
				+ CASE 
					WHEN N.CodeLen = 0 THEN ''  -- �±��볤��Ϊ 0, ��ʾȥ����α���
					ELSE N'
		+ CASE
				-- ��������ǰ��α���ļ�¼����Ҫ����
				WHEN LEN(' + @FieldName + N') < ' + CAST(O.CodeLens as varchar) + N'
					THEN '''' 
				ELSE ' 
						+ CASE
							WHEN N.CodeLen = O.CodeLen THEN O.Code  --�¾ɱ��볤����ͬʱ����Ҫ����
							WHEN N.CodeLen > O.CodeLen
								THEN CASE   -- ������볤�ȵĴ���, ���� @Position �;ɱ��볤�Ⱦ�����������λ��
										WHEN @Position = -1 OR @Position >= O.CodeLen
										THEN O.Code + N' + ' + QUOTENAME(REPLICATE(@CharFill,N.CodeLen - O.CodeLen), N'''')
										ELSE N'STUFF(' + O.Code + N', ' + CAST(@Position + 1 as varchar)
												+ N', 0, ' + QUOTENAME(REPLICATE(@CharFill, N.CodeLen - O.CodeLen), N'''')
												+ N')'
									END
							ELSE CASE		-- �������볤�ȵĴ���, ���� @Position ���±��볤�Ⱦ�������Ľ�ȡλ��
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



-- �����������Ĵ洢����(��Ҫ��ǰ��ĺ������ʹ��)
CREATE PROC dbo.p_ChangeCodeRule
	@TableName    sysname,			-- �����������ı���
	@FieldName    sysname,			-- �����ֶ���
	@CodeRule_Old varchar(50),		-- �Զ��ŷָ��ľɵı������,ÿ�����ĳ���,���� 1, 2, 3, ��ʾ���������,��һ�㳤��Ϊ 1, �ڶ��㳤��Ϊ 2, �����㳤��Ϊ 3
	@CodeRule_New varchar(50),		-- �Զ��ŷָ��ľɵı������,���ĳ����εı��볤��Ϊ 0,��ʾɾ���ò����
	@CharFill     char(1) = '0',	-- �������ʱ,�����ַ�
	@Position     int = 0			-- Ϊ 0, �ӱ������ǰ�濪ʼѹ���������,Ϊ -1 ���ߴ��ھɱ���ĳ���, �����һλ��ʼ����,Ϊ����ֵ,��ָ����λ�ú�ʼ����
AS
-- �������
IF ISNULL(OBJECTPROPERTY(OBJECT_ID(@TableName), N'IsUserTable'), 0) = 0
BEGIN
	RAISERROR(N'"%s" ������,���߲����û���',16, 1, @TableName)
	RETURN
END

IF NOT EXISTS(
		SELECT * FROM dbo.syscolumns
		WHERE ID = OBJECT_ID(@TableName)
			AND name = @FieldName)
BEGIN
	RAISERROR(N'���� "%s" ���û��� "%s" �в�����',16, 1, @FieldName, @TableName)
	RETURN	
END

IF ISNULL(@CodeRule_Old, '') = '' 
	OR ISNULL(@CodeRule_New, '') = '' 
BEGIN
	RAISERROR(N'�����������ַ���', 16, 1)
	RETURN	
END

IF PATINDEX(N'%[^0-9^,]%', @CodeRule_Old) > 0
BEGIN
	RAISERROR(N'��������ַ��� "%s" ��ֻ�ܰ������ֺͶ���(,)', 16, 1, @CodeRule_Old)
	RETURN	
END
IF PATINDEX(N'%[^0-9^,]%', @CodeRule_New) > 0
BEGIN
	RAISERROR(N'��������ַ��� "%s" ��ֻ�ܰ������ֺͶ���(,)', 16, 1, @CodeRule_New)
	RETURN	
END

-- ���ú��� dbo.f_ChangeCodeRule �õ����봦��� T-SQL ���
DECLARE
	@s nvarchar(4000)
SET @s = dbo.f_ChangeCodeRule(@CodeRule_Old, @CodeRule_New, @CharFill, @Position, @FieldName)

-- ���±������
EXEC(N'
BEGIN TRAN
-- �������ı����봦��ǰ�ı��뱣�浽��ʱ��
SELECT 
	No_Old = ' + @FieldName + N',
	No_New = ' + @s + N'
INTO #
FROM ' + @TableName + N' WITH(XLOCK, TABLOCK)
-- �����º�ı����Ƿ�����ظ�
IF EXISTS(
		SELECT 
			No_New
		FROM #
		GROUP BY No_New
		HAVING COUNT(*) > 1)
BEGIN
	-- ����ظ�, ����ʾ���������ı���
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
	-- ������봦����ظ�, ����µ��������
	UPDATE A SET
		' + @FieldName + N' = B.No_New
	FROM ' + @TableName + N' A, # B
	WHERE A.' + @FieldName + N' = B.No_Old

	COMMIT TRAN
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
UNION ALL     SELECT '305101'
UNION ALL     SELECT '6'
UNION ALL     SELECT '601'

-- b.1 ����������� - �ᵼ���ظ�
EXEC dbo.p_ChangeCodeRule
	@TableName = N'dbo.tb',
	@FieldName = N'No',
	@CodeRule_Old = '1,2,3',
	@CodeRule_New = N'3,2,2',
	@CharFill = '0',
	@Position = 0

-- b.2 ����������� - ���ᵼ���ظ�
EXEC dbo.p_ChangeCodeRule
	@TableName = N'dbo.tb',
	@FieldName = N'No',
	@CodeRule_Old = '1,2,3',
	@CodeRule_New = N'3,2,2',
	@CharFill = '0',
	@Position = 1

-- c. ��ʾ���
SELECT * FROM dbo.tb
DROP TABLE dbo.tb
GO

DROP PROC dbo.p_ChangeCodeRule
DROP FUNCTION dbo.f_ChangeCodeRule