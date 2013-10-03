
--测试数据
DROP TABLE SalesOrderHeader_test
SELECT * 
INTO dbo.SalesOrderHeader_test
FROM sales.SalesOrderHeader

DROP TABLE SalesOrderDetail_test
SELECT * 
INTO dbo.SalesOrderDetail_test
FROM sales.SalesOrderDetail

--在salesorderid上创建聚集索引
CREATE CLUSTERED INDEX  SalesOrderHeader_test_CL ON SalesOrderHeader_test(SalesOrderID)

--在明细表建非聚集索引
CREATE INDEX SalesOrderDetail_test_NCL ON SalesOrderDetail_test(SalesOrderID)

--在主表中增加9条订单记录，编号75124-75132，每张单有12万数据，即明细表中90%数据属于这9张单
DECLARE @i INT
SET @i=1
WHILE @i<=9
BEGIN
INSERT INTO dbo.SalesOrderHeader_test( RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, 
SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, TerritoryID, BillToAddressID,
 ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, 
 Freight, TotalDue, Comment, rowguid, ModifiedDate)
 SELECT RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, 
SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, TerritoryID, BillToAddressID,
 ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, 
 Freight, TotalDue, Comment, rowguid, ModifiedDate
 FROM dbo.SalesOrderHeader_test
 WHERE salesorderID = 75123
 
 IF @@ERROR=0
 INSERT INTO dbo.salesorderDetail_test(SalesOrderID,  CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID,
  UnitPrice, UnitPriceDiscount, LineTotal, rowguid, ModifiedDate)
  SELECT 75123+@i,CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID,
  UnitPrice, UnitPriceDiscount, LineTotal, rowguid, GETDATE()
  FROM sales.SalesOrderDetail
  SET @i = @i+1
END
  
--SELECT COUNT(0) FROM SalesOrderHeader_test
--SELECT COUNT(0) FROM dbo.salesorderDetail_test

--在堆上表扫描
SET  STATISTICS PROFILE ON --斯特期 '斯嗲死特
SELECT salesorderdetailID,unitprice 
FROM salesorderdetail_test
WHERE unitprice>200

/*
聚集索引扫描：在创建了聚集索引的表上执行表扫描，因为聚集索引的叶级页就是数据页，其实还是相当于表扫描，
*/

CREATE CLUSTERED INDEX salesorderdetail_test_cl ON salesorderdetail_test(SalesOrderDetailID)

/*
创建非聚集索引，为每一次记录存储一份非聚集索引索引键值和一份聚集索引索引键的值（没有聚集索引，则是RID值）
因为非聚集索引的叶级索引值页指向聚聚索引的值。没有话则是数据行的ID值。
*/

CREATE INDEX salesorderdetail_test_Ncl_price ON salesorderdetail_test(UnitPrice)

/*
在返回的字段上加几个字段，sqlserver 就要先在非聚集索引上找到所有unitprice大于200的记录，然后再根据salesorderdetialid 的值找到
找到存储在聚集索引上的详细数据，这个过程称为"Bookmark Lookup"
在sqlserver2005以后，bookmark lookup 的动作要用一个嵌套循 环来宛成，所以在执行计划里，可能看到先seek了非聚集
索引，然后用clustered index seek把需要的行找出来
*/
SELECT salesorderID,salesOrderDetailID,unitPrice 
FROM dbo.SalesOrderDetail_test WITH(INDEX(salesorderdetail_test_Ncl_price))
WHERE unitPrice>200

SET STATISTICS PROFILE OFF


/*统计信息
统计信息是sqlServer 对数据的分析报告，数据引擎则根据这份数据报告作依据调整执行计划
*/
-- stati s tics 
UPDATE STATISTICS SalesOrderHeader_test(SalesOrderHeader_test_CL)
DBCC SHOW_STATISTICS (SalesOrderHeader_test,SalesOrderHeader_test_CL)

