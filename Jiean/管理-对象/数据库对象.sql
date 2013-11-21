

--数据库对象
/*
架构schema
 是独立于数据库用户的非重复命名空间，也就是说，架构只是对象的容器，任何用户都可以拥有架构，并且架构所有权可以转移.

它把用户和数据库对象分离
	对象可以在架构间移动.
	单个架构可以包含由多个数据库用户拥有的对象.
	多个数据库用户可以共享单个默认架构
*/

--修改对象的schema
ALTER SCHEMA dbo transfer [db_abc].[table_a]

SELECT 'ALTER SCHEMA dbo TRANSFER ' + s.Name + '.' + p.Name + ';'
	FROM sys.tables p INNER JOIN sys.Schemas s on p.schema_id = s.schema_id 
	WHERE s.Name = 'db_abc'


--改当前用户的default schema，这时就可以不用加前缀了
ALTER USER dbo WITH DEFAULT_SCHEMA =emdbuser;

--上下文切换”，操作完以后，可以实用REVERT命令切换回来
EXECUTE AS USER = 'emdbuser';


--表名获取一个表的Schema
select sys.objects.name as A1,sys.schemas.name A2
from　 sys.objects,
　　　　sys.schemas
where sys.objects.type='U'
and　 sys.objects.schema_id=sys.schemas.schema_id

-------------------------------------------------------------------------------------------

/*
架构
sys.schemas

对象
sys.objects

类型		表				列				
sys.types	sys.tables		sys.columns		

存储过程		触发器			视图
sys.procedures	sys.triggers	sys.views
*/

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

/*
模块对象信息：包括了存储过程，视图，触发器，用户定义函数等

sys.procedures :每个存储过程对应此表中的一条记录
sys.views :每个视图对应此表中的一条记录
sys.triggers :每个触发器对应此表中的一条记录
sys.objects : 在数据库中创建的每个用户定义的架构范围内的对象在该表中均对应一行。type列指定了该对象的类型

对应关联：
sys.procedures 和sys.objects sys.objects.type = 'P,X,RF,PC'
sys.views 和sys.objects sys.objects.type = 'V'
sys.triggers  和sys.objects sys.objects.type = 'TR,TA'
*/

--查询当前数据库中所有SQL言语定义模式的SQL定义
SELECT
	object_type = O.type_desc,
	object_name = O.name,
	O.create_date,
	O.modify_date,
	sql_definition = M.definition
FROM sys.sql_modules M
	INNER JOIN sys.objects O
		ON M.object_id = O.object_id
WHERE O.is_ms_shipped = 0
ORDER BY object_type, object_name