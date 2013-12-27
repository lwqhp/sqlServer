/*
介质集，介质簇，备份集

备份介质：备份载体的最小单元，分磁盘和磁带
介质集(媒体集)media set：  备份介质的有序集合(逻辑概念).
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


--介质集
select * from  msdb.dbo.backupmediaset

--里面的记录表明某个媒体集编号包含多少个物理文件，每一行又称为介质簇
select * from  msdb.dbo.backupmediafamily
/*
physical_device_name : 备份集的保存路径

backup_set_id：对数据库的每次备份都有唯一的一个编号，即为备份集编号

media_set_id：为备份媒体集编号，此为一个逻辑名称，对三个物理文件的抽象的称谓，如果是把多次的备份同时放入一个物理文件中，那备份媒体集编号是不变的

last_family_number：备份放入多少个物理文件中的
*/

--备份日志，备份的历史信息,每当对数据库做备份时，sqlserver往msdb.dbo.backupset表中插入一行记录
select * from msdb.dbo.backupset

--数据库备份文件信息
select * from  msdb.dbo.backupfile
/*
physical_drive 备份来源的驱动器
physical_name 备份来源的物理路径
*/

SELECT 
c.first_lsn, 
c.last_lsn,
c.database_backup_lsn,
c.backup_finish_date,
c.type,
b.physical_device_name
FROM msdb..backupmediafamily a --介质集记录每一次备份信息
INNER JOIN msdb..backupmediafamily b ON a.media_set_id = b.media_set_id -- 介质簇具体记录保存路径，簇数
INNER JOIN msdb..backupset c ON a.media_set_id = c.media_set_id --备份日志：关联相关的介质集的备份记录(一般直接查询这里即可)
INNER JOIN msdb..backupfile d ON c.backup_set_id = d.backup_set_id --关联出备份来源的相关信息
ORDER BY c.backup_finish_date DESC 
/*
对于日志备份来讲，first_lsn 标识备份集中第一个日志记录的日志，last_lsn 标识备份集之后的下一条日志记录的日志
序列号，所以(first_lsn,last_lsn-1)标识了这个日志备份所包含的所有日志序列。

batabase_backup_lsn 标识上一次数据库全备份的起始LSN.
*/

BACKUP DATABASE [Test] TO DISK = 'e:\Test.bak'

SELECT * FROM msdb..backupset a
--INNER JOIN msdb..backupfile b ON a.backup_set_id = b.backup_set_id
WHERE  a.database_name ='Test'
--first_lsn last_lsn checkpoint_lsn database_backup_lsn
--253000000558200037  253000000559800001 253000000558200037 253000000555800037

CREATE TABLE tbb1(id int)
go
INSERT INTO tbb1 VALUES(1)

--做一个日志备份
BACKUP LOG [test] TO DISK = 'e:\Testlog.bak'

SELECT * FROM msdb..backupset
--fork_point_lsn - first_lsn - last_lsn - database_backup_lsn
--67000000022400001	67000000022400001  253000000561500001 253000000558200037
/*
日志备份的checkpoint点是上次备份的point点，database_bakcup_lsn点保持不变
*/

--做一次修改
INSERT INTO tbb1(id) VALUES(2)

--再做一次日志备份
BACKUP LOG [Test] TO DISK='e:\Testlog2.bak'
SELECT * FROM msdb..backupset
--fork_point_lsn - first_lsn - last_lsn - database_backup_lsn
--null	253000000561500001  253000000558200037 253000000558200037
/*
first_lsn 是上一次日志备份的尾lsn,不影响database_backup_lsn
*/


--做一个差异备份
INSERT INTO tbb1(id) VALUES(3)

BACKUP DATABASE [Test] TO DISK='e:\Testdiff.bak' WITH differential
SELECT * FROM msdb..backupset
--differential_baselsn - first_lsn - last_lsn - checkpoint_lsn - database_backup_lsn
--253000000558200037	253000000561800144  253000000567800001 253000000561800144 253000000558200037
/*
差异备份的point_lsn是跟着完全备份的
*/

--再做一次日志备份
INSERT INTO tbb1(id) VALUES(4)

BACKUP LOG [Test] TO DISK ='e:\Testlog3.bak'
SELECT * FROM msdb..backupset
--fork_point_lsn - first_lsn - last_lsn - database_backup_lsn
--null	253000000561700001  253000000568000001 253000000558200037
/*
日志备份的first_lsn是紧跟着上一次日志备份的last_lsn，database_backup_lsn则保存最近一次数据备份不变
*/

/*
总结：
1）不管是全备份还是差异备份，都不会影响lsn的序列，所以，即使用最近的几个全备份或差异备份受损，只要有一个全备份，
以及该全备后所有的日志备份，我们也是能够完整无缺地把数据恢复出来，只是恢复的时间会稍微长一点。
中间的差异备份或其他全备份只是减少了需要恢复的日志备份数目，这进一步说明了日志备份的重要性。

2）日志备份的lsn是连续的，否则在恢复的时候，会碰到日志断裂的问题，恢复是不能继续下去的。

*/

--检查日志链
SELECT ROW_NUMBER() OVER(ORDER BY backup_finish_date) id,first_lsn,last_lsn
INTO #tmp
 FROM msdb..backupset a
INNER JOIN msdb..backupfile b ON a.backup_set_id = b.backup_set_id AND b.file_type='L'
WHERE type='L' AND b.physical_name='F:\DB\Test_log.ldf'
ORDER BY backup_finish_date

SELECT * FROM #tmp

;WITH CTETmp AS(
	SELECT id,first_lsn,last_lsn,0 AS [level] FROM #tmp WHERE id = 1
	UNION ALL
	SELECT a.id,a.first_lsn,a.last_lsn,b.[level] +1 AS [level] FROM #tmp a
	INNER JOIN CTETmp b ON a.id = b.id+1 AND a.first_lsn <>b.last_lsn
)
SELECT * FROM CTETmp WHERE [level]>0

--测试
UPDATE #tmp SET first_lsn = 253000000561500002 WHERE id = 2

