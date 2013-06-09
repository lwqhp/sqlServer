/*
首先Inner join是表和表的联接查询，而Cross apply是表和表值函数的联接查询。 可能通过inner join实现相同的cross apply查询。
执行过程：
Cross apply首先执行TVF（table-valued functions），然后对表Studnet进行全表扫描，接着通过遍历sID查找匹配值。

Inner join对表Student和Apply进行全表扫描，然后通过哈希匹配查找匹配的sID值。
如果表的数据量很大，那么Inner join的全表扫描耗费时间和CPU资源就增加了
虽然大多数采用Cross apply实现的查询，可以通过Inner join实现，但Cross apply可能产生更好的执行计划和更佳的性能，因为它可以在联接执行之前限制集合加入。 

SQL Server 2005 新增 cross apply 和 outer apply 联接语句，增加这两个东东有啥作用呢？ 
 
我们知道有个 SQL Server 2000 中有个 cross join 是用于交叉联接的。
实际上增加 cross apply 和 outer apply 是用于交叉联接表值函数（返回表结果集的函数）的， 
更重要的是这个函数的参数是另一个表中的字段。这个解释可能有些含混不请，请看下面的例子： 

cross apply是可以连接表值函数的 而inner join不可以 这个就是区别 当然两边连接的不是函数的时候 cross apply 可以模拟inner join 
 */
-- 1. cross join 联接两个表
select *
  from TABLE_1 as T1
 cross join TABLE_2 as T2
 
-- 2. cross join 联接表和表值函数，表值函数的参数是个“常量”
select *
  from TABLE_1 T1
 cross join FN_TableValue(100)
 
-- 3. cross join  联接表和表值函数，表值函数的参数是“表T1中的字段”
select *
  from TABLE_1 T1
 cross join FN_TableValue(T1.column_a)
 
Msg 4104, Level 16, State 1, Line 1
The multi-part identifier "T1.column_a" could not be bound.
最后的这个查询的语法有错误。在 cross join 时，表值函数的参数不能是表 T1 的字段， 为啥不能这样做呢？我猜可能微软当时没有加这个功能：），后来有客户抱怨后， 于是微软就增加了 cross apply 和 outer apply 来完善，请看 cross apply, outer apply 的例子： 
 
 
-- 4. cross apply
select *
  from TABLE_1 T1
 cross apply FN_TableValue(T1.column_a)
 
-- 5. outer apply
select *
  from TABLE_1 T1
 outer apply FN_TableValue(T1.column_a)
 
cross apply 和 outer apply 对于 T1 中的每一行都和派生表（表值函数根据T1当前行数据生成的动态结果集）
 做了一个交叉联接。cross apply 和 outer apply 的区别在于： 
 如果根据 T1 的某行数据生成的派生表为空，cross apply 后的结果集 就不包含 T1 中的这行数据，
 而 outer apply 仍会包含这行数据，并且派生表的所有字段值都为 NULL。 
 
下面的例子摘自微软 SQL Server 2005 联机帮助，它很清楚的展现了 cross apply 和 outer apply 的不同之处： 
 
注意 outer apply 结果集中多出的最后一行。 当 Departments 的最后一行在进行交叉联接时：deptmgrid 为 NULL，fn_getsubtree(D.deptmgrid) 生成的派生表中没有数据，但 outer apply 仍会包含这一行数据，这就是它和 cross join 的不同之处。 
 

 ----------------------------------------------------------------------------------------------------
-- create Employees table and insert values
IF OBJECT_ID('Employees') IS NOT NULL
 DROP TABLE Employees
GO
CREATE TABLE Employees
(
 empid INT NOT NULL,
 mgrid INT NULL,
 empname VARCHAR(25) NOT NULL,
 salary MONEY NOT NULL
)
GO
IF OBJECT_ID('Departments') IS NOT NULL
 DROP TABLE Departments
GO
-- create Departments table and insert values
CREATE TABLE Departments
(
 deptid INT NOT NULL PRIMARY KEY,
 deptname VARCHAR(25) NOT NULL,
 deptmgrid INT
)
GO

