

--优化参数设定
SET STATISTICS TIME ON --显示分析、编译和执行各语句所需的毫秒数。
SET STATISTICS IO ON   --使SQL Server 显示有关由Transact-SQL 语句生成的磁盘活动量的信息。
DBCC FREEPROCCACHE; --从过程缓存中删除所有元素。释放过程缓存将导致系统重新编译某些语句（例如，即席SQL 语句），而不重用缓存中的语句。
DBCC DROPCLEANBUFFERS --从缓冲池中删除所有清除缓冲区。若要从缓冲池中删除清除缓冲区，请首先使用CHECKPOINT 生成一个冷缓存。这可以强制将当前数据库的全部脏页写入磁盘，然后清除缓冲区。完成此操作后，便可发出DBCC DROPCLEANBUFFERS 命令来从缓冲池中删除所有缓冲区。


/*
二，执行计划

3.	Performance Dashboard工具 ，该工具利用DMV 和DMF来获取以下数据：
1）CPU瓶颈(和什么查询最损耗CPU)
2）IO瓶颈(还有，什么查询执行最多的IO)
3）	查询优化器产生的索引建议(缺失索引)；
4.	 SQL Server profiler.数据库跟踪服务，适合跟踪执行语句，并回放。
5.	 数据库引擎优化顾问。

*/