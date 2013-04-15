DECLARE
	@sql_head nvarchar(4000),
	@sql_end nvarchar(4000),
	@sql_body nvarchar(4000),
	@sql_variable_definition nvarchar(4000),
	@sql_variable_init nvarchar(4000),
	@sql_variable_set nvarchar(4000),
	@groups varchar(20)

-- a. �������ݴ�����ʱ��
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

-- b. ������ʱ��
UPDATE A SET
	@groups = id / i,
	g = @groups	
FROM # A
	CROSS JOIN(
		-- ÿ�������ܹ������name ����
		SELECT
			i = 3800 / MAX(LEN(fd))
		FROM #
	)B

-- c. �������ݴ������
SELECT
	-- ���汨�� T-SQL ��ͷ��, ��ΪҪ���ٴνӽ�, ����Ҫ��������ַ����߽��(')������
	@sql_head=N''''
		+ REPLACE(N'
SELECT
	xtype
', N'''', N'''''')
		+'''',
	-- ���汨�� T-SQL ��β����, ��ΪҪ���ٴνӽ�, ����Ҫ��������ַ����߽��(')������
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
		-- ��֯��������� T-SQL ���
		@sql_variable_definition = N',
	@' + @groups + N' nvarchar(4000)'
									+ @sql_variable_definition,
		-- ��֯������ʼ���� T-SQL ���
		@sql_variable_init = N',
	@' + @groups + N' = N'''''
									+ @sql_variable_init,
		-- ��֯������ֵ�� T-SQL ���
		@sql_variable_set = N',
	@' + @groups + N' = CASE g
					WHEN ' + @groups + N' THEN @' + @groups + N' + fd
					ELSE @' + @groups + N'
				END'
						+ @sql_variable_set,
		-- ��֯ ���汨�� T-SQL �еı������(���  ���汨�� T-SQL )
		@sql_body = N' + @' + @groups
					+ @sql_body,
		@groups = @groups - 1
-- ȥ�����������е�һЩ�����ǰ������
SELECT 
	@sql_variable_definition = STUFF(@sql_variable_definition, 1, 1, N''),
	@sql_variable_init = STUFF(@sql_variable_init, 1, 1, N''),
	@sql_variable_set = STUFF(@sql_variable_set, 1, 1, N''),
	@sql_body = STUFF(@sql_body, 1, 1, N'')

-- d. ִ��
EXEC(N'
-- 1. ��������
DECLARE ' + @sql_variable_definition + N'

-- 2. ��ʼ������
SELECT
	' + @sql_variable_init + N'

-- 3. ������ֵ
SELECT
	' + @sql_variable_set + N'
FROM #

-- 4. ��֯��̬ T-SQL ��ִ��
EXEC(N' + @sql_head + N'         -- ���汨�� T-SQL ��ͷ��
		' + @sql_body + N'   -- ���汨�� T-SQL ���д�����
		+ ' + @sql_end + N'   -- ���汨�� T-SQL ��β��
)
')
-- e. ɾ����ʱ��
DROP TABLE #