/*
all density :索引列的选择度，如果这个值 小于0.1说明选择性是比较高的，大于0.1,就差些了

直方图
range_hi_key 说明分成三组，每组数据的最大值
range_rows  每组数据区间的行数，上限值除外，第一组只有一个43659,最后一个是75132,其它都在第二区间里
distinct_range_rows 区间里非重复值的数目
avg_range_rows 每组区间内重复值的平均数目，计算公式=（range_rows/distinct_range_rows for distinct_range_rows>0）
*/


DBCC SHOW_STATISTICS(SalesOrderDetail_test,SalesOrderDetail_test_NCL)
/*
SalesOrderDetail_test 90%数据属于751124-75132这9 张单

density不但有索引列saleorderID的选择址，还有SalesOrderID, SalesOrderDetailID合并起来的选择性值，而后一个的
选择性要比第一个高的多。
*/

--比较两种写法
SET STATISTICS PROFILE ON 

SELECT b.salesorderID,b.orderDate,a.* 
FROM salesorderdetail_test a
INNER JOIN salesorderheader_test b 
ON a.salesorderID  = b.salesOrderID
WHERE b.salesorderID = 72642

SELECT b.salesorderID,b.orderDate,a.* 
FROM salesorderdetail_test a
INNER JOIN salesorderheader_test b 
ON a.salesorderID  = b.salesOrderID
WHERE b.salesorderID = 75127

/*
从索引的统计信息可以看出72642 的 EQ_rows估计返回行数3,75127返回行数是121317,并针对此选择了不同的执行计划，
而返回结果和实际返回的行数是相等的，说明统计信息是准确的，并根据统计信息调整了执行计划
*/

/*
统计信息的维护

当数据库属性里，默认打开两个属性：auto create statistics 和auto update statistics，能够让sqlserver在需要的时候
自动去创建统计信息，也能在发现统计信息过时，自动去更新。
auto update statistics asynchronously异步更新(2005新功能)，当发现统计信息过时时，会用老的统计信息继续现在的查询编译，
但会在后台启动一个任务，去更新这个统计信息，下次使用时就是新的版本了。


有3种情况会自动去创建统计信息
1)创建索引时，会自动在索引列上创建统计信息

2)手动创建  

3)当sqlserver想要使用某些列上的统计信息，发现没有时，会自动创建统计信息。

增删改都会影响统计信息的准备性，而更新统计信息也需要消耗一定的资源，所以触发统计信息的更新需要一个平衡。
1）如果统计信息是定义在普通表上的，那么当发生下面变化之一后，统计信息就被 认为是过时的了，下次使用时，会
自动触 发一个更新动作
1,表记录从无到有
2，对于数据量小于500行的，当统计信息的第一个字段数据累计变化量大于500以后
3,对于数据量大于500行的，当统计信息的第一个字段数累计变化量磊于500+(20%*总记录数)，也就是当1/5以上的数据发生
变化后,sqlserver才会去重算统计信息。
注：临时表也有统计信息，但表变量没有。

对于小于500行的数据表，而其统计信息第一字段的更新累计没有超过500,不会触发自动更新统计信息，比如用作关联的字段，
很少更新，但关联表的数据却经常更新，则统计信息就会不准确了。
*/

--做个实验

EXEC sp_helpstats salesorderheader_test
--此对象没有任何统计信息。

SELECT COUNT(0) FROM salesorderheader_test WHERE orderdate = '2004-06-11 00:00:00.000'
/*
statistics_name                                                                                                                  statistics_keys
-------------------------------------------------------------------------------------------------------------------------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
_WA_Sys_00000003_75035A77                                                                                                        OrderDate

有了一个新的统计信息
*/

/*
编译和重编译

sqlServer 对指令的执行，要完成语法解析，语意解析，-》编译complie,生成能够运行的执行计划，并绶存到内存中。
*/

/*
只有完全相同的sql 语句才会使用到缓存执行计划
objtype类型 adhoc:select ,insert,update,delete批处理指令
在sql Trace 里
	sp:cacheinsert 第一次执行有过编译事件
	sp:cachehit 第二次执行重用先前的执行计划
*/
--查看当前缓存的执行计划
SELECT usecounts,cacheobjtype,objtype,text FROM sys.dm_exec_cached_plans
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
ORDER BY usecounts DESC


