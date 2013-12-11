

--锁的观察笔记

/*
?查看前当sqlServer里所有的连接持有的锁的情况
*/
sp_lock

SELECT 
	resource_database_id --数据库ID
	,resource_associated_entity_id --对象ID
,* FROM sys.dm_tran_locks

/*
?具体查看某个表，索引上持有那些锁

sys.dm_tran_locks ：sqlServer里所有的锁都在这里了
sys.partitions    : 每一个分区中的表和索引对象都在这了
*/

SELECT 
b.object_id,OBJECT_NAME(b.object_id),
* FROM sys.dm_tran_locks a
LEFT JOIN sys.partitions b ON a.resource_associated_entity_id= b.hobt_id

/*
?观察语句执行过程中锁的申请和释放过程

SQL Server Profiler 
	Lock:Accquired
	Lock:Released
*/