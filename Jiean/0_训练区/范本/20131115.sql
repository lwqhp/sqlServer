

--�û�������������

create type T_Billno from varchar(20) null

drop type T_billno

create type T_Billno_L from varchar(40) not null

drop type T_Billno_L

create type T_Billno from varchar(20) not null

--  �鿴����������Ϣ
select * from information_schema.domains

select * from information_schema.domains

select * from information_schema.domains where DOMAIN_NAME='T_Billno'

--�鿴�û������������͵�ʹ�����
select * from information_schema.column_domain_usage

create type T_Billno_L from varchar(40) null

select * from information_schema.domains

select * from Song

alter table Song add billno T_Billno_L

select * from information_schema.column_domain_usage

--��ֵ���㺯��
select abs(-1234123)

select round(234.3245,2)

select ceiling(234.3245)


select ceiling