/*
sqlserver 还有一种自动参数化的查询，缓存了还参数的执行计划，可以重复调用
或者用 sp_executesql 调用指令
*/

DBCC freeproccache
go

SELECT ProductID,SalesOrderID FROM sales.SalesOrderDetail WHERE productid >1000
GO
SELECT ProductID,SalesOrderID FROM sales.SalesOrderDetail WHERE productid >2000
GO
SELECT * FROM sys.syscacheobjects

/*
当表结枸发现变化，统计信息，以及dbcc freeproccache,sp_recompile,keep plan,keepfixed plan都会形成重编译
*/
--查看缓存的所有执行计划
SELECT * FROM sys.syscacheobjects

--清除执行计划缓存
DBCC freeproccache
DBCC flushprocindb(db_id)

/*sql Trace 里跟编译有关的事件
cursors-cursorrecompile: 当游标所基于的对象发生架构变化，导致的TSQL游标做的重编译
performance-AUTO STATS :发生自动创建或者更新统计信息的事件
stored procedures 下面有好几个很有用的事件;
sp:cachehit : 说明当前语句在缓存里找到一个可用的执行计划
sp:cacheinsert :当前有一个新执行讲被插入到缓存里
sp:cachemiss :说明当前语句在缓存里找不到一个可用的执行计划
sp:cacheremove:有执行计划被从缓存里移除，内存有压力时会发生
sp:recompile:一个存储过程发生了重编译，eventsubclass记录了重编译发生的原因。


有用的计数器
sqlserver:buffer manager
sqlserver:cache manager
sqlserver:memory manager
sqlserver:sql statistics
*/

--=======================================================================
/*
执行计划
有两种方式可以查询到语句的执行计划
1)在语句前打开些开关，把语句的结束集和预估执行计划或实际执行计划同时显示出来
set showplan_all on --在找到可用的执行计划后输出，语句不执行
set showplan_xml on 
set statistics profile on --发生在语句执行之后，实际的执行计划
2)另一种在sql Trace里用事件来跟踪语句的执行计划
showplan all --事件发生在语句开始之前
showplan statistics profile --发生在语句执行之后
showplan xml statistcs profile

有些信息，比如是不是reuse了一个执行计划，sql server有没有觉得缺少索引，只能在xml的输出里看到。
*/

SET SHOWPLAN_ALL ON 
go
SELECT a.SalesOrderID,a.OrderDate,a.CustomerID,b.SalesOrderDetailID,b.ProductID,b.OrderQty,b.UnitPrice 
FROM dbo.SalesOrderHeader_test a
INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b.SalesOrderID
WHERE a.SalesOrderID = 43659
--只有esitmaterows

SET SHOWPLAN_ALL OFF

SET STATISTICS PROFILE ON
go
SELECT a.SalesOrderID,a.OrderDate,a.CustomerID,b.SalesOrderDetailID,b.ProductID,b.OrderQty,b.UnitPrice 
FROM dbo.SalesOrderHeader_test a
INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b.SalesOrderID
WHERE a.SalesOrderID = 43659
--有rows

SET STATISTICS PROFILE OFF

/*
解析执行计划的执行顺序
树结构，下一层分支逮属于上一层子句，执行从最底层开始，在xml图中，是从最右边往左，从下往上开始

首先执行第6，5行的index seek和clustered index seek 
的此之上，将两个结果集用嵌套循环的方式连接起来，4，得到结果，和执行第3行，在salesorderheader_test 上作culustered index seek 并列为一层
2层是一个嵌套循环，说明sqlserver 是使用的嵌套循环把两个结果集合并起来。

首先salesorderheader_test 在salesorderID上有聚集索引，sqlserver可以直热闹找到salesorderID=43659,然后把它的几个字
段取出，是一个culustered index seek

而salesorderdetail_test在salesorderID上的是非聚集索引，返回的值不能宛全被非聚集索引所包含，所以先用非聚找到
salesorderID=43659记录，再要据指针和聚集索引做nested loops的连接，把所有的字段值取出来。

--------------
表与表之间的关联，本质就是两表之间的一个循环遍历，sqlServer会对表间的关联进行分析，选择一个折中的循环算法.

<sqlserver循环算法有几种，什么情况下会影响他选择算法>
sqlserver有三种join方法：

Nested loops Join
Nested loops 是一种最基本的连接方法，算法是对于两张要被 连接在一起的表格，sqlserver选择一张做outer table,
另一张做 inner table
*/
SET STATISTICS PROFILE ON 
GO
SELECT * FROM dbo.SalesOrderHeader_test a
INNER LOOP JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID
WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660

