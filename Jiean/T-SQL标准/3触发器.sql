

--������
/*
����������;��
1��ǿ�Ʋ��������ԣ�һ�㽨��ʹ����������������DRI,�����ڿ����ݿ��������Ĳ���������,�����ô�����
2��������Ƹ��٣����ٴ������ǰ�����ݣ���������ÿ����¼����ʵ���޸ĵ���ʷ���ݣ�2008�и����ݸ��ٹ��ܡ�
3��������checkԼ�����ƵĹ��ܣ����Կ�������ݿ⣬�����ǿ������ʹ�á�
4�����Լ����������û��Ĳ�����䣺��ͨ����������������ͼ�еĲ��������
5����ر�ṹ�ı仯��

������Ҫ�㣺
1��������ͨ�������Σ����Ҳ���������ǣ�ȷ���� ��������������ĵ����ǡ��ɼ��ġ�
2��������е������޸����̶���ͨ���洢������ɵģ�ǿ���Ƽ��ڴ洢������ִ�����л��������ʹ�ô�������
����ĳЩ�߼�ʱ���洢����ͨ���ȴ�����Ҫ����ά���͹���
3��ʼ����Ҫ��֤���ܣ�Ҳ����˵��������Ҫ�ܿ���ִ�С�
4������¼��־�ĸ��²�������DML�������Ĵ���������writetext,truncate table �Լ��������������
5��Լ��ͨ����DML���������죬������Լ�����������ҵ��������ʹ��Լ���������after�������������޸ķ�������У�
������ǲ��ܷ�ֹԼ����Υ��
6���������ڴ�������ʹ��select ���ؽ������

��������Ӧ�ã�ʵʩ���������Թ���
1�����������������������
2,ʹ�ô������������µı仯inserted ��deleted
3���������������Զ��������Ϣ

--����������
�������Ǹ����ڱ����ͼ�ϵĴ���Ƭ�Σ��޴�������ͷ����룬���ݱ���ͼ�Ĳ��룬���º�ɾ��������Ϊ��������+ �����

ע�����еĲ����ڼ�¼�л�Żἤ�������truncate table���ͷſռ���������ἤ�����
��������Ĭ������²��������������ʾ��֪�����������������

*/

create Trigger tr_name
on tableName--ָ���� ������Ҫ���ӵı����ͼ
after  --���������������,after����������ͼ��
INSERT, update,delete
as
/*
ע��for=Afterָ�����������ڴ��� SQL �����ָ�������в������ѳɹ�ִ��ʱ�ű����������ִ�����������⣬��After���ᱻִ��.
	instead of ����ǰ,ָ��ִ�� DML �����������Ǵ��� <!-- --> SQL ��䣬��ˣ������ȼ����ڴ������Ĳ��� 
	�����������ͼ�ϣ���ͼ���ж�������������޸Ĳ���ȷʱ��instead of���������ԶԲ��ܸ��µ���ͼ���������޸ġ�
*/	
if update(columnName)
begin 
	/*
	�ṩ���������ڿ����е��޸Ĵ���
update()������ֻ�ڴ������������������ã��ṩһ������ֵ����˵��ĳ���������Ƿ��Ѿ����¡�
columns_updated()������
*/
ROLLBACK
end


--�������е��������-----------------------
/*
�������뼤���������䱻��Ϊͬһ����������ζ�����ֱ���� ������ɺ������ɡ�after�����������й����Ѿ�
��ɺ���������ζ�Żع��Ĵ����ǰ����

��������������ʱ��sqlserver���ǻ�Ϊ������һ�����������ɴ���������÷��������κ��޸Ļع���֮ǰ��״̬��
����ڴ���������ʾ��������RollBack,��ô��������������rollback����ʱ���κ��ɴ��������е������޸Ļ�����������
����䶼������ɡ����ô�������t-sql���˻�������Ҳ�ᱻȡ����ع������������÷�Ƕ������ʽ�����ڣ�����������
����ᱻȡ���ͻع����������ʽ������ʹ�ô�������sqlserver���������Ƕ������rollback ��ع��������񣬲���
Ƕ�׶��ٲ㡣
*/

