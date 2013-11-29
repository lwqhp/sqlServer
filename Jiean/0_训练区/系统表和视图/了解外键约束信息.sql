

/*
数据库常通过外键约束来保证数据的一致性

和外键约束有关的系统表
sys.foreign_keys : 每个外键约束以应此表中的一条记录
sys.foreign_key_columns : 组成外键的每一列对应此表中的一条记录
*/

--查询当前数据库的所有外键约束信息
;WITH
FK AS(
	SELECT
		foreign_schema_name = SCH.name,
		foreign_name = FK.name,
		FK.is_disabled,
		delete_action = FK.delete_referential_action_desc,
		update_action = FK.update_referential_action_desc,
		constraint_column_id = FKC.constraint_column_id,
		FKC.parent_object_id,
		FKC.parent_column_id,
		FKC.referenced_object_id,
		FKC.referenced_column_id
	 FROM sys.foreign_keys FK
		INNER JOIN sys.foreign_key_columns FKC
			ON FK.object_id = FKC.constraint_object_id
		INNER JOIN sys.schemas SCH
			ON FK.schema_id = SCH.schema_id
),
TB AS(
	SELECT 
		TB.object_id,
		schema_name = SCH.name,
		table_name = TB.name,
		column_id = C.column_id,
		column_name = C.name
	FROM sys.tables TB WITH(NOLOCK)
		INNER JOIN sys.columns C WITH(NOLOCK)
			ON TB.object_id = C.object_id
		INNER JOIN sys.schemas SCH WITH(NOLOCK)
			ON TB.schema_id = SCH.schema_id
	WHERE TB.is_ms_shipped = 0  -- 此条件表示仅查询不是由内部 SQL Server 组件创建对象
)
SELECT
	FK.foreign_schema_name,
	FK.foreign_name,
	FK.is_disabled,
	FK.delete_action,
	FK.update_action,
	FK.constraint_column_id,
	parent_table_schema_name = TBP.schema_name,
	parent_table_name = TBP.table_name,
	parent_table_column_name = TBP.column_name,
	referenced_table_schema_name = TBR.schema_name,
	referenced_table_name = TBR.table_name,
	referenced_table_column_name = TBR.column_name
FROM FK
	INNER JOIN TB TBP
		ON FK.parent_object_id = TBP.object_id
			AND FK.parent_column_id = TBP.column_id
	INNER JOIN TB TBR
		ON FK.referenced_object_id = TBR.object_id
			AND FK.referenced_column_id = TBR.column_id
ORDER BY foreign_schema_name, parent_table_schema_name, parent_table_name, constraint_column_id
