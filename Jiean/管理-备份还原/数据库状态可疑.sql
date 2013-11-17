


/*
一、SQL-Server附加数据库时失败。
1、异常情况：服务器在正常运行的情况下突然断电，导致数据库文件损坏，具体表现是：数据库名后面有“（置疑）”字样。
2、异常分析：关于823错误的 SQL-SERVER 中的帮助：
错误 823
严重级别 24
消息正文
在文件 "%4!" 的偏移量 %3! 处的 %2! 过程中，检测到 I/O 错误 %1!。 
解释
Microsoft SQL Server 在对某设备进行读或写请求时遇到 I/O 错误。该错误通常表明磁盘问题。但是，错误日志中在错误 823 之前记录的其它核心消息应指出涉及了哪个设备。

*/
/*解决办法：
在SQL-Server企业管理器中，新建同名数据库（这里假设为Test）后，停止数据库，
把损坏的数据库文件Data.mdf和Test_log.LDF覆盖刚才新建数据库目录下的Data.mdf和Test_log.LDF，
同时删除Test_log.LDF文件；启动数据库服务，发现数据库名Test后面有“置疑”字样。不要紧，
打开SQL自带查询分析器，分别执行如下SQL语句：

*/
USE MASTER
GO
exec sp_configure 'allow updates',1 RECONFIGURE WITH OVERRIDE /* 打开修改系统表的开关 */
GO
--数据库标记为 READ_ONLY，禁用日志记录，并且仅限 sysadmin 固定服务器角色的成员访问。EMERGENCY 主要用于故障排除。例如，可以将由于损坏了日志文件而标记为可疑的数据库设置为 EMERGENCY 状态。这样，系统管理员便可对数据库进行只读访问。只有 sysadmin 固定服务器角色的成员才可以将数据库设置为 EMERGENCY 状态。
ALTER DATABASE Test SET EMERGENCY
GO
sp_dboption 'Test', 'single user', 'true' --设置数据为单用户模式
GO

----设置数据库为单用户模式
--alter database Test set single_user with ROLLBACK IMMEDIATE 

----恢复多用户模式
--alter database Test set multi_user with ROLLBACK IMMEDIATE

DBCC CHECKDB('MyDB','REPAIR_ALLOW_DATA_LOSS') --允许丢失数据修复
GO
ALTER DATABASE Test SET ONLINE --数据库已打开且可用
GO

sp_configure 'allow updates', 0 reconfigure with override /* 关闭打开修改系统表的开关 */
GO
sp_dboption 'MyDB', 'single user', 'false' --关闭数据单用户模式
GO


