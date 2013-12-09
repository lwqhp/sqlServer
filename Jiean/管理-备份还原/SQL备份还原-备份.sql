

--备份
/*
简单恢复模式:不能做日志备份，只能将数据库恢复到最后一次备份的结尾，如果发生灾难，数据库最后一次备份之后做的
	数据修改将全部丢失。为了降低风险，可以引入差异备份
特点：不管是数据库完整备份还是差异备份，都不可能以比较频繁的频率进行，一般只能在晚间进行，如果数据库比较大，
	或者不允许比较长时间的数据技失，这样的备份策略是不能满足要求的。
	
完整恢复模式：可以使用日志备份，允许将数据库还原到日志备份内包含的任何时点
?尾日志备份：是不是用于出现故障时的尾部日志备份，会不会下次的日志备份是新的起点


文件或文件组备份：指备份一个或多个文件或文件组中的所有数据，在完整恢复模式下，一整套完整文件备份和涵盖所有
	文件备份的日志备份合起来，等同于一个完整数据备份。
使用文件备份能够只还原损坏文件，而不用还原数据库的其余部份，从而可加快恢复速度。

在完整恢复模式下，恢复一个文件组备份，不但需要恢复文件组备份本身，还需要依次恢复从上一次完整数据库备份后到
恢复的目标时间点为止的所有日志备份。以确保该文件与数据库的其余部份保持一致。所以要恢复的事务日志备份数据
会很多，要辟免这种情况，可以考虑使用差异文件备份。


*/

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