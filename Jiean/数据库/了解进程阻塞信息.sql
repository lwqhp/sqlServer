

/*
阻塞：当一个正常处理过程，超过常规处理时间还没有完成时，一般就意味着阻塞的产生。

从数据库来讲，阻塞是正常现象，它保证了事务完整性并维护数据库一致性，而且只要等街，当产生阻塞的进程处理完成，阻塞就会消失。
但从业务角度来讲，阻塞不一定是正常的，比如：一个业务程序的BUG导致事务没有提交就结束了，则这个数据库中的相关资源被锁定，在这个业务程序断工连接之前，这个锁定会一直存在，其它业务程序访问被锁定的资源就会被阻塞。

*/

--查询：sys.dm_exec_requests视图的blocking_session_id 指示了阻塞此进程（这条记录代表了一个进程）的进程ID（session_id）
--sysprocess视图，则产生阻塞进程的session_id(这个ID在这个表中对应的是spid)放在blocked列中


--DBCC INPUTBUFFER 与 sys.dm_exec_sql_text 差异测试1
DECLARE 
	@session_id smallint
SELECT
	@session_id = @@SPID

-- 这个将返回当前执行的全部 T-SQL 编码
DBCC INPUTBUFFER(@session_id)

-- 这个只返回当前正在执行的这一段，即下面的这个查询部分
SELECT 
	current_sql = SUBSTRING(T.text,
			R.statement_start_offset / 2 + 1,
			CASE
				WHEN statement_end_offset = -1 THEN LEN(T.text)
				ELSE (R.statement_end_offset - statement_start_offset) / 2+1
			END)
FROM sys.dm_exec_requests R
	OUTER APPLY sys.dm_exec_sql_text(R.sql_handle) T
WHERE R.session_id = @session_id

/*
========================
*/
-- 测试存储过程
IF OBJECT_ID(N'tempdb..#p') IS NOT NULL
	DROP PROC #p
GO

CREATE PROC #p
AS
SET NOCOUNT ON
DECLARE 
	@session_id smallint
SELECT
	@session_id = @@SPID

-- 这个将返回当前执行的全部 T-SQL 编码
DBCC INPUTBUFFER(@session_id)

-- 这个只返回当前正在执行的这一段，即下面的这个查询部分
SELECT TEXT,
	current_sql = SUBSTRING(T.text,
			R.statement_start_offset / 2 + 1,
			CASE
				WHEN statement_end_offset = -1 THEN LEN(T.text)
				ELSE (R.statement_end_offset - statement_start_offset) / 2+1
			END)
FROM sys.dm_exec_requests R
	OUTER APPLY sys.dm_exec_sql_text(R.sql_handle) T
WHERE R.session_id = @session_id
GO

-- 调用测试存储过程
RAISERROR(N'测试开始', 10, 1) WITH NOWAIT
EXEC #P

----------------------------------------------------------
--演示了如何实现阻塞信息的获取方法

-- ===========================================
-- 获取阻塞的 session_id 及阻塞时间
DECLARE @tb_block TABLE(
	top_blocking_session_id smallint,
	session_id smallint,
	blocking_session_id smallint,
	wait_time int,
	Level int,
	blocking_path varchar(8000),
	PRIMARY KEY(
		session_id, blocking_session_id)
)
INSERT @tb_block(
	session_id,
	blocking_session_id,
	wait_time)
SELECT
	session_id,
	blocking_session_id,
	wait_time = MAX(wait_time)
FROM sys.dm_exec_requests
WHERE blocking_session_id > 0
GROUP BY session_id, blocking_session_id

-- ===========================================
-- 处理阻塞的 session_id 之间的关系
DECLARE
	@Level int
SET @Level = 1

INSERT @tb_block(
	session_id, top_blocking_session_id, blocking_session_id,
	Level, blocking_path)
