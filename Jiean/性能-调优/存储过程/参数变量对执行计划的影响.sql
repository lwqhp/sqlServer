

--参数变量对执行计划的影响
/*
参数变量来源有两种：
一种是存贮过程传入参数，当调用存储过程的时候，必须要给它代入值，这种变量，slserver在编译的时候知道它的值是多少。
另一种是在存储过程中定义的变量，它的值是在存储过程的语句执行的过程中得到的。所以对这种本地变量sqlServer在编译的时候不知道它的值是多少.

*/
USE AdventureWorks
go

CREATE PROC sniff(@i INT )
AS
SELECT COUNT(b.salesorderid),SUM(p.weight)
FROM salesorderheader_test a
INNER JOIN salesorderdetail_test b on a.salesorderid = b.salesorderid
INNER JOIN production.product p ON b.productid = p.productid
WHERE a.salesorderid = @i
GO

--参数变量
/*
当存储过程的参数是在调用的时候传入，那么存储过程生成的执行计划是第一次运行时代入的值生成的。

潜在问题：可能存在生成的执行计划不适合与所有的变量值，这会触发"parameter sniffing"问题
*/

SET STATISTICS PROFILE ON 

DBCC freeproccache
go

EXEC sniff 50000
go
--发生编译，插入一个使用nested loops 连接的执行计划

EXEC sniff 75124
go
--发生执行计划重用，重用上面的nested loops 的执行计划

--测试2
DBCC freeproccache
go

EXEC sniff 75124
go
--发生编译，插入一个使用Hash Match 连接的执行计划

EXEC sniff 50000
go
--发生执行计划重用，重用上面的Hash Match 的执行计划

/*
由于数据分布差别很大，参数50000和75124只对自己生成的执行计划有好的性能，如果使用对方生成的执行计划，性能就会下降。
参数50000返回的结果集比较小，所以性能不下降还不太严重，参数75124返回的结果集大就有了明显的性能下降，两个计划的差别
有近10倍。

？Parameter Sniffing 的解决方案
答：
1）用exec()的方式支行动态sql语句： exec() 会在每次执行前先进行重编译
优点：彻底避免了Parameter Sniffing的问题。
缺点：放弃了存储过程一次编译，多次运行的优点，在编译性能上有所损失。

2)使用本地变量
把变是赋值给一个本地变量,sqlServer在编译的时候是没办法知道这个本地变量的值的，所以它会根据表格里数据的一般分布情况，
“猜测”一个返回值，不管用户在调用存储过程的时候代入的变量值是多少，做出来的执行计划都是一样的，而这样的执行计划一般
比较中庸，不会是最优的执行计划，但是对大多数变量值来讲，也不会是一个很差的执行计划。
缺点：不是最优的。

3）在语句里使用Query Hint ,指定执行计划
在DML语句的最后，添加option(<query_hint>)子句，指导sqlServer如何产生执行计划。
针对 Parameter Sniffing常用的有：
a,Recompile :重编译 在语句最尾：option(recompile) 在存储过程定义处：with recompile
b,指定join 运算
c，optimize for()
d,Plan Guide


问题：会在运行前改变值的变量
解决：
A，在语句的尾部加上 option(recompile)
B,把改变变量的语句单独做成一个子存储过程，让原来的存储过程调用子存储过程，而不是语句本身。
*/