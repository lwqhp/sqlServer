
/*�ڲ�ѯ����� ���䲻����������������û�з�������ҵ��ļ�¼*/

--������������
/*
where����ɸѡ����Բ����ϵļ�¼,���Ҫ��û�������õ�����Ҳͳ����ʾ��
group by ������ ALL(ֻ����select��仹����where�Ӿ�ʱ��all�ؼ��ֲ�������)
�Ѳ�ѯ���������������ֶ��У�ʹ��case��������������

*/
--1)��group by ���� all

--2)�Ѳ�ѯ��������������sum�����У�ʹ��Case ��������������

select employers,
	sale = sum(
		case when sale_price >=1000 then sale_rice
		else 0
)	
	from orders
	group by employers
	
--��������
--�ڱ�������ʾû��ҵ�����������ݣ�һ���Ƕ���һ����������������б�Ȼ����ʵ��������left join �õ����ս��.


DECLARE @dept TABLE(id int,name varchar(10))
INSERT INTO @dept SELECT 1,'A����'
union all 		select 2,'B����'
UNION all		SELECT 3,'C����'

declare @employees table(id int,name varchar(10),deptid int)
insert into @employees select 1,'����',1
union all			select 2,'����',1
union all			select 3,'����',2

declare @orders table (id int,employeesid int,sale_price decimal(10,2),date datetime)
insert into @orders select 1,1,100.00,'2005-1-1'
union all		select 2,1,90.00,'2005-3-1'
union all		select 3,2,80.00,'2005-3-1'
union all		select 4,2,90.00,'2005-3-7'
union all		select 5,2,40.00,'2005-4-1'
union all		select 6,2,55.00,'2005-5-7'

select m.[month],d.id,d.name,
sales = sum(o.sale_price)
from @dept d
cross join (
	select [month] =1 union all
	select [month] =2 union all
	select [month] =3 union all
	select [month] =4 union all
	select [month] =5 union all
	select [month] =6
)m
left join @employees e
	on d.id = e.deptid
left join @orders o
	on e.id = o.employeesid
	and o.date>=stuff('2005--1',6,0,m.[month])
	AND o.date<stuff('2005--1',6,0,m.[month]+1)
GROUP BY m.[month],d.id,d.name

