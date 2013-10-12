

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
*/