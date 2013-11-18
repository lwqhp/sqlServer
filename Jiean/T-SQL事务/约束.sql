/*��ѯԼ����Ϣ*/
select * from sys.key_constraints --��������Լ����ΨһԼ������Ϣ
select * from information_schema.check_constraints --checkԼ��
select * from sys.foreign_keys -- ���Լ����Ϣ
select * from sys.foreign_key_columns

--Լ��
/*
Լ�������ͷ�Ϊ���ࣺ
3.1)��Լ�������Ʊ��ĳһ�л���е�ֵ��Χ������,checkԼ��
3.2)ʵ��Լ�������Ƕ��е�ֵ�������ƣ���ͬ��ֵ���ܴ���������������,����Լ��,ΨһԼ��
3.3)����������Լ����һ�����е�һ������ĳ�����е���һ���е�ֵƥ��,�������Լ��

Լ������
һ���Ǽ�����ˣ���ӳԼ�������壬����
���磺Լ������_Լ�����ڱ���_�ֶ�(����)

*/
--��ϰ��
--״̬��
CREATE TABLE sys_state(
	billStats INT,
	billStatsName VARCHAR(20),
	PRIMARY KEY(billStats) 
)
--���״̬������
ALTER TABLE sys_state ALTER COLUMN  billStats INT NOT NULL 
ALTER TABLE sys_state ADD CONSTRAINT PI_sys_state PRIMARY KEY(billStats)

--����
CREATE TABLE sd_pur_ordermaster(
	companyID VARCHAR(20),
	billno VARCHAR(30),
	billStats INT 
)
go
--��Ӽ�¼
INSERT INTO sys_state
SELECT 0,'δ����' UNION ALL
SELECT 1,'������' UNION ALL
SELECT 2,'δ���' UNION ALL
SELECT 4,'�����' 


INSERT INTO sd_pur_ordermaster
SELECT 'PT','PI131117admin-001',0 UNION ALL 
SELECT 'PT','PI131117admin-002',1 UNION ALL 
SELECT 'PT','PI131117admin-003',2 UNION ALL 
SELECT 'PT','PI131117admin-004',4


--drop table sd_pur_ordermaster
--����Լ��--------------------------------------------------------------------------
/*
1,������ʱ�򴴽�����(һ�������ֶεĺ�����ϣ���һ�����������,���ַ�ʽ����ͬʱ����������)
2,�޸ı�ṹ�ķ�ʽ����������������Ҫ���������ֶ���"����Ϊ��"��
*/
CREATE TABLE sd_pur_ordermaster(
	companyID VARCHAR(20) primary key,
	billno VARCHAR(30) ,
	billStats INT
)

CREATE TABLE sd_pur_ordermaster(
	companyID VARCHAR(20),
	billno VARCHAR(30),
	billStats INT,
	primary key(companyID,billno)
)

alter table sd_pur_ordermaster alter column companyID VARCHAR(20) not null 
alter table sd_pur_ordermaster add constraint PK_sd_pur_ordermaster_companyID primary key(companyID)

go
--���Լ��--------------------------------------------------------------------------------------
/*
���ڱ�֤����������ı����Ϣ�����ԣ�Լ�����⽨��һ���ԡ�

ע����ʵ�����ǲ������������Լ�������ٳ���ԱΪ�˷��㣬��֤����������ı�����ݲ����ֹ�������(��������������Ѹ�)
�����ñ����������Լ�����£��������и�ȱ�㣬�ѱ���������Ӧ��Ҫ���ļ�鶪�������ݿ⣬���������ݿ��ѹ����2��������
ҵ���߼������Ӳ��������Ѷȡ�

һЩСӦ�ã�����һ��ʹ��״̬�ֶΣ����Թܿز�����Ҫ��״̬����ʾ������

���Լ�������ֲ�����
2.1)Լ��������õ�һ����
2.2)�⽡�������������޸��������¼����ͬʱ�޸������Լ���ı��¼
*/

--drop table sd_pur_ordermaster
CREATE TABLE sd_pur_ordermaster(
	companyID VARCHAR(30),
	billno VARCHAR(30),
	billStats INT FOREIGN KEY REFERENCES sys_state(billStats) --���Լ��
)

--������Լ��
ALTER TABLE sd_pur_ordermaster ADD CONSTRAINT FK_sd_pur_ordermaster FOREIGN KEY(billStats) REFERENCES sys_state(billStats)

--�Ա����Լ��
/*���빹�������ϵ���б��붨��Ϊ����ͬһ���Ⱥ�С��λ��
�������ʱ������������ �Ϳ��Ժ��� foreign key ���
�������õ������ ��������Ϊnull Ҫ���ǲ��������ģ����������е���Ҫ��
*/
alter table sd_pur_ordermaster add constraint FK_sd_pur_ordermaster2 foreign key(billno) references sd_pur_ordermaster(companyID)--companyIDҪ������

