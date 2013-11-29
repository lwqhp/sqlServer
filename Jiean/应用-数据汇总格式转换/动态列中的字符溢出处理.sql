DECLARE
	@sql_head nvarchar(4000),
	@sql_end nvarchar(4000),
	@sql_body nvarchar(4000),
	@sql_variable_definition nvarchar(4000),
	@sql_variable_init nvarchar(4000),
	@sql_variable_set nvarchar(4000),
	@groups varchar(20)

-- a. 生成数据处理临时表
SELECT
	id = IDENTITY(int, 0, 1),
	g = 0,
	fd = CONVERT(nvarchar(4000),
			N', ' + QUOTENAME(name)
			+ N' =SUM(CASE name WHEN N' + QUOTENAME(name, N'''')
			+ N' THEN 1 END)')
INTO #
FROM dbo.syscolumns
WHERE name > N''
GROUP BY name

-- b. 分组临时表
UPDATE A SET
	@groups = id / i,
	g = @groups	
FROM # A
	CROSS JOIN(
		-- 每个变量能够处理的name 个数
		SELECT
			i = 3800 / MAX(LEN(fd))
		FROM #
	)B

-- c. 生成数据处理语句
SELECT
	-- 交叉报表 T-SQL 的头部, 因为要被再次接接, 所以要对里面的字符串边界符(')做处理
	@sql_head=N''''
		+ REPLACE(N'
SELECT
	xtype
', N'''', N'''''')
		+'''',
	-- 交叉报表 T-SQL 的尾部分, 因为要被再次接接, 所以要对里面的字符串边界符(')做处理
	@sql_end = N''''
		+ REPLACE(N'
FROM dbo.syscolumns
GROUP BY xtype
', N'''', N'''''')
		+ N'''',

	@sql_variable_definition = N'',
	@sql_variable_init = N'',
	@sql_variable_set = N'',
	@sql_body = N''
WHILE @groups >= 0
	SELECT
		-- 组织变量定义的 T-SQL 语句
		@sql_variable_definition = N',
	@' + @groups + N' nvarchar(4000)'
									+ @sql_variable_definition,
		-- 组织变量初始化的 T-SQL 语句
		@sql_variable_init = N',
	@' + @groups + N' = N'''''
									+ @sql_variable_init,
		-- 组织变量赋值的 T-SQL 语句
		@sql_variable_set = N',
	@' + @groups + N' = CASE g
					WHEN ' + @groups + N' THEN @' + @groups + N' + fd
					ELSE @' + @groups + N'
				END'
						+ @sql_variable_set,
		-- 组织 交叉报表 T-SQL 中的变量相加(组成  交叉报表 T-SQL )
		@sql_body = N' + @' + @groups
					+ @sql_body,
		@groups = @groups - 1
-- 去掉各个变量中的一些多余的前导符号
SELECT 
	@sql_variable_definition = STUFF(@sql_variable_definition, 1, 1, N''),
	@sql_variable_init = STUFF(@sql_variable_init, 1, 1, N''),
	@sql_variable_set = STUFF(@sql_variable_set, 1, 1, N''),
	@sql_body = STUFF(@sql_body, 1, 1, N'')

-- d. 执行
EXEC(N'
-- 1. 变量定义
DECLARE ' + @sql_variable_definition + N'

-- 2. 初始化变量
SELECT
	' + @sql_variable_init + N'

-- 3. 变量赋值
SELECT
	' + @sql_variable_set + N'
FROM #

-- 4. 组织动态 T-SQL 及执行
EXEC(N' + @sql_head + N'         -- 交叉报表 T-SQL 的头部
		' + @sql_body + N'   -- 交叉报表 T-SQL 的列处理部分
		+ ' + @sql_end + N'   -- 交叉报表 T-SQL 的尾部
)
')
-- e. 删除临时表
DROP TABLE #
