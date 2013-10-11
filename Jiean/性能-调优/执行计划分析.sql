
--执行计划分析
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
*/
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