/*
sqlserver 选择 a作为outer table ,首先在header_test上使用聚集索引做一个seek,找出每一条a.salesorderid>4365的记录
，每找到一条记录，sqlserver都时入inner table ,找能够和它join返回数据的记录 a.saleorderID = b.saleorderID,由于
outer table 上有10000条记录符合，所以 inner table 被扫描了10000次 看executes和rows

关键点
算法复杂度等于inner table *outer table 如果outer table 表很大，innertable 会被扫描很多次，消耗很多的资源.
outer table 的数据集最好能够事先排序好，以便提高栓索效率
inner table 和最好有一个索引，能够支持检索
*/

SELECT * FROM dbo.SalesOrderHeader_test a
INNER MERGE JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID
WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660

/*
2) Merge Join

造合大表连接，从两边的数据集中各取各一个值，比较一下，如果相等，就把这两行连接起来返回，如果不相等，
就把小的那个值丢掉，按顺序取下一个更大的。两边的数据集有一边遍历结束，整个join 的过程就结束了，所以整个算法
最大就是大的那个数据集里的记录数量。

关键点
做连接的两个数据集必须要事先按照join的字段排好序。
（例子中两个数据集都是根据在salesorderID字段的索引上seek出来的，所以不需要再做排序） 

Merge Join只能以“值相等”为条件的连接，如果数据集可能有重复的数据，merge join 要采用mary-to-mary这种很费资源
连接方式。如果数据集1有两个或者多个记录值相等，sqlserver就必肌得把数据集2里找描过的数据暂时建立一个数据结构存放起来
，万一数据集1里的下一个记录还是这个值，那还有用，这个临时的数据结构称为 worktable 会被 放在tempdb 或者内存里。
从totaosubstreecost可以看出来，如果把cl这个索引改成一个unique的聚集索引，sqlserver就知道数据集1的值不会重复，
也就不需要做many-to-many join
*/


SELECT * FROM dbo.SalesOrderHeader_test a
INNER HASH JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID
WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660

/*
3) Hash Join 
利用哈希算法作匹配的连接算法，分两步，“bulid”和“Probe”在 BULID阶段，sqlserver选择两个要做join 的数据集中
的一个，根据记录的值 建立起一张在内存中的hash表，然后在probe阶段，sqlserver选 择另外一个数据集，将里面的记录值 
依次带入，找出符合条件，返回可以做连接的行

关键点
1,算法复杂度就是分别遍历两的数据集集各一遍
2，不需要数据集事先按照面什么顺序排序，也不要求上面有索引
3，可以比较容易地升级成使用多处理器的并行执行计划

hash join是比较耗资源的算法，在做join之前，要先在内存里建立一张hash表，建立过程需示cpu资源，hash需要用内存
或tempdb存放，而join的过程也要使用cpu资源来计算 （probe）,建议还是尽量降低join输入的数据集的大小，配以合适
的索引，引导sqlserver尽量使用nested loop或merge来join

-----缺一张图片
*/

/*
aggregation
主要用来计算 sum(),count,max,min等聚合运算，Aggregation分两种
stream aggreation:将数据集排成一个队列以后做运算
hash aggreation:类似 hash join ,需要在内存中建一个hash表，才能做运算
*/

SET STATISTICS PROFILE ON 

SELECT SalesOrderID,COUNT(SalesOrderDetailID)
FROM dbo.SalesOrderDetail_test
GROUP BY SalesOrderID

