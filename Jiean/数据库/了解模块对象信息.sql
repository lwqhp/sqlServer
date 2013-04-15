

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