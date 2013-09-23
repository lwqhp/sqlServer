
--Apply 表运算符

/*
apply表运算符把右表表达式应用到左表表达式中的每一行，它不像联接那样先计算哪个表表达式都可以，apply必须先逻辑地计算左表表达式，把
左表中的每一条记录代入右表表达式，通过对右输入求值来获得左输入每一行的计算结果，生成的行被组合起来作为最终输出.

Inner join对表Student和Apply进行全表扫描，然后通过哈希匹配查找匹配的sID值。
如果表的数据量很大，那么Inner join的全表扫描耗费时间和CPU资源就增加了
虽然大多数采用Cross apply实现的查询，可以通过Inner join实现，但Cross apply可能产生更好的执行计划和更佳的性能，因为它可以在联接执行之前限制集合加入。 

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
 
 /*
cross apply 和 outer apply 对于 T1 中的每一行都和派生表（表值函数根据T1当前行数据生成的动态结果集）
 做了一个交叉联接。cross apply 和 outer apply 的区别在于： 
 如果根据 T1 的某行数据生成的派生表为空，cross apply 后的结果集 就不包含 T1 中的这行数据，
 而 outer apply 仍会包含这行数据，并且派生表的所有字段值都为 NULL。 
 
下面的例子摘自微软 SQL Server 2005 联机帮助，它很清楚的展现了 cross apply 和 outer apply 的不同之处： 
 
注意 outer apply 结果集中多出的最后一行。 当 Departments 的最后一行在进行交叉联接时：deptmgrid 为 NULL，fn_getsubtree(D.deptmgrid) 生成的派生表中没有数据，但 outer apply 仍会包含这一行数据，这就是它和 cross join 的不同之处。 
 
 */
    
    
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
 
select   * from   #T a
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
 
select     * from     #T a
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