SELECT DISTINCT
	blocking_session_id, blocking_session_id, 0,
	@Level, RIGHT(100000 + blocking_session_id, 5)
FROM @tb_block A
WHERE NOT EXISTS(
		SELECT * FROM @tb_block
		WHERE session_id = A.blocking_session_id)
WHILE @@ROWCOUNT > 0
BEGIN
	SET @Level = @Level + 1
	UPDATE A SET
		top_blocking_session_id = B.top_blocking_session_id,
		Level = @Level,
		blocking_path = B.blocking_path 
			+ RIGHT(100000 + A.session_id, 5)
	FROM @tb_block A, @tb_block B
	WHERE A.blocking_session_id = B.session_id
		AND B.Level = @Level - 1
END

-- ===========================================
-- 如果只要显示阻塞时间超过多少毫秒的记录，可以在这里做一个过滤
-- 这里假设阻塞时间必须超过 1 秒钟(1000毫秒)
DELETE A 
FROM @tb_block A
WHERE NOT EXISTS(
		SELECT * FROM @tb_block
		WHERE top_blocking_session_id =A.top_blocking_session_id
			AND wait_time >= 1000)

-- ===========================================
-- 使用 DBCC INPUTBUFFER 获取阻塞进程的 T-SQL 脚本
DECLARE @tb_block_sql TABLE(
	id int IDENTITY,
	EventType nvarchar(30),
	Parameters int,
	EventInfo nvarchar(4000),
	session_id smallint)
DECLARE
	@session_id smallint
DECLARE tb CURSOR LOCAL STATIC FORWARD_ONLY READ_ONLY
FOR
SELECT DISTINCT
	session_id
FROM @tb_block
OPEN tb
FETCH tb INTO @session_id
WHILE @@FETCH_STATUS = 0
BEGIN
	INSERT @tb_block_sql(
		EventType, Parameters, EventInfo)
	EXEC(N'DBCC INPUTBUFFER(' + @session_id + ') WITH NO_INFOMSGS')
	IF @@ROWCOUNT > 0
		UPDATE @tb_block_sql SET
			session_id = @session_id
		WHERE IDENTITYCOL = @@IDENTITY

	FETCH tb INTO @session_id
END
CLOSE tb
DEALLOCATE tb

-- ===========================================
-- 显示阻塞进程信息
;WITH
BLK AS(
	SELECT
		A.top_blocking_session_id,
		A.session_id,
		A.blocking_session_id,
		A.Level,
		A.blocking_path,
		SQL = B.EventInfo
	FROM @tb_block A
		LEFT JOIN @tb_block_sql B
			ON A.session_id = B.session_id
)
SELECT
--	BlockPath = REPLICATE(' ', Level * 2 - 2)
--			+ '|-- '
--			+ RTRIM(session_id),
	BLK.top_blocking_session_id,
	BLK.session_id,
	BLK.blocking_session_id,
	BLK.Level,
	wait_type = P.waittype,
	wait_time = P.waittime,
	last_wait_type = P.lastwaittype,
	wait_resource = P.waitresource,
	P.login_time,
	P.last_batch,
	P.open_tran,
	P.status,
	host_name = P.hostname,
	P.program_name,
	P.cmd,
	login_name = P.loginame,
	BLK.SQL,
	current_sql = T.text,
	current_run_sql = SUBSTRING(T.text,
			P.stmt_start / 2 + 1,
			CASE
				WHEN P.stmt_end = -1 THEN LEN(T.text)
				ELSE (P.stmt_end - P.stmt_start) / 2+1
			END)
FROM BLK
	-- 简省代码起见，直接引用 sysprocess, 读者可以改为引用前述介绍的“查询进程"的脚本进行替换
	INNER JOIN master.dbo.sysprocesses P
		ON BLK.session_id = P.spid
	OUTER APPLY sys.dm_exec_sql_text(P.sql_handle) T
ORDER BY BLK.top_blocking_session_id, BLK.blocking_path
