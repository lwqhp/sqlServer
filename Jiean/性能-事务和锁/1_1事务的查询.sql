

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

--�������ʵ����Ҫ��sys.partitions��ͼ��ȡ
SELECT 
request_session_id AS spid,
DB_NAME(resource_database_id) AS dbname,
CASE WHEN resource_type = 'object' THEN OBJECT_NAME(resource_associated_entity_id)
	WHEN resource_associated_entity_id = 0 THEN 'n/a'
	ELSE OBJECT_NAME(p.object_id) END AS entity_name,
	index_id,
	resource_type AS RESOURCE,
	resource_description AS DESCRIPTION,
	request_mode AS mode,
	request_status AS status
 FROM sys.dm_tran_locks t 
LEFT JOIN sys.partitions p ON p.partition_id = t.resource_associated_entity_id
WHERE resource_database_id = DB_ID()