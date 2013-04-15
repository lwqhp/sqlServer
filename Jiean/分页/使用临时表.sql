CREATE PROC dbo.sp_PageView
	@tbname     sysname,				-- Ҫ��ҳ��ʾ�ı���
	@FieldKey   sysname,				-- ���ڶ�λ��¼������(Ωһ��)�ֶ�,ֻ���ǵ����ֶ�
	@PageCurrent int = 1,				-- Ҫ��ʾ��ҳ��
	@PageSize   int = 10,				-- ÿҳ�Ĵ�С(��¼��)
	@FieldShow  nvarchar(1000) = N'',	-- �Զ��ŷָ���Ҫ��ʾ���ֶ��б�,�����ָ��,����ʾ�����ֶ�
	@FieldOrder  nvarchar(1000) = N'',	-- �Զ��ŷָ��������ֶ��б�,����ָ�����ֶκ���ָ�� DESC/ASC ����ָ������˳��
	@Where     nvarchar(1000) = N'',	-- ��ѯ����
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
IF ISNULL(@PageCurrent, 0)< 1
	SET @PageCurrent = 1

IF ISNULL(@PageSize, 0)< 1
	SET @PageSize = 10

IF ISNULL(@FieldShow, N'') = N''
	SET @FieldShow = N'*'

IF ISNULL(@FieldOrder, N'') = N''
	SET @FieldOrder = N''
ELSE
	SET @FieldOrder = N'ORDER BY ' + LTRIM(@FieldOrder)

IF ISNULL(@Where, N'') = N''
	SET @Where = N''
ELSE
	SET @Where = N'WHERE (' + @Where + N')'

-- ���@PageCountΪNULLֵ, �������ҳ��(������ƿ���ֻ�ڵ�һ�μ�����ҳ��,�Ժ����ʱ,����ҳ�����ظ��洢����,�����ٴμ�����ҳ��,���ڲ��������ҳ���Ĵ������,���Ը�@PageCount��ֵ)
IF @PageCount IS NULL
BEGIN
	-- ȡ��¼��
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

	-- ���ݼ�¼������ҳ��
	SET @PageCount = (@PageCount + @PageSize - 1) / @PageSize
END

-- ��һҳֱ����ʾ
IF @PageCurrent = 1
BEGIN
	SET ROWCOUNT @PageSize
	EXEC(N'
SELECT
	' + @FieldShow + N'
FROM ' + @tbname + N'
' + @Where + N'
' + @FieldOrder
	)
	SET ROWCOUNT 0
END
ELSE
BEGIN
	DECLARE
		@Rows_Start varchar(20),
		@Rows_Stop varchar(20),
		@WhereJoin nvarchar(4000),
		@FieldKeys nvarchar(1000),
		@FieldKeyName sysname
	SELECT
		@Rows_Stop = @PageSize * @PageCurrent, -- Ҫ��ѯ��ҳ���һ����¼���ڼ�¼�ļ�¼��
		@Rows_Start = @Rows_Stop - @PageSize,  -- Ҫ��ѯ��ҳ��ǰһҳ���һ����¼���ڼ�¼�ļ�¼��
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

	-- ��ѯ
	EXEC(N'
-- �����������ݵ���ʱ��
SET ROWCOUNT ' + @Rows_Stop + N'
SELECT ' + @FieldKey + N'
INTO #
FROM ' + @tbname + N'
' + @Where + N'
' + @FieldOrder + N'

-- ����ʱ����ɾ����ǰҳ֮ǰ��ҳ������¼
SET ROWCOUNT ' + @Rows_Start + N'
DELETE FROM #
SET ROWCOUNT 0

-- ������ʱ���Ի�ȡ��ѯ���
SELECT
	' + @FieldShow + N'
FROM ' + @tbname + N' A
WHERE EXISTS(
		SELECT * FROM # B
		WHERE ' + @WhereJoin + N'
	)
' + @FieldOrder
	)
END
GO
