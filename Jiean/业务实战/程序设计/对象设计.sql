

--�������

/*
ʵ�������ҵ��ķ����ߣ�������ҵ���߼�����������ÿһ��ʵ�����󶼿��ܻ����Լ������Ժ�ֵ��

ʵ����������÷�Ϊ��
1��ҵ����������������ҵ���߼��ķ����ߣ����繫˾���ͻ�����Ӧ��
2��ҵ��Ĵ��������ҵ����ת�д���Ķ��󣬱����Ʒ
3��ҵ��Ŀ��ƶ�����ҵ����������������õĶ���

�����ݿ��У������֯ʵ������������ֵ�أ�

����һЩ�������Ʒ��������ǵ���ȱ�㣺

A)EAV ��--ֵ�ṹ---------------------------------------------------


�ʺϳ�����

ÿһ����ֵ��ռһ����¼���������޵���չ
��ȡ��������ֵ�ȽϷ��㣬ֻ���ṩ�������Ƽ��ɡ�

ȱ�㣺
1��������Լ����ǿ���޷���֤��ֵ�Ե��ظ����֣���Ϊ������ڱ�ṹ�Ͻ���һ�����������Ե�Լ������֤��������Ψһ�ԡ�
2���޷�����ǿ�����ԣ���Ϊ��ͬ������ֵ������һ���ϣ����ܶ�ֵ����Լ����ֻ����ʹ��ͨ���������ͣ������ַ���������������ԡ�
3������-ֵ���ţ���������������ò�ʹ�ö�ι���������ֵ������ʾ��

Ӧ�ã�
������ƽṹ��Ҫ�����ڼ�-ֵ���ϵĿ���չ�ԣ�һ�����ڿ��ƶ������������ǲ����ļ��ϣ���-ֵ����չ���ǲ������ϵ��ص�.

Ϊ�˽����ֵ�����Ե�Լ������Ҫ�����ӱ����Լ����

����Ӧ�ã�
*/

--�����������еĲ����ļ���������������ID,���ӿ����в���������˵���ȡ�
create table Sys_ParameterItem(
SysParaID varchar(20)		--����ID
,SysParaCode varchar(20)	--����code
,ItemIndex INT				--����
,SysParaName varchar(40)	--��������
,Remark varchar(100)		--˵��
,PRIMARY KEY(SysParaID)
)

--�ӱ�:�����������ID��������Ӧ������-ֵ
CREATE TABLE Sys_ParameterDetail(
	companyID VARCHAR(20), --��˾
	sysParaID VARCHAR(20), --����ID
	SysParacode  VARCHAR(20), --����code
	SysParaValue VARCHAR(40)	--ֵ
	,PRIMARY KEY(companyID,sysParaID)
)

-------------------
/*
B)����̳�
��ר���ڶ�������ԺͶ������ͬһ�����У���������ʾ����ĸ�����-ֵ

�ŵ㣺���Ը��Ŷ����ߣ���������
ȱ�㣺����������Ҫ�޸ı�ṹ�����Ϊ�����������õ���������ҲҪ�����ж���������У�ֵΪ�ա�������

ʹ�þ�������Ҫ���ڶ�����ר�����ԣ�������һ��̶����䡣

Ӧ�ã�
*/
--��������-��˾
create table Bas_company(
	companyID varchar(20),	--����ID
	companyCode varchar(20),--����code
	companyName varchar(40),--��˾����
	shortName varchar(20),	--���
	Fax varchar(20),		--����
	Email varchar(20),		--�ʼ�
	Telphone varchar(20)	--�绰
)

/*--------------------------------------------------
C��ʵ��̳�
���ǶԵ���̳���Ƶ���չ,����������԰������۷ֵ���һ������.����ͨ�����������

1)��ϸ��:���������Ϣ��������ϸ����������ϸ����.
2)��ֵ���Ѷ������ϸ�����۷ֵ���ֵ���С�

*/

--����-��Ӧ��
--2.1)����
create table Bas_InterCompany(
	companyID varchar(20),	--��˾
	vendcustID varchar(20),	--��Ӧ��ID
	parentID varchar(20),	--��ID
	fullName varchar(20),	--ȫ��
	vendcustname varchar(20),--��Ӧ������
	checker varchar(20),	--�����
	checkState varchar(20),--���״̬
	lockState varchar(20),--����״̬
	AllowUsed varchar(20),--ʹ��״̬
	Remark varchar(20) --��ע
)
--2.1)��ϸ��
create table Bas_InterCompanyParam(
	companyID varchar(20),	--��˾
	VendCustID varchar(20),--��Ӧ��ID
	AccAmount varchar(20),--���ý��
	remark varchar(20),--��ע
	ModifyDTM varchar(20),--�޸�ʱ��
	AmtCalModeID varchar(20)--�����㷽ʽ
)

--2.2)��ֵ��
/*��Ӧ�̶����Լ��Ľ����㷽ʽ,���������㷽ʽ���ƣ�ֵ1��ֵ2������۸�С����λ�������С����λ��
�����ۼƣ�
vendcustID,AmtCalMode,PriceDecimalDigits,AmtDecimalDigits
PT0001		������λС����  2,2
PT0002		����һλС����  1,2
*/

--ʵ���ֵ�����
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

--�����������
/*vendcustID,AmtCalModeID
PT0001		0001
PT0002		0002
*/

--D)����̳�---------------------------------------------
/*
�����ɶ���Ӷ�����ɣ�ÿһ���Ӷ���̳и����󣬸��Ӷ�����м̳й�ϵ,�����������Ǵ洢�Ӷ�������.

����һ�������ɶ��С���󹹳�һ�����壬�������
*/

--��Ʒ������
create table SD_Mat_Material(
	materialID varchar(20), --��ƷID
	materialCode varchar(20),--��Ʒ����
	materialName varchar(20),--��Ʒ����
	cardid varchar(20),	--Ʒ��ID
	kindid varchar(20),--���ID
	seriesid varchar(20),--ϵ��ID
	modelid varchar(20) --��ʽID
)

--�Ӷ���
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

---��������ֵ---------------------------------------
/*
ÿһ�������п��ܻ��ж�����ԣ������Ʒ������,������1,������2,������3,������4,���ֲ���ÿһ����Ʒ������ȫ�����С�

������Ʒ���Ա�����Ӧÿ����Ʒ�ļ۸����EAVҲ��Щ��ͬ
*/

--��Ʒ�����Ա�
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
