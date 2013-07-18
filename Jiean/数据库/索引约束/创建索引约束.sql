

 /*
 今天把日常用的不多，但又时不时跳出来让你捉襟肘见的几个知识点复习一下

 主键,索引，约束,外键
 */
--创建索引
/*
语法结构
CREATE [UNIQUE] [CLUSTERED|NONCLUSTERED] 
    INDEX   index_name
     ON table_name (column_name…)
      [WITH FILLFACTOR=x]
       UNIQUE表示唯一索引，可选
       CLUSTERED、NONCLUSTERED表示聚集索引还是非聚集索引，可选
       FILLFACTOR表示填充因子，指定一个0到100之间的值，该值指示索引页填满的空间所占的百分比

来点通俗的吧
CREATE [索引类型] INDEX 索引名称 ON 表名(列名)
WITH FILLFACTOR = 填充因子值0~100

用create index 命令可以创建两种索引类型，聚集索引和非聚集索引(默认情况下是非聚集索引),以及带唯一约束的非聚集索引，又叫唯一索引

几种索引，约束间的关系

建表或是在表设计中添加主键的同时，会默认生成一个聚集索引
唯一索引是对索引列的唯一约束，可以有多个唯一索引（因为其本质是非聚集索引）,允许索引列null值存在。
GO
*/

--删除一个索引，格式差不多，指明索引名称和表名就可以了
drop index [索引名] on [表名]
drop index [表名].[索引名]


---=====================================================================================================================
约束是从表级别上保证数据的完整性,所以约束的定义和修改在create table 或alter table 中设置

约束有5种：
主键约束 primary key ,唯一的标识出表的每一行,且不允许空值值,一个表只能有一个主键约束,创建主键约束的同时会自动生成聚集索引
外键约束 foreign key ,一个表中的列引用了其它表中的列，使得存在依赖关系，可以指向引用自身的列.
唯一约束 unique ,指定的列中没有重复值，或该表中每一个值或者每一组值都将是唯一的,创建唯一约束的同时会自动生成唯一索引
默认值约束 default(0) ,包含非空约束(not null),对新生成记录，默认值定义
条件约束 check ,指定该列是否满足某个条件

约束命名规则
    推荐的约束命名是：约束类型_表名_列名。
       NN：NOT NULL          非空约束，比如nn_emp_sal
       UK：UNIQUE KEY         唯一约束
       PK：PRIMARY KEY       主键约束
       FK：FOREIGN KEY       外键约束
       CK：CHECK             条件约束

语法：
	constraint [约束名] 约束类型([字段])
    constraint [约束名] references 表名（字段名）
--===============================================================
注：在创建表的同时创建约束，有两种方式：
--===============================================================
	1）在列级类型后上追加,如果不指定约束名，系统会自动添加
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
	deptno varchar(10) references bas_dept(deptID) --从表中references 指定主表及字段
)

--指定约束名
create table bas_constraint_2
(
	empno varchar(10) constraint pk_constraint_empno primary key,
	enmae varchar(20) constraint nn_constraint_enmae not null,
	email varchar(30) constraint uk_constraint_email unique,
	sal decimal(24,6) constraint ck_constraint_sal check(sal>1500),
	deptno varchar(10) constraint fk_constraint_deptno references bas_dept(deptID)
)

2)在表级定义后声明约束，可以是创建复合键约束
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

--外键关联测试

--从表外键必须存在于主表主键中，否则无法插入
insert into bas_dept(deptID,deptName)
select '5','aaa'

insert into bas_constraint_1(empno,enmae,sal,deptno)
select 'd','c',1600,'5'

--从表记录可以随意删除，主表记录删除必须先清除对应的从表记录
delete from bas_constraint_1

--存在外键约束关系，无法对键值进行更改
update bas_dept set deptID='6'

--===============================================================
注：在建表后使用ALTER TABLE创建约束：
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

--不能在null列上添加主键约束
alter table bas_constraint_4 add constraint pk_bas_constraint_4 primary key(empno)

--not null,默认值 约束使用alter column
alter table bas_constraint_4 alter column ename varchar(20) not null

--创建唯一索引
alter table bas_constraint_4 add constraint uk_bas_constraint_4 unique(email)

--创建check约束
alter table bas_constraint_4 add constraint ck_bas_constraint_4 check(sal>1500)

--创建外建约束
alter table bas_constraint_4 add constraint fk_bas_constraint_4 foreign key(deptno) references bas_dept(deptID)


--禁用或启用外键约束
alter table bas_constraint_4 nocheck constraint all
alter table bas_constraint_4 check constraint all


---生成启用or禁用指定表外键约束的sql  
select 'ALTER TABLE ' + b.name + ' NOCHECK CONSTRAINT ' + a.name +';'  from sysobjects a ,sysobjects b where a.xtype ='f' and a.parent_obj = b.id and b.name='bas_constraint_4';  
select 'ALTER TABLE ' + b.name + ' CHECK CONSTRAINT ' + a.name +';'  from sysobjects a ,sysobjects b where a.xtype ='f' and a.parent_obj = b.id and b.name='bas_constraint_4'; 


--删除约束
alter table bas_constraint_4 drop constraint uk_bas_constraint_4




--查看约束状态
select * from sys.foreign_keys
exec sp_helpconstraint 'bas_constraint_4'

    