/*
介质集，介质簇，备份集

备份介质：备份载体的最小单元，分磁盘和磁带
介质集(媒体集)media set：  备份介质的有序集合.
介质簇media family : 是对介质集中‘备份设备’的标识，同一组的镜像备份设备标识为一个簇。
		在介质集中，根据介质簇在介质集中的位置，按顺序给介质簇进行编号。 
备份集: 也就是备份设备，这是一个逻辑概念，在磁盘中，是指文件，在磁带机中，则是指磁带.

还原：
 对于任何从磁盘备份进行的还原以及任何联机还原，必须同时装入全部介质簇。 
 对于从磁带备份进行的脱机还原，可以在数量少于介质簇的备份设备中处理介质簇。 
 必须在每一介质簇已完全处理之后才能开始处理另一个介质簇。 介质簇总是并行处理的，除非使用单个设备还原介质簇。
 
 选项：
 追加到现有备份集 ：通常将新的备份集追加到现有介质集。 追加到备份时会保留所有以前的备份。
	备份集过期时间：备份集到达预定义的到期日期时，备份会自动覆盖备份集。保持当前介质标头位置不变。

追加到现有备份集 ： 可以将来自相同或不同数据库的、在不同时间执行的备份存储在同一个介质上。 
	通过将其他备份集追加到现有介质上，介质上以前的内容保持不变，新的备份在介质上最后一个备份的结尾处写入。  
*/

------------------------------------------------------------------------------------------------
/*
当你得到一个备份时，有时候可能会不知道备份集中包含的备份信息
 只针对当前服务器路径
*/

--RESTORE 语句查询备份文件备份（媒体）集信息
RESTORE LABELONLY FROM DISK='F:\DBBak\ad01.bak'

/*FamilyCount :介质簇数目，如果>1,而实际上所能使用的备份集小于这个数目的话，则意味着无法从这个备份媒体
进行数据还原。
*/


--查看备份集所有信息
RESTORE HEADERONLY FROM DISK='F:\DBBak\ad01.bak'

/*
备份的文件名可以自定义，通过headeronly可以查看到备份文件备份时的名称backupname，备份的数据库databasename,
备份集在备份媒体中的位置position,用于file选项，备份类型和时间等。
*/

--查看备份文件信息，数据文件和日志文件
RESTORE FILELISTONLY FROM DISK='F:\DB\Backup\947kan' WITH FILE =1

/*
恢复数据库的时候，当需要把备份文件恢复他它原来的位置，这里可以查到备份时的数据库路径和原来的数据库名，
在GUI中只看到重命名的数据库名。
*/


----===========================================================================

/*通过系统信息了解数据库的备份记录和备份策略*/

--备份的历史信息,每当对数据库做备份时，sqlserver往msdb.dbo.backupset表中插入一行记录
select * from msdb.dbo.backupset

--数据库备份文件信息
select * from  msdb.dbo.backupfile

--备份集
select * from  msdb.dbo.backupmediaset

--里面的记录表明某个媒体集编号包含多少个物理文件，每一行又称为媒体簇
select * from  msdb.dbo.backupmediafamily
/*
backup_set_id：对数据库的每次备份都有唯一的一个编号，即为备份集编号

media_set_id：为备份媒体集编号，此为一个逻辑名称，对三个物理文件的抽象的称谓，如果是把多次的备份同时放入一个物理文件中，那备份媒体集编号是不变的

last_family_number：备份放入多少个物理文件中的
*/


--=================================================================================

/*
备份 | 
backup database 数据库 to 备份媒体集 with DifferEntial init | skip | format
init -表示备份时需要覆盖备份媒体，并在备份媒体上将该 备份作为第一个文件写入。
format 表示在每一次使用媒体时对备份媒体进行初始化，并覆盖任何现有的的媒体标头。不能和init同时使用。
DifferEntial 差异备份参数
*/
--完全备份：备份数据库中的所有数据，以及可以恢复这些数据的足够日志。

