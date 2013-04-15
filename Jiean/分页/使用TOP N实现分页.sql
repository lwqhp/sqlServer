IF OBJECT_ID(N'dbo.p_show') IS NOT NULL
	DROP PROCEDURE dbo.p_show
GO

/*--实现分页的通用存储过程

	显示指定表、视图、查询结果的第X页
	对于表中主键或标识列的情况,直接从原表取数查询，其它情况使用临时表的方法
	如果视图或查询结果中有主键,不推荐此方法
	如果使用查询语句,而且查询语句使用了order by,则查询语句必须包含top 语句

--*/

/*--调用示例
EXEC dbo.p_show 
	@QueryStr = N'tb',
	@PageSize = 5,
	@PageCurrent = 3,
	@FdShow = 'id, colid, name',
	@FdOrder = 'colid, name'
select id, colid from tb
order by colid, name


EXEC dbo.p_show 
	@QueryStr = N'
SELECT TOP 100 PERCENT 
	* 
FROM dbo.sysobjects
ORDER BY xtype',
	@PageSize = 5,
	@PageCurrent = 2,
	@FdShow = 'name, xtype',
	@FdOrder = 'xtype, name'
--*/
CREATE PROC dbo.p_show
	@QueryStr nvarchar(4000),		-- 表名、视图名、查询语句
	@PageSize int = 10,				-- 每页的大小(行数)
	@PageCurrent int = 1,			-- 要显示的页
	@FdShow nvarchar (4000) = N'',	-- 要显示的字段列表,如果查询结果不需要标识字段,需要指定此值,且不包含标识字段
	@FdOrder nvarchar (1000) = N''	-- 排序字段列表
AS
SET NOCOUNT ON
-- 1. 变量设置
-- 1.a 公共变量
DECLARE
	@Obj_ID int,		-- 对象ID
	@Id1 sysname,		-- 分页记录(对于使用临时表的分页方法, 则为临时表的记录 ID)
	@Id2 sysname

-- 1.b 用于表中有单主键(或唯一键), 或者临时表(数据来源于查询语句)
DECLARE
	@FdName sysname 	-- 表中的主键或临时表中的标识列名

-- 1.b 表中有复合主键的处理
DECLARE
	@strfd nvarchar(2000),		-- 复合主键列表
	@strjoin nvarchar(4000),	-- JOIN 连接条件
	@strwhere nvarchar(2000)	-- 查询条件

-- 2. 参数检查
SELECT
	@Obj_ID = OBJECT_ID(@QueryStr),  -- 获取 object id, 可以以此确定数据来源于查询语句还是数据库中的对象
	@FdShow = CASE 
					WHEN @FdShow > N'' THEN N' ' + @FdShow
					ELSE N' *'
				END,
	@FdOrder = CASE
					WHEN @FdOrder > N'' THEN N' ORDER BY ' + @FdOrder
					ELSE N' ' 
				END,
	@QueryStr = CASE  -- 如果数据来源于查询语句, 则封装子查询
					WHEN @Obj_ID IS NULL THEN N' (' + @QueryStr + N')A'
					ELSE N' ' + @QueryStr
				END

-- 3. 分页处理
-- a. 如果显示第一页，可以直接用 top 来完成
IF @PageCurrent = 1	
BEGIN
	SELECT 
		@Id1 = CAST(@PageSize as varchar(20))
	EXEC(N'
SELECT TOP ' + @Id1 + N'
	' + @FdShow + N'
FROM ' + @QueryStr + N'
' + @FdOrder
)
	RETURN
END

-- b. 确定数据来源确定处理方法
--    如果数据来源不是表, 则使用临时表的处理方法
IF @Obj_ID IS NULL OR OBJECTPROPERTY(@Obj_ID, 'IsTable') = 0
	GOTO lb_usetemp
