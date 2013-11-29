


---查询用户表的索引信息
;WITH
TB AS(
	SELECT
		TB.object_id,
		schema_name = SCH.name,
		table_name = TB.name
	FROM sys.tables TB
		INNER JOIN sys.schemas SCH
			ON TB.schema_id = SCH.schema_id
	WHERE TB.is_ms_shipped = 0       -- 此条件表示仅查询不是由内部 SQL Server 组件创建对象
),
IX AS(
	SELECT
		IX.object_id,
		index_name = IX.name,
		index_type_desc = IX.type_desc,
		IX.is_unique,
		IX.is_primary_key,
		IX.is_unique_constraint,
		IX.is_disabled,
		index_column_name = C.name,
		IXC.index_column_id,
		IXC.is_descending_key,
		IXC.is_included_column
	FROM sys.indexes IX
		INNER JOIN sys.index_columns IXC
			ON IX.object_id = IXC.object_id
				AND IX.index_id = IXC.index_id
		INNER JOIN sys.columns C
			ON IXC.object_id = C.object_id
				AND IXC.column_id = C.column_id
)
SELECT
	TB.schema_name,
	TB.table_name,
	IX.index_name,
	IX.index_type_desc,
	IX.is_unique,
	IX.is_primary_key,
	IX.is_unique_constraint,
	IX.is_disabled,
	IX.index_column_name,
	IX.index_column_id,
	IX.is_descending_key,
	IX.is_included_column
FROM TB
	INNER JOIN IX
		ON TB.object_id = IX.object_id
ORDER BY schema_name, table_name, index_name, index_column_id


---查询用户表的索引信息(将每个索引的列组合在一起，并且用不同的列来显示索引中的列和包含在索引中的列)
;WITH
TB AS(
	SELECT
		TB.object_id,
		schema_name = SCH.name,
		table_name = TB.name
	FROM sys.tables TB
		INNER JOIN sys.schemas SCH
			ON TB.schema_id = SCH.schema_id
	WHERE TB.is_ms_shipped = 0       -- 此条件表示仅查询不是由内部 SQL Server 组件创建对象
),
IXC AS(
	SELECT
		IXC.object_id,
		IXC.index_id,
		IXC.index_column_id,
		IXC.is_descending_key,
		IXC.is_included_column,
		column_name = C.name
	FROM sys.index_columns IXC
		INNER JOIN sys.columns C
			ON IXC.object_id = C.object_id
				AND IXC.column_id = C.column_id
),
IX AS(
	SELECT
		IX.object_id,
		index_name = IX.name,
		index_type_desc = IX.type_desc,
		IX.is_unique,
		IX.is_primary_key,
		IX.is_unique_constraint,
		IX.is_disabled,
		index_columns = STUFF(IXC_COL.index_columns, 1, 2, N''),
		index_columns_include = STUFF(IXC_COL_INCLUDE.index_columns_include, 1, 2, N'')
	FROM sys.indexes IX
		CROSS APPLY(
			SELECT index_columns = (
					SELECT
						N', ' + QUOTENAME(column_name)
							+ CASE is_descending_key
									WHEN 1 THEN N' DESC'
									ELSE N'' 
								END
					FROM IXC
					WHERE object_id = IX.object_id
						AND index_id = IX.index_id
						AND is_included_column = 0
					ORDER BY index_column_id
					FOR XML PATH(''), ROOT('r'), TYPE
				).value('/r[1]', 'nvarchar(max)')	
		)IXC_COL
		OUTER APPLY(
			SELECT index_columns_include = (
					SELECT
						N', ' + QUOTENAME(column_name)
					FROM IXC
					WHERE object_id = IX.object_id
						AND index_id = IX.index_id
						AND is_included_column = 1
					ORDER BY index_column_id
					FOR XML PATH(''), ROOT('r'), TYPE
				).value('/r[1]', 'nvarchar(max)')	
		)IXC_COL_INCLUDE
	WHERE index_id > 0 -- 不查询堆信息
)
SELECT
	TB.schema_name,
	TB.table_name,
	IX.index_name,
	IX.index_type_desc,
	IX.is_unique,
	IX.is_primary_key,
	IX.is_unique_constraint,
	IX.is_disabled,
	IX.index_columns,
	IX.index_columns_include
FROM TB
	INNER JOIN IX
		ON TB.object_id = IX.object_id
ORDER BY schema_name, table_name, index_name


-- 查询所有未使用过的索引信息
-- 需要在SQL Server运行了很长时间未重新启动过的情况下运行，否则执行结果没有意义
--原理：sys.dm_db_index_usage_stats 记录索引的使用情况，在第一次索引被使用时，相关信息插入到sys.dm_db_index_usage_statsK中.
SELECT
	schema_name = SCH.name,
	table_name = TB.name,
	index_name = IX.name
FROM sys.tables TB
	INNER JOIN sys.schemas SCH
		ON TB.schema_id = SCH.schema_id
	INNER JOIN sys.indexes IX
		ON TB.object_id = IX.object_id
WHERE TB.is_ms_shipped = 0 -- 此条件表示仅查询不是由内部SQL Server 组件创建对象
	AND index_id > 0       -- 不查询堆信息
	AND NOT EXISTS(
		SELECT * FROM sys.dm_db_index_usage_stats 
		WHERE database_id = DB_ID()
			AND object_id = IX.object_id
			AND index_id = IX.index_id)
ORDER BY schema_name, table_name, index_name

