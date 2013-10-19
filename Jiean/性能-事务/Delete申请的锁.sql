

--Delete动作要申请的锁

SET TRAN ISOLATION LEVEL READ COMMITTED
GO
SET STATISTICS PROFILE ON

BEGIN TRAN 
DELETE  dbo.employee_demo_Btree WHERE LoginID ='adventure-works\kim1'

ROLLBACK TRAN 

/*
delete 语句在所在的索引上加了排它锁，在它们所在的页面上申请了意向排它锁。
*/

SET TRAN ISOLATION LEVEL REPEATABLE READ
GO

BEGIN TRAN
DELETE  dbo.employee_demo_heap WHERE LoginID ='adventure-works\tete0'

ROLLBACK TRAN 

/*
在REPEATABLE READ隔离级别下
所有的索引各申请了一个X锁，在它们所在的页面上申请了一个IX锁，在修改发生的heap页面上，申请了一个IX锁，相应
的RID上(真正的数据记录)申请了一个X锁，其它扫描过的页面申请了IU锁。

总结：
a,delete的过程是先找到符合条件的记录，然后做删除，可以理解成先是一个select ,然后是delete，所以，如果有合适的
索引，第一步申请的锁就会比较少。

b,delete不但把数据行本身删除，还要删除所有相关的索引键。所以一张表上索引数目越多，锁的数目就会越多，也就越容易阻塞。

所以，为了访止阻塞， 们即不能绝对地不建索引，也不能随随便便地建很多索引，而是要建对查找有利的索引。对于没有使用到
的索引，还是去掉比较好。
*/