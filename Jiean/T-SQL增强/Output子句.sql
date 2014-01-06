/*
ʹ��Output�Ӿ�
�ٷ����ͣ�OutPut�Ӿ䣨http://technet.microsoft.com/zh-cn/library/ms177564.aspx��
������ INSERT��UPDATE��DELETE �� MERGE ���Ӱ��ĸ����е���Ϣ���򷵻ػ�������Щ���Ӱ��ĸ��еı��ʽ�� 
��Щ������Է��ص�����Ӧ�ó����Թ���ȷ����Ϣ���浵�Լ��������Ƶ�Ӧ�ó���Ҫ����ʹ�á� 
Ҳ���Խ���Щ��������������� ���⣬�����Բ���Ƕ��� INSERT��UPDATE��DELETE �� MERGE ����� OUTPUT �Ӿ�Ľ����
Ȼ����Щ�������Ŀ������ͼ��
*/
--�����������Ա�
IF NOT OBJECT_ID('DepartDemo') IS NULL
DROP TABLE [DepartDemo]
GO
IF NOT OBJECT_ID('DepartChangeLogs') IS NULL
DROP TABLE [DepartChangeLogs]
GO
--���Ա�
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

--��¼��־��
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
OUTPUT Inserted.*,getdate(),'I' ---ע��������������
INTO DepartChangeLogs ---ע��������������
VALUES (N'����ί', N'0', N'������', 0, N'DeomUser',
 CAST(0x00009DF7017B6F96 AS DateTime), N'', CAST(0x0000000000000000 AS DateTime),
 1, N'�ͼۣ���˵����', 0, N'')
GO

SELECT * FROM [DepartChangeLogs]

/*
��ע�⣺
1����OUTPUT �з��ص��з�ӳ INSERT��UPDATE �� DELETE ������֮���ڴ�����ִ��֮ǰ�����ݡ�
2��SQL Server ������֤��ʹ�� OUTPUT �Ӿ�� DML ��䴦��ͷ����е�˳��
3���봥������ȣ�OutPut�Ӿ����ֱ�Ӵ���Merge��䡣
�������ַ�������ǧ��ں��ʵ�����²�ȡ���ʵķ����������ǵ�ѡ�����˾�ϲ���ǣ�SQL Server 2008��
Ϊ�����ṩ�˸�Ϊǿ����ڽ��ķ�����������ݲ���CDC��http://msdn.microsoft.com/zh-cn/library/bb500244%28v=sql.100%29.aspx���͸��ĸ��٣���������¡�ؽ������ǡ�
*/

