
/*清除数据库日志文件并释放物理空间。*/
/*此方法会产生较多的磁盘碎片，不可作为常用手段。*/

--1、设置为"简单模式"。

USE [master]
GO
ALTER DATABASE hk_erp_qd SET RECOVERY SIMPLE WITH NO_WAIT
GO
ALTER DATABASE hk_erp_qd SET RECOVERY SIMPLE 
GO

--2、清除日志文件并释放空间给操作系统。
USE hk_erp_qd 
GO
declare @ID int 
SET @ID=(select file_idex('HK_ERP_blank_log'))
DBCC SHRINKFILE (N'HK_ERP_blank_log' ,@ID, TRUNCATEONLY)  --参数依次参考下列信息。
GO
/*file_name 
要收缩的文件的逻辑名称。

file_id 
要收缩的文件的标识 (ID) 号。若要获得文件 ID，请使用 FILE_IDEX 系统函数(select file_idex('HK_ERP_blank_log'))，
或查询当前数据库中的 sys.database_files 目录视图。

TRUNCATEONLY
将文件末尾的所有可用空间释放给操作系统，但不在文件内部执行任何页移动。数据文件只收缩到最后分配的区。
		*/

--3、还原为"完全模式",因为高风险的操作需要日志进行恢复。
USE [master]
GO
ALTER DATABASE hk_erp_qd SET RECOVERY FULL WITH NO_WAIT
GO
ALTER DATABASE hk_erp_qd SET RECOVERY FULL  
GO


--------------------------------------------------------------------
--SET RECOVERY _参数_

--当指定为 FULL 时，将使用事务日志备份在发生介质故障后进行完全恢复。如果数据文件损坏，介质恢复可以还原所有已提交的事务。

--当指定为 BULK_LOGGED 时，将综合某些大规模或大容量操作的最佳性能和日志空间的最少占用量，在发生介质故障后进行恢复。

--当指定为 SIMPLE 时，将提供占用最小日志空间的简单备份策略。



-----------------清除日志---------------------------------------------------------

--2000和2005支持，2008不支持
DUMP TRANSACTION debug_pt_v101 WITH NO_LOG
-(SQL2005)


Backup Log DNName with no_log
go
dump transaction debug_pt_v101 with no_log
go
USE debug_pt_v101
DBCC SHRINKFILE (2)
Go


--2008下清除日志
USE [master]
GO
ALTER DATABASE pattySocure01 SET RECOVERY SIMPLE WITH NO_WAIT
GO
ALTER DATABASE pattySocure01 SET RECOVERY SIMPLE   --简单模式
GO
USE pattySocure01
GO
DBCC SHRINKFILE (N'HK_ERP_Blank_log' , 11, TRUNCATEONLY)
GO

USE [master]
GO
ALTER DATABASE pattySocure01 SET RECOVERY FULL WITH NO_WAIT
GO

ALTER DATABASE pattySocure01 SET RECOVERY FULL  --还原为完全模式
GO

/*
--优点：此清除日志所运行消耗的时间短，90GB的日志在分钟左右即可清除完毕，做完之后做个完全备份在分钟内
即可完成。
缺点： 不过此动作最好不要经常使用，因为它的运行会带来系统碎片。普通状态下LOG和DIFF的备份即可截断日志。
此语句使用的恰当环境：当系统的日志文件异常增大或者备份LOG时间太长可能影响生产的情况下使用。

*