

--更新UPDATE动作申请的锁
/*
对于update语句，可以简单理解为SQLServer先做查询，把需要修改的记录给找到，然后在这个记录上做修改，找记录的动作
要加共享锁，找到要修改的记录后会先加更新锁，再将更新锁升级到排它锁。
*/

SET TRAN ISOLATION LEVEL REPEATABLE READ
GO

SET STATISTICS PROFILE ON 

BEGIN TRAN
UPDATE dbo.Employee_Demo_Heap SET title ='changedheap' WHERE EmployeeID IN(3,30,200)

/*
在非聚集索引上申请了3个更新锁，在RID上申请了3个排他锁，这是因为语句借助非聚集索引找到了这3条记录，非聚集索引
本身没有用到title这一列，所以它自己不需要做修改，但是数据rid上有了修改，所以rid上加的是排它锁，其它索引上没有加锁。

总结：如果update借助了哪个索引，这个索引的键值上就会有更新锁，没有用到的索引上没有锁，真正修改发生的地方会有排它锁，
对于查询涉及的页面，sqlServer加了意向更新锁，修改发生的页面，加了意向排它锁。
*/

--修改的列被一个索引使用到了

CREATE NONCLUSTERED INDEX employee_Demo_BTree_Title ON employee_demo_btree(title)
DROP INDEX employee_Demo_BTree_Title ON employee_demo_btree

SET STATISTICS PROFILE ON

BEGIN TRAN 
UPDATE dbo.employee_demo_Btree SET Title='changeed' WHERE EmployeeID IN(3,30,200)

ROLLBACK TRAN 

/*
语句利用聚集索引找到会修改的3条记录，但是我们看到有9个键上有排它锁
因为index=1上聚集索引，也是数据存放的地方，刚才做的update语句没有改到它的索引列，它只须把title这个列的值改掉。
所在在index1上，它只须申请3个排它锁。

但是表格在title上面有一个非聚集索引 index4,并且title是第一列，它被修改后，原来的索引键值就要被删掉，并且插入新的键值，
所以在index4上要申请6个排它锁，老的键值3个，新的键值3个。
*/

-------------
/*
总结：
a,对每一个使用到的索引，sqlServer会对上面的键值加U锁
b,sqlserver只对要做修改的记录或键值加X锁
c,使用到要修改的列的索引越多，锁的数目也会越多
d,扫描过的页面越多，意向锁也会越多，在扫描的过程中，对所有扫描到的记录也会加锁，哪怕上面没有修改。

所以，如果想降低一个update被别人阻塞住的概率，除了注意它的查询部份以外，数据库设计者还要做的事情有：
1，尽量修改少的记录集，修改的记录越多，需要的锁也就越多。
2，尽量减少无谓的索引，索引的数目越多，需要的锁也可能越多。
3，但是也要严格避免表扫描的发生，如果只是修改表格记录的一小部分，要尽量使用index seek ，避免全表扫描这
种执行计划。
*/