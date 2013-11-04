

--日志文件增长定位

--检查日志现在使用情况和数据库状态

DBCC SQLPERF(LOGSPACE)
GO
SELECT 
name,recovery_model_desc,log_reuse_wait,log_reuse_wait_desc--反映sqlserver认为的不能截断日志的原因
 FROM sys.databases
 
 --检查最老的活动事务
 /*
 如果大部份日志在使用中，而且日志重用等待状态是active_transaction,那么要看这个数据库最久未提交的事务到底是由
 谁申请的
 */
 
 DBCC OPENTRAN
 GO
 SELECT * FROM sys.dm_exec_sessions t2,sys.dm_exec_connections t1
 CROSS APPLY sys.dm_exec_sql_text(t1.most_recent_sql_handle) st
 WHERE t1.session_id = t2.security_id
 AND t1.session_id >50
 
 /*
 再次运行dbcc opentran,命令会返回下一个最久未提交的事务，直到所有的事务被提交或回滚完毕为止。
 */