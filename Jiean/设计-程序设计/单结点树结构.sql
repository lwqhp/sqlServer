
--��������ṹ
/*

��Ҫ��һ�б�ʾ�ڵ��ϵ����ʽ[���ڵ�][�ӽڵ�1][�ӽڵ�2]...
��ҪԤ�ȶ���ڵ�ĸ�ʽ��ͳһ���еĽڵ�ռ��λ������ָ��λ��

�ŵ㣺
�����˫�ڵ����ṹ��������ʡ�ռ䣬����Ҫ�����ڽ���ֻ��������룬�ܷܺ����show����صĽڵ㷶Χ
�����ϸ�˫�ڵ��·����Ȳ�࣬����ȱ����Ϻܷ��㡣

ȱ�㣺
��һ���ַ����б�ʾ����ϵ���ڽڵ��ƶ������Ʒ������Է���

*/

/*һ����Ŀ����Ʒ���*/

--��Ŀ������һ�����׿����ж����Ŀ������
CREATE TABLE [dbo].[FIGL_Bas_AccountScheme](
	[AccountSchemeID] VARCHAR(20) NOT NULL, --��Ŀ��������
	[AccperiodSchemeID] VARCHAR(20) NOT NULL,--��Ʒ�������
	[AccountSchemeCode] VARCHAR(30) NOT NULL,--��Ŀ��������
	[AccountSchemeName] VARCHAR(50) NOT NULL,--����
	[Remark] [nvarchar](200) NULL,--��ע
	[CodeRule] VARCHAR(20) NOT NULL, --�������
	[AllowChildAdd] [bit] NOT NULL,--�Ƿ�����Ǽ���������ӿ�Ŀ
	[AllowChildAddFirst] [bit] NOT NULL,--�Ƿ�����Ǽ����������һ����Ŀ
	[UnityAccountLevel] [bit] NULL,--
	[ControlAccountLevel] [int] NULL,--��Ŀ����
	[AllowUsed] [bit] NOT NULL,--����ʹ��
	[ModifyDTM] [datetime] NOT NULL,--�޸�ʱ��
	[UseSeparator] [bit] NULL,--����
	CONSTRAINT PK_FIGL_Bas_AccountScheme PRIMARY KEY CLUSTERED(AccountSchemeID)
 )

--SELECT * FROM FIGL_Bas_AccountScheme
INSERT INTO FIGL_Bas_AccountScheme
SELECT '000000000001','000000000001','002','�����Ŀ����','','4/2/2/2/2/2/2',1,1,0,0,1,GETDATE(),'0' UNION ALL
SELECT '00000001','00000001','001','��׼��Ŀ����','ϵͳĬ�Ͽ�Ŀ����','4/2/2/2/2/2/2/2/2',1,1,0,0,1,GETDATE(),'0' 

--��Ŀ���
CREATE TABLE [dbo].[FIGL_Bas_AccountType](
	[CompanyID] VARCHAR(20) NOT NULL,
	[AccountTypeID] VARCHAR(20) NOT NULL,
	[AccountTypeCode] VARCHAR(20) NULL,
	[AccountTypeName] VARCHAR(20) NOT NULL,
	[DebitOrCredit] [int] NOT NULL,
	[ParentID] VARCHAR(20) NOT NULL,
	[Level] [smallint] NOT NULL,
	[IsDetail] [bit] NOT NULL,
	[FullName] VARCHAR(20) NULL,
	[FullParentID] VARCHAR(20) NOT NULL,
	[Remark] VARCHAR(20) NULL,
	[AllowUsed] VARCHAR(20) NOT NULL,
	[ModifyDTM] [datetime] NOT NULL,
	CONSTRAINT PK_FIGL_Bas_AccountType PRIMARY KEY CLUSTERED (CompanyID,AccountTypeID)
 )


Insert Into [FIGL_Bas_AccountType] ([CompanyID],[AccountTypeID],[AccountTypeCode],[AccountTypeName],[DebitOrCredit],[ParentID],[Level],[IsDetail],[FullName],[FullParentID],[Remark],[AllowUsed],[ModifyDTM]) Values ('00000000','000000000001',N'01',N'�ʲ�',1,'',1,1,N'�ʲ�','000000000001',N'',1,'03  5 2013 11:46AM')
Insert Into [FIGL_Bas_AccountType] ([CompanyID],[AccountTypeID],[AccountTypeCode],[AccountTypeName],[DebitOrCredit],[ParentID],[Level],[IsDetail],[FullName],[FullParentID],[Remark],[AllowUsed],[ModifyDTM]) Values ('00000000','000000000002',N'02',N'��ծ',-1,'',1,1,N'��ծ','000000000002',N'',1,'03  5 2013 11:46AM')
Insert Into [FIGL_Bas_AccountType] ([CompanyID],[AccountTypeID],[AccountTypeCode],[AccountTypeName],[DebitOrCredit],[ParentID],[Level],[IsDetail],[FullName],[FullParentID],[Remark],[AllowUsed],[ModifyDTM]) Values ('00000000','000000000003',N'03',N'Ȩ��',-1,'',1,1,N'Ȩ��','000000000003',N'',1,'03  5 2013 11:47AM')
Insert Into [FIGL_Bas_AccountType] ([CompanyID],[AccountTypeID],[AccountTypeCode],[AccountTypeName],[DebitOrCredit],[ParentID],[Level],[IsDetail],[FullName],[FullParentID],[Remark],[AllowUsed],[ModifyDTM]) Values ('00000000','000000000004',N'04',N'�ɱ�',1,'',1,1,N'�ɱ�','000000000004',N'',1,'03  5 2013 11:47AM')
Insert Into [FIGL_Bas_AccountType] ([CompanyID],[AccountTypeID],[AccountTypeCode],[AccountTypeName],[DebitOrCredit],[ParentID],[Level],[IsDetail],[FullName],[FullParentID],[Remark],[AllowUsed],[ModifyDTM]) Values ('00000000','000000000005',N'05',N'����',1,'',1,1,N'����','000000000005',N'',1,'03  5 2013 11:48AM')
 Go
 
 --SELECT * FROM FIGL_Bas_AccountType
 
 --��ƿ�Ŀ
create table FIGL_Bas_Account(
companyID varchar(20), --��˾
AccountSchemaID varchar(20),--����
AccountTypeID varchar(20),--���
OrganID	varchar(30),--�������
OrganBookID varchar(30),--�����ʲ�
AccountID varchar(30), --��Ŀ����
Accountcode varchar(100),--��Ŀ����
AccountName varchar(50),--��Ŀ����
constraint PK_FIGL_Bas_Account primary key clustered (companyID,AccountSchemaID,AccountTypeID,AccountID)
)

INSERT INTO FIGL_Bas_Account
select '00000000','00000001','000000000001','','','00000000000001','1001','�ֽ�' union all
select '00000000','00000001','000000000001','','','00000000000002','100101','����' union all
select '00000000','00000001','000000000001','','','00000000000003','100102','Ƥ��' union all
select '00000000','00000001','000000000001','','','00000000000004','1002','���д��' union all
select '00000000','00000001','000000000001','','','00000000000005','100201','����' union all
select '00000000','00000001','000000000001','','','00000000000006','10020101','��������840027925008091001' union all

select 'PT','00000001','000000000001','00000000000001','0000000000000001','00000000000007','1001','�ֽ�' union all
select 'PT','00000001','000000000001','00000000000001','0000000000000001','00000000000008','100101','����' union all
select 'PT','00000001','000000000001','00000000000001','0000000000000001','00000000000009','100102','Ƥ��' union all
select 'PT','00000001','000000000001','00000000000001','0000000000000001','00000000000010','1002','���д��' union all
select 'PT','00000001','000000000001','00000000000001','0000000000000001','00000000000005','100201','����' union all
select 'PT','00000001','000000000001','00000000000001','0000000000000001','00000000000006','10020101','��������840027925008091001'

--SELECT * FROM figl_bas_account
