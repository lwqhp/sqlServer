/*��ѯԼ����Ϣ*/
select * from sys.key_constraints --��������Լ����ΨһԼ������Ϣ
select * from information_schema.check_constraints --checkԼ��
select * from sys.foreign_keys -- ���Լ����Ϣ
select object_name(referenced_object_id) '������',
object_name(parent_object_id) '���Լ����',
 'Լ����' =(select name from sys.columns where a.parent_object_id=object_id and a.parent_column_id=column_id),
* from sys.foreign_key_columns a

select * from information_schema.referential_constraints --���Լ������Ϣ
select * from information_schema.constraint_column_usage--�鿴ָ�����ݿ��е�����Լ������Ϣ�Լ�Լ�����еĶ�Ӧ��ϵ
select * from information_schema.CONSTRAINT_TABLE_USAGE --�鿴���ݿ��е����б��е�Լ����Ϣ
select * from INFORMATION_SCHEMA.table_constraints --��ȡԼ���Ļ�����Ϣ
select * from information_schema.KEY_COLUMN_USAGE --��ȡ��Լ���е���Ϣ


--Լ��
/*
Լ�������ͷ�Ϊ���ࣺ
3.1)��Լ�������Ʊ��ĳһ�л���е�ֵ��Χ������,checkԼ��
3.2)ʵ��Լ�������Ƕ��е�ֵ�������ƣ���ͬ��ֵ���ܴ���������������,����Լ��,ΨһԼ��
3.3)����������Լ����һ�����е�һ������ĳ�����е���һ���е�ֵƥ��,�������Լ��

Լ������
һ���Ǽ�����ˣ���ӳԼ�������壬����
���磺Լ������_Լ�����ڱ���_�ֶ�(����)

�����Ĭ��ֵ
����7.0��ǰ��Լ���������ǲ�����ANSI��׼������ִ�����ܲ���Լ���á��Բ�����ʹ��
Լ���Ǳ�Ĺ��ܣ�����û�д�����ʽ���������Ĭ��ֵ�������ʵ�ʶ��󣬱�����ڣ�Լ�����ڱ����ж���ģ��������
Ĭ��ֵ�ǵ�������ģ�Ȼ�󡰰󶨡������ϡ�

�����Ĭ��ֵ�Ķ�����������ʹ�����ǿ���������ʱ�������¶��塣ʵ���ϣ������Ĭ��ֵ�����ڰ󶨵����ϣ�����Ҳ���԰�
�������������ϣ����������ڲ�����CLR�������� ��sql server�汾�ϴ����߶ȹ��ܻ����û��Զ����������͡�

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
3������Ĭ�ϴ���Ψһ���ۼ�������Ҳ��������������ʱ��ʽָ������һ���Ǿۼ�������
*/
CREATE TABLE sd_pur_ordermaster(
	companyID VARCHAR(20) primary key, --��Լ��
	billno VARCHAR(30) ,
	billStats INT
)

