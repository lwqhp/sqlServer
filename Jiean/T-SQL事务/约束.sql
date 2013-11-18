/*查询约束信息*/
select * from sys.key_constraints --保存主键约束和唯一约束的信息
select * from information_schema.check_constraints --check约束
select * from sys.foreign_keys -- 外键约束信息
select * from sys.foreign_key_columns

--约束
/*
约束按类型分为三类：
3.1)域约束：限制表的某一列或多列的值范围，比如,check约束
3.2)实体约束：这是对行的值进行限制，相同的值不能存在于其他的行中,主键约束,唯一约束
3.3)引用完整性约束：一个表中的一个列与某个表中的另一个列的值匹配,比如外键约束

约束命名
一般是简结明了，反映约束对象含义，名称
比如：约束类型_约束所在表名_字段(或含义)

*/
--练习表
--状态表
CREATE TABLE sys_state(
	billStats INT,
	billStatsName VARCHAR(20),
	PRIMARY KEY(billStats) 
)
--添加状态表主键
ALTER TABLE sys_state ALTER COLUMN  billStats INT NOT NULL 
ALTER TABLE sys_state ADD CONSTRAINT PI_sys_state PRIMARY KEY(billStats)

--主表
CREATE TABLE sd_pur_ordermaster(
	companyID VARCHAR(20),
	billno VARCHAR(30),
	billStats INT 
)
go
--添加记录
INSERT INTO sys_state
SELECT 0,'未送审' UNION ALL
SELECT 1,'已送审' UNION ALL
SELECT 2,'未审核' UNION ALL
SELECT 4,'已审核' 


INSERT INTO sd_pur_ordermaster
SELECT 'PT','PI131117admin-001',0 UNION ALL 
SELECT 'PT','PI131117admin-002',1 UNION ALL 
SELECT 'PT','PI131117admin-003',2 UNION ALL 
SELECT 'PT','PI131117admin-004',4


--drop table sd_pur_ordermaster
--主键约束--------------------------------------------------------------------------
/*
1,定义表的时候创建主键(一种是在字段的后面加上，另一种是在最后定义,这种方式可以同时定义多个主键)
2,修改表结构的方式创建主键，但必须要加主键的字段是"不可为空"的
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
--外键约束--------------------------------------------------------------------------------------
/*
用于保证引用了外键的表的信息完整性，约束主外建的一致性。

注：事实上我们并不建议用外键约束，不少程序员为了方便，保证引用了外键的表的数据不出现孤立数据(即主键表的数据已改)
在引用表上增加外键约束了事，但这样有个缺点，把本来程序里应该要做的检查丢给了数据库，增加了数据库的压力，2，隐藏了
业务逻辑，增加查找问题难度。

一些小应用，增加一个使用状态字段，可以管控不再需要的状态不显示出来。

外键约束有两种操作：
2.1)约束外键引用的一致性
2.2)外健的联级操作：修改主键表记录，会同时修改有外键约束的表记录
*/

--drop table sd_pur_ordermaster
CREATE TABLE sd_pur_ordermaster(
	companyID VARCHAR(30),
	billno VARCHAR(30),
	billStats INT FOREIGN KEY REFERENCES sys_state(billStats) --外键约束
)

--添加外键约束
ALTER TABLE sd_pur_ordermaster ADD CONSTRAINT FK_sd_pur_ordermaster FOREIGN KEY(billStats) REFERENCES sys_state(billStats)

--自表外键约束
/*参与构造外键关系的列必须定义为具有同一长度和小数位数
创建表的时候做表自引用 就可以忽略 foreign key 语句
表自引用的外键列 必须允许为null 要不是不允许插入的（避免对最初行的需要）
*/
alter table sd_pur_ordermaster add constraint FK_sd_pur_ordermaster2 foreign key(billno) references sd_pur_ordermaster(companyID)--companyID要是主键

--删除已引用了的主键记录
DELETE sys_state --出错

--需要先删除外键约束记录中相应的记录后，才能删除主键记录
DELETE sd_pur_ordermaster WHERE billStats=4

DELETE sys_state WHERE billStats=4

--改主键名称(已引用了不能修改)
UPDATE sys_state SET billStats=5 WHERE billStats=2 --出错


-->>>>>2.2)联级操作
/*
约束未尾声明
on update cascade --联级更新，主键更新，同时更新受外键约束值
on delete cacade	--联级删除,主键删除，同时删除受外键约束值
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

--唯一约束---------------------------------------------------------------------------------------------------
/*
Unique
唯一约束和主键约束类似，区别在于主键约束要求列不能为nul,而unique约事则可以
*/

alter table sd_pur_ordermaster add constraint AK_sd_pur_ordermaster unique(billstats)

--Check约束---------------------------------------------------------------------------------------------------
/*
check不局限于一个特定的列，可以约束一个列，也可以通过某个列来约束另一个列
定义check约束使用的规则与where子句中的基本一样
*/

--select * from sd_pur_ordermaster
alter table sd_pur_ordermaster add constraint CK_sd_pur_ordermaster check(billstats between 1 and 12)

insert into sys_state
select 12,'未知'

insert into sd_pur_ordermaster
select 'PT',	'PI131117admin-005',12 --受check约束

/*
其它
between 1 and 12
like '[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
in ('ups','fed ex','usps')
price >=0
shipdate >= orderdate
dateinsystem <= getdate()
*/


--default约束 --------------------------------------------------------------------------------
/*
1.如果插入的新行在定义了默认值的列上没有给出值，那么这个列上的数据就是定义的默认值
2.默认值只在insert语句中使用
3.如果插入的记录给出了这个列的值，那么该列的数据就是插入的数据
4.如果没有给出值，那么该列的数据总是默认值
*/
CREATE TABLE sd_pur_ordermaster(
	companyID VARCHAR(20),
	billno VARCHAR(30),
	billStats INT default(0)
)

alter table sd_pur_ordermaster add constraint DF_sd_pur_ordermaster  default(0) for billstats



--禁用约束------------------------------------------------------------------------------------------ 
/* 
primary key 和 unique约束 这对孪生约束是不能禁用的
从系统信息里可以看到：主键，unique是不能禁用的，check约束，外键约束是可以禁用的
*/

--禁用外键约束
--select * from sd_pur_ordermaster

insert into sd_pur_ordermaster
select 'PT','PI131117admin-006',6

alter table sd_pur_ordermaster nocheck constraint FK_sd_pur_ordermaster

--规则-------------------------------------------------------------------------------------------------
go
Create rule SalaryRule
as @salary >0;
sp_bindrule 'SalaryRule' , 'Employee.Salary'

/*第一句定义了一个规则叫SalaryRul
e 进行比较的事物是一个变量
这个变量的值是所检查的列的值
第二句把规则绑定到某个表的一个列上
规则和ckeck约束很相似，
但是规则只作用在一个列上
一个规则可以绑定在多个列上，但是它不会意识到其他列的存在
check可以定义column1>=column2
*/
--取消规则
exec sp_unbindrule 'Employee.Salary'
--删除规则
Drop rule SalaryRule

--默认值--------------------------------------------------------------------------------------------
--默认值与default约束类似（有区别的，但是我说不清楚）

create default salarydefault
as 0;
exec sp_binddefault 'salarydefault' , 'employee.salary';

--取消默认值：
exec sp_unbinddefault 'employee.salary'

--删除默认值：
drop default 'salarydefault'

