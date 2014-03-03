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

--һЩ�ֳ�Ӧ��

--1�������µļ�¼����������ţ�����identity,��Ϊ������;
INSERT [dbo].[DepartDemo] ([DCode])
OUTPUT Inserted.DCode --ͬ��delete.dcode���Բ���ǰɾ������
INTO DepartChangeLogs ---output ���صļ�¼���嵽������
VALUES (N'����ί', N'0', N'������', 0, N'DeomUser',
 CAST(0x00009DF7017B6F96 AS DateTime), N'', CAST(0x0000000000000000 AS DateTime),
 1, N'�ͼۣ���˵����', 0, N'')

/*
�ڰ�Ҫɾ�������ݴ浵ʱ������������Ƶ���һ�����ݱ��У�ʹ��output�Ӿ�ǳ����������û��output�Ӿ䣬����Ҫ�Ȳ�
ѯ���ݲ��浵��Ȼ����ɾ�������ַ����������������Ҹ����ӣ�Ϊ�˱�֤select��delete֮�䲻��������ƥ��ɸѡ������(
Ҳ��Ϊ�ö����������ÿ����л��ĸ��뼶������һҪ�浵�����ݣ���ʹ��output�Ӿ䣬�Ͳ��õ��Ļö����� ��


*/

--һ����ϲ�ѯ�����ӣ���merge�е����ݴ���ͨ��outputѡ�����׳�����뵽������
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