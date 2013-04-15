CREATE PROC dbo.sp_PageView
	@tbname     sysname,				-- 要分页显示的表名
	@FieldKey   nvarchar(1000),			-- 用于定位记录的主键(惟一键)字段,可以是逗号分隔的多个字段
	@PageCurrent int = 1,				-- > 0 表示要显示的页码, = 0 表示仅清理缓存数据的临时表,不返回数据,其他值代表重建缓存数据的临时表
	@PageSize   int = 10,				-- 每页的大小(记录数)
	@FieldShow  nvarchar(1000) = N'',	-- 以逗号分隔的要显示的字段列表,如果不指定,则显示所有字段
	@Where     nvarchar(1000) = N'',	-- 查询条件
	@UserName  sysname = N'',			-- 调用查询的用户名
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
IF ISNULL(@PageSize, 0)< 1
	SET @PageSize = 10

IF ISNULL(@FieldShow, N'') = N''
	SET @FieldShow = N'*'

IF ISNULL(@Where, N'') = N''
	SET @Where = N''
ELSE
	SET @Where = N'WHERE (' + @Where + N')'

-- 分页数据缓存临时表状态检测
DECLARE
	@tempTable sysname,
	@TempField sysname,
	@TempTableDate datetime
-- a. 分页数据缓存临时表名
SET @tempTable = QUOTENAME(
					N'##'
					+ RTRIM(LEFT(HOST_NAME(), 50))
					+ N'_' + RTRIM(LEFT(CASE
											WHEN ISNULL(@UserName, N'') = N'' THEN SUSER_SNAME()
											ELSE @UserName
										END, 50))
					+ N'_' + RTRIM(@tbname))
-- b. 分页数据缓存临时表的标识列及创建日期(如果存在的话)
SELECT
	@TempField = QUOTENAME(C.name),
	@TempTableDate = DATEADD(Hour, 1, O.crdate) -- 分页数据缓存临时表的有效缓存时间为 1 小时,创建时间超过 1 小时会被重建
FROM tempdb.dbo.sysobjects O, tempdb.dbo.syscolumns C
WHERE O.id = C.id 
	AND O.id = OBJECT_ID(N'tempdb..' + @tempTable)
	AND C.status = 0x80

-- 如果检查到分页数据缓存临时表
IF @@ROWCOUNT > 0
	-- 如果需要删除分页数据缓存临时表, 或者分页数据缓存临时表创建时间超过一小时, 则执行删除操作
	IF ISNULL(@PageCurrent, 0) < 1 OR @TempTableDate < GETDATE()
	BEGIN
		EXEC('
DROP TABLE ' + @tempTable)

		IF @PageCurrent = 0  -- 如果仅需要删除分页数据缓存临时表, 则直接退出
			RETURN
	END
	ELSE  -- 如果 分页数据缓存临时表已经存在, 并且未过期, 则转到临时表已经建立好的部分继续处理
		GOTO lb_TempTable_Created
ELSE
	SELECT @TempField = QUOTENAME(NEWID())

-- 创建分页数据缓存临时表
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
-- 计算总页数
SET @PageCount = (@@ROWCOUNT + @PageSize - 1) / @PageSize
GOTO lb_ShowData

lb_TempTable_Created:
-- 对于使用已经存在的 分页数据缓存临时表 的情况, 检查总页数
-- 如果@PageCount为NULL值, 则计算总页数(这样设计可以只在第一次计算总页数,以后调用时,把总页数传回给存储过程,避免再次计算总页数,对于不想计算总页数的处理而言,可以给@PageCount赋值)
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

	-- 计算总页数
	SET @PageCount = (@PageCount + @PageSize - 1) / @PageSize
END

lb_ShowData:
-- 显示数据
IF ISNULL(@PageCurrent, 0) < 1
	SET @PageCurrent = 1

-- 计算分页显示的 开始和结束记录 id
DECLARE
	@id_start varchar(20),
	@id_stop varchar(20)
SELECT
	@id_stop = @PageCurrent * @PageSize,
	@id_start = @id_stop - @PageSize + 1

-- 生成主键(惟一键)处理条件
DECLARE
	@WhereJoin nvarchar(4000),
	@FieldKeys nvarchar(1000),
	@FieldKeyName sysname
SELECT
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

-- 执行查询
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
