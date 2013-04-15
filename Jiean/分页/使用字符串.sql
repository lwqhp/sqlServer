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
	-- ��ȡҪ��ѯ��ҳ��������ֵ
	DECLARE
		@KeyValues nvarchar(4000)
	SELECT
		@sql=N'
-- ֻ��ѯ @PageSize * @PageCurrent ����¼
DECLARE
	@rows int
SELECT @rows = @PageSize * @PageCurrent

SET ROWCOUNT @rows
SELECT
	@rows = @rows - 1,
	@KeyValues = CASE
			WHEN @rows < @PageSize  -- �����ѯʣ��ļ�¼��С��ҳ�Ĵ�С, ��˵����ǰ��¼��Ҫ��ѯ��ҳ��
				THEN @KeyValues + N'','' 
					+ CONVERT(varchar(8000), QUOTENAME(RTRIM(' + @FieldKey + N'), N''''''''))
			ELSE N''''
		END
FROM ' + @tbname + N'
' + @Where + N'
' + @FieldOrder + N'
SET ROWCOUNT 0
'

	EXEC sp_executesql
		@sql,
		N'
			@PageSize int,
			@PageCurrent int,
			@KeyValues nvarchar(4000) OUTPUT
		',
		@PageSize, @PageCurrent, @KeyValues OUTPUT
	
	-- ���Ҫ��ѯ��ҳû�м�¼(�����������ҳ��), ����ʾ�ܹ�
	IF @KeyValues = N''
		EXEC(N'
SELECT TOP 0
	' + @FieldShow + N'
FROM ' + @tbname)
	ELSE
	BEGIN
		SET @KeyValues = STUFF(@KeyValues, 1, 1, N'')		
		--ִ�в�ѯ
		SET ROWCOUNT @PageSize
		EXEC(N'
SELECT
	' + @FieldShow + N'
FROM ' + @tbname + N'
WHERE ' + @FieldKey + N' IN(
	' + @KeyValues + N'
	)
' + @FieldOrder)
		SET ROWCOUNT 0
	END
END
GO
