

----Parameter Sniffing 
/*
是指因为重用他人生成的执行计划而导致的性能问题，主要出现在带参数的存储过程调用

存储过程是通过编译，重用执行计划的方式来执行存储过程的。
当存储过程第一次执行的时候，会发生编译。
当缓存中没有执行计划的时候，调用会发生编译。
当不是第一次执行，缓存中有执行计划的时候，则重用执行计划。

存储过程的编译是根据参数变量来的，如果变量是外面定义传入的，sqlServer在对过程体编译的时候，是知道变量值的，
生成的执行计划对当前参数调用来讲是最优的。

当变量是在内部定义的，那么sqlServer在对过程体中使用该变量的语句编译时，是不知道该变量值的，也就是说生成的
执行计划是比较中庸的，跟变量的值的变化关系不大。

关注点解析：
对于那些必须在过程中查询得出的变量以及使用该变量的语句，可不关注。
关注那些使用传入参数，且很大可能造成查询结果分布不平均的语句。
分支条件参数的影响
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
SET STATISTICS IO ON
SET STATISTICS TIME ON
SET STATISTICS PROFILE OFF 
SET STATISTICS IO OFF
SET STATISTICS TIME OFF

DBCC freeproccache
go

EXEC sniff 50000
go
/*
首先，执行计划先根据索引查找过滤salesorderdetail_test的salesorderid值，然后跟product进行关联
因为salesorderdetail_test表的记录不多，使用了nested循环，每一条代入product进行查找，只执行了一次。

然后索引查找salesorderheader_test表符合条件的记录，因为只一很少的一条，所以也使用了nested loop来关联。
>>从这里可以看出，执行计划并不是从语句的最开始从上往下来执行，他会尝试多种关联方式，并选择最好的一种作为最终执行计划


*/
EXEC sniff 75124
go
/*
发生执行计划重用，重用上面的nested loops 的执行计划

当条件值发生了变化后，salesorderdetail_test 返回了很多的记录121317，（两次的查找，逻辑读242634次）
按原来的执行计划，使用nested loops 和product进行循环，就需要执行121317次，每次把一条记录放到product中查找。
（salesorderdetail_test 再加一次逻辑读121317，product一次逻辑读121317）

返回121317笔记录，再次salesorderheader_test 用nested loops和该结果集循环,因salesorderheader_test只有一条记录，这里还好。
（product再加一次逻辑读121317）

*/
--测试2
DBCC freeproccache
go

EXEC sniff 75124
go
/*
采用ID=75124编译，插入一个使用Hash Match 连接的执行计划

由于salesorderdetail_test会返返回121317笔记录，这里选择了先进行salesorderheader_test和product的循环，因为记录不
多，这里使用了nested loops,
然后通过排序，对salesorderdetail_test两个结果集使用Hash Match关联。（产生两个Worktable）
*/

EXEC sniff 50000
go
--发生执行计划重用，重用上面的Hash Match 的执行计划

/*
由于数据分布差别很大，参数50000和75124只对自己生成的执行计划有好的性能，如果使用对方生成的执行计划，性能就会下降。
参数50000返回的结果集比较小，所以性能不下降还不太严重，参数75124返回的结果集大就有了明显的性能下降，两个计划的差别
有近10倍。

*/

-----------------------------------------------------------------------------------------------
--本地变量的执行计划
CREATE PROC sniff2(@i INT )
AS
DECLARE @j INT
SET @j = @i
SELECT COUNT(b.salesorderid),SUM(p.weight)
FROM salesorderheader_test a
INNER JOIN salesorderdetail_test b on a.salesorderid = b.salesorderid
INNER JOIN production.product p ON b.productid = p.productid
WHERE a.salesorderid = @j
GO

DBCC freeproccache

EXEC sniff2 50000
/*
执行计划和原来的差不多nested loop
*/

EXEC sniff2 75124
/*
重用了nested loop执行计划
*/

DBCC freeproccache

EXEC  sniff2 75124
/*
由于不知道@j变量的值，还是使用了nested loop的执行计划

可见，本地变量，因编译时不知道变量的值，生成的执行计划在大数据量关联的时候性能会比较差。
但是把变量放到参数里传入，则只会生成第一次执行时的传入参数的高效计划。
*/

--分支查询
CREATE PROC sniffIF(@i INT,@flag int  )
AS
IF @flag=0 
BEGIN 
SELECT COUNT(b.salesorderid),SUM(p.weight)
FROM salesorderheader_test a
INNER JOIN salesorderdetail_test b on a.salesorderid = b.salesorderid
INNER JOIN production.product p ON b.productid = p.productid
WHERE a.salesorderid = @i
END
ELSE IF @flag=1 
BEGIN 
	SELECT COUNT(b.salesorderid),SUM(p.weight)
	FROM salesorderheader_test a
	INNER JOIN salesorderdetail_test b on a.salesorderid = b.salesorderid
	INNER JOIN production.product p ON b.productid = p.productid
	WHERE a.salesorderid = @i+1
END 

DBCC freeproccache

EXEC sniffIF 50000,1


alter PROC sniffIF2(@i INT,@flag int  )
AS
SELECT COUNT(b.salesorderid),SUM(p.weight)
	FROM salesorderheader_test a
	INNER JOIN salesorderdetail_test b on a.salesorderid = b.salesorderid
	INNER JOIN production.product p ON b.productid = p.productid
	WHERE a.salesorderid = @i
IF @flag=0 
BEGIN 
DECLARE @j INT
SET @j=@i
SELECT COUNT(b.salesorderid),SUM(p.weight)
FROM salesorderheader_test a
INNER JOIN salesorderdetail_test b on a.salesorderid = b.salesorderid
INNER JOIN production.product p ON b.productid = p.productid
WHERE a.salesorderid = @j
END
ELSE IF @flag=1 
BEGIN 
	SELECT COUNT(b.salesorderid),SUM(p.weight)
	FROM salesorderheader_test a
	INNER JOIN salesorderdetail_test b on a.salesorderid = b.salesorderid
	INNER JOIN production.product p ON b.productid = p.productid
	WHERE a.salesorderid = @i
END 

DBCC freeproccache

EXEC sniffIF2 50000,0
EXEC sniffIF2 75124,0



/*------------------------------------------------------------------------------
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
c，optimize for() option(optimize fro(@i>1000))
d,Plan Guide


问题：会在运行前改变值的变量
解决：
A，在语句的尾部加上 option(recompile)
B,把改变变量的语句单独做成一个子存储过程，让原来的存储过程调用子存储过程，而不是语句本身。
*/


