1,Ĭ��Լ��
	����Ĭ��Լ��:	create table [default expertion]
			�޸ģ�ALTER TABLE
 
	����Ĭ��Լ������CREATE DEFAULT
			���sp_bindefault

2,����Լ��
	��������Լ����	CHECK()
	�����������	CREATE RULE

3,��ϵԼ��
	������ϵԼ����	PRIMARY KEY  UNIQUE 	UNIQUE
	
Լ������
1.����Լ��
2.������֮��Լ��
3.���ݿ������ݿ�֮���Լ��
һ������ 
1.Լ��������һ��������
2.��Լ�����������������漰һ�������У�������ĳһ�е����ݴ���0��
3.ʵ��Լ����������������ͬ��ֵ���ܴ���������������
4.����������Լ��������һ�����е�һ������ĳ�����е���һ���е�ֵƥ��
�������� 
1.Լ���ǿ��������� һ������������
2.pk_customer_***
3.pk�������� customer�����������ڵı� ���������Լ�����ģ�Ҫȷ���������Ƶ�Ψһ�ԣ�
1.��������Լ��
2.����Լ����һ�����id, һ�����������һ������
����1
use accounting
create table employee
(
id int identity not null,
firstname varchar(20) not null
)
����2
use accounting
alter table employee
add constraint pk_employeeid
primary key (id)

�ģ����Լ�� 
1.���Լ������ȷ�����������Ժ�������֮��Ĺ�ϵ��
�ȿ�����
create table orders
(
id int identity not null primary key,
customerid int not null foreign key references customer(id),
orderdate smalldatetime not null,
eid int not null
)
ע�⣺�����������������һ�����������
�����б���������
alter table orders
add constraint fk_employee_creator_order
foreign key (eid) references employee(employeeid)
ʹ�ñ�������
��������Ҫ��һ�����ݲſ�����ô��
alter table employee
add constraint fk_employee_has_manager
foreign key (managerid) references employee(employeeid)
�������ʱ������������ �Ϳ��Ժ��� foreign key ���
�������õ������ ��������Ϊnull Ҫ���ǲ��������ģ����������е���Ҫ��
һ��������һ������Լ����������ǲ��ܱ�ɾ����
��������
�ȿ�����
create table orderdetails
(
orderid int not null ,
id int not null ,
description varchar(123) not null,
--��������
constraint pkOrderdetails primary key (orderid,id),
--�����������������
constraint fkOrderContainsDetails 
foreign key (orderid)
references orders(orderid)
on update no action
on delete cacade
)
on delete cacade ��ɾ������¼ʱ ͬʱɾ���ü�¼
Ҳ���ǵ�ɾ��orders���е�һ����¼��
��֮��ص�orderdetails���еļ�¼Ҳ����ɾ��
�����������û�����Ƶ�,����ÿ���������������on delete cacade 
no action�ǿ�ѡ��

�壺uniqueԼ�� 
1.uniqueԼ��������Լ�����ƣ�ͬ��Ҳ��Ҫ��ָ��������Ψһ��ֵ
2.����һ�����п����ж��uniqueԼ�����У�ͬʱ������������nullֵ���������һ��nullֵ��
�����ӣ�
create table shippers
(
id int indentity not null primery key,
zip varchar(10) not null ,
phoneno varchar(14) not null unique
)
���Ӷ���
alter table employee
add constraint ak_employeeSSN
unique(ssn)

����checkԼ�� 
1.check��������һ���ض����У�����Լ��һ���У�Ҳ����ͨ��ĳ������Լ����һ����
2.����checkԼ��ʹ�õĹ�����where�Ӿ��еĻ���һ��
������д����
between 1 and 12
like '[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
in ('ups','fed ex','usps')
price >=0
shipdate >= orderdate
�����ӣ�
alter table customers
add constraint cn_customerDateinsystem
check
(dateinsystem <= getdate())
getdate()�����õ���ǰʱ�䣬����������ӵ���˼��dateinsystem�е����ݲ��ܴ��ڵ�ǰʱ��
�������������в���һ�������ʱ�䣬�ͻ����

�ߣ�defaultԼ�� 
1.�������������ڶ�����Ĭ��ֵ������û�и���ֵ����ô������ϵ����ݾ��Ƕ����Ĭ��ֵ
2.Ĭ��ֵֻ��insert�����ʹ��
3.�������ļ�¼����������е�ֵ����ô���е����ݾ��ǲ��������
4.���û�и���ֵ����ô���е���������Ĭ��ֵ
�ˣ�����Լ�� 
1.�ڴ���Լ��֮ǰ�����ݿ����Ѿ���һЩ�����Ϲ�ص����ݴ��ڡ�
2.����Լ��֮���������һЩ�����Ϲ�ص����ݡ�
3.��Щʱ���Ҫ����Լ����primary key �� uniqueԼ�� �������Լ���ǲ��ܽ��õ�
��һ���Ѿ��������ݵı��һ��Լ����
alter table customers 
add constraint cn_customerPhoneNo
check
(phone like '([0-9][0-9][0-9])[0-9][0-9][0-9][0-9][0-9][0-9]')
��������в��������Լ���ļ�¼��sqlserver�ͻᱨ��
�������д���Ͳ��ᱨ����
alter table customers 
with no check
add constraint cn_customerPhoneNo
check
(phone like '([0-9][0-9][0-9])[0-9][0-9][0-9][0-9][0-9][0-9]')
�����Ҫ��һЩ�����Ϲ�ص����ݼ��뵽������ô��
��ʱ�����Ҫ��ʱ�������е�Լ����
alter table customers
nocheck
constraint cn_customerPhoneNo
--�������ײ��룬�˴���������ǰ�涨���
insert into customer (phone) values (123456)
--��ʼ�����ײ��룡
alter table customers
check
constraint cn_customerPhoneNo
--�´β���Ҫ����

�ţ�����
�ȿ����ӣ�
Create rule SalaryRule
as @salary >0;
sp_bindrule 'SalaryRule' , 'Employee.Salary'
��һ�䶨����һ�������SalaryRul
e ���бȽϵ�������һ������
���������ֵ���������е�ֵ
�ڶ���ѹ���󶨵�ĳ�����һ������
�����ckeckԼ�������ƣ�
���ǹ���ֻ������һ������
һ��������԰��ڶ�����ϣ�������������ʶ�������еĴ���
check���Զ���column1>=column2
ȡ������
exec sp_unbindrule 'Employee.Salary'
ɾ������
Drop rule SalaryRule

ʮ��Ĭ��ֵ
Ĭ��ֵ��defaultԼ�����ƣ�������ģ�������˵�������
�ȿ����ӣ�
create default salarydefault
as 0;
exec sp_binddefault 'salarydefault' , 'employee.salary';
ȡ��Ĭ��ֵ��
exec sp_unbinddefault 'employee.salary'
ɾ��Ĭ��ֵ��
drop default 'salarydefault'
