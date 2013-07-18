

 /*
 ������ճ��õĲ��࣬����ʱ��ʱ����������׽������ļ���֪ʶ�㸴ϰһ��

 ����,������Լ��,���
 */
--��������
/*
�﷨�ṹ
CREATE [UNIQUE] [CLUSTERED|NONCLUSTERED] 
    INDEX   index_name
     ON table_name (column_name��)
      [WITH FILLFACTOR=x]
       UNIQUE��ʾΨһ��������ѡ
       CLUSTERED��NONCLUSTERED��ʾ�ۼ��������ǷǾۼ���������ѡ
       FILLFACTOR��ʾ������ӣ�ָ��һ��0��100֮���ֵ����ֵָʾ����ҳ�����Ŀռ���ռ�İٷֱ�

����ͨ�׵İ�
CREATE [��������] INDEX �������� ON ����(����)
WITH FILLFACTOR = �������ֵ0~100

��create index ������Դ��������������ͣ��ۼ������ͷǾۼ�����(Ĭ��������ǷǾۼ�����),�Լ���ΨһԼ���ķǾۼ��������ֽ�Ψһ����

����������Լ����Ĺ�ϵ

��������ڱ���������������ͬʱ����Ĭ������һ���ۼ�����
Ψһ�����Ƕ������е�ΨһԼ���������ж��Ψһ��������Ϊ�䱾���ǷǾۼ�������,����������nullֵ���ڡ�
GO
*/

--ɾ��һ����������ʽ��ָ࣬���������ƺͱ����Ϳ�����
drop index [������] on [����]
drop index [����].[������]


---=====================================================================================================================
Լ���Ǵӱ����ϱ�֤���ݵ�������,����Լ���Ķ�����޸���create table ��alter table ������

Լ����5�֣�
����Լ�� primary key ,Ψһ�ı�ʶ�����ÿһ��,�Ҳ������ֵֵ,һ����ֻ����һ������Լ��,��������Լ����ͬʱ���Զ����ɾۼ�����
���Լ�� foreign key ,һ�����е����������������е��У�ʹ�ô���������ϵ������ָ�������������.
ΨһԼ�� unique ,ָ��������û���ظ�ֵ����ñ���ÿһ��ֵ����ÿһ��ֵ������Ψһ��,����ΨһԼ����ͬʱ���Զ�����Ψһ����
Ĭ��ֵԼ�� default(0) ,�����ǿ�Լ��(not null),�������ɼ�¼��Ĭ��ֵ����
����Լ�� check ,ָ�������Ƿ�����ĳ������

Լ����������
    �Ƽ���Լ�������ǣ�Լ������_����_������
       NN��NOT NULL          �ǿ�Լ��������nn_emp_sal
       UK��UNIQUE KEY         ΨһԼ��
       PK��PRIMARY KEY       ����Լ��
       FK��FOREIGN KEY       ���Լ��
       CK��CHECK             ����Լ��

�﷨��
	constraint [Լ����] Լ������([�ֶ�])
    constraint [Լ����] references �������ֶ�����
--===============================================================
ע���ڴ������ͬʱ����Լ���������ַ�ʽ��
--===============================================================
	1�����м����ͺ���׷��,�����ָ��Լ������ϵͳ���Զ����
create table bas_dept(
	deptID varchar(10) primary key,
	deptName varchar(50) not null,
)

create table bas_constraint_1
(
	empno varchar(10) primary key,
	enmae varchar(20) not null,
	email varchar(30) unique,
	sal decimal(24,6) check(sal>1500),
	deptno varchar(10) references bas_dept(deptID) --�ӱ���references ָ�������ֶ�
)

--ָ��Լ����
create table bas_constraint_2
(
	empno varchar(10) constraint pk_constraint_empno primary key,
	enmae varchar(20) constraint nn_constraint_enmae not null,
	email varchar(30) constraint uk_constraint_email unique,
	sal decimal(24,6) constraint ck_constraint_sal check(sal>1500),
	deptno varchar(10) constraint fk_constraint_deptno references bas_dept(deptID)
)

2)�ڱ����������Լ���������Ǵ������ϼ�Լ��
create table bas_constraint_3
(
	empno varchar(10) ,
	enmae varchar(20) ,
	email varchar(30) ,
	sal decimal(24,6) ,
	deptno varchar(10),
	constraint pk_bas_constraint primary key(empno,enmae),
	constraint uk_bas_constraint unique(email,sal) 
)

--�����������

--�ӱ����������������������У������޷�����
insert into bas_dept(deptID,deptName)
select '5','aaa'

insert into bas_constraint_1(empno,enmae,sal,deptno)
select 'd','c',1600,'5'

--�ӱ��¼��������ɾ���������¼ɾ�������������Ӧ�Ĵӱ��¼
delete from bas_constraint_1

--�������Լ����ϵ���޷��Լ�ֵ���и���
update bas_dept set deptID='6'

--===============================================================
ע���ڽ����ʹ��ALTER TABLE����Լ����
--===============================================================

drop table bas_constraint_4
create table bas_constraint_4
(
	empno varchar(10) not null,
	ename varchar(20),
	email varchar(30),
	sal decimal(24,6) ,
	deptno varchar(10)
)

--������null�����������Լ��
alter table bas_constraint_4 add constraint pk_bas_constraint_4 primary key(empno)

--not null,Ĭ��ֵ Լ��ʹ��alter column
alter table bas_constraint_4 alter column ename varchar(20) not null

--����Ψһ����
alter table bas_constraint_4 add constraint uk_bas_constraint_4 unique(email)

--����checkԼ��
alter table bas_constraint_4 add constraint ck_bas_constraint_4 check(sal>1500)

--�����⽨Լ��
alter table bas_constraint_4 add constraint fk_bas_constraint_4 foreign key(deptno) references bas_dept(deptID)


--���û��������Լ��
alter table bas_constraint_4 nocheck constraint all
alter table bas_constraint_4 check constraint all


---��������or����ָ�������Լ����sql  
select 'ALTER TABLE ' + b.name + ' NOCHECK CONSTRAINT ' + a.name +';'  from sysobjects a ,sysobjects b where a.xtype ='f' and a.parent_obj = b.id and b.name='bas_constraint_4';  
select 'ALTER TABLE ' + b.name + ' CHECK CONSTRAINT ' + a.name +';'  from sysobjects a ,sysobjects b where a.xtype ='f' and a.parent_obj = b.id and b.name='bas_constraint_4'; 


--ɾ��Լ��
alter table bas_constraint_4 drop constraint uk_bas_constraint_4




--�鿴Լ��״̬
select * from sys.foreign_keys
exec sp_helpconstraint 'bas_constraint_4'

    