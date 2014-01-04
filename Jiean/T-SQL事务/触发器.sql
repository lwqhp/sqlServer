

--触发器
/*
触发器的用途：
1，强制参照完整性：一般建议使用声明参照完整性DRI,但对于跨数据库或服务器的参照完整性,建议用触发器
2，创建审计跟踪：跟踪大多数当前的数据，还包括对每个记录进行实际修改的历史数据，2008有个数据跟踪功能。
3，创建与check约束类似的功能，可以跨表，跨数据库，甚至是跨服务器使用。
4，用自己的语句代替用户的操作语句：这通常用于启动复杂视图中的插入操作。
5，监控表结构的变化。

触发器要点：
1，触发器通常很隐蔽，因比也就容易忘记，确保触 发器在你的数据文档中是“可见的”
2，如果所有的数据修改流程都是通过存储过程完成的，强烈推荐在存储过程中执行所有活动，而不是使用触发器。
处理某些逻辑时，存储过程通常比触发器要更易维护和管理。
3，始终需要保证性能，也就是说触发器需要能快速执行。
4，不记录日志的更新不会引起DML触发器的触发（比如writetext,truncate table 以及批量插入操作）
5，约束通常比DML触发器更快，因此如果约束能满足你的业务需求，则使用约束来替代。after触发器在数据修改发生后进行，
因此它们不能防止约束的违反
6，不允许在触发器中使用select 返回结果集。

触发器的应用：实施数据完整性规则
1，处理来自于其他表的需求
2,使用触发器来检查更新的变化inserted 和deleted
3，将触发器用于自定义错误消息

--触发器类型
触发器是附加在表或视图上的代码片段，无传入参数和返回码，根据表，视图的插入，更新和删除操作分为三种类型+ 混合型

注：进行的操作在记录中活动才会激活触发器，truncate table是释放空间操作，不会激活触发器
批量操作默认情况下不激活触发器，需显示甜知批量操作激活触发器。

*/

create Trigger tr_name
on tableName--指出触 发器将要附加的表或视图
after  --触发器激活的类型,after不能用于视图，
INSERT, update,delete
as
/*
注：for=After指定触发器仅在触发 SQL 语句中指定的所有操作都已成功执行时才被触发，如果执行语句出现问题，则After不会被执行.
	instead of 操作前,指定执行 DML 触发器而不是触发 <!-- --> SQL 语句，因此，其优先级高于触发语句的操作 
	其可以用于视图上，视图中有多个表而造成数据修改不明确时，instead of触发器可以对不能更新的视图进行数据修改。
*/	
if update(columnName)
begin 
	/*
	提供了两个用于控制列的修改触发
update()函数：只在触发器的作用域内适用，提供一个布尔值，来说明某个特殊列是否已经更新。
columns_updated()函数：
*/
ROLLBACK
end


--触发器中的事务机制-----------------------
/*
触发器与激活触发器的语句被视为同一事务处理，这意味着语句直到触 发器完成后才算完成。after触发器在所有工作已经
完成后发生，这意味着回滚的代价是昂贵的

当触发器触发的时候，sqlserver总是会为它创建一个事务，允许由触发器或调用方做出的任何修改回滚到之前的状态。
如果在触发器内显示的声明了RollBack,那么，当触发器发起rollback命令时，任何由触发器进行的数据修改或事务中其余
的语句都不会完成。调用触发器的t-sql查谒或批处理也会被取消或回滚。如果激活调用方嵌入在显式事务内，则整个调用
事务会被取消和回滚。如果在显式事务中使用触发器，sqlserver会把它当作嵌套事务，rollback 会回滚所有事务，不管
嵌套多少层。
*/

--查看触发器元数据
SELECT * FROM sys.triggers
WHERE parent_class_desc = 'object_or_column'
ORDER BY OBJECT_NAME(parent_id),name

SELECT  * FROM sys.sql_modules a
INNER JOIN sys.objects b ON a.object_id = b.object_id
WHERE b.type ='TR'

--创建两个测试表
IF NOT OBJECT_ID('DepartDemo') IS NULL
DROP TABLE [DepartDemo]
GO
IF NOT OBJECT_ID('DepartChangeLogs') IS NULL
DROP TABLE [DepartChangeLogs]
GO
--测试表
CREATE TABLE [dbo].[DepartDemo](
[DID] [int] IDENTITY(101,1) NOT NULL PRIMARY KEY,
[DName] [nvarchar](200) NULL,
[DCode] [nvarchar](500) NULL,
[Manager] [nvarchar](50) NULL,
[ParentID] [int] NOT NULL DEFAULT ((0)),
[AddUser] [nvarchar](50) NULL,
[AddTime] [datetime] NULL,
[ModUser] [nvarchar](50) NULL,
[ModTime] [datetime] NULL,
[CurState] [smallint] NOT NULL DEFAULT ((0)),
[Remark] [nvarchar](500) NULL,
[F1] [int] NOT NULL DEFAULT ((0)),
[F2] [nvarchar](300) NULL
)
GO

