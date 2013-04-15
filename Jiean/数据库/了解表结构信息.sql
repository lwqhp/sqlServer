
/*
了解一个数据库时候，通常是先了解下表，以及表的结构。
与表结构有关的系统表
sys.schemas : 每一行对应一个数据库中的架构
sys.tables  : 每一条记录对应数据库中的一个表
sys.columns : 列信息。包含很多，表，函数
sys.types   : 每一条记录对应一个数据类型

对应关系
schema_id ->sys.schemas的ID值
object_id -> 对象ID，数据库中的对象都有一个ID唯一标识
system_type_id -> 类型ID 类型表sys.types
user_type_id -> 类型ID 类型表sys.types

sys.tables.schema_id = sys.schemas.schema_id 
sys.tables.object_id = sys.columns.object_id

sys.columns.system_type_id = sys.types.system_type_id
sys.columns.user_type_id - sys.types.user_type_id
*/

SELECT * FROM sys.tables
--查询当前数据库的所有表结构信息
SELECT
	schema_name = SCH.name,
	table_name = TB.name,
	column_name = C.name,
	type_name = T.name,
	column_length_byte = C.max_length,
	column_precision = C.precision,
	column_scale = C.scale,
	column_is_nullable = C.is_nullable,
	column_is_identity = C.is_identity,
	column_is_computed = C.is_computed
FROM sys.tables TB
	INNER JOIN sys.schemas SCH
		ON TB.schema_id = SCH.schema_id
	INNER JOIN sys.columns C
		ON TB.object_id = C.object_id
	INNER JOIN sys.types T
		ON C.user_type_id = T.user_type_id
WHERE TB.is_ms_shipped = 0       -- 此条件表示仅查询不是由内部 SQL Server 组件创建对象
ORDER BY schema_name, table_name, column_name