SELECT customerID,COUNT(*)
FROM dbo.SalesOrderheader_test
GROUP BY customerID

/*
concatenation 数据合并
两种操作会生成 concatenation运算:union 和union all
union 会产生一个sort排序，把重复的数据去掉

parallelism :并行操作
*/

---============================================
DBCC DROPCLEANBUFFERS
--清除buffer pool里的所有缓存的数据
DBCC freeproccache
--清除buffer pool里的所有缓存的执行计划

--《查看执行时间细节》
/*
执行用时包括分析，编译时间和sql的执行时间,其中，占用时间包括了对应的cpu时间。剩余为IO，内存，等待操作时间了
*/
SET STATISTICS TIME ON
GO

SELECT DISTINCT ProductID,UnitPrice 
FROM dbo.SalesOrderDetail_test
WHERE ProductID=777
UNION 
SELECT  ProductID,UnitPrice 
FROM dbo.SalesOrderDetail_test
WHERE ProductID=777

SET STATISTICS TIME OFF

--《查看IO的操作》
/*
扫描次数：按照执行计划，表被scan了几次
逻辑读取：从数据缓存读取的页数（数据是以页存储的，每一次存取都是以页为单位）页数越多，说明查询要访问的
数据量就越大，内存消耗量越大，查询也就越昂贵。可以检查是否应该调整索引，减少扫描的次数，缩小扫描范围。
物理读取：从磁盘读取的页数。
预读：为进行查询而预读入缓存的页数
*/

DBCC DROPCLEANBUFFERS
GO
SET STATISTICS IO ON

SELECT DISTINCT  ProductID,UnitPrice 
FROM dbo.SalesOrderDetail_test
WHERE ProductID=777

SET STATISTICS IO OFF


--《查看执行计划》
/*
rows:执行计划每一步返回的实际行数
executes :执行计划每一步被运行了多少次
*/

SET STATISTICS PROFILE ON 

SELECT DISTINCT  ProductID,UnitPrice 
FROM dbo.SalesOrderDetail_test
WHERE ProductID=777

/*
分析：
6,clustered index scan全表聚集索引扫描，找出porductID =777的记录
5,使用sort的方式把返回的2420记录做一个排序，从中选出distinct 值，排序只有unitprice,预估行数差别大，说明
在productID+unitprice上没有直接的统计信息
4，把unitprice排成一个队列后，ProductID,UnitPrice 做distinct()运算
3，parallelism，并行执和
2，一个distinct order by 排序，返回结果
从执行计划来看，主要cost用在了lustered index scan上，在productID加一个索引是一个比较自然的想法
*/
SET STATISTICS PROFILE OFF


SELECT COUNT(b.SalesOrderID)
FROM dbo.SalesOrderHeader_test a 
INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b .SalesOrderID
WHERE a.SalesOrderID>43659 AND a.SalesOrderID<53660

/*
5,a.SalesOrderID上有聚集索引，所以直接用了索引查找clustered index seek,估计行正确，cost 低
6，SalesOrderDetail_test里找出（SalesOrderID>43659 AND SalesOrderID<53660）的记录，因为SalesOrderID上有非
聚集索引，所以这里用了索引查找index seek ,从这里看出，执行计划是先在两个表中都找出了符合条件的记录，再作
的join关联。
4，两个结果集比较大，所以选择了hash match的方法，因为两张表的salesorderid上都有统计信息，所以预估是比较准的
3，执行count(*)运算
2，值类型转换成int类型，作为结果返回，cost 机乎可以不计。
*/

