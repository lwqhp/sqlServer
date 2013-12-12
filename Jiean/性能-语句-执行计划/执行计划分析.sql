
--执行计划分析
/*
概念：执行计划又叫查询优化器，它通过对语句中的每种可以组合的运算符计算出一个成本低，效益高的策略，也就是执行计划，
缓存到内存中，当语句被调用时，语句将按准备好了的执行计划进行解析。
*/
SET STATISTICS PROFILE ON 

/*
解释：
Rows：执行计划每一步返回的实际行数。
Executes :执行计划每一步被运行了多少次。
StmtText : 执行计划的具体内容。执行计划以一棵树的形式显示。每一行，都是运行的一步，都会有结果集返回，也都会有自己的Cost.
EstimateRows :  sqlServer根据表格上的统计信息，预估的每一步的返回行数。
EstimateIO: sqlServer根据EstimateRows和统计信息里记录的字段长度，预估的每一步会产生的IO Cost.
EstimateCPU: sqlServer根据EstimateRows和统计信息里记录的字段长度,以及要做的事情的复杂度，预估的每一步会产生的CPU Cost.
TotalSubtreeCost : SQLServers根据EstimateIO和EstimateIO通过某种计算公式，计算出的每一步执行计划子树cost
Wamings : SQLServer 在运行每一步时遇到的警告。
Parallel : 执行计划的这一步是不是使用了并行的执行计划。

分析：
--语句的开销
1，多语句，可在图形界面上看到各语句的开销占比
2, 单语句，可在图形界面上看到各运算的开销占比

--系统提示
2，查看是否有感叹号。

--查看数据量和使用的连接方式
3，节点之间的连接箭头宽度，可以看出传输的数据量，分析箭头左边的节点以理解其需要这么多行的原因，还要检查箭头的
属性，可能看到估计的行和实际的行不一样，这可能同过时的统计造成。
4，观察连接方式，对比输出的数据集，看连接方式是否合理。

--细看 使用的运算符（索引，排序，书签）
5，寻找书签查找操作，对大结果集的书签操作可能造成大量的逻辑读。
6，寻找执行排序操作的步骤，这表示数据没有以正确的排序进行检索。
7，查看索引的使用，以及是否是最佳索引

--脚本从内存中查看执行计划
9，直接从保存它们的内存空间-计划缓存中读取语句的执行计划
*/
SELECT p.query_plan,t.text FROM sys.dm_exec_cached_plans r
CROSS APPLY sys.dm_exec_query_plan(r.plan_handle) p
CROSS APPLY sys.dm_exec_sql_text(r.plan_handle) t


----------------------------------------------------------------------------------------------------------------------
USE AdventureWorks
go

SET STATISTICS PROFILE ON 

SELECT COUNT(b.SalesOrderID)
FROM dbo.SalesOrderHeader_test a 
INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b .SalesOrderID
WHERE a.SalesOrderID>43659 AND a.SalesOrderID<53660

SET STATISTICS PROFILE OFF 

/*
?如果观察执行计划
答：
1，首先检查执行计划的估算是否准确性：对比rows 和EstimateRows的数量。
当sqlserver预估某一步不会有记录返回时，它不是把estimaterows置为0,而是置为1,如果实际的rows不为0
而estimaterows为1，就要好好检查sqlserver在这里的预估开销是否准确，是否会影 响到执行计划的准确性。

有时虽然两者的数量差距比较大，但成本cost很低，没有做其它运算，也是可以接受的。

2，如果实际返回记录数很大，再看上一级是否有循环运算，用的是nested loops,这是不太合适的。

3，更细一步查看查找方式是index seek 还是table Scan 。
seek 和scan，一般seek要比scan要快，但如果返回的是表格中的大部份数据，那么，索引上的seek就不会有什么帮助，甚至直接用scan可能
还会更快一些。所以关键要看EstimateRows和Rows的大小

如果用的是table scan 或者是index scan ,再比较它返回的行数和表格实际行数，如果返回行数远小于实际行数，那就说明sqlServer没有
合适的索引供它做seek,这时候加索引就是一个比较好的选择。
*/


set statistics profile on

set statistics time on
select count(b.CarrierTrackingNumber) 
from SalesOrderDetail_test b
where b.SalesOrderDetailID>10000 and b.SalesOrderDetailID<=10100


select count(b.CarrierTrackingNumber) 
from SalesOrderDetail_test b
where convert(numeric(9,3),b.SalesOrderDetailID/100)=100

set statistics profile off
/*
因为SalesOrderDetailID中加了运算，所以用不到SalesOrderDetailID的索引，如果去scan整个表格，是一件非常用浩大的工程。所以它
找找自己有没有其它索引覆盖了salesorderdetiaid这个字段。因为索引只包含了表格的一小部分字段，占用的页面数量会比表格本身要小很
多，去scan这样的索引，可以大大降低scan的消耗。sqlserver作了变通，在saleOrderID非聚集索引上进行了index sxan
,而这个非聚集索引没有覆盖carriertrackingnumber这附上字段，所以sqlser还要根据挑出来的记录在salesorderDetailID值，到salesorderDetailID
聚集索引上去找carriertrackingnumber,也就是clustered index seek
*/

/*
?如何根据执行计划调优
答：
1）预估返回结果休大小EstimateRows不准确，导致执行计划实际TotalSubTreeCost比预估的高很多。
统计信息不存在，或者没有及时更新，是产生这个问题的主要原因。应对的方法，是开启数据库上的Auto Create Statistics和 Auto Update Statistics
如果这样还不能保证Statistics 的精确性可以定义一个任务，定期更新统计信息。

子句太过复杂，也可能使sqlserver猜不出一个准确的，只好猜一个平均数，比如where子句里对字段做计算，代入函数等行为，都可能会影
响sqlserver预估的准确性，如果发现这种情况，就要想办法简化语句，降低复杂度，提高效率。

当语句代入的变量是一个参数，而sqlserver在编译的时候 可能不知道这个参数的值，只好根据某些击剑则，猜一个预估值，这也可能会
影响到预估的准确性.

2)语句重用了一个不合适的执行计划
sqlserver的执行计划重用机制，是一次编译多次重用，如果传入的参数导致的数据分布不均匀，重复的记录多，就会造成先编译的执行计划
的不合适。

3）筛选子句写的不太合适，妨碍sqlserver选取更优的执行计划
Sqlserver对筛选条件(Search Argument/SARG)的写法有一些建议：
SARG运算符包括：= ，>,<,>=,<=,in,between, like(左前缀匹配)，AND
对于不使用SARG运算符的表达式，索引是没有用的，包括：NOT ,<>,not exists,not in,not like 和内部函数

*/


