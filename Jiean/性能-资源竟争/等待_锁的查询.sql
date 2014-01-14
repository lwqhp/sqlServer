

--���ڵȴ������Ĳ�ѯ
/*
��ص���ͼ��ϵͳ��

ϵͳ�ܹ��еı�
sys.parations : ϵͳ��ÿһ�����������ÿ������ռһ�У���sqlServer2008���з�����ĸ���ģ���������ǰ�����
	����֯�ģ�Ĭ�������ļ����е�һ���������������ͼ���Բ鿴��������ķ���ID
	
����Դ��ͼ
sys.dm_tran_locks : ����������ͼ�����Բ鿴��ǰ����������Ϣ�����ǵ�ǰ��ģ���û�н���������Դʹ�����	


����ϵͳ��Դ�ȴ�����ͼ
sys.dm_os_waiting_tasks : ���Բ鿴��ǰ���ڵȴ���Դ�Ķ�����������Ϣ��

���������������ͼ
sys.dm_exec_requests : ���Բ鿴��ǰ��ÿ��������Ϣ


���ڲ�ѯ������ͼ
sys.dm_exec_sql_text : ִ�й���sql�������ı�


*/

SELECT 
a.request_session_id AS waitingSessionID
, b.blocking_session_id AS blockingSessionID
,b.resource_description
,b.wait_type
,b.wait_duration_ms
,DB_NAME(a.resource_database_id) AS databaseName
,a.resource_associated_entity_id AS waitingAssociatedEntity
,a.resource_type AS waitingRequestType
,a.request_type AS waitingRequestType
,d.text AS waitingTsql
,g.request_type blockingRequestType
,f.text AS blockingTsql
FROM sys.dm_tran_locks a
INNER JOIN sys.dm_os_waiting_tasks b ON a.lock_owner_address = b.resource_address
INNER JOIN sys.dm_exec_requests c ON c.session_id = a.request_session_id
CROSS APPLY sys.dm_exec_sql_text(c.sql_handle) d
LEFT JOIN sys.dm_exec_requests e ON e.session_id = b.blocking_session_id
OUTER APPLY sys.dm_exec_sql_text(e.sql_handle) f
LEFT JOIN sys.dm_tran_locks g ON e.session_id = g.request_session_id

--sqltrace���ٷ�ʽ
--��������������ֵ
SET sp_configure 'blocked process threshold',5
RECONFIGURE;

--���ýű�trace ,Error and Wairnings --blocked rocess Report

--������������
/*
1���Ż������ͱ�������spid��ִ�еĲ�ѯ
2,���͸��뼶��
3���������õ�����
	���������ݰ����ݽ���ˮƽ�ָ��ͬ�ķ�������ʹ����������ڵ����ķ����ϲ���ִ�У����ụ����������Щ����
	�ķ�������Ϊ��ѯ�����ºͲ����һ����Ԫ��sqlserverֻ�ָ�洢�ͷ��ʡ�
4�������õ�������ʹ�ø�������

���������Ľ���
1�����̵ֶ�����
2����һ��������ִ�����ٵĲ��衢�߼�
3������Ҫ������ִ�д������ⲿ����緢�͸����ʼ���ִ�������û������Ļ
4��ʹ�������Ż���ѯ
5������Ҫ������������ȷ��ϵͳ�в��˵���������
6��������Ƶ�����µ�����ʹ�þۼ����������¾ۼ�������Ҫ���ھۼ������ͷǾۼ������ϵ���
7������ʹ���������Է���������seelct���
8�����Ƿ������õı�
9��ʹ�ò�ѯ����������ʧ�صĲ�ѯ
10��������Ϊ���ӵĴ������� �̿�Ӧ���߼���������Χʧ��
11��ʹ��set xact_abort on���������г��ִ���ʱ���ִ�
12����ִ�а��������sql�����ߴ洢�������ӿͻ��˴�����catch ִ��if @@trancount>0 rollback
13��ʹ�����Ϸǵ���͸��뼶��
14��ʹ��Ĭ�ϸ��뼶��
15������ʹ���а汾���ư����������á�
*/

--�Զ��������ռ�������Ϣ
/*
���ܼ�����
SqlServer ��LOcks
	average wait time ƽ���ȴ�ʱ��
	lock wait time ���ȴ�ʱ��

*/

--��������
/*
1��������ͬ��ʱ��˳�������Դ
2�������������罫�Ǿۼ�����ת��Ϊ�ۼ�������Ϊselect���ʹ�ø�������
3����С���������ã�����ʵ���а汾���ƣ����͸��뼶��ʹ������ʾ
*/