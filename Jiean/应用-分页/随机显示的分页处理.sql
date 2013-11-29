CREATE PROC dbo.sp_PageView
	@tbname     sysname,				-- Ҫ��ҳ��ʾ�ı���
	@FieldKey   nvarchar(1000),			-- ���ڶ�λ��¼������(Ωһ��)�ֶ�,�����Ƕ��ŷָ��Ķ���ֶ�
	@PageCurrent int = 1,				-- > 0 ��ʾҪ��ʾ��ҳ��, = 0 ��ʾ�����������ݵ���ʱ��,����������,����ֵ�����ؽ��������ݵ���ʱ��
	@PageSize   int = 10,				-- ÿҳ�Ĵ�С(��¼��)
	@FieldShow  nvarchar(1000) = N'',	-- �Զ��ŷָ���Ҫ��ʾ���ֶ��б�,�����ָ��,����ʾ�����ֶ�
	@Where     nvarchar(1000) = N'',	-- ��ѯ����
	@UserName  sysname = N'',			-- ���ò�ѯ���û���
	@PageCount  int OUTPUT				-- ��ҳ��
AS
SET NOCOUNT ON
DECLARE
	@sql nvarchar(4000)
--�������Ƿ���Ч
IF OBJECT_ID(@tbname) IS NULL
BEGIN
	RAISERROR(N'����"%s"������', 16, 0, @tbname)
	RETURN
END
IF OBJECTPROPERTY(OBJECT_ID(@tbname), N'IsTable') = 0
	AND OBJECTPROPERTY(OBJECT_ID(@tbname), N'IsView') = 0
	AND OBJECTPROPERTY(OBJECT_ID(@tbname), N'IsTableFunction') = 0
BEGIN
	RAISERROR(N'"%s"���Ǳ���ͼ���߱�ֵ����', 16, 0, @tbname)
	RETURN
END

-- ��ҳ�ֶμ��
IF ISNULL(@FieldKey, N'') = ''
BEGIN
	RAISERROR(N'��ҳ������Ҫ����������Ωһ����',16, 0)
	RETURN
END

-- ����������鼰�淶
IF ISNULL(@PageSize, 0)< 1
	SET @PageSize = 10

IF ISNULL(@FieldShow, N'') = N''
	SET @FieldShow = N'*'

IF ISNULL(@Where, N'') = N''
	SET @Where = N''
ELSE
	SET @Where = N'WHERE (' + @Where + N')'

-- ��ҳ���ݻ�����ʱ��״̬���
DECLARE
	@tempTable sysname,
	@TempField sysname,
	@TempTableDate datetime
-- a. ��ҳ���ݻ�����ʱ����
SET @tempTable = QUOTENAME(
					N'##'
					+ RTRIM(LEFT(HOST_NAME(), 50))
					+ N'_' + RTRIM(LEFT(CASE
											WHEN ISNULL(@UserName, N'') = N'' THEN SUSER_SNAME()
											ELSE @UserName
										END, 50))
					+ N'_' + RTRIM(@tbname))
-- b. ��ҳ���ݻ�����ʱ��ı�ʶ�м���������(������ڵĻ�)
SELECT
	@TempField = QUOTENAME(C.name),
	@TempTableDate = DATEADD(Hour, 1, O.crdate) -- ��ҳ���ݻ�����ʱ�����Ч����ʱ��Ϊ 1 Сʱ,����ʱ�䳬�� 1 Сʱ�ᱻ�ؽ�
FROM tempdb.dbo.sysobjects O, tempdb.dbo.syscolumns C
WHERE O.id = C.id 
	AND O.id = OBJECT_ID(N'tempdb..' + @tempTable)
	AND C.status = 0x80