/*
语句调优思路和方法
1)确认是否是因为做了物理i/o而导致的性能不佳
语句的调优，要先确认数据页面能够事先缓存在内存里，如果这个问题得到解决，性能还不能达到要求，才有后续调优
的必要。如果这个问题解决后语句就能跑得足够快，那说明这个问题也是一个系统资源瓶颈问题，而不主要是语句本身的问题。

2）确认是否是因为编译时间长而导致的性能不佳
大部份情况下，编译时间会远小于执行时间，如果编译时间占了总时间50%左右，而语句执行的速度又很快，调优的重点
会转向如何避免重编译，或者降低编译时间。

3）当i/O，编译时间都趋向合理，但语句执行很慢，就要重点调优语句的执行。从执行计划分析sqlServer选择的执行计划
是否准确，主要看sqlserver是否正确的预估了每一步的cost,因为cost是根据EstimatedRows的大小来预估cost的，如果预
估值和实际值相差很多，说明sqlServer根据一个不准确的统计信息制定了的一个执行计划。

4）如果sqlserver选择的执行计划是合理的，那就说明现有的表结构和索引，sqlServer无法做到在预期的时间内完成语
句的执行，那就要检查表结构和语句逻辑，通过减少数据集，调整索引，改变业务逻辑的处理方法来实际调优。
*/

--查看i/o
DBCC DROPCLEANBUFFERS

SET STATISTICS IO ON 
SET STATISTICS TIME ON 

