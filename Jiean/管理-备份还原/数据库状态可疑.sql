


/*
һ��SQL-Server�������ݿ�ʱʧ�ܡ�
1���쳣��������������������е������ͻȻ�ϵ磬�������ݿ��ļ��𻵣���������ǣ����ݿ��������С������ɣ���������
2���쳣����������823����� SQL-SERVER �еİ�����
���� 823
���ؼ��� 24
��Ϣ����
���ļ� "%4!" ��ƫ���� %3! ���� %2! �����У���⵽ I/O ���� %1!�� 
����
Microsoft SQL Server �ڶ�ĳ�豸���ж���д����ʱ���� I/O ���󡣸ô���ͨ�������������⡣���ǣ�������־���ڴ��� 823 ֮ǰ��¼������������ϢӦָ���漰���ĸ��豸��

*/
/*����취��
��SQL-Server��ҵ�������У��½�ͬ�����ݿ⣨�������ΪTest����ֹͣ���ݿ⣬
���𻵵����ݿ��ļ�Data.mdf��Test_log.LDF���Ǹղ��½����ݿ�Ŀ¼�µ�Data.mdf��Test_log.LDF��
ͬʱɾ��Test_log.LDF�ļ����������ݿ���񣬷������ݿ���Test�����С����ɡ���������Ҫ����
��SQL�Դ���ѯ���������ֱ�ִ������SQL��䣺

*/
USE MASTER
GO
exec sp_configure 'allow updates',1 RECONFIGURE WITH OVERRIDE /* ���޸�ϵͳ��Ŀ��� */
GO
--���ݿ���Ϊ READ_ONLY��������־��¼�����ҽ��� sysadmin �̶���������ɫ�ĳ�Ա���ʡ�EMERGENCY ��Ҫ���ڹ����ų������磬���Խ�����������־�ļ������Ϊ���ɵ����ݿ�����Ϊ EMERGENCY ״̬��������ϵͳ����Ա��ɶ����ݿ����ֻ�����ʡ�ֻ�� sysadmin �̶���������ɫ�ĳ�Ա�ſ��Խ����ݿ�����Ϊ EMERGENCY ״̬��
ALTER DATABASE Test SET EMERGENCY
GO
sp_dboption 'Test', 'single user', 'true' --��������Ϊ���û�ģʽ
GO

----�������ݿ�Ϊ���û�ģʽ
--alter database Test set single_user with ROLLBACK IMMEDIATE 

----�ָ����û�ģʽ
--alter database Test set multi_user with ROLLBACK IMMEDIATE

DBCC CHECKDB('MyDB','REPAIR_ALLOW_DATA_LOSS') --����ʧ�����޸�
GO
ALTER DATABASE Test SET ONLINE --���ݿ��Ѵ��ҿ���
GO

sp_configure 'allow updates', 0 reconfigure with override /* �رմ��޸�ϵͳ��Ŀ��� */
GO
sp_dboption 'MyDB', 'single user', 'false' --�ر����ݵ��û�ģʽ
GO