-- �����鵽��ҳ���ݻ�����ʱ��
IF @@ROWCOUNT > 0
	-- �����Ҫɾ����ҳ���ݻ�����ʱ��, ���߷�ҳ���ݻ�����ʱ����ʱ�䳬��һСʱ, ��ִ��ɾ������
	IF ISNULL(@PageCurrent, 0) < 1 OR @TempTableDate < GETDATE()
	BEGIN
		EXEC('
DROP TABLE ' + @tempTable)

		IF @PageCurrent = 0  -- �������Ҫɾ����ҳ���ݻ�����ʱ��, ��ֱ���˳�
			RETURN
	END
	ELSE  -- ��� ��ҳ���ݻ�����ʱ���Ѿ�����, ����δ����, ��ת����ʱ���Ѿ������õĲ��ּ�������
		GOTO lb_TempTable_Created
ELSE
	SELECT @TempField = QUOTENAME(NEWID())

-- ������ҳ���ݻ�����ʱ��
EXEC(N'
SELECT
	*,
	IDENTITY(decimal(38, 0), 1, 1) as ' + @TempField + N'
INTO ' + @tempTable + N'
FROM(
	SELECT TOP 100 PERCENT
		' + @FieldKey + N'
	FROM ' + @tbname + N'
	' + @Where + N'
	ORDER BY NEWID()
)A
')
-- ������ҳ��
SET @PageCount = (@@ROWCOUNT + @PageSize - 1) / @PageSize
GOTO lb_ShowData

lb_TempTable_Created:
-- ����ʹ���Ѿ����ڵ� ��ҳ���ݻ�����ʱ�� �����, �����ҳ��
-- ���@PageCountΪNULLֵ, �������ҳ��(������ƿ���ֻ�ڵ�һ�μ�����ҳ��,�Ժ����ʱ,����ҳ�����ظ��洢����,�����ٴμ�����ҳ��,���ڲ��������ҳ���Ĵ������,���Ը�@PageCount��ֵ)
IF @PageCount IS NULL
BEGIN
	SET @sql = N'
SELECT
	@PageCount = COUNT(*)
FROM ' + @tbname + N'
' + @Where

	EXEC sp_executesql
		@sql,
		N'
			@PageCount int OUTPUT
		',
		@PageCount OUTPUT

	-- ������ҳ��
	SET @PageCount = (@PageCount + @PageSize - 1) / @PageSize
END

lb_ShowData:
-- ��ʾ����
IF ISNULL(@PageCurrent, 0) < 1
	SET @PageCurrent = 1

-- �����ҳ��ʾ�� ��ʼ�ͽ�����¼ id
DECLARE
	@id_start varchar(20),
	@id_stop varchar(20)
SELECT
	@id_stop = @PageCurrent * @PageSize,
	@id_start = @id_stop - @PageSize + 1

-- ��������(Ωһ��)��������
DECLARE
	@WhereJoin nvarchar(4000),
	@FieldKeys nvarchar(1000),
	@FieldKeyName sysname
SELECT
	@WhereJoin = N'',
	@FieldKeys = @FieldKey + N','
-- ��������(Ωһ��)��������
WHILE @FieldKeys > N''
	SELECT
		@FieldKeyName = LTRIM(RTRIM(LEFT(@FieldKeys, CHARINDEX(N',', @FieldKeys) - 1))),
		@FieldKeys = STUFF(@FieldKeys, 1, CHARINDEX(N',', @FieldKeys), N''),
		@WhereJoin = @WhereJoin
			+ N' AND A.' + @FieldKeyName + N' = B.' + @FieldKeyName
SET @WhereJoin = STUFF(@WhereJoin, 1, 5, N'')

-- ִ�в�ѯ
EXEC(N'
SELECT
	' + @FieldShow + N'
FROM ' + @tbname + N' A
WHERE EXISTS(
		SELECT * FROM ' + @tempTable + N' B
		WHERE B.' + @TempField + N'
				BETWEEN ' + @id_start + N' AND ' + @id_stop + N'
			AND(
				' + @WhereJoin + N'
				)
	)
')
GO
