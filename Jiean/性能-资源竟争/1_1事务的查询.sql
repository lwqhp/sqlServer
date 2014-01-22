

--����Ĳ�ѯ

--��ʾ��ǰ��������������
DBCC OPENTRAN('databaseName')
/*
���ڹ������ӣ������ݿ��Ǵ򿪵ģ�����Ӧ�ó����ͻ����Ѿ��Ͽ������ӣ����ų������õģ����ܰ��������ҳ���©
��commit����rollback ������
*/

--�����Ų�

--1)���鵱ǰ���д򿪵������Լ���Ӧ�ĻỰID
SELECT * FROM sys.dm_tran_session_transactions

--2��ͨ���ỰID�˽�������̵����ӣ����ִ�е�����
SELECT * FROM sys.dm_exec_connections a
CROSS APPLY sys.dm_exec_sql_text(a.most_recent_sql_handle) b
WHERE session_id=3

--��ѯ���ڽ��кͻ�����
SELECT * FROM sys.dm_exec_connections a
INNER join sys.dm_exec_requests b ON a.session_id = b.session_id
WHERE a.session_id=3

--3)�˽�����������Ϣ����ʱ�䣬�������ͼ�״̬��
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