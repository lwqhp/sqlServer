CREATE PROC dbo.p_VerifyData
	@TableName     sysname,		-- ҪУ���������ݵı�
	@CodeField      sysname,	-- �����ֶ���
	@ParentCodeField sysname	-- �ϼ������ֶ���
AS
SET NOCOUNT ON
-- �������
IF ISNULL(OBJECTPROPERTY(OBJECT_ID(@TableName), N'IsUserTable'), 0) = 0
BEGIN
	RAISERROR(N'"%s" ������,���߲����û���', 16, 1, @TableName)
	RETURN
END
IF NOT EXISTS(
		SELECT * FROM dbo.syscolumns
		WHERE ID = OBJECT_ID(@TableName)
			AND name = @CodeField)
BEGIN
	RAISERROR(N'�� "%s" ���û��� "%s "�в�����', 16, 1, @CodeField, @TableName)
	RETURN	
END
IF NOT EXISTS(
		SELECT * FROM dbo.syscolumns
		WHERE ID = OBJECT_ID(@TableName)
			AND name = @ParentCodeField)
BEGIN
	RAISERROR(N'�� "%s" ���û��� "%s" �в�����', 16, 1, @ParentCodeField, @TableName)
	RETURN	
END

-- ���ݼ��
EXEC(N'
-- ��鵼��ѭ���Ľ��
DECLARE
	@Level int
SET @Level = 1
SELECT
	ID, PID,
	Path = CAST(ID as varchar(8000)),
	Level = @Level
INTO #
FROM(-- �г����и���㲻�Ǹ���������(ʹ���Ӳ�ѯ�Ƿ�ֹ������Ϊ IDENTITY ��ʱ,���º���Ĳ��봦�����)
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

-- ��ʾ���
SELECT
	' + @CodeField + N',
	Description = N''�������Ч'' 
FROM ' + @TableName + N' A
WHERE ' + @ParentCodeField + N' IS NOT NULL
	AND NOT EXISTS(
			SELECT * FROM ' + @TableName + N'
			WHERE ' + @CodeField + N' = A.' + @ParentCodeField + N')
UNION ALL -- ��ʾ����ѭ���Ľ��
SELECT
	ID,
	N''ѭ��:'' + Path + ''>'' + CAST(ID as varchar(8000))
FROM #
WHERE ID = PID
')
GO
