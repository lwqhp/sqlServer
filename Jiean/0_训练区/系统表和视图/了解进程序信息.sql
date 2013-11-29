

/*
sql 通过锁定和行版本控制 来保证事务的完整性。
加锁和释放锁一般由sql server 自动控制，对于经常出现并发操作的数据库而言，锁很重要.

*/

--查询当前执行的进程，主要可以用sys.dm_exec_sessions,sys.dm_exec_requests 和sys.dm_exec_connections这三个动态管理视图。
SELECT
	S.session_id, R.blocking_session_id,
	S.host_name, S.login_name, S.program_name,
	S.status,
	S.cpu_time, memory_usage_kb = S.memory_usage * 8, S.reads, S.writes,
	S.transaction_isolation_level,
	C.connect_time, C.last_read, C.last_write,
	C.net_transport, C.client_net_address, C.client_tcp_port, C.local_tcp_port,
	R.start_time, R.command, R.status,
	R.wait_time, R.wait_type, R.last_wait_type, R.wait_resource,
	R.open_transaction_count, R.transaction_id,
	current_execute_sql = SUBSTRING(T.text,
				R.statement_start_offset / 2 + 1,
				CASE
					WHEN statement_end_offset = -1 THEN LEN(T.text)
					ELSE (R.statement_end_offset - statement_start_offset) / 2+1
				END)
FROM sys.dm_exec_sessions S
	LEFT JOIN sys.dm_exec_connections C
		ON S.session_id = C.session_id
	LEFT JOIN sys.dm_exec_requests R
		ON S.session_id = R.session_id
			AND C.connection_id = R.connection_id
	OUTER APPLY sys.dm_exec_sql_text(R.sql_handle) T
WHERE S.is_user_process = 1  -- 如果不限制此条件，则查询所有进程（系统和用户进程）