/*
如果在单个语句调优时发现性能问题，只在有物理i/o的时候才出现，则
a,检查生产服务器是否有内存瓶颈，是否存在经常换页的现象
	如果生产环境下，内存没有瓶颈，或者很少有page out/page in的动作，那说明sqlserver能够把数据页维护在内存里
	你看到的性能问题就不太会发生，所以无须太过优虑。
b,检查这句话，和它访问的数据，是被经常使用的，还是偶尔使用的，对一偶尔使用，而访问的数据量又大，那sqlserver
没有把它放到内存中也是正常的，对这样的语句，其运行时间里有物理i/o时间是合理的。
c,检查语句执行计划，是否能够减少其访问的数据量
d,检查磁盘子系统的性能
如果语句访问的数据很可能就不在内存里，而其数据量，还一定要提高其性能，那唯一的出路就是提高磁盘子系统的性能了。


2，是否是因为编译时间长而导致性能不佳
一般需要对两类语句重点检查编译，一类是比较简单，长充比罗短，涉及表格比较少，但是在应用或任务里反复调用的语句
如果能够通过执行计划重用来去除编译时间，或者通过调整 数据库设计聊低骗译时间，那整 体的效率就能够提高40-50%
还有一类是语句本身比较复杂，或者其所基于的表格上有太多的索引可供选择，使得编译时间就超过1秒。
*/
--用sql trace来检查编译时间
DROP PROC longcompile
GO
CREATE PROC longcompile (@i INT ) 
AS
DECLARE @cmd VARCHAR(max)
DECLARE @j INT
SET @J =0
SET @cmd  ='
	select * from dbo.SalesOrderHeader_test a
	INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b.SalesOrderID
	INNER JOIN Production.Product p ON b.ProductID = p.ProductID
	WHERE a.SalesOrderID IN(43659'
WHILE @j<@i
BEGIN
SET @cmd = @cmd +','+STR(@j+43659)
SET @j=@j+1
END
SET @cmd=@cmd + ')'
EXEC(@cmd)
go


dbcc dropcleanbuffers

set statistics time on
longcompile 100
/*
查看语句(含存储过程)的编译，执行所需要的时间
stored Procedures
	PRC:completed
	PRC:starting
	SP:stmtCompleted
	SP:stmtstarting
TSQL
	SQL:BatchCompleted
	SQL:BatchStarting
	SQL:StmtCompleted
	SQL:StmtRecompile
	SQL:StmtStaiting

一个Batch编译时间，等于其SQL:BatchStarting 事件的开始时间，减去其第一条语句的SQL:StmtStarting事件开始时间（因为sqlServer
是先编译整个Batch,然后再开始运行第一句。）如果两个时间相等，说明是执行计划重用，或者编译时间可以忽略不计。

一个stored procedure 的编译时间，等于调用它的statement的SQL:StmtStarting 事件开始时间（或者是RPC:starting时间）减去其第一条
语句SP：StmtStarting 的开始时间(因为Sqlserver是先编译整理个SP，然后再运行第一句)

如果是动态语句，在Batch或SP编译的时候 假不会包含它的编译时间，它的编译时间发生在它真正运行之前，出就是exec 指令和真正的语句这
两个sp:stmtstarting事件之间

分析
sp:stmtstarting exec(@cmd)的开始执行时间：370毫秒
到动态语句的开始执行 sp:stmtstarting select *..... 的开始执行时间是437毫秒，中间的67秒就是动态语句的编译时间
sp:cachinsert 事件说明这里发生了编译

动态语句自己完成使用的时间是1136毫秒 sp:stmtCompleted,不包含编译时间
sp:stmtcompleted exec(@cmd) 语句的duration时间是1204毫秒,其中包含了动态语句执行的1136和67秒的编译时间=1毫秒

SQL:Stmtcompleted exec longcompile 100 用时1224毫秒,-1204=20毫秒，除动态语句外的其它语句用了20毫秒

如果你发现语句性能问题和编译有关，击破考虑的方向有：
1）检查语句本身是否过于复杂，长度太长，，可以把一句话折成几句更简单的语句，或者用temp table 代替大的in子句

2)检查语句使用的表格上是不是有太多的索引，索引越多，sqlserver要评估的执行计划就越多，花的时间越长，。
3）引导sqlserver尽量多重用执行计划，减少编译
*/


/*
判断执行计划是否合适
从以下几个方面，判断现在得到的执行计划是否准确，以及有没有提高的空间
1,预估cost的准确性
sqlserver在候选的执行计划中，挑一算出来totalsubtreecost最低的，而totalsubtreecost是通过估算出estimateio和
estimatecup再进行计算得出的，如是果选择的执行计划有问题，常常是因为estimaterows估错了.
有个注意点，当sqlserver预估某一步不会有记录返回时，它不是把estimaterows置为0,而是置为1,如果实际的rows不为0
而estimaterows为1，就要好好检查sqlserver在这里的预估开销是否准确，是否会影 响到执行计划的准确性。

在看执行计划中，如果实际返回记录数很大，用的却是nested loops,这是不太合适的。
*/


/*
index seek 还是Table Scan

检查的第二个重点，是要检查sqlServer从表格里检索数据的时候，是否选择了合适的方法。

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

/*
因为SalesOrderDetailID中加了运算，所以用不到SalesOrderDetailID的索引，如果去scan整个表格，是一件非常用浩大的工程。所以它
找找自己有没有其它索引覆盖了salesorderdetiaid这个字段。因为索引只包含了表格的一小部分字段，占用的页面数量会比表格本身要小很
多，去scan这样的索引，可以大大降低scan的消耗。sqlserver作了变通，在saleOrderID非聚集索引上进行了index sxan
,而这个非聚集索引没有覆盖carriertrackingnumber这附上字段，所以sqlser还要根据挑出来的记录在salesorderDetailID值，到salesorderDetailID
聚集索引上去找carriertrackingnumber,也就是clustered index seek
*/
set statistics profile off

/*
是nested loops  还是hash(merge) join
*/

drop proc sniff
go

create proc sniff(@i int)
as
select * from SalesOrderHeader_test a
inner join SalesOrderDetail_test b on a.SalesOrderID = b.SalesOrderID
inner join production.Product p on b.productid = p.productid
where a.salesorderid = @i
go


dbcc freeproccache

exec sniff 50000
go

exec sniff 75124

/*
filter 运算位置
表与表间关联，一般是先filter掉部份,再做合并

从第一句看出，虽然只有一个where子句p.productid between 758 and 800,但是在执行计划里可以看到有两个filter动作：一个在saleorderdetial_test
上，另一个在product上，这是因为sqlserver发现这两张表将要通过b.productid = p.productid作连接，所以在product上的条件，同样会造合
在saleorderdetail_test上，这样，sqlServer先在salesorderdetail_test上做一个filter,结果集就小得多，再作join

而第二个语句只作了一次filter,因为(p.productid/2) between 380 and 400这样的语句没办法作用在SalesOrderDetail_test上.
*/

select count(b.ProductID) from SalesOrderHeader_test a
inner join SalesOrderDetail_test b on a.SalesOrderID = b.SalesOrderID
inner join production.Product p on b.productid = p.productid
where p.productid between 758 and 800
option(maxdop 1)
go

select count(b.ProductID) from SalesOrderHeader_test a
inner join SalesOrderDetail_test b on a.SalesOrderID = b.SalesOrderID
inner join production.Product p on b.productid = p.productid
where (p.productid/2) between 380 and 400
option(maxdop 1)
go

/*
总结：
1）预估返回结果休大小EstimateRows不准确，导致执行计划实际TotalSubTreeCost比预估的高很多。
统计信息不存在，或者没有及时更新，是产生这个问题的主要原因。

子句太过复杂，也可能使sqlserver猜不出一个准确的，只好猜一个平均数，比如where子句里对字段做计算，代入函数等行为，都可能会影
响sqlserver预估的准确性，如果发现这种情况，就要想办法简化语句，降低复杂度，提高效率。

当语句代入的变量是一个参数，而sqlserver在编译的时候 可能不知道这个参数的值，只好根据某些击剑则，猜一个预估值，这也可能会
影响到预估的准确性.

2)语句重用了一个不合适的执行计划
sqlserver的执行计划重用机制，是一次编译多次重用，如果传入的参数导致的数据分布不均匀，重复的记录多，就会造成先编译的执行计划
的不合适。

3）筛选子句写的不太合适，妨碍sqlserver选取更优的执行计划

*/


/*
parameter sniffing

参数变量有两种，一种是在传入参数，在编译的时候知道值，另一种是在存储过程中定义的变量，需要在执行后才知道，而执行计划重用会诱
发一个现象，叫parameter sniffing 


*/

set statistics profile on


dbcc freeproccache

exec sniff 50000

exec sniff 75124

--2)
exec sniff 75124

