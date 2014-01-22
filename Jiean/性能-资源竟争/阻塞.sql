

--����
/*

����������ԭ��
1����һ��û�������ı��Ϲ����������ᵼ��sqlserver�õ�һ���������Ӷ�������������
2��Ӧ�ó����һ�����񣬹ع����񱣳ִ򿪵�ʱ��Ҫ���û����з������߽�����
3������begin���ѯ�����ݿ���������ʼ֮ǰ������
4����ѯ��ǡ����ʹ��������ʾ
5��Ӧ�ó���ʹ�ó�ʱ�����е�������һ�������и����˺ܶ��л�ܶ��(��һ���������µ������ɶ�����½���
�������ܰ������Ʋ�����)
*/

--��ѯ������Ϣ
SELECT  blocking_session_id, --��������������
wait_duration_ms,--����ʱ��
session_id --����������
FROM sys.dm_os_waiting_tasks
WHERE blocking_session_id IS NOT NULL


--�������ִ�����
SELECT b.text FROM sys.dm_exec_connections a
CROSS APPLY sys.dm_exec_sql_text(a.most_recent_sql_handle) b
WHERE a.session_id = 54

--ɱ������
KILL 54 WITH statusonly

--�������ȴ����ͷŵ�ʱ��
SET LOCK_TIMEOUT 1000 --1��

--����
/*
����������ԭ��
1,Ӧ�ó����Բ�ͬ�Ĵ�����ʱ�
2��Ӧ�ó���ʹ���˳�ʱ�����е�������һ�������и��ºܶ��л�ܶ���������������еı�������Ӷ�����������ͻ
3,��һЩ��ʷ�£�sqlserver������һЩ������֮�����־�����������Ϊ�����������Щ������ͬ������ҳ���У���������
�Ựϣ��ͬʱ����ͬ��ҳ�����������ȣ��ͻ����������
*/

--����д��־׷��

DBCC TRACEON(1222,-1) --�����������ٱ�־��д��־
GO
DBCC TRACESTATUS --��ʾ���غ�ȫ�ֻỰ�л�ĸ���
GO

--һ����������
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

WHILE 1=1
BEGIN 
BEGIN TRAN 
	UPDATE purchasing.vendor SET creditrating=1 WHERE businessentityID = 1494
	UPDATE purchasing.vendor SET creditrating=2 WHERE businessentityID = 1492
COMMIT TRAN 
END

--
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

WHILE 1=1
BEGIN 
BEGIN TRAN 
	UPDATE purchasing.vendor SET creditrating=2 WHERE businessentityID = 1492
	UPDATE purchasing.vendor SET creditrating=1 WHERE businessentityID = 1494
COMMIT TRAN 
END

--�رձ�־
DBCC TRACEOFF(1222,-1)
GO
DBCC TRACESTATUS

--�������������ȼ�
SET DEADLOCK_PRIORITY LOW | NORMAL | High