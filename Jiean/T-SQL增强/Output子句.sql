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

--一些现场应用

--1，插入新的记录，并返回序号，比如identity,作为其它用途
INSERT [dbo].[DepartDemo] ([DCode])
OUTPUT Inserted.DCode --同理，delete.dcode可以捕获当前删除的行
INTO DepartChangeLogs ---output 返回的记录集插到这里来
VALUES (N'发改委', N'0', N'向问天', 0, N'DeomUser',
 CAST(0x00009DF7017B6F96 AS DateTime), N'', CAST(0x0000000000000000 AS DateTime),
 1, N'油价，我说了算', 0, N'')

/*
在把要删除的数据存档时，比如把数据移到另一个备份表中，使用output子句非常有利，如果没有output子句，就需要先查
询数据并存档，然后再删除，这种方法不但更慢，而且更复杂，为了保证select和delete之间不会新增加匹配筛选器的行(
也称为幻读），必须用可序列化的隔离级别来锁一要存档的数据，而使用output子句，就不用担心幻读问题 。


*/

--一个组合查询的例子，在merge中的数据处理通过output选择性抛出后插入到其它表。
IF OBJECT_ID('dbo.CustomersAudit', 'U') IS NOT NULL
  DROP TABLE dbo.CustomersAudit;

CREATE TABLE dbo.CustomersAudit
(
  audit_lsn  INT NOT NULL IDENTITY,
  login_name SYSNAME NOT NULL DEFAULT (SUSER_SNAME()),
  post_time  DATETIME NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  custid       INT         NOT NULL,
  companyname  VARCHAR(25) NOT NULL,
  phone        VARCHAR(20) NOT NULL,
  address      VARCHAR(50) NOT NULL,
  CONSTRAINT PK_CustomersAudit PRIMARY KEY(audit_lsn)
);

BEGIN TRAN

INSERT INTO dbo.CustomersAudit(custid, companyname, phone, address)
  SELECT custid, Icompanyname, Iphone, Iaddress
  FROM (MERGE INTO dbo.Customers AS TGT
        USING dbo.CustomersStage AS SRC
          ON TGT.custid = SRC.custid
        WHEN MATCHED THEN
          UPDATE SET
            TGT.companyname = SRC.companyname,
            TGT.phone = SRC.phone,
            TGT.address = SRC.address
        WHEN NOT MATCHED THEN 
          INSERT (custid, companyname, phone, address)
          VALUES (SRC.custid, SRC.companyname, SRC.phone, SRC.address)
        OUTPUT $action AS action, 
          inserted.custid,
          inserted.companyname AS Icompanyname,
          inserted.phone AS Iphone,
          inserted.address AS Iaddress) AS D
  WHERE action = 'INSERT';
  
SELECT * FROM dbo.CustomersAudit;

ROLLBACK TRAN