exec sniff 50000


/*
当一个语句出现问题，而且已经排除了系统资源瓶颈，阻塞与死锁，物理i/o编译与重编译，parameter sniffing 这些因素以后，要不就是调
整数据库设计，提高语句性能，要不就是修改改句本身，以达到更高的效率

1)调整索引
当确认EstimateSubtreeCost这一列是准确的以后，应该找对cost贡献最多的子句，如果它用的是table scan,或者index scan,请比较它返回
的行数和表格实际行数，如果返回行数远小于实际行数，那就说明sqlserver没有合适的索引供它做好seek,这时候加索引就是一个比较好的
选择。

*/
set statistics profile on

select distinct ProductID,UnitPrice from SalesOrderDetail_test where ProductID=777

/*
sql trace中跟性能有关的事件
performance-showplan xml statistics profile

跟性能有关的视图
sys.dm_db_missing_index_details

数据库引擎优化顾问

1）每次分析的输入量要合理
2)最好不要在生产数据库上直接运行DTA
3)DTA 给的建议，要经过确认以后，才能在数据库上实施。
*/


/*
调整语句设计提高性能
当我们上面的方法都用尽了的时候，就要考虑语句的设计是否合理了

筛选条件和计算字段
最好使用sarg的运算符，=,>,<,>=,<=,in,between,like前缀
非sarg运算符 not ,<>,not exists,not in, not like,内部函数,例如convert upper等

*/

--一个特殊的例子,找年龄大于30的员工
select datediff(yy,birthdate,getdate())>30 --用不到
select birthdate<dateadd(yy,-30,getdate())

/*
会在运行前改变值的变量
对于存储过程代入的变量，sqlserver知道它值，也会根据它的值对语句进行优化，但如果在语句使用它之前，被告其它语句修改过，那sqlserver
生成的执行讲划就不准了，这种情况，有时也会导致性能问题

一种方法是在使用变量的语句后面加一个option(recompile)的query hint,这样当sqlserver 运行到这句话的时候，会重编译可能出问题的语句

另一种方法是把可能出问题的语句做成一个子存储过程，让原来的存储过程调用子存储过程，而不是语本身，这样的好处是可以省下语句重编译
的时间。
*/