ELSE
BEGIN
-- 如果数据来源是表, 则检查表中是否有记录定位的列(主键或者标识列)
	-- 分页记录
	SELECT
		@Id1 = CAST(@PageSize as varchar(20)),
		@Id2 = CAST((@PageCurrent - 1) * @PageSize as varchar(20))

	-- 检查标识列
	SELECT
		@FdName = name
	FROM dbo.syscolumns
	WHERE id = @Obj_ID
		AND status = 0x80
	IF @@ROWCOUNT = 0 -- 如果表中无标识列,则检查表中是否有主键
	BEGIN
		DECLARE
			@pk_number int

		SELECT
			@strfd = N'',
			@strjoin = N'',
			@strwhere = N''

		-- 检查主键
		SELECT
			-- 主键列表
			@strfd = @strfd 
					+ N',' + QUOTENAME(name),
			-- 主键 JOIN 条件
			@strjoin = @strjoin 
					+ N' AND A.' + QUOTENAME(name) 
					+ N' = B.' +  QUOTENAME(name),
			-- 主键过滤条件
			@strwhere = @strwhere 
					+ N' AND B.' + QUOTENAME(name) + N' IS NULL'
		FROM(
			SELECT
				IX.id, IX.indid,
				IXC.colid, ixc.keyno,
				C.name
			FROM dbo.sysobjects O, 
				dbo.sysindexes IX,
				dbo.sysindexkeys IXC,
				dbo.syscolumns C
			WHERE O.parent_obj = @Obj_ID
				AND O.xtype = 'PK'
				AND O.name = IX.name
				AND IX.id = @Obj_ID
				AND IX.id = IXC.id
				AND IX.indid = IXC.indid
				AND IXC.id = C.id
				AND IXC.colid = C.colid
		)A
		ORDER BY keyno

		SELECT
			@pk_number = @@ROWCOUNT,			
			@strfd = STUFF(@strfd, 1, 1, N''),
			@strjoin = STUFF(@strjoin, 1, 5, N''),
			@strwhere = STUFF(@strwhere, 1, 5, N'')			

		-- 确定是否有主键, 主键是单一的, 还是复合的, 并做相应的处理
		IF @pk_number = 0
			GOTO lb_usetemp		--如果表中无主键,则用临时表处理
		ELSE IF @pk_number = 1
		BEGIN
			SELECT
				@FdName = @strfd
			GOTO lb_useidentity	-- 使用单一主键
		END
		ELSE
			GOTO lb_usepk		-- 使用复合主键
	END
END

/*-- 使用标识列或主键为单一字段的处理方法 --*/
lb_useidentity:	
EXEC(N'
SELECT TOP ' + @Id1 + N'
	' + @FdShow + N'
FROM '+@QueryStr + N'
WHERE ' + @FdName + ' NOT IN(
		SELECT TOP ' + @Id2 + N'
			' + @FdName + '
		FROM ' + @QueryStr + N'
		' + @FdOrder + N')
' + @FdOrder + N'
')
RETURN

/*-- 表中有复合主键的处理方法 --*/
lb_usepk:		
EXEC(N'
SELECT 
	' + @FdShow + N'
FROM(
	SELECT TOP ' + @Id1 + N'
		A.*
	FROM ' + @QueryStr + N' A
		LEFT JOIN(
				SELECT TOP ' + @Id2 + N'
					' + @strfd + N' 
				FROM ' + @QueryStr + N'
				' + @FdOrder + N'
			)B
				ON ' + @strjoin + N'
	WHERE ' + @strwhere + N'
	' + @FdOrder + N'
)A
' + @FdOrder + N'
')
RETURN

/*-- 用临时表处理的方法 --*/
lb_usetemp:		
SELECT
	-- 附加的标识列名(用于定位记录)
	@FdName = QUOTENAME(N'ID_' + CAST(NEWID() as varchar(40))),
	@Id1 = CAST(@PageSize * (@PageCurrent-1) as varchar(20)),
	@Id2 = CAST(@PageSize * @PageCurrent-1 as varchar(20))

EXEC(N'
SELECT 
	' + @FdName + N' = IDENTITY(int, 0, 1),
	' + @FdShow + N'
INTO #tb
FROM(
	SELECT TOP 100 PERCENT 
		* 
	FROM ' + @QueryStr + N'
	' + @FdOrder + N'
)A
' + @FdOrder + N'

SELECT 
	' + @FdShow + N'
FROM #tb 
WHERE ' + @FdName + ' BETWEEN ' + @Id1 + ' AND ' + @Id2 + N'
'
)
GO