select * from Departments
select * from Employees

 
-- fill datas
INSERT  INTO employees VALUES  (1,NULL,'Nancy',00.00)
INSERT  INTO employees VALUES  (2,1,'Andrew',00.00)
INSERT  INTO employees VALUES  (3,1,'Janet',00.00)
INSERT  INTO employees VALUES  (4,1,'Margaret',00.00)
INSERT  INTO employees VALUES  (5,2,'Steven',00.00)
INSERT  INTO employees VALUES  (6,2,'Michael',00.00)
INSERT  INTO employees VALUES  (7,3,'Robert',00.00)
INSERT  INTO employees VALUES  (8,3,'Laura',00.00)
INSERT  INTO employees VALUES  (9,3,'Ann',00.00)
INSERT  INTO employees VALUES  (10,4,'Ina',00.00)
INSERT  INTO employees VALUES  (11,7,'David',00.00)
INSERT  INTO employees VALUES  (12,7,'Ron',00.00)
INSERT  INTO employees VALUES  (13,7,'Dan',00.00)
INSERT  INTO employees VALUES  (14,11,'James',00.00)
 
INSERT  INTO departments VALUES  (1,'HR',2)
INSERT  INTO departments VALUES  (2,'Marketing',7)
INSERT  INTO departments VALUES  (3,'Finance',8)
INSERT  INTO departments VALUES  (4,'R&D',9)
INSERT  INTO departments VALUES  (5,'Training',4)
INSERT  INTO departments VALUES  (6,'Gardening',NULL)
GO
--SELECT * FROM departments
 
-- table-value function
IF OBJECT_ID('fn_getsubtree') IS NOT NULL
 DROP FUNCTION  fn_getsubtree
GO
CREATE  FUNCTION dbo.fn_getsubtree(@empid AS INT) 
RETURNS TABLE 
AS 
RETURN(
  WITH Employees_Subtree(empid, empname, mgrid, lvl)
  AS 
  (
    -- Anchor Member (AM)
    SELECT empid, empname, mgrid, 0
    FROM employees
    WHERE empid = @empid   
    UNION ALL
    -- Recursive Member (RM)
    SELECT e.empid, e.empname, e.mgrid, es.lvl+1
    FROM employees AS e
       join employees_subtree AS es
          ON e.mgrid = es.empid
  )
    SELECT * FROM Employees_Subtree
)
GO
 
-- cross apply query
SELECT  *
FROM Departments AS D
    CROSS APPLY fn_getsubtree(D.deptmgrid) AS ST
 
 
 
-- outer apply query
SELECT  *
FROM Departments AS D
    OUTER APPLY fn_getsubtree(D.deptmgrid) AS ST
    
    
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
create table #T(姓名 varchar(10))
insert into #T values('张三')
insert into #T values('李四')
insert into #T values(NULL )
 
 
create table #T2(姓名 varchar(10) , 课程 varchar(10) , 分数 int)
insert into #T2 values('张三' , '语文' , 74)
insert into #T2 values('张三' , '数学' , 83)
insert into #T2 values('张三' , '物理' , 93)
insert into #T2 values(NULL , '数学' , 50)
 
 SELECT * FROM #T
  SELECT * FROM #T2
--drop table #t,#T2
go
 
select 
    * 
from 
    #T a
cross apply
    (select 课程,分数 from #t2 where 姓名=a.姓名) b
 
/*
姓名         课程         分数
---------- ---------- -----------
张三         语文         74
张三         数学         83
张三         物理         93
 
(3 行受影响)
 
*/
 
select 
    * 
from 
    #T a
outer apply
    (select 课程,分数 from #t2 where 姓名=a.姓名) b
/*
姓名         课程         分数
---------- ---------- -----------
张三         语文         74
张三         数学         83
张三         物理         93
李四         NULL       NULL
NULL       NULL       NULL
 
(5 行受影响)
 
 
*/ 
 
 ---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

 -- 演示数据
CREATE table  #A (
    id int)
INSERT #A
SELECT id = 1 UNION ALL
SELECT id = 2
 
CREATE table #B (
    id int)
INSERT #B
SELECT id = 1 UNION ALL
SELECT id = 3
 
 SELECT * FROM #A
  SELECT * FROM #b
-- 1. 右输入为表时, APPLY操作符与CROSS JOIN的结果一样
SELECT *
FROM #A
    CROSS APPLY #B
 
-- 2. 右输入为派生表时, 可以用APPLY操作符模拟JOIN
-- 2.a 模拟 INNER JOIN
SELECT *
FROM #A A
    CROSS APPLY(
        SELECT * FROM #B
        WHERE id = A.id
    )B
 
-- 2.b 模拟 LEFT JOIN
SELECT *
FROM #A A
    OUTER APPLY(
        SELECT * FROM #B
        WHERE id = A.id
    )B
