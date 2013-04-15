

/*
���࣬���٣��������������������ݲ�ѯ���Ӱ�졣

�������йص�ϵͳ��
sys.indexes :ÿ���������������ͼ���ֵ��������������Ѷ�����һ�У��������û�оۼ��������������Ϊ�ѽṹ��������sys.indexs�е�������һ����¼��
sys.index_columns ������ÿ���ж���Ӧ��Ŀ¼��ͼ�е�һ�м�¼��

ϵͳ��Ĺ�����
object_id -> ����ID
index_id -> ����ID �������ı�sys_indexes

column_id -> ��ID,�еı�sys.columns
*/

SELECT * FROM sys.indexes

SELECT * FROM sys.index_columns

---��ѯ�û����������Ϣ
;WITH
TB AS(
	SELECT
		TB.object_id,
		schema_name = SCH.name,
		table_name = TB.name
	FROM sys.tables TB
		INNER JOIN sys.schemas SCH
			ON TB.schema_id = SCH.schema_id
	WHERE TB.is_ms_shipped = 0       -- ��������ʾ����ѯ�������ڲ� SQL Server �����������
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


---��ѯ�û����������Ϣ(��ÿ���������������һ�𣬲����ò�ͬ��������ʾ�����е��кͰ����������е���)
;WITH
TB AS(
	SELECT
		TB.object_id,
		schema_name = SCH.name,
		table_name = TB.name
	FROM sys.tables TB
		INNER JOIN sys.schemas SCH
			ON TB.schema_id = SCH.schema_id
	WHERE TB.is_ms_shipped = 0       -- ��������ʾ����ѯ�������ڲ� SQL Server �����������
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
	WHERE index_id > 0 -- ����ѯ����Ϣ
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


-- ��ѯ����δʹ�ù���������Ϣ
-- ��Ҫ��SQL Server�����˺ܳ�ʱ��δ��������������������У�����ִ�н��û������
--ԭ��sys.dm_db_index_usage_stats ��¼������ʹ��������ڵ�һ��������ʹ��ʱ�������Ϣ���뵽sys.dm_db_index_usage_statsK��.
SELECT
	schema_name = SCH.name,
	table_name = TB.name,
	index_name = IX.name
FROM sys.tables TB
	INNER JOIN sys.schemas SCH
		ON TB.schema_id = SCH.schema_id
	INNER JOIN sys.indexes IX
		ON TB.object_id = IX.object_id
WHERE TB.is_ms_shipped = 0 -- ��������ʾ����ѯ�������ڲ�SQL Server �����������
	AND index_id > 0       -- ����ѯ����Ϣ
	AND NOT EXISTS(
		SELECT * FROM sys.dm_db_index_usage_stats 
		WHERE database_id = DB_ID()
			AND object_id = IX.object_id
			AND index_id = IX.index_id)
ORDER BY schema_name, table_name, index_name

