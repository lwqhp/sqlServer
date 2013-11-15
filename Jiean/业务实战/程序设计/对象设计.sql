

--对象设计

/*
实体对象是业务的发起者，他们是业务逻辑的主导对象，每一个实体以象都可能会有自己的属性和值。

实体对象其作用分为：
1）业务主导对象：他们是业务逻辑的发起者，比如公司，客户，供应商
2）业务的处理对象：是业务流转中处理的对象，比如货品
3）业务的控制对象：是业务流程中起控制作用的对象。

在数据库中，如何组织实体对象的性属和值呢？

介绍一些对象的设计方法及他们的优缺点：

A)EAV 键--值结构---------------------------------------------------


适合场景：

每一个键值对占一条记录，可以无限的扩展
获取单个属性值比较方便，只需提供属性名称即可。

缺点：
1，完整性约束不强，无法保证键值对的重复出现，因为你很难在表结构上建立一个数据完整性的约束来保证的属生的唯一性。
2，无法声明强制属性，因为不同的属性值都存于一列上，不能对值进行约束，只能是使用通用数据类型，比如字符型来兼顾所有属性。
3，属性-值横排，对这种情况，不得不使用多次关联让属性值横排显示。

应用：
这种设计结构主要体现在键-值对上的可扩展性，一般用于控制对象，这类对象多是参数的集合，键-值，扩展，是参数集合的特点.

为了解决键值完整性的约束，需要建主从表进行约束。

具体应用：
*/

--主表：定义所有的参数的键名，主键是内码ID,附加可以有参数的描述说明等。
create table Sys_ParameterItem(
SysParaID varchar(20)		--内码ID
,SysParaCode varchar(20)	--代码code
,ItemIndex INT				--排序
,SysParaName varchar(40)	--参数名称
,Remark varchar(100)		--说明
,PRIMARY KEY(SysParaID)
)

--从表:外键主表内码ID，设置相应的属性-值
CREATE TABLE Sys_ParameterDetail(
	companyID VARCHAR(20), --公司
	sysParaID VARCHAR(20), --内码ID
	SysParacode  VARCHAR(20), --代码code
	SysParaValue VARCHAR(40)	--值
	,PRIMARY KEY(companyID,sysParaID)
)

-------------------
/*
B)单表继承
把专属于对象的属性和对象放在同一个表中，用列名表示对象的各属性-值

优点：属性跟着对象走，操作方便
缺点：增加属性需要修改表结构，如果为单个对象设置单独属生，也要在所有对象上添加列，值为空。不够灵活。

使用景场：主要用于对象有专属属性，而属性一般固定不变。

应用：
*/
--主导对象-公司
create table Bas_company(
	companyID varchar(20),	--内码ID
	companyCode varchar(20),--代码code
	companyName varchar(40),--公司名称
	shortName varchar(20),	--简称
	Fax varchar(20),		--传真
	Email varchar(20),		--邮件
	Telphone varchar(20)	--电话
)

/*--------------------------------------------------
C）实体继承
这是对单表继承设计的扩展,将对象的属性按功能折分到另一个表中.两表通过主外键关联

1)明细表:对象基础信息存主表，明细表保存对象的明细参数.
2)键值表：把对象的明细参数折分到键值表中。

*/

--对象-供应商
--2.1)主表
create table Bas_InterCompany(
	companyID varchar(20),	--公司
	vendcustID varchar(20),	--供应商ID
	parentID varchar(20),	--父ID
	fullName varchar(20),	--全称
	vendcustname varchar(20),--供应商名称
	checker varchar(20),	--审核人
	checkState varchar(20),--审核状态
	lockState varchar(20),--锁定状态
	AllowUsed varchar(20),--使用状态
	Remark varchar(20) --备注
)
--2.1)明细表
create table Bas_InterCompanyParam(
	companyID varchar(20),	--公司
	VendCustID varchar(20),--供应商ID
	AccAmount varchar(20),--可用金额
	remark varchar(20),--备注
	ModifyDTM varchar(20),--修改时间
	AmtCalModeID varchar(20)--金额计算方式
)

--2.2)键值表
/*供应商都有自己的金额计算方式,包括金额计算方式名称，值1，值2，比如价格小数点位数，金额小数点位数
单表役计：
vendcustID,AmtCalMode,PriceDecimalDigits,AmtDecimalDigits
PT0001		保留两位小数，  2,2
PT0002		保留一位小数，  1,2
*/

--实体键值表设计
create table SD_Bas_AmtCalcMode(
	companyID  varchar(20),
	AmtCalcModeID varchar(20),
	AmtCalcModeCode varchar(20),
	AmtCalcmodeName varchar(20),
	PriceDecimalDigits varchar(20),
	AmtDecimalDigits varchar(20),
	allowUsed varchar(20),
	ModifyDtm varchar(20)
)

--主表引用外键
/*vendcustID,AmtCalModeID
PT0001		0001
PT0002		0002
*/

--D)对象继承---------------------------------------------
/*
对象由多个子对象组成，每一个子对象继承父对象，父子对象间有继承关系,在主对象上是存储子对象的外键.

用于一个对象由多个小对象构成一个整体，比如货号
*/

--货品主对象
create table SD_Mat_Material(
	materialID varchar(20), --货品ID
	materialCode varchar(20),--货品代码
	materialName varchar(20),--货品名称
	cardid varchar(20),	--品牌ID
	kindid varchar(20),--类别ID
	seriesid varchar(20),--系列ID
	modelid varchar(20) --款式ID
)

--子对象
create table SD_Mat_Card(
	cardID  varchar(20),
	cardCode  varchar(20),
	cardname varchar(20),
	FullName varchar(20),
	remark varchar(20),
	allowused varchar(20),
	modifydtm varchar(20)
)

create table SD_Mat_kind(
	kindID  varchar(20),
	kindCode  varchar(20),
	kindname varchar(20),
	remark varchar(20),
	allowused varchar(20),
	modifydtm varchar(20)
)

---多列属性值---------------------------------------
/*
每一个对象都有可能会有多个属性，比如货品批发价,批发价1,批发价2,批发价3,批发价4,而又不是每一个货品都必须全部都有。

创建货品属性表来对应每个货品的价格，这个EAV也有些不同
*/

--货品的属性表
create table SD_Mat_MaterialPrice(
	companyId varchar(20),
	PriceModeID int,
	MaterialID varchar(20),
	Price money,
	checkDate datetime,
	checker varchar(20),
	allowused bit,
	modifyDTM datetime
)