--ɾ���������˵�������¼
DELETE sys_state --����

--��Ҫ��ɾ�����Լ����¼����Ӧ�ļ�¼�󣬲���ɾ��������¼
DELETE sd_pur_ordermaster WHERE billStats=4

DELETE sys_state WHERE billStats=4

--����������(�������˲����޸�)
UPDATE sys_state SET billStats=5 WHERE billStats=2 --����


-->>>>>2.2)��������
/*
Լ��δβ����
on update cascade --�������£��������£�ͬʱ���������Լ��ֵ
on delete cacade	--����ɾ��,����ɾ����ͬʱɾ�������Լ��ֵ
*/

select * from sys_state
select * from sd_pur_ordermaster


--alter table sd_pur_ordermaster drop constraint FK_sd_pur_ordermaster
alter table sd_pur_ordermaster add constraint FK_sd_pur_ordermaster 
foreign key(billStats) references sys_state(billStats) on update cascade

alter table sd_pur_ordermaster add constraint FK_sd_pur_ordermaster 
foreign key(billStats) references sys_state(billStats) on delete cascade

update sys_state set billStats=5  where billStats=0
delete sys_state where billStats=1

--ΨһԼ��---------------------------------------------------------------------------------------------------
/*
Unique
ΨһԼ��������Լ�����ƣ�������������Լ��Ҫ���в���Ϊnul,��uniqueԼ�������
*/

alter table sd_pur_ordermaster add constraint AK_sd_pur_ordermaster unique(billstats)

--CheckԼ��---------------------------------------------------------------------------------------------------
/*
check��������һ���ض����У�����Լ��һ���У�Ҳ����ͨ��ĳ������Լ����һ����
����checkԼ��ʹ�õĹ�����where�Ӿ��еĻ���һ��
*/

--select * from sd_pur_ordermaster
alter table sd_pur_ordermaster add constraint CK_sd_pur_ordermaster check(billstats between 1 and 12)

insert into sys_state
select 12,'δ֪'

insert into sd_pur_ordermaster
select 'PT',	'PI131117admin-005',12 --��checkԼ��

/*
����
between 1 and 12
like '[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
in ('ups','fed ex','usps')
price >=0
shipdate >= orderdate
dateinsystem <= getdate()
*/


--defaultԼ�� --------------------------------------------------------------------------------
/*
1.�������������ڶ�����Ĭ��ֵ������û�и���ֵ����ô������ϵ����ݾ��Ƕ����Ĭ��ֵ
2.Ĭ��ֵֻ��insert�����ʹ��
3.�������ļ�¼����������е�ֵ����ô���е����ݾ��ǲ��������
4.���û�и���ֵ����ô���е���������Ĭ��ֵ
*/
CREATE TABLE sd_pur_ordermaster(
	companyID VARCHAR(20),
	billno VARCHAR(30),
	billStats INT default(0)
)

alter table sd_pur_ordermaster add constraint DF_sd_pur_ordermaster  default(0) for billstats



--����Լ��------------------------------------------------------------------------------------------ 
/* 
primary key �� uniqueԼ�� �������Լ���ǲ��ܽ��õ�
��ϵͳ��Ϣ����Կ�����������unique�ǲ��ܽ��õģ�checkԼ�������Լ���ǿ��Խ��õ�
*/

--�������Լ��
--select * from sd_pur_ordermaster

insert into sd_pur_ordermaster
select 'PT','PI131117admin-006',6

alter table sd_pur_ordermaster nocheck constraint FK_sd_pur_ordermaster

--����-------------------------------------------------------------------------------------------------
go
Create rule SalaryRule
as @salary >0;
sp_bindrule 'SalaryRule' , 'Employee.Salary'

/*��һ�䶨����һ�������SalaryRul
e ���бȽϵ�������һ������
���������ֵ���������е�ֵ
�ڶ���ѹ���󶨵�ĳ�����һ������
�����ckeckԼ�������ƣ�
���ǹ���ֻ������һ������
һ��������԰��ڶ�����ϣ�������������ʶ�������еĴ���
check���Զ���column1>=column2
*/
--ȡ������
exec sp_unbindrule 'Employee.Salary'
--ɾ������
Drop rule SalaryRule

--Ĭ��ֵ--------------------------------------------------------------------------------------------
--Ĭ��ֵ��defaultԼ�����ƣ�������ģ�������˵�������

create default salarydefault
as 0;
exec sp_binddefault 'salarydefault' , 'employee.salary';

--ȡ��Ĭ��ֵ��
exec sp_unbinddefault 'employee.salary'

--ɾ��Ĭ��ֵ��
drop default 'salarydefault'

