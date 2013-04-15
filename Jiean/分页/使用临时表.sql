CREATE PROC dbo.sp_PageView
	@tbname     sysname,				-- 要分页显示的表名
	@FieldKey   sysname,				-- 用于定位记录的主键(惟一键)字段,只能是单个字段
	@PageCurrent int = 1,				-- 要显示的页码
	@PageSize   int = 10,				-- 每页的大小(记录数)
	@FieldShow  nvarchar(1000) = N'',	-- 以逗号分隔的要显示的字段列表,如果不指定,则显示所有字段
	@FieldOrder  nvarchar(1000) = N'',	-- 以逗号分隔的排序字段列表,可以指定在字段后面指定 DESC/ASC 用于指定排序顺序
	@Where     nvarchar(1000) = N'',	-- 查询条件
	@PageCount  int OUTPUT				-- 总页数
AS
SET NOCOUNT ON
DECLARE
	@sql nvarchar(4000)
--检查对象是否有效
IF OBJECT_ID(@tbname) IS NULL
BEGIN
	RAISERROR(N'对象"%s"不存在', 16, 0, @tbname)
	RETURN
END
IF OBJECTPROPERTY(OBJECT_ID(@tbname), N'IsTable') = 0
	AND OBJECTPROPERTY(OBJECT_ID(@tbname), N'IsView') = 0
	AND OBJECTPROPERTY(OBJECT_ID(@tbname), N'IsTableFunction') = 0
BEGIN
	RAISERROR(N'"%s"不是表、视图或者表值函数', 16, 0, @tbname)
	RETURN
END

-- 分页字段检查
IF ISNULL(@FieldKey, N'') = ''
BEGIN
	RAISERROR(N'分页处理需要主键（或者惟一键）',16, 0)
	RETURN
END

-- 其他参数检查及规范
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

-- 如果@PageCount为NULL值, 则计算总页数(这样设计可以只在第一次计算总页数,以后调用时,把总页数传回给存储过程,避免再次计算总页数,对于不想计算总页数的处理而言,可以给@PageCount赋值)
IF @PageCount IS NULL
BEGIN
	-- 取记录数
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

	-- 根据记录数计算页数
	SET @PageCount = (@PageCount + @PageSize - 1) / @PageSize
END

-- 第一页直接显示
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
		@Rows_Stop = @PageSize * @PageCurrent, -- 要查询的页最后一条记录所在记录的记录数
		@Rows_Start = @Rows_Stop - @PageSize,  -- 要查询的页的前一页最后一条记录所在记录的记录数
		@WhereJoin = N'',
		@FieldKeys = @FieldKey + N','
	-- 生成主键(惟一键)过滤条件
	WHILE @FieldKeys > N''
		SELECT
			@FieldKeyName = LTRIM(RTRIM(LEFT(@FieldKeys, CHARINDEX(N',', @FieldKeys) - 1))),
			@FieldKeys = STUFF(@FieldKeys, 1, CHARINDEX(N',', @FieldKeys), N''),
			@WhereJoin = @WhereJoin
				+ N' AND A.' + @FieldKeyName + N' = B.' + @FieldKeyName
	SET @WhereJoin = STUFF(@WhereJoin, 1, 5, N'')

	-- 查询
	EXEC(N'
-- 生成主键数据到临时表
SET ROWCOUNT ' + @Rows_Stop + N'
SELECT ' + @FieldKey + N'
INTO #
FROM ' + @tbname + N'
' + @Where + N'
' + @FieldOrder + N'

-- 从临时表中删除当前页之前的页主键记录
SET ROWCOUNT ' + @Rows_Start + N'
DELETE FROM #
SET ROWCOUNT 0

-- 关联临时表以获取查询结果
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
