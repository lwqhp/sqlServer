

--锁资源争用
/*
sqlServer通过对不同的请求类型，分配相应的锁资源，以协调各个事务对资源的排队使用。


sqlServer中有3种类型的锁，操作锁，意向锁和架构锁
3.1）操作锁
共享锁(S) 赋予不更改或不更新数据的读取操作，比如select 
更新锁(U) 赋予更新语句，防止当多个会话在读取，锁定以及随后可能进行的资源更新时发生常见形式的死锁
排他锁(X) 赋予数据修改操作语句，比如insert ,update,delete,确保不会同时对同一资源进行多重更新

架构锁    赋予表架构操作语句，架构锁包含 两种类型：架构修改（sch-M）和架构稳定性(sch-S)
大容量更新锁(BU) 在向表进行大容量数据复制且指定了TABLOCK提示时使用
键范围 当使用可序列化事务隔离级别时何护查询读取的行的范围，确保再次运行查询时其它事务无法插入符合可序列化事务的查询的行。

意向锁：由其它锁请求产生，位于资源层次结构这一级别上的锁，用于锁申请，和等待阶段，以及锁的检查，事务不必检查表内各个页锁，只需要查
表上的意向锁即可，以提升性能。
包括 意向共享锁(IS),意向排他锁(IX) 和意向排他共享锁(SIX)


3)锁的控制等级
共享锁S：允许并发事务在封闭式并发控制下读取select资源，资源上存在共享锁时，任何其它事务都不能修改数据。

更新锁U：一次只有一个事务可以获得资源的更新锁，事务真正修改数据时，将更新锁转换为排他锁。

排他锁X：任何其它事务都无法读取或者修改数据，仅在使用 nolock提示或未提交读隔离级别时才会进行读操作。

意向锁I :意向锁可防止其它事务随后在表上提升锁请求，保护事务资源的完整性。


*/

--共享锁S
/*
只读查询会分配共享锁，它不会阻止其他只读查询同时访问数据，因为数据完整性不会被并发读破坏。
但是数据上的并发数据修改将被阻止以维护数据完整性。

的默认隔离级别 read_committed下，共享锁是在数据读出后就立即释放，而不会等到事务完成。

*/

--更新锁U
/*
更新有两个操作过程：读取和修改

读取操作会分配U更新锁,U锁兼容S锁，但隔离其它U锁，同样，U锁会存在于读取经过的数据当中，当不是需要修改的数
据时，U锁会被释放，而不会等到事务的结束。
如果数据为需要修改的数据，则U锁会转换为X锁。
*/


--排它锁X
/*
排它锁阻止其它事务访问修改之下的资源，insert和delete语句在执行的开始获取X锁，update则是在被修改的数据读出
后转换为X锁，在事务中，X锁被保持到事务结束。

X锁目的：
1）阻止其他事务访问修改之下的资源这样它们可以看到修改之前或之后的值，而不是正在修改的值
2）在需要时允许事务修秘诀资源以安全地回滚到修改之前的原始值因为没有其他事务被允许同时修改资源。
*/

--意向锁
/*
指出在查询有罗低的锁级别上获取对应的s,x锁的意向，在更刘级别上的ix锁阻止其他事务获取包含 该行的表或者页面上不兼空的锁

*/