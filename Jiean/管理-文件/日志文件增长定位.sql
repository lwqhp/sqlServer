

--��־�ļ�������λ

--�����־����ʹ����������ݿ�״̬

DBCC SQLPERF(LOGSPACE)
GO
SELECT 
name,recovery_model_desc,log_reuse_wait,log_reuse_wait_desc--��ӳsqlserver��Ϊ�Ĳ��ܽض���־��ԭ��
 FROM sys.databases
 
 --������ϵĻ����
 /*
 ����󲿷���־��ʹ���У�������־���õȴ�״̬��active_transaction,��ôҪ��������ݿ����δ�ύ�����񵽵�����
 ˭�����
 */
 
 DBCC OPENTRAN
 GO
 SELECT * FROM sys.dm_exec_sessions t2,sys.dm_exec_connections t1
 CROSS APPLY sys.dm_exec_sql_text(t1.most_recent_sql_handle) st
 WHERE t1.session_id = t2.security_id
 AND t1.session_id >50
 
 /*
 �ٴ�����dbcc opentran,����᷵����һ�����δ�ύ������ֱ�����е������ύ��ع����Ϊֹ��
 */