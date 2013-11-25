

--Plan Guide 计划指南
/*
当在不能变改语句的时候，可以使用计划指南强制指定新的计划缓存

可以创建三种类型的计划指南。下面来自SQL Server联机帮助的摘录总结了这几种计划指南：

OBJECT 计划指南与事务-SQL存储过程、纯量函数、跨语句表-值函数和DML触发器的上下文环境下执行的查询相匹配。

SQL 计划指南与单机事务-SQL语句和不是数据库对象的成分上下文环境下执行的查询相匹配。基于SQL的计划指南也可以用来匹配确定指定表的参数的查询。

TEMPLATE 计划指南与确定指定表的参数的单机查询相匹配。这些计划指南用来取代一系列的查询成为一个数据库当前参数化的数据库设置选项。
*/

--一个计划指南的定义是通过系统存储过程sp_create_plan_guide来实现的:
sp_create_plan_guide parameters
EXEC sp_create_plan_guide @name, @stmt, @type, @module_or_batch, @params, @hints
Here is an explanation of the parameters:
@name - name of the plan guide
@stmt - a T-SQL statement or batch
@type - indicates the type of guide (OBJECT, SQL, or TEMPLATE)
@module_or_batch - the name of a module (i.e. a stored procedure)
@params - for SQL and TEMPLATE guides, a string of all parameters for a T-SQL batch to be matched by this plan guide
@hints - OPTION clause hint to attach to a query as defined in the @stmt parameter

--查看在数据库中存储的所有计划指南列表
SELECT * FROM sys.plan_guides
GO


--删除计划指南，把它停用，或者如果之前已经停止它，那么重新启用它。
sp_control_plan_guide parameters
EXEC sp_control_plan_guide @operation, @name
Explanation of its parameters:
@operation - a control option; one of DROP, DROP ALL, DISABLE, DISABLE ALL, ENABLE, ENABLE ALL
@name - name of the plan guide to CONTROL

EXEC sp_control_plan_guide N'DROP', N'GETSALESPRODUCTS_RECOMPILE_Fix'
GO

--原来的例子
EXEC sys.sp_create_plan_guide 
	@ @name = 'Guidel', -- sysname
    @stmt = N'SELECT COUNT(b.salesorderid),SUM(p.weight)
FROM salesorderheader_test a
INNER JOIN salesorderdetail_test b on a.salesorderid = b.salesorderid
INNER JOIN production.product p ON b.productid = p.productid
WHERE a.salesorderid = @i', -- nvarchar(max)
    @type = N'OBJECT', -- nvarchar(60)
    @module_or_batch = N'Sniff', -- nvarchar(max)
    @params = null, -- nvarchar(max)
    @hints = N'Option(optimize for(@i=75124))' -- nvarchar(max)

