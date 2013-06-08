
/*������ݿ���־�ļ����ͷ�����ռ䡣*/
/*�˷���������϶�Ĵ�����Ƭ��������Ϊ�����ֶΡ�*/

--1������Ϊ"��ģʽ"��

USE [master]
GO
ALTER DATABASE hk_erp_qd SET RECOVERY SIMPLE WITH NO_WAIT
GO
ALTER DATABASE hk_erp_qd SET RECOVERY SIMPLE 
GO

--2�������־�ļ����ͷſռ������ϵͳ��
USE hk_erp_qd 
GO
declare @ID int 
SET @ID=(select file_idex('HK_ERP_blank_log'))
DBCC SHRINKFILE (N'HK_ERP_blank_log' ,@ID, TRUNCATEONLY)  --�������βο�������Ϣ��
GO
/*file_name 
Ҫ�������ļ����߼����ơ�

file_id 
Ҫ�������ļ��ı�ʶ (ID) �š���Ҫ����ļ� ID����ʹ�� FILE_IDEX ϵͳ����(select file_idex('HK_ERP_blank_log'))��
���ѯ��ǰ���ݿ��е� sys.database_files Ŀ¼��ͼ��

TRUNCATEONLY
���ļ�ĩβ�����п��ÿռ��ͷŸ�����ϵͳ���������ļ��ڲ�ִ���κ�ҳ�ƶ��������ļ�ֻ�����������������
		*/

--3����ԭΪ"��ȫģʽ",��Ϊ�߷��յĲ�����Ҫ��־���лָ���
USE [master]
GO
ALTER DATABASE hk_erp_qd SET RECOVERY FULL WITH NO_WAIT
GO
ALTER DATABASE hk_erp_qd SET RECOVERY FULL  
GO


--------------------------------------------------------------------
--SET RECOVERY _����_

--��ָ��Ϊ FULL ʱ����ʹ��������־�����ڷ������ʹ��Ϻ������ȫ�ָ�����������ļ��𻵣����ʻָ����Ի�ԭ�������ύ������

--��ָ��Ϊ BULK_LOGGED ʱ�����ۺ�ĳЩ���ģ�������������������ܺ���־�ռ������ռ�������ڷ������ʹ��Ϻ���лָ���

--��ָ��Ϊ SIMPLE ʱ�����ṩռ����С��־�ռ�ļ򵥱��ݲ��ԡ�



-----------------�����־---------------------------------------------------------

--2000��2005֧�֣�2008��֧��
DUMP TRANSACTION debug_pt_v101 WITH NO_LOG
-(SQL2005)


Backup Log DNName with no_log
go
dump transaction debug_pt_v101 with no_log
go
USE debug_pt_v101
DBCC SHRINKFILE (2)
Go


--2008�������־
USE [master]
GO
ALTER DATABASE pattySocure01 SET RECOVERY SIMPLE WITH NO_WAIT
GO
ALTER DATABASE pattySocure01 SET RECOVERY SIMPLE   --��ģʽ
GO
USE pattySocure01
GO
DBCC SHRINKFILE (N'HK_ERP_Blank_log' , 11, TRUNCATEONLY)
GO

USE [master]
GO
ALTER DATABASE pattySocure01 SET RECOVERY FULL WITH NO_WAIT
GO

ALTER DATABASE pattySocure01 SET RECOVERY FULL  --��ԭΪ��ȫģʽ
GO

/*
--�ŵ㣺�������־���������ĵ�ʱ��̣�90GB����־�ڷ������Ҽ��������ϣ�����֮��������ȫ�����ڷ�����
������ɡ�
ȱ�㣺 �����˶�����ò�Ҫ����ʹ�ã���Ϊ�������л����ϵͳ��Ƭ����ͨ״̬��LOG��DIFF�ı��ݼ��ɽض���־��
�����ʹ�õ�ǡ����������ϵͳ����־�ļ��쳣������߱���LOGʱ��̫������Ӱ�������������ʹ�á�

*