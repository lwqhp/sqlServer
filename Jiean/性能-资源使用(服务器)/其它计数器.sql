

--其它计数器

--关于索引的计数器
/*
SQL Server:Access Methods 
	FressSpace Scans/sec ：每秒空闲空间扫描数，在堆表上的插入操作数量
	Full Scans/sec 每秒全扫描数，全表扫描的次数

数据库阻塞
SQLServer : Latches 
	Total Latch Wait Time 总闩锁等待时间
	闩锁被sqlserver用于保护内部强者构如表行的完整 性，监视在前一秒中必须等待的闰锁请求的总闩锁等待时间，这个
	计数据的高值表示花费太多时间等待内部同步机制。

SQLServer:Locks
	Lock Time Outs/sec 每秒锁超时数
	Lock Wait Time 锁等待时间
	应该期望lock timeouts/sec 为0，lock wait time 非常低，否则表示数据库中发生过多的阻塞
	Nmber of Deadlocks/sec 每秒死锁数，期望值0
	
不可重用的执行计划
SQLServer:SQL Statistics 
	SQL re-compilations/sec :每秒sql 重编译数
	
总体表现
SQLServer:General Statistics --User Connections 用户连接数
SQLServer:SQl Statistics --BatchRequests/sec 每秒批请求数		
*/