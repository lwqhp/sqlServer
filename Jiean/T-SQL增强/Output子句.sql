/*
使用Output子句
官方解释：OutPut子句（http://technet.microsoft.com/zh-cn/library/ms177564.aspx）
返回受 INSERT、UPDATE、DELETE 或 MERGE 语句影响的各行中的信息，或返回基于受这些语句影响的各行的表达式。 
这些结果可以返回到处理应用程序，以供在确认消息、存档以及其他类似的应用程序要求中使用。 
也可以将这些结果插入表或表变量。 另外，您可以捕获嵌入的 INSERT、UPDATE、DELETE 或 MERGE 语句中 OUTPUT 子句的结果，
然后将这些结果插入目标表或视图。
*/
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

INSERT [dbo].[DepartDemo] ([DName], [DCode], [Manager], [ParentID],
[AddUser], [AddTime], [ModUser], [ModTime], [CurState], [Remark], [F1], [F2])
OUTPUT Inserted.*,getdate(),'I' ---注意这行是新增的
INTO DepartChangeLogs ---注意这行是新增的
VALUES (N'发改委', N'0', N'向问天', 0, N'DeomUser',
 CAST(0x00009DF7017B6F96 AS DateTime), N'', CAST(0x0000000000000000 AS DateTime),
 1, N'油价，我说了算', 0, N'')
GO

SELECT * FROM [DepartChangeLogs]

/*
　注意：
1、从OUTPUT 中返回的列反映 INSERT、UPDATE 或 DELETE 语句完成之后但在触发器执行之前的数据。
2、SQL Server 并不保证由使用 OUTPUT 子句的 DML 语句处理和返回行的顺序。
3、与触发器相比，OutPut子句可以直接处理Merge语句。
以上两种方法各有千秋，在合适的情况下采取合适的方法才是明智的选择，令人惊喜的是，SQL Server 2008起，
为我们提供了更为强大的内建的方法－变更数据捕获（CDC，http://msdn.microsoft.com/zh-cn/library/bb500244%28v=sql.100%29.aspx）和更改跟踪，下面我们隆重介绍它们。
*/

