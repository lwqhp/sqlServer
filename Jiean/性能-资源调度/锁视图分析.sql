

--B连接

/*
sys.dm_tran_locks 锁视图分析查询结束以后连接A还持有的锁
*/
USE AdventureWorks
GO


SELECT request_session_id	--锁的来源进程
,resource_type --来源锁的类型
,request_status
,request_mode	--锁的名称
,b.index_id  --索引ID
,b.object_id,OBJECT_NAME(b.object_id),
* FROM sys.dm_tran_locks a
LEFT JOIN sys.partitions b ON a.resource_associated_entity_id= b.hobt_id
ORDER BY a.request_session_id,a.resource_type

/*
1,database 因为连接正在访问数据库adventureworks,所以它在数据库一级加了一个共享锁，以防止别人将数据库删除。
2，object 因为正在防问表格，所以在表格上加了一个意向共享锁，以防别人修改表的定义。
3，key,Page 查询有1条记录返回，所以在这条记录所在的聚集索引键上，持有一个共享锁。在这个键所在的页面上，持有一个意向共享锁。

总结：这个查询申请锁的数目是很少的。其他用户访问同一张表，只要不访问这条记录，就不会被影响到。这是因为查询
使用了clustered index seek 的关系。
*/

-----------------

--查询2
/*
因为在Empoyee_demo_Heap的EmployeeID上是一个非聚集索引，所以SQLServer在用非聚集索引找到这条记录后，必须再到
数据页面上把其它的行上面的数据找出来(所谓的Bookmark Lookup),虽然只返回一条记录，可是它在PK_employee_demo_heap
上申请了一个KEY锁，在RID（data page 上的row）申请了一个row锁。在这两个资源所在的页面上各申请了一个page意向锁。

总结：虽然返回的结果和查询1一样，但是由于它使用的是非聚集索引+bookmark lookup,所以申请的锁的数目要比查询1多。
一个查询要使用的索引键(或者RID)数目越多，它申请的锁也就会越多，没有使用到的索引上不会申请共享锁。
*/


--查询3
SET STATISTICS PROFILE ON

BEGIN TRAN 
SELECT employeeid,loginID,title 
FROM employee_demo_heap WHERE employeeID IN(3,30,200)

/*
由于要返回3条分布在不同数据页上的记录，SQLServer认为做非聚集索引+Bookmark Lookup并不比做一个表扫描快，所以它
直接选择了一个表扫描，这样的执行计划会带来什么样的效果呢？

查询3在1:4621:22 4621页面的读到第22行，在这个页面上申请一个意向锁和行锁共享锁，但因为上一个语句在
修改这一行的记录，已经添加了一个行锁排它锁，所以查询3被阻塞了。

看看一次表扫描所有数据页面带来的后果：

查询3不但在记录页上申请了意向锁，还在表格的所有页面上都申请了意向锁，查询3在扫描每一张页面的时间，会对读到的
每一个数据记录加上一个共享锁（读完了这条记录就会释放，不用等到整个语句结束），只要有任何一个记录上的锁没有申请
到，查询就会被阻塞住。
*/

ROLLBACK TRAN 

--同样的查询，运行在employee_demo_Btree上
BEGIN TRAN 
SELECT employeeid,loginID,title 
FROM employee_demo_Btree WHERE employeeID IN(3,30,200)

/*
没有发生阻塞，这是因为查询使用的是index seek,不需要每条记录都读一遍，所以就不用去读employeeid=70,也就不会被阻塞住
*/


/*
总结：

在非“未提交读” 的隔离级别上

1,查询在运行的过程中，会对每一条读到的记录或键值加共享锁，如果记录不用返回，那锁就会被释放，如果记录需要返回，
则视隔离级别而定，如果是"已提交读"，则也释放，否则不释放。

2，对每一个使用到的索引sqlserver也会对上面的键值加共享锁。

3，对每一个读过的页面，sqlserver会加一个意向锁。

4，查询需要扫描的页面和记录越多，锁的数目也会越多，查询用到的索引越多，锁的数目也会越多。

所以，如果想减少一个查询被别人阻塞或阻塞去哪里人的概率数据库设计者能做的事情有：

a,尽量返回少的记录集。返回的结果越多，需要的锁也就越多。
b,如果返回结果集只是表格所有记录的一小部份，要尽量使用index seek,避免全表扫描这种执行计划。
c,可能的话，设计好合适的索引，避免sqlServer通过多个索引才找到数据。

当然这些都是对于“已提交读”以上的隔离级别而言。如果选用“未提交读”，sqlServer就不会申请这些共享锁，阻塞也就不会发生。
*/