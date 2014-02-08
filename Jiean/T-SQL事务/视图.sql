

--视图

/*
1）视图多用来为查询编写者简化数据访问，隐藏底层select语句的复杂度。
2）视图开发：管理和保护敏感数据，对视图授于执行权限，而不对表授于权限，包含指定列而不是所有的列，数据结构
与设计分离，数据结构的改变不影响调用视图的程序。
*/

--3.3）普通视图
/*
视图并不能提升性能，视图最终会被解释成语句，所以，对视图的关联条件，同样也会影响视图内部的表关联，
不要嵌套视图超过一级，具体来讲，不要定义一个调用另一个视图的视图

1)像select 查询一样对视图进行性能调优，因为普通视图从本质上说是一个“已存储的”查询，性能糟糕的视图会严重影响
服务器性能
2)不要嵌套视图超过一级
3）如果可能的话，使用存储过程而不用视图
4）除非使用了top关键字，否则不能使用ordr by 
*/

CREATE VIEW vw_name
AS


--查看视图
SELECT * FROM sys.sql_modules

--显示视图及结构
SELECT * FROM sys.VIEWS a 
INNER JOIN sys.schemas b ON a.SCHEMA_ID = b.SCHEMA_ID


--查看视图的依赖性
SELECT * FROM sys.sql_expression_dependencies

--刷新视图
/*
视图保存查询的语句，视图结构中元数据保存了引用基表返回列的数据结构，列名，数据类型等信息
这也是为什么可以通过视图更新基表的原因
*/
EXEC sp_refreshview 'vw_name'

EXEC sys.sp_refreshsqlmodule @name = 'vw_name'

-----------------------------------------------------------------------------------------
--3.2)索引视图
/*
在视图上他建一个唯一的聚集索引，一旦视图上的索引被创建，用于物化视图的数据就像表的聚集索引那样保存，在视
图上创建了唯一的聚集索引之后，还可以创建另外的非聚集索引，基础表不会受到这些视图索引创建的影响，因为
他们是独立的基础对象。

索引视图对于跨多行聚合数据的视图定义来说特别理想，因为聚合值能保持是最新的和物化的，可以直接查询而不用重新计算
索引视图对频繁引用更新的基础表的查询来说也很理想，但是在变化非常快的表上创建它们可能会由于要不断更新索引而
导致性能下降，更新非常频繁的基础表会引起视图的索引频繁更新，也不是说更新速度要以查询性能为代价。
*/
go
CREATE VIEW vw_name2
WITH SchemaBinding 
/*绑定视图到基础表的架构上，这样会阻止在基础表上进行的，对视图定义有影响的任何修改操作
也为视图的查询定义增加了额外的需求，架构绑定视图中引用的对象必须包含两部份的schema.object命名规则，并且
所有引用的对象必须处于同一个数据库中。
*/
AS
SELECT name,objec,score FROM dbo.t --一定要指定列名，表要带上架构


go
--创建聚集索引
CREATE UNIQUE CLUSTERED INDEX PK_vw_name1 ON vw_name2(name,objec)

--然后创建非聚集索引
CREATE NONCLUSTERED INDEX IX_vw_name1 ON vw_name2(name)
/*
索引视衅允许把视图的结构物化成一个物理对象，和普通表以及相关的索引相似，它允许sqlserver查询优化器从单独的物
理区域获取数据，而不用每次调用的时候处理视图定义查询

with (noexpand)强制优化器为索引视图使用索引
*/
SET STATISTICS PROFILE ON
SELECT * FROM t WHERE NAME = 'a' AND objec = 'CH'
SET STATISTICS PROFILE OFF 
----------------------------------------------------------------------------------------
--3.1)分区视图
/*
分布式分区视图允许为分布在不同sqlserver实例的两个多个水平分区表创建单个逻辑表现(视图)

要创建一个分布式分区视图，需要根据check约束中定义的一组值把大表分割成更小的一些表，check约束确保每一个更小的
表保存着不能在其他表中保存的唯一数据，然后使用union all创建分布式分区视图，把所有小表联结成单独的结果集。

查询时，视图根据日期范围分区，并用查询来返回仅保存在一个分区表中的行，那么sqlserver会智能地只搜索一个分区而
不是分布式分区视图中的所有表。
*/

--创建链接服务器,两个服务器实例都要创建
EXEC sys.sp_addlinkedserver  'sererName','SQL Server'

--开启跳过检查远程表结构,查询执行之前不查询架构
EXEC sp_serveroption 'serverName','lazy schema validation','true'

--创建有check约束的表
CREATE TABLE TB(val VARCHAR(30),
	CHECK(val='lwqhp'),
	CONSTRAINT PK_primary PRIMARY KEY(val)
)

--创建分区视图
go
CREATE VIEW vs_name2
as
SELECT * FROM sys.objects
UNION ALL
SELECT * FROM [192.168.1.1].[server].dbo.sys.objects
GO

--在分区视图上更新
/*
分区列（这里是val）不能允许空值计算列或者标识，默认或时间列，分区建也需要是主键的一部份。
*/
SET XACT_ABORT ON --启用分布式事务
INSERT INTO vw_name2(val) VALUES('a')

