

--用户定义数据类型

create type T_Billno from varchar(20) null

drop type T_billno

create type T_Billno_L from varchar(40) not null

drop type T_Billno_L

create type T_Billno from varchar(20) not null

--  查看数据类型信息
select * from information_schema.domains

select * from information_schema.domains

select * from information_schema.domains where DOMAIN_NAME='T_Billno'

--查看用户定义数据类型的使用情况
select * from information_schema.column_domain_usage

create type T_Billno_L from varchar(40) null

select * from information_schema.domains

select * from Song

alter table Song add billno T_Billno_L

select * from information_schema.column_domain_usage

--数值运算函数
select abs(-1234123)

select round(234.3245,2)

select ceiling(234.3245)


select ceiling