--记录日志表
CREATE TABLE [DepartChangeLogs]
([LogID] [bigint] IDENTITY(1001,1) NOT NULL PRIMARY KEY,
[DID] [int] NOT NULL,
[DName] [nvarchar](200) NULL,
[DCode] [nvarchar](500) NULL,
[Manager] [nvarchar](50) NULL,
[ParentID] [int] NOT NULL DEFAULT ((0)),
[AddUser] [nvarchar](50) NULL,
[AddTime] [datetime] NULL,
[ModUser] [nvarchar](50) NULL,
[ModTime] [datetime] NULL,
[CurState] [smallint] NOT NULL DEFAULT ((0)),
[Remark] [nvarchar](500) NULL,
[F1] [int] NOT NULL DEFAULT ((0)),
[F2] [nvarchar](300) NULL,
[LogTime] DateTime Default(Getdate()) Not Null,
[InsOrUpd] char not null
)
GO

select * from [DepartDemo]
select * from [DepartChangeLogs]



/*******　　　创建一个After DML触发器　　******/

go
CREATE TRIGGER dbo.tri_LogDepartDemo
ON [dbo].[DepartDemo]
AFTER INSERT, Delete 
AS

INSERT [DepartChangeLogs]
(DID,[DName], [DCode], [Manager], [ParentID],
[AddUser], [AddTime], [ModUser], [ModTime], [CurState], [Remark], [F1], [F2],
    LogTime, InsOrUPD)
SELECT DISTINCT DID,[DName], [DCode], [Manager], [ParentID],
[AddUser], [AddTime], [ModUser], [ModTime], [CurState], [Remark], [F1], [F2],
    GETDATE(), 'I'
FROM inserted i

-- Deleted rows
INSERT [DepartChangeLogs]
(DID,[DName], [DCode], [Manager], [ParentID],
[AddUser], [AddTime], [ModUser], [ModTime], [CurState], [Remark], [F1], [F2],
    LogTime, InsOrUPD)
SELECT DISTINCT DID,[DName], [DCode], [Manager], [ParentID],
[AddUser], [AddTime], [ModUser], [ModTime], [CurState], [Remark], [F1], [F2],
    GETDATE(), 'D'
FROM deleted d
GO

INSERT [dbo].[DepartDemo] ([DName], [DCode], [Manager], [ParentID],
[AddUser], [AddTime], [ModUser], [ModTime], [CurState], [Remark], [F1], [F2])
VALUES (N'国家统计局房产审计一科', N'0', N'胡不归', 0, N'DeomUser',
    CAST(0x00009DF7017B6F96 AS DateTime), N'', CAST(0x0000000000000000 AS DateTime),
    1, N'专业评估全国房价，为老百姓谋福祉', 0, N'')
GO

----该Update不会被触发器记录，但Update会生效
UPDATE departDemo SET [Manager]='任我行' WHERE DID=101
GO

DELETE FROM departDemo where DID=101
GO

SELECT * FROM [DepartChangeLogs]




go
--创建一个更新触发器
CREATE TRIGGER dbo.[tri_LogDepartDemo2]
ON [dbo].[DepartDemo]
AFTER Update
AS
IF Update([Manager])
    Begin
        print '该部门主管实行终身任免制，不得中途更改！'
        Rollback ----回滚Update操作
    End

GO
UPDATE departDemo SET [Manager]='任我行' WHERE DID=101
GO

----------------------------------------------------------------------------
--DDL触发器
/*
DDL触发器是对服务器或数据库事件作出响应，而不是表数据修改，例如，可以对审核表创建一个ddl触发器，只要数据库
用户使用 create table 或drop table  命令都会触发，或者，在服务器级别，可以创建ddl触发器对新建登陆名作出
响应，比如阻止新建某个登录名
*/

CREATE TRIGGER trddl_name
ON DATABASE | ALL SERVER --是在数据库范围还是在服务器范围的事件作出响应（服务器级的触发器，要建在master库中）
FOR CREATE_INDEX,ALTER_INDEX,DROP_INDEX --这是针对索引操作的跟踪
FOR CREATE_LOGIN,logon --这是针对服务器登录
AS
INSERT into changeattempt(EVENTDATA,dbuser)VALUES(EVENTDATA(),USER)


--查看DDL触发器的元数据
SELECT * FROM sys.triggers WHERE parent_class_desc = 'database'

--服务器触发器
SELECT * FROM sys.server_triggers a
INNER JOIN sys.server_trigger_events b ON a.OBJECT_ID = b.OBJECT_ID


--启禁用触发器
DISABLE TRIGGER tr_name ON tbname

ENABLE TRIGGER tr_name ON tbname

--限制触发器嵌套
EXEC sp_configure 'nested triggers',0 --禁止
RECONFIGURE WITH OVERRIDE 

EXEC sp_configure 'nested triggers',1 --启用
RECONFIGURE WITH OVERRIDE 

--触发器递归控制
ALTER DATABASE dbName
SET RECURSIVE_TRIGGERS ON --允许

ALTER DATABASE dbName
SET RECURSIVE_TRIGGERS OFF --禁止

--查看
SELECT is_recursive_triggers FROM sys.databases WHERE NAME = 'dbName'

--执行顺序
EXEC sp_settriggerorder 'trName1','first','insert'
EXEC sp_settriggerorder 'trname2','last','insert'
/*
可以设置first,none,last,任何介于第一个触发器和最后一个触发之间的触发器以随机次序触发
*/

--删除
DROP TRIGGER tr_name