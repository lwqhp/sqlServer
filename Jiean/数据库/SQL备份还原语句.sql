/*
���ݲ���Ҫ�㣺

 ���ȼ򵥵Ľ���һ��Sql server ���ݵ������У�
 
1���������ݣ����е������ļ��Ͳ��ֵ�������־�ļ���
 
2�����챸�ݣ����һ����ɱ��ݺ����ݿ�ı�Ĳ��֣�
 
3���ļ����ļ��鱸�ݣ���ָ�����ļ����ļ��鱸�ݣ�
 
4��������־���ݣ��������ݿ�ı����
 
5��β���ڱ��ݣ���־�Ļ���֣�ָ��һ��Ϊ���ݵ���־���֣�
 
6�����ֱ��ݣ����ļ��顢ÿ���ɶ���д�ļ����ָ����ֻ���ļ��飩
 
7�������Ʊ��ݣ����ݿ������־�ı��ݣ���Ӱ�����屸�ݣ�
 */



--------------------��������Ĭ��׷�ӵ����е��ļ�---------------  
backup database NorthWind
To disk='d:/backup/NorthWindCS-Full-2010-11-23.bak'  
 
--------�������ݣ��������е��ļ�  
Backup database NorthWind  
To disk='d:/backup/NorthWindCS-Full-2010-11-23.bak'  
With init---���������ļ�����
  
--------���챸�ݣ��ϴ�һ�������������ı������ҳ��  
backup database NorthWind  
To Disk='d:/backup/NorthWindCS-Full-2010-11-23.bak'  
with differential  
  
-----������־���ݣ����Զ��ض���־(Ĭ�ϻ�׶���־)  
backup log NorthWind  
To Disk='d:/backup/NorthWindCS-log-2010-11-23'  

-----������־���ݣ����ض���־(Ĭ�ϻ�׶���־)  
backup log NorthWind  
To Disk='d:/backup/NorthWindCS-log-2010-11-23'  
With No_Truncate  
 
-----������ֱ�ӽ׶���־����SQL SERVER2008�в���֧�֡�  
backup log NorthWind With No_Log  
backup log NorthWind With Tuancate_only  
 
-----SQL SERVER 2008 ����Ľض���־����  
alter database NorthWind set Recovery Simple  
exec sp_helpdb NorthWInd  
use NorthWind   
dbcc shrinkfile('NorthWind_log')  
alter database NorthWind set Recovery Full  
  
----���������ݿ���ļ����ļ��鱸��  
Exec sp_helpdb NorthWind  
backup database NorthWind File='NorthWind_Current'  
to disk='h:/backup/NorthwindCS_Full_2010031.bak'  
backup database NorthWind FileGroup='Current'  
to disk='h:/backup/NorthwindCS_FG_2010031.bak'  
  
---�����Ʊ��ݣ���Ӱ�����еı�������  
backup database NorthWind  
To disk='h:/backup/NorthwindCS_Full_2010031.bak'  
With Copy_only  
 
  
--β����־����,������ɺ����ݿⲻ���ṩ����  
use master  
go  
backup log NorthWind  
to disk='h:/backup/Northwind-taillog-20101031.bak'  
With NoRecovery  
  
--�ظ����ݿ��ṩ����  
Restore databse NorthWind with Recovery  
  
--�ָ�ݵ����Ŀ���ļ�  
backup database NorthWind   
to disk='h:/backup/Northwind-part1.bak',  
disk='h:/backup/NorthwindCS-part2.bak'  
  
--���񱸷ݣ���Ҫ����With Format  
backup database NorthWind  
to disk='h:/backup/NorthwindCS-Mirror1.bak'  
Mirror to disk='h:/backup/NorthwindCS-Mirror2.bak'----Mirror����  
With Format  
 
 
--���ݵ�Զ�̷�����  
--ʹ��SQL SERVER �ķ��������˺ŷ���Զ�̹����д�ļ���  
backup database Northwind  
to disk='//192.168.3.20/backup/nw-yourname.bak'  
  
--���ݵ�Զ�̷�����,ָ������Զ�̷��������˺ź�����  
Exec sp_configure  
Exec Sp_COnfigure 'show advanced options',1  
Reconfigure with Overrid  
Exec sp_configure 'xp_cmdshell',1  
Reconfigure with override  
  
 
Exec xp_cmdshell  
'net use //192.168.10.101', '/user:administrator password'  

backup database Northwind   
to disk='//192.168.10.101/backup/nw-fy.bak'  
  
Exec sp_configure 'xp_cmdshell',0  
Reconfigure with override  
 
 
--------------------------------------  
--����ѹ��  
--------------------------------------  
Backup Database AdventureWorks  
To disk='h:/backup/adv��ѹ������.bak'  
--132MB  ���� 7.789 ��(16.877 MB/��)��  
  
--���ݵ�NTFSĿ¼  
Backup Database AdventureWorks  
To disk='H:/backup/test/advNTFSѹ������.bak'  
--60MB     ���� 11.871 ��(11.073 MB/��)��  
  
Backup Database AdventureWorks  
To disk='h:/backup/advѹ������.bak'  
With Compression  
--132MB  ���� 7.789 ��(16.877 MB/��)��  
--34MB    ���� 3.775 ��(34.820 MB/��)��  
 
--����Ĭ�ϱ���ѹ��  
EXEC sp_configure 'backup compression default', '1'  
RECONFIGURE WITH OVERRIDE  
GO  





/*======================������ԭ����*=======================*/
use master
go

restore database New_database from disk='����·��'
go

/*
��ػ�ԭ���� A�����ݣ�B����ԭ
*/
use master

--��ȡ��ر����ļ�λ��
restore filelistonly 
from disk='E:\DB\HK_ERP_YBL_backup_2013_06_04_000003_9242408\HK_ERP_YBL_backup_2013_06_04_000003_9242408\HK_ERP_YBL_backup_2013_06_04_000003_9242408.bak'

--��ȡĿ�����ݿ�λ��
sp_helpdb 'Upgrade_V1.11_YBL'

--��ԭ��ر����ļ���Ҫ�õ���with move��
restore database Upgrade_V111_YBL 
from disk='E:\DB\HK_ERP_YBL_backup_2013_06_04_000003_9242408\HK_ERP_YBL_backup_2013_06_04_000003_9242408\HK_ERP_YBL_backup_2013_06_04_000003_9242408.bak' 
with move 'HK_ERP_Blank' to 'D:\DB\Upgrade_V1.11_YBL.mdf',
move 'HK_ERP_Blank_log' to 'D:\DB\Upgrade_V1.11_YBL_1.ldf'

--�޸����ݿ���
sp_renamedb 'Upgrade_V111_YBL','Upgrade_V1.11_YBL'