--差异备份：自最近一次完整备份后发生更改的数据，最近一次完整备份称为差异的“基准”
/*以下都可以作为差异备份的基准
完全数据库备份
部份备份
文件和文件组备份
*/

--部份备份：(针对文件组的备份)类似于完全备份，但是部份备份仅包含指定的文件组中的数据：主文件组，所有可读写文件组以及任何指定的只读文件组。

USE master
go
CREATE DATABASE db_test ON(
NAME = 'db_test_data',
FILENAME = 'F:\DB\db_test.mdf'
),
FILEGROUP FG_READ_WITE(
	NAME =db_test_RW,
	FILENAME = 'F:\DB\db_test.ndf'
),
filegroup FG_READ_ONLY(
	NAME = db_test_r,
	FILENAME = 'F:\DB\db_test_r.ndf'
)
LOG ON(
	NAME = db_test_LOG,
	FILENAME = 'F:\DB\db_test.ldf'
)
go

ALTER DATABASE db_test MODIFY FILEGROUP FG_READ_ONLY READ_ONLY
go

BACKUP DATABASE db_test READ_WRITE_FILEGROUPS TO DISK = 'F:\DB\Backup\db_test.bak' WITH format

--指定文件组名称
BACKUP DATABASE db_test 
	FILEGROUP = 'PRIMARY',
	FILE = 'db_test_R'
TO DISK = 'F:\DB\Backup\db_test2.bak'
WITH format

--日志备份
/*
日志备份能用于完全备份FULL,和大容量记录的备份模式下，仅备份自上次备份后对数据库执行的所有事务的一系列记录，一般宜定期备份事务
日志，它可能使工作丢失的可能性降到最低，而且还能截断事务日志，不至于让日志文件无限制增长。
*/
BACKUP LOG db_test TO DISK='F:\DB\Backup\db_test3.bak'

---+==============================================================================
--备份媒体的可靠性
/*
1)在备份的同时多备份几份：镜像备份
这是sql2005的功能，允许在backup备份的时候，通过Mirror to子句指定镜像备份媒体集，一个备份语句中最多支持指定
3个镜像备份媒体集。
注：镜像媒体集与备份媒集需要有相同数据和类型的备份媒体。

2)验证备份集
a，备份时启用备份校验和 with checksums
b,备份完成后用restore verifyonly 检查备份集的完整性以及是否可读。
*/
--创建一个包含两个媒体簇的备份媒体集，并生成两个与备份媒体集一样的镜像媒体集。
BACKUP DATABASE msdb
TO DISK='F:\DB\Backup\msdb_a.bak',DISK='F:\DB\Backup\msdb_b.bak'
MIRROR TO DISK='F:\DB\Backup\msdb_a1.bak',DISK='F:\DB\Backup\msdb_b1.bak'
MIRROR TO DISK='F:\DB\Backup\msdb_a2.bak',DISK='F:\DB\Backup\msdb_b2.bak'
WITH format

--+================================================================================
--数据库还原
/*
数据库的还原有一个固定的过程
1)数据复制阶段，此阶段将创建数据库的所有数据文件和日志文件，并从指定的备份媒体中 复制指定备份集中备份的数据，日志和索引到数据
库和各个对应的文件中。
2）重做与前滚：在此阶段，所有记录的事务应用到数据复制阶段恢复的数据中。
3）撤消与回滚：回滚所有未提交的事务。完成此阶段后，数据库可以被用户使用，但无法再在此基础上还原其后续的备份。

还原选项
备份还原后，数据库是交付给用户使用，还是保持还原状态，以等待在此基础上继续还原后续的备份，这取决于还原
备份时所使用的是recovery 还是nocoverry选项
*/

如果你的数据库里面使用了作业，那么做数据库迁移或者换服务器的时候记得备份并还原msdb ，madb的还原要用单用户模式。