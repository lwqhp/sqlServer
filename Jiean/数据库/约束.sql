1,默认约束
	创建默认约束:	create table [default expertion]
			修改：ALTER TABLE
 
	创建默认约束对象CREATE DEFAULT
			邦定：sp_bindefault

2,规则约束
	创建规则约束：	CHECK()
	创建规则对象：	CREATE RULE

3,关系约束
	创建关系约束：	PRIMARY KEY  UNIQUE 	UNIQUE
	
约束分类
1.单表约束
2.表与表表之间约束
3.数据库与数据库之间的约束
一：类型 
1.约束的类型一共分三种
2.域约束：　　　　　　涉及一个或多个列，（限制某一列的数据大于0）
3.实体约束：　　　　　相同的值不能存在于其他的行中
4.引用完整性约束：　　一个表中的一个列与某个表中的另一个列的值匹配
二：命名 
1.约束是可以命名的 一般这样命名：
2.pk_customer_***
3.pk代表主键 customer代表主键所在的表 后面是你自己定义的（要确保整个名称的唯一性）
1.三：主键约束
2.主键约束：一般就是id, 一个表中最多有一个主键
例子1
use accounting
create table employee
(
id int identity not null,
firstname varchar(20) not null
)
例子2
use accounting
alter table employee
add constraint pk_employeeid
primary key (id)

四：外键约束 
1.外键约束用在确保数据完整性和两个表之间的关系上
先看例子
create table orders
(
id int identity not null primary key,
customerid int not null foreign key references customer(id),
orderdate smalldatetime not null,
eid int not null
)
注意：这个表的外键必须是另一个表的主键！
在现有表上添加外键
alter table orders
add constraint fk_employee_creator_order
foreign key (eid) references employee(employeeid)
使用表自引用
表内至少要有一行数据才可以这么做
alter table employee
add constraint fk_employee_has_manager
foreign key (managerid) references employee(employeeid)
创建表的时候做表自引用 就可以忽略 foreign key 语句
表自引用的外键列 必须允许为null 要不是不允许插入的（避免对最初行的需要）
一个表与另一个表有约束，这个表是不能被删除的
级联操作
先看例子
create table orderdetails
(
orderid int not null ,
id int not null ,
description varchar(123) not null,
--设置主键
constraint pkOrderdetails primary key (orderid,id),
--设置外键，级联操作
constraint fkOrderContainsDetails 
foreign key (orderid)
references orders(orderid)
on update no action
on delete cacade
)
on delete cacade 当删除父记录时 同时删除该记录
也就是当删除orders表中的一条记录，
与之相关的orderdetails表中的记录也将被删除
级联的深度是没有限制的,但是每个外键都必须设置on delete cacade 
no action是可选的

五：unique约束 
1.unique约束与主键约束类似，同样也是要求指定的列有唯一的值
2.但是一个表中可以有多个unique约束的列，同时这个列允许存在null值。（最多有一个null值）
看例子：
create table shippers
(
id int indentity not null primery key,
zip varchar(10) not null ,
phoneno varchar(14) not null unique
)
例子二：
alter table employee
add constraint ak_employeeSSN
unique(ssn)

六：check约束 
1.check不局限于一个特定的列，可以约束一个列，也可以通过某个列来约束另一个列
2.定义check约束使用的规则与where子句中的基本一样
下面我写几个
between 1 and 12
like '[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
in ('ups','fed ex','usps')
price >=0
shipdate >= orderdate
看例子：
alter table customers
add constraint cn_customerDateinsystem
check
(dateinsystem <= getdate())
getdate()函数得到当前时间，上面这个例子的意思是dateinsystem列的数据不能大于当前时间
现在如果给这个列插入一个明天的时间，就会出错

七：default约束 
1.如果插入的新行在定义了默认值的列上没有给出值，那么这个列上的数据就是定义的默认值
2.默认值只在insert语句中使用
3.如果插入的记录给出了这个列的值，那么该列的数据就是插入的数据
4.如果没有给出值，那么该列的数据总是默认值
八：禁用约束 
1.在创建约束之前，数据库中已经有一些不符合规矩的数据存在。
2.创建约束之后，又想加入一些不符合规矩的数据。
3.这些时候就要禁用约束。primary key 和 unique约束 这对孪生约束是不能禁用的
对一个已经存在数据的表加一个约束：
alter table customers 
add constraint cn_customerPhoneNo
check
(phone like '([0-9][0-9][0-9])[0-9][0-9][0-9][0-9][0-9][0-9]')
如果表内有不符合这个约束的记录，sqlserver就会报错
如果这样写，就不会报错了
alter table customers 
with no check
add constraint cn_customerPhoneNo
check
(phone like '([0-9][0-9][0-9])[0-9][0-9][0-9][0-9][0-9][0-9]')
如果需要把一些不符合规矩的数据加入到表中怎么办
这时候就需要临时禁用现有的约束：
alter table customers
nocheck
constraint cn_customerPhoneNo
--允许不带套插入，此处的名称是前面定义的
insert into customer (phone) values (123456)
--开始不带套插入！
alter table customers
check
constraint cn_customerPhoneNo
--下次插入要带套

九：规则
先看例子：
Create rule SalaryRule
as @salary >0;
sp_bindrule 'SalaryRule' , 'Employee.Salary'
第一句定义了一个规则叫SalaryRul
e 进行比较的事物是一个变量
这个变量的值是所检查的列的值
第二句把规则绑定到某个表的一个列上
规则和ckeck约束很相似，
但是规则只作用在一个列上
一个规则可以绑定在多个列上，但是它不会意识到其他列的存在
check可以定义column1>=column2
取消规则
exec sp_unbindrule 'Employee.Salary'
删除规则
Drop rule SalaryRule

十：默认值
默认值与default约束类似（有区别的，但是我说不清楚）
先看例子：
create default salarydefault
as 0;
exec sp_binddefault 'salarydefault' , 'employee.salary';
取消默认值：
exec sp_unbinddefault 'employee.salary'
删除默认值：
drop default 'salarydefault'