--�鿴������Ԫ����
SELECT * FROM sys.triggers
WHERE parent_class_desc = 'object_or_column'
ORDER BY OBJECT_NAME(parent_id),name

SELECT  * FROM sys.sql_modules a
INNER JOIN sys.objects b ON a.object_id = b.object_id
WHERE b.type ='TR'

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

select * from [DepartDemo]
select * from [DepartChangeLogs]



/*******����������һ��After DML����������******/

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
VALUES (N'����ͳ�ƾַ������һ��', N'0', N'������', 0, N'DeomUser',
    CAST(0x00009DF7017B6F96 AS DateTime), N'', CAST(0x0000000000000000 AS DateTime),
    1, N'רҵ����ȫ�����ۣ�Ϊ�ϰ���ı����', 0, N'')
GO

----��Update���ᱻ��������¼����Update����Ч
UPDATE departDemo SET [Manager]='������' WHERE DID=101
GO

DELETE FROM departDemo where DID=101
GO

SELECT * FROM [DepartChangeLogs]




go
--����һ�����´�����
CREATE TRIGGER dbo.[tri_LogDepartDemo2]
ON [dbo].[DepartDemo]
AFTER Update
AS
IF Update([Manager])
    Begin
        print '�ò�������ʵ�����������ƣ�������;���ģ�'
        Rollback ----�ع�Update����
    End

GO
UPDATE departDemo SET [Manager]='������' WHERE DID=101
GO

----------------------------------------------------------------------------
--DDL������
/*
DDL�������ǶԷ����������ݿ��¼�������Ӧ�������Ǳ������޸ģ����磬���Զ���˱���һ��ddl��������ֻҪ���ݿ�
�û�ʹ�� create table ��drop table  ����ᴥ�������ߣ��ڷ��������𣬿��Դ���ddl���������½���½������
��Ӧ��������ֹ�½�ĳ����¼��
*/

CREATE TRIGGER trddl_name
ON DATABASE | ALL SERVER --�������ݿⷶΧ�����ڷ�������Χ���¼�������Ӧ�����������Ĵ�������Ҫ����master���У�
FOR CREATE_INDEX,ALTER_INDEX,DROP_INDEX --����������������ĸ���
FOR CREATE_LOGIN,logon --������Է�������¼
AS
INSERT into changeattempt(EVENTDATA,dbuser)VALUES(EVENTDATA(),USER)


--�鿴DDL��������Ԫ����
SELECT * FROM sys.triggers WHERE parent_class_desc = 'database'

--������������
SELECT * FROM sys.server_triggers a
INNER JOIN sys.server_trigger_events b ON a.OBJECT_ID = b.OBJECT_ID


--�����ô�����
DISABLE TRIGGER tr_name ON tbname

ENABLE TRIGGER tr_name ON tbname

--���ƴ�����Ƕ��
EXEC sp_configure 'nested triggers',0 --��ֹ
RECONFIGURE WITH OVERRIDE 

EXEC sp_configure 'nested triggers',1 --����
RECONFIGURE WITH OVERRIDE 

--�������ݹ����
ALTER DATABASE dbName
SET RECURSIVE_TRIGGERS ON --����

ALTER DATABASE dbName
SET RECURSIVE_TRIGGERS OFF --��ֹ

--�鿴
SELECT is_recursive_triggers FROM sys.databases WHERE NAME = 'dbName'

--ִ��˳��
EXEC sp_settriggerorder 'trName1','first','insert'
EXEC sp_settriggerorder 'trname2','last','insert'
/*
��������first,none,last,�κν��ڵ�һ�������������һ������֮��Ĵ�������������򴥷�
*/

--ɾ��
DROP TRIGGER tr_name