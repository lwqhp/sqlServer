/*
备份策略要点：

 首先简单的介绍一下Sql server 备份的类型有：
 
1：完整备份（所有的数据文件和部分的事务日志文件）
 
2：差异备份（最后一次完成备份后数据库改变的部分）
 
3：文件和文件组备份（对指定的文件和文件组备份）
 
4：事物日志备份（所有数据库的变更）
 
5：尾日期备份（日志的活动部分，指上一次为备份的日志部分）
 
6：部分备份（主文件组、每个可读可写文件组和指定的只读文件组）
 
7：仅复制备份（数据库或者日志的备份，不影响整体备份）
 */



--------------------完整备份默认追加到现有的文件---------------  
backup database NorthWind
To disk='d:/backup/NorthWindCS-Full-2010-11-23.bak'  
 
--------完整备份，覆盖现有的文件  
Backup database NorthWind  
To disk='d:/backup/NorthWindCS-Full-2010-11-23.bak'  
With init---覆盖现有文件代码
  
--------差异备份（上次一完整备份以来改变的数据页）  
backup database NorthWind  
To Disk='d:/backup/NorthWindCS-Full-2010-11-23.bak'  
with differential  
  
-----事物日志备份，会自动截断日志(默认会阶段日志)  
backup log NorthWind  
To Disk='d:/backup/NorthWindCS-log-2010-11-23'  

-----事物日志备份，不截断日志(默认会阶段日志)  
backup log NorthWind  
To Disk='d:/backup/NorthWindCS-log-2010-11-23'  
With No_Truncate  
 
-----不备份直接阶段日志，在SQL SERVER2008中不再支持。  
backup log NorthWind With No_Log  
backup log NorthWind With Tuancate_only  
 
-----SQL SERVER 2008 替代的截断日志方法  
alter database NorthWind set Recovery Simple  
exec sp_helpdb NorthWInd  
use NorthWind   
dbcc shrinkfile('NorthWind_log')  
alter database NorthWind set Recovery Full  
  
----超大型数据库的文件和文件组备份  
Exec sp_helpdb NorthWind  
backup database NorthWind File='NorthWind_Current'  
to disk='h:/backup/NorthwindCS_Full_2010031.bak'  
backup database NorthWind FileGroup='Current'  
to disk='h:/backup/NorthwindCS_FG_2010031.bak'  
  
---仅复制备份，不影响现有的备份序列  
backup database NorthWind  
To disk='h:/backup/NorthwindCS_Full_2010031.bak'  
With Copy_only  
 
  
--尾部日志备份,备份完成后数据库不再提供访问  
use master  
go  
backup log NorthWind  
to disk='h:/backup/Northwind-taillog-20101031.bak'  
With NoRecovery  
  
--回复数据库提供访问  
Restore databse NorthWind with Recovery  
  
--分割备份到多个目标文件  
backup database NorthWind   
to disk='h:/backup/Northwind-part1.bak',  
disk='h:/backup/NorthwindCS-part2.bak'  
  
--镜像备份，需要加入With Format  
backup database NorthWind  
to disk='h:/backup/NorthwindCS-Mirror1.bak'  
Mirror to disk='h:/backup/NorthwindCS-Mirror2.bak'----Mirror镜像  
With Format  
 
 
--备份到远程服务器  
--使用SQL SERVER 的服务启动账号访问远程共享可写文件夹  
backup database Northwind  
to disk='//192.168.3.20/backup/nw-yourname.bak'  
  
--备份到远程服务器,指定访问远程服务器的账号和密码  
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
--备份压缩  
--------------------------------------  
Backup Database AdventureWorks  
To disk='h:/backup/adv不压缩备份.bak'  
--132MB  花费 7.789 秒(16.877 MB/秒)。  
  
--备份到NTFS目录  
Backup Database AdventureWorks  
To disk='H:/backup/test/advNTFS压缩备份.bak'  
--60MB     花费 11.871 秒(11.073 MB/秒)。  
  
Backup Database AdventureWorks  
To disk='h:/backup/adv压缩备份.bak'  
With Compression  
--132MB  花费 7.789 秒(16.877 MB/秒)。  
--34MB    花费 3.775 秒(34.820 MB/秒)。  
 
--启动默认备份压缩  
EXEC sp_configure 'backup compression default', '1'  
RECONFIGURE WITH OVERRIDE  
GO  





/*======================本机还原策略*=======================*/
use master
go

restore database New_database from disk='本机路径'
go

/*
异地还原策略 A机备份，B机还原
*/
use master

--获取异地备份文件位置
restore filelistonly 
from disk='E:\DB\HK_ERP_YBL_backup_2013_06_04_000003_9242408\HK_ERP_YBL_backup_2013_06_04_000003_9242408\HK_ERP_YBL_backup_2013_06_04_000003_9242408.bak'

--获取目标数据库位置
sp_helpdb 'Upgrade_V1.11_YBL'

--还原异地备份文件需要用到（with move）
restore database Upgrade_V111_YBL 
from disk='E:\DB\HK_ERP_YBL_backup_2013_06_04_000003_9242408\HK_ERP_YBL_backup_2013_06_04_000003_9242408\HK_ERP_YBL_backup_2013_06_04_000003_9242408.bak' 
with move 'HK_ERP_Blank' to 'D:\DB\Upgrade_V1.11_YBL.mdf',
move 'HK_ERP_Blank_log' to 'D:\DB\Upgrade_V1.11_YBL_1.ldf'

--修改数据库名
sp_renamedb 'Upgrade_V111_YBL','Upgrade_V1.11_YBL'


