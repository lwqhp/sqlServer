

--备份模式
/*
简单恢复模式:不能做日志备份，只能将数据库恢复到最后一次备份的结尾，如果发生灾难，数据库最后一次备份之后做的
	数据修改将全部丢失。为了降低风险，可以引入差异备份
特点：1）在简单恢复模式下对事务日志的处理，采取自动截断日志，在checkpoint点，把不活动的事务日志截断重用，他还是
有可能会产生日志增长，但增长是比较小的。
2）不管是数据库完整备份还是差异备份，都不可能以比较频繁的频率进行，一般只能在晚间进行，如果数据库比较大，
	或者不允许比较长时间的数据丢失，这样的备份策略是不能满足要求的。
	
完整恢复模式：可以使用日志备份，允许将数据库还原到日志备份内包含的任何时点
特点：1)在完整恢复模式下，事务日志是需要备份的，sqlServer 会认为你要备份日志而一直保留，不管是否是活动的，直到做
完日志备份才会截断，不备份日志会造成日志文件快速增长。
2)尾日志备份：捕获尚未备份的所有日志记录作为一个结尾日志，用于在还原计划中，能还能到最近一个时间点。
结尾日志备份将是数据库还原计划中相关的最后一个备份.
尾日志和一般日志备份的区别：文件和备份方式没有不同，在数据库损坏或离线时作的尾日志备份，需要日志文件未
损坏且与日志相关的数据文件存在且未损坏。

完全备份：备份数据库中的所有数据，以及可以恢复这些数据的足够日志。

文件或文件组备份：指备份一个或多个文件或文件组中的所有数据，在完整恢复模式下，一整套完整文件备份和涵盖所有
	文件备份的日志备份合起来，等同于一个完整数据备份。
使用文件备份能够只还原损坏文件，而不用还原数据库的其余部份，从而可加快恢复速度。

在完整恢复模式下，恢复一个文件组备份，不但需要恢复文件组备份本身，还需要依次恢复从上一次完整数据库备份后到
恢复的目标时间点为止的所有日志备份。以确保该文件与数据库的其余部份保持一致。所以要恢复的事务日志备份数据
会很多，要辟免这种情况，可以考虑使用差异文件备份。

差异备份：自最近一次完整备份后发生更改的数据，最近一次完整备份称为差异的“基准”

以下都可以作为差异备份的基准
完全数据库备份
部份备份
文件和文件组备份

*/
backup database HK_ERP_HP
to disk = 'd:\HK_ERP_HP.bak'
with compression,copy_only

--备份---------------------------------------------------------------------------------------------
BACKUP 
--1)备份声明:数据库,日志文件,或是文件，或是文件组且是否备份只读文件
DATABASE | LOG  sqllwqhp
FILEGROUP ='指定备份的文件组名称'
FILE ='指定备份的文件逻辑名称'
READ_WRITE_FILEGROUPS --用于部份备份时的参数，表示不备份只读的文件组

TO 
--2)备份到那里：指定一个备份集，或是镜像备份
DISK ='d:\sqllwqhp_20131226_2132.bak'--disk表示一个备份集（备份设备）
   ,DISK='e:\sqllwqhp_20131226_2132_2.bak' --多个备份集，也就是媒体簇
MIRROR TO DISK='f:\sqllwqhp_20131226_2132_2.bak' --镜像备份
WITH format --第一次创建镜像备份集时，需要带上

WITH 
--3)参数定义
--a)备份集和介质集描述:包括名称，备注
DESCRIPTION ='说明备份集的自由格式文本，帮助识别备份设备的内容'
,NAME ='备份集的名称'
,MEDIADESCRIPTION ='介质集的自由格式文本，帮助识别媒体的内容'
,MEDIANAME ='整个备份介质集的名称，最多为128个字符'

--b)定义写入备份集方式
,RETAINDAYS=30 --指定在这个备份集上保留时间，超过这个时间才会被覆盖
,INIT |NOINIT --是覆盖还是追加到当前备份集(表示备份时需要覆盖备份介质，并在备份介质上将该 备份作为第一个文件写入)
,format --表示在每一次使用媒体时对备份媒体进行初始化，并覆盖任何现有的的媒体标头。不能和init同时使用。

--c)日志备份参数
,NO_TRUNCATE /*备份当前日志中活动的部份，而且不截断事务日志中不活动的部份，也就是会一直保留，默认是备份
完日志后，不活动部份日志会被截断，重新使用*/
,NORECOVERY /*备份事务的尾部，然后让数据库处于restoring状态，standby 也备份事务日志尾部，但不会将数据
库处于restoring状态，而把它置为只读standby状态，用于日志传送*/ 

--d)备份设定
,DIFFERENTIAL --差异备份
,compression | NO_COMPRESSION --是否压缩备份(默认是不压缩)
,COPY_ONLY --仅备份，不破坏备份序列
,STATS =25 -- 在备份过程中返回返馈信息到客户端

----===========================================================================================


--查看设置服务器压缩设定
EXEC sp_configure 'backup compression default','1'
RECONFIGURE WITH override
go

SELECT * FROM sys.configurations WHERE name ='backup compression default'

--自定义备份设备,可以在备份的时候只输逻辑名而不用输路径
EXEC sys.sp_addumpdevice @devtype = 'disk', -- varchar(20)
    @logicalname = 'logicName', -- sysname
    @physicalname = N'd:\sqllwqhp_20131226_2132.bak', -- nvarchar(260)
    @cntrltype = 0, -- smallint
    @devstatus = '' -- varchar(40)

--查看
EXEC sp_helpdevice 'logicName'
SELECT * FROM sys.backup_devices

--删除
EXEC sp_dropdevice 'logicName','delfile'

--备份
BACKUP DATABASE sqllwqhp
TO logicname




--部份备份：(针对文件组的备份)类似于完全备份，但是部份备份仅包含指定的文件组中的数据：
--主文件组，所有可读写文件组以及任何指定的只读文件组。

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

EXEC sp_helpfile

--指定文件组名称
BACKUP DATABASE db_test 
	FILEGROUP = 'PRIMARY',
	FILE = 'db_test_R'
TO DISK = 'F:\DB\Backup\db_test2.bak'
WITH format

--日志备份------------------------------------------------------------------------------
/*
日志备份能用于完全备份FULL,和大容量记录的备份模式下，仅备份自上次备份后对数据库执行的所有事务的一系列记录，
一般宜定期备份事务日志，它可能使工作丢失的可能性降到最低，而且还能截断事务日志，不至于让日志文件无限制增长。
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