

/*
��������һ������������̣��������洦��ʱ�仹û�����ʱ��һ�����ζ�������Ĳ�����

�����ݿ�������������������������֤�����������Բ�ά�����ݿ�һ���ԣ�����ֻҪ�Ƚ֣������������Ľ��̴�����ɣ������ͻ���ʧ��
����ҵ��Ƕ�������������һ���������ģ����磺һ��ҵ������BUG��������û���ύ�ͽ����ˣ���������ݿ��е������Դ�������������ҵ�����Ϲ�����֮ǰ�����������һֱ���ڣ�����ҵ�������ʱ���������Դ�ͻᱻ������

*/

--��ѯ��sys.dm_exec_requests��ͼ��blocking_session_id ָʾ�������˽��̣�������¼������һ�����̣��Ľ���ID��session_id��
--sysprocess��ͼ��������������̵�session_id(���ID��������ж�Ӧ����spid)����blocked����


--DBCC INPUTBUFFER �� sys.dm_exec_sql_text �������1
DECLARE 
	@session_id smallint
SELECT
	@session_id = @@SPID

-- ��������ص�ǰִ�е�ȫ�� T-SQL ����
DBCC INPUTBUFFER(@session_id)

-- ���ֻ���ص�ǰ����ִ�е���һ�Σ�������������ѯ����
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
-- ���Դ洢����
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

-- ��������ص�ǰִ�е�ȫ�� T-SQL ����
DBCC INPUTBUFFER(@session_id)

-- ���ֻ���ص�ǰ����ִ�е���һ�Σ�������������ѯ����
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

-- ���ò��Դ洢����
RAISERROR(N'���Կ�ʼ', 10, 1) WITH NOWAIT
EXEC #P

----------------------------------------------------------
--��ʾ�����ʵ��������Ϣ�Ļ�ȡ����

-- ===========================================
-- ��ȡ������ session_id ������ʱ��
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
-- ���������� session_id ֮��Ĺ�ϵ
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
-- ���ֻҪ��ʾ����ʱ�䳬�����ٺ���ļ�¼��������������һ������
-- �����������ʱ����볬�� 1 ����(1000����)
DELETE A 
FROM @tb_block A
WHERE NOT EXISTS(
		SELECT * FROM @tb_block
		WHERE top_blocking_session_id =A.top_blocking_session_id
			AND wait_time >= 1000)

-- ===========================================
-- ʹ�� DBCC INPUTBUFFER ��ȡ�������̵� T-SQL �ű�
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
-- ��ʾ����������Ϣ
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
	-- ��ʡ���������ֱ������ sysprocess, ���߿��Ը�Ϊ����ǰ�����ܵġ���ѯ����"�Ľű������滻
	INNER JOIN master.dbo.sysprocesses P
		ON BLK.session_id = P.spid
	OUTER APPLY sys.dm_exec_sql_text(P.sql_handle) T
ORDER BY BLK.top_blocking_session_id, BLK.blocking_path
