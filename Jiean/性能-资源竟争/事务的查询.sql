

--事务的查询

--显示当前还活动的最早的事务
DBCC OPENTRAN('databaseName')
/*
对于孤立连接（在数据库是打开的，但与应用程序或客户端已经断开的连接）的排除是有用的，并能帮助我们找出遗漏
了commit或者rollback 的事务。
*/

--事务排查

--1)看查当前所有打开的事务以及对应的会话ID
SELECT * FROM sys.dm_tran_session_transactions

--2）通过会话ID了解这个进程的连接，最后执行的命令
SELECT * FROM sys.dm_exec_connections a
CROSS APPLY sys.dm_exec_sql_text(a.most_recent_sql_handle) b
WHERE session_id=3

--查询正在进行和活动的语句
SELECT * FROM sys.dm_exec_connections a
INNER join sys.dm_exec_requests b ON a.session_id = b.session_id
WHERE a.session_id=3

--3)了解更多事务的信息，打开时间，事务类型及状态等
SELECT 
transaction_begin_time,
CASE transaction_type 
	WHEN 1 THEN 'read/write transaction'
	WHEN 2 THEN 'read-only transaction'
	WHEN 3 THEN 'system transaction'
	WHEN 4 THEN 'distributed transaction'
END tran_type,
CASE transaction_state
	WHEN 0 THEN 'not been completely initialized yet'
	WHEN 1 THEN 'iitialized but has not started'
	WHEN 2 THEN 'active'
	WHEN 3 THEN 'ended read-only transaction'
	WHEN 4 THEN 'commit initiated for distributed transaction'
	WHEN 5 THEN 'transaction prepared and waiting resolution'
	WHEN 6 THEN 'committed'
	WHEN 7 THEN 'being rolled back'
	WHEN 8 THEN 'been rolled back'
END tran_state
FROM sys.dm_tran_active_transactions