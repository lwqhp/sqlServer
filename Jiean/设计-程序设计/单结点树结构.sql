
--单结点树结构
/*

主要用一列表示节点关系，格式[根节点][子节点1][子节点2]...
需要预先定义节点的格式，统一所有的节点占几位，或者指定位数

优点：
相对于双节点树结构，单结点结省空间，最主要在用于界面只需输入代码，能很方便的show出相关的节点范围
操作上跟双节点的路径深度差不多，在深度遍历上很方便。

缺点：
用一个字符串列表示结点关系，在节点移动，复制方面会相对烦麻

*/

/*一个科目的设计方案*/

--科目方案，一个帐套可以有多个科目管理方案
CREATE TABLE [dbo].[FIGL_Bas_AccountScheme](
	[AccountSchemeID] VARCHAR(20) NOT NULL, --科目方案内码
	[AccperiodSchemeID] VARCHAR(20) NOT NULL,--会计方案内码
	[AccountSchemeCode] VARCHAR(30) NOT NULL,--科目方案代码
	[AccountSchemeName] VARCHAR(50) NOT NULL,--名称
	[Remark] [nvarchar](200) NULL,--备注
	[CodeRule] VARCHAR(20) NOT NULL, --代码规则
	[AllowChildAdd] [bit] NOT NULL,--是否允许非集团帐套添加科目
	[AllowChildAddFirst] [bit] NOT NULL,--是否允许非集团帐套添加一级科目
	[UnityAccountLevel] [bit] NULL,--
	[ControlAccountLevel] [int] NULL,--科目级别
	[AllowUsed] [bit] NOT NULL,--允许使用
	[ModifyDTM] [datetime] NOT NULL,--修改时间
	[UseSeparator] [bit] NULL,--操作
	CONSTRAINT PK_FIGL_Bas_AccountScheme PRIMARY KEY CLUSTERED(AccountSchemeID)
 )

--SELECT * FROM FIGL_Bas_AccountScheme
INSERT INTO FIGL_Bas_AccountScheme
SELECT '000000000001','000000000001','002','财务科目方案','','4/2/2/2/2/2/2',1,1,0,0,1,GETDATE(),'0' UNION ALL
SELECT '00000001','00000001','001','基准科目方案','系统默认科目方案','4/2/2/2/2/2/2/2/2',1,1,0,0,1,GETDATE(),'0' 

--科目类别
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


Insert Into [FIGL_Bas_AccountType] ([CompanyID],[AccountTypeID],[AccountTypeCode],[AccountTypeName],[DebitOrCredit],[ParentID],[Level],[IsDetail],[FullName],[FullParentID],[Remark],[AllowUsed],[ModifyDTM]) Values ('00000000','000000000001',N'01',N'资产',1,'',1,1,N'资产','000000000001',N'',1,'03  5 2013 11:46AM')
Insert Into [FIGL_Bas_AccountType] ([CompanyID],[AccountTypeID],[AccountTypeCode],[AccountTypeName],[DebitOrCredit],[ParentID],[Level],[IsDetail],[FullName],[FullParentID],[Remark],[AllowUsed],[ModifyDTM]) Values ('00000000','000000000002',N'02',N'负债',-1,'',1,1,N'负债','000000000002',N'',1,'03  5 2013 11:46AM')
Insert Into [FIGL_Bas_AccountType] ([CompanyID],[AccountTypeID],[AccountTypeCode],[AccountTypeName],[DebitOrCredit],[ParentID],[Level],[IsDetail],[FullName],[FullParentID],[Remark],[AllowUsed],[ModifyDTM]) Values ('00000000','000000000003',N'03',N'权益',-1,'',1,1,N'权益','000000000003',N'',1,'03  5 2013 11:47AM')
Insert Into [FIGL_Bas_AccountType] ([CompanyID],[AccountTypeID],[AccountTypeCode],[AccountTypeName],[DebitOrCredit],[ParentID],[Level],[IsDetail],[FullName],[FullParentID],[Remark],[AllowUsed],[ModifyDTM]) Values ('00000000','000000000004',N'04',N'成本',1,'',1,1,N'成本','000000000004',N'',1,'03  5 2013 11:47AM')
Insert Into [FIGL_Bas_AccountType] ([CompanyID],[AccountTypeID],[AccountTypeCode],[AccountTypeName],[DebitOrCredit],[ParentID],[Level],[IsDetail],[FullName],[FullParentID],[Remark],[AllowUsed],[ModifyDTM]) Values ('00000000','000000000005',N'05',N'损益',1,'',1,1,N'损益','000000000005',N'',1,'03  5 2013 11:48AM')
 Go
 
 --SELECT * FROM FIGL_Bas_AccountType
 
 --会计科目
create table FIGL_Bas_Account(
companyID varchar(20), --公司
AccountSchemaID varchar(20),--方案
AccountTypeID varchar(20),--类别
OrganID	varchar(30),--会计主体
OrganBookID varchar(30),--主体帐簿
AccountID varchar(30), --科目内码
Accountcode varchar(100),--科目代码
AccountName varchar(50),--科目名称
constraint PK_FIGL_Bas_Account primary key clustered (companyID,AccountSchemaID,AccountTypeID,AccountID)
)

INSERT INTO FIGL_Bas_Account
select '00000000','00000001','000000000001','','','00000000000001','1001','现金' union all
select '00000000','00000001','000000000001','','','00000000000002','100101','朗贤' union all
select '00000000','00000001','000000000001','','','00000000000003','100102','皮革' union all
select '00000000','00000001','000000000001','','','00000000000004','1002','银行存款' union all
select '00000000','00000001','000000000001','','','00000000000005','100201','朗贤' union all
select '00000000','00000001','000000000001','','','00000000000006','10020101','朗贤中行840027925008091001' union all

select 'PT','00000001','000000000001','00000000000001','0000000000000001','00000000000007','1001','现金' union all
select 'PT','00000001','000000000001','00000000000001','0000000000000001','00000000000008','100101','朗贤' union all
select 'PT','00000001','000000000001','00000000000001','0000000000000001','00000000000009','100102','皮革' union all
select 'PT','00000001','000000000001','00000000000001','0000000000000001','00000000000010','1002','银行存款' union all
select 'PT','00000001','000000000001','00000000000001','0000000000000001','00000000000005','100201','朗贤' union all
select 'PT','00000001','000000000001','00000000000001','0000000000000001','00000000000006','10020101','朗贤中行840027925008091001'

--SELECT * FROM figl_bas_account