CREATE TABLE sd_pur_ordermaster(
	companyID VARCHAR(20),
	billno VARCHAR(30),
	billStats INT,
	primary key(companyID,billno)--��Լ����������ϼ���ֻ���ñ�Լ��
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
ALTER TABLE sd_pur_ordermaster 
ADD CONSTRAINT FK_sd_pur_ordermaster --Լ����
FOREIGN KEY(billStats) --������Ϊ�������
REFERENCES sys_state(billStats)--��Ϊ�����ı�(����)

--�Ա����Լ��
/*���빹�������ϵ���б��붨��Ϊ����ͬһ���Ⱥ�С��λ��
�������ʱ������������ �Ϳ��Ժ��� foreign key ���
�������õ������ ��������Ϊnull Ҫ���ǲ��������ģ����������е���Ҫ��

һ�����ڱ��ֵݹ��ϵ��
*/
alter table sd_pur_ordermaster 
add constraint FK_sd_pur_ordermaster2 
foreign key(billno) 
references sd_pur_ordermaster(companyID)--companyIDҪ������

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
on delete cascade	--����ɾ��,����ɾ����ͬʱɾ�������Լ��ֵ
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
ΨһԼ��������Լ�����ƣ�������������Լ��Ҫ���в���Ϊnul,��uniqueԼ�������,��ֻ�ܲ���һ��nullֵ����unique������
���е�nullֵ���ǳ���һ���ġ�
uniqueԼ���ڴ�����ʱ��ᴴ��һ���������������������������clustered������nonclustered ,�����ڱ��Ѿ����ھۼ�
������ʱ���ܴ���clustered����
*/

CREATE TABLE sd_pur_ordermaster(billstats VARCHAR(20) NULL UNIQUE)
alter table sd_pur_ordermaster add constraint AK_sd_pur_ordermaster unique(billstats)

--CheckԼ��---------------------------------------------------------------------------------------------------
/*
check��������һ���ض����У�����Լ��һ���У�Ҳ����ͨ��ĳ������Լ����һ����
����checkԼ��ʹ�õĹ�����where�Ӿ��еĻ���һ��
�﷨��
check(logical_expression)
���check���߼����ʽ����ΪT,�оͻᱻ���룬���checkԼ���ı��ʽ����ΪF,�в���ͻ�ʧ�ܡ�
*/

--select * from sd_pur_ordermaster
alter table sd_pur_ordermaster add constraint CK_sd_pur_ordermaster check(billstats between 1 and 12)

--�����ԭ�������Ƿ����Լ������
alter table sd_pur_ordermaster WITH NOCHECK ADD  constraint FK_sd_pur_ordermaster CHECK (billstats between 1 and 12)

insert into sys_state
select 12,'δ֪'

insert into sd_pur_ordermaster
select 'PT',	'PI131117admin-005',12 --��checkԼ��

--��ֹ������Լ��

ALTER TABLE sd_pur_ordermaster NOCHECK CONSTRAINT  FK_sd_pur_ordermaster --��ʱ��ֹ��Լ���ļ��

--�ٴ�����
ALTER TABLE sd_pur_ordermaster CHECK CONSTRAINT  FK_sd_pur_ordermaster

--�������е�check��foreign key 
ALTER TABLE sd_pur_ordermaster NOCHECK CONSTRAINT ALL 

--�������е�check��foreign key
ALTER TABLE sd_pur_ordermaster CHECK CONSTRAINT ALL

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
--�鿴Լ��״̬
EXEC sys.sp_helpconstraint @objname = N'', -- nvarchar(776)
    @nomsg = '' -- varchar(5)


--�������Լ��
--select * from sd_pur_ordermaster

insert into sd_pur_ordermaster
select 'PT','PI131117admin-006',6

alter table sd_pur_ordermaster nocheck constraint FK_sd_pur_ordermaster

--����-------------------------------------------------------------------------------------------------
/*
���������Ĭ��ֵ��Ӧ��Ҫ����CHECK��DEFAULTԼ���������ǽ��ϵ�SQL Server����Լ����һ���֣���ȻҲ����û���ŵ㡣��7.0�汾֮��MicroSoft�г������Ĭ��ֵֻ��Ϊ�������ݣ�����׼�����Ժ����֧��������ԡ���˶��������´���ʱ��Ӧ��ʹ��Լ����

��������Ĭ��ֵ��Լ���ı��������ǣ�Լ����һ���������������û�д�����ʽ���������Ĭ��ֵ�Ǳ�������ʵ�ʶ��󣬱�����ڡ�Լ�����ڱ����ж���ģ��������Ĭ��ֵ�ǵ������壬Ȼ��"�󶨵�"���ϡ�

���������Ĭ��ֵ�Ķ�����������ʹ�����ǿ���������ʱ�������¶��塣ʵ���ϣ������Ĭ��ֵ�����ڱ��󶨵����ϣ�����Ҳ���԰󶨵����������ϡ�

*/
--�鿴��Щ�����������ʹ�ø����Ĺ����Ĭ��ֵ 
EXEC sys.sp_depends  @objname = N'' -- nvarchar(776)


go
Create rule SalaryRule
as @salary >0;
sp_bindrule 'SalaryRule' , 'Employee.Salary' --������Ǳ�������Ҳ�������û�������������

--�鿴����
EXEC sp_helptext SalaryRule
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
--Ĭ��ֵ��defaultԼ�����ƣ������������Ǳ�׷��һ���еķ�ʽ���û��Զ����������͵�Ĭ��ֵ���Ƕ��󣬶�����Լ������֧�֣�

create default salarydefault
as 0;
exec sp_binddefault 'salarydefault' , 'employee.salary';

--ȡ��Ĭ��ֵ��
exec sp_unbinddefault 'employee.salary'

--ɾ��Ĭ��ֵ��
drop default 'salarydefault'


EXEC sp_depends 'dbo.D_T_Numeric6'
