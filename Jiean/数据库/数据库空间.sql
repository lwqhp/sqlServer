

--数据库空间组织架构


--数据库的文件有那几个
/*
数据库有两类文件：数据文件和日志文件
*/

--我怎么找出数据文件
/*
看文件结尾 .mdf 是主数据文件，必须的.
再找.ndf 他是数据库辅助数据文件。可包含有多个。
*/

--在数据库系统中，我怎么看数据文件的信息呢
/*

*/

--插入的记录怎么存到数据文件中的呢，或者说数据文件是怎么保存记录的
/*
的数据文件中，记录都是按页来保存的，页是数据存储的基本单位，页的大小为8K.页这上，则是按区划分页，
用区来有效管理页，所有的页都存储在区中，1个区包含8个物理上连续的页集合。
*/

页，区的分析

--数据文件比较大，而且似乎跟记录数比有点不正常，我的记录并不多，又删掉了一些，但空间还是那么大,我想看看空间的使用情况
/*
ssms提供了4种简单直接的报表，可以统计出从不同角度分析的数据库空间使用情况。
1，磁盘使用情况
2, 排在前面的表的磁盘使用情况
3，按表的磁盘使用情况
4，按分区的磁盘使用情况
*/

/* 按区查看
因为sqlserver绝大多数时间都是按照区为单位来分配新空间的，对比一个数据文件 区的总数 和已使用过的区的
数目，可以看出有多少区是空置的。
*/
DBCC showFileStats
/*
这个命令可以直接从gam 和sgam这样的系统分配页面上面读取区的分配信息，速度快，较准确可靠，在服务器负
载很高的情况下也能安全执行。

注： GAM(全局分配位图)是用于标识SQL Server空间使用的位图的页。位于数据库的第3个页，也就是页号是2的页。
*/

--想具体知道表格或者索引使用了多少空间
/*
从页级别来分析

决择
*/
/*根据sys.allocation_units和sys.partitions两张管理视图来计算存储空间,不一定能及进反映出数据库的
准确信息，加上 updateusage 参数，又太耗资源。而且一次只能查询一个对象。*/
sp_spaceused 

/*
dm_db_partition_stats
管理视图反映了某张表或索引用了多少页面，多少区，甚至页面上的平均数据量。从这些值可以算出
一张表格占用了多少空间。根据不同的扫描模式，消耗资源不同.
*/
select o.name,SUM(p.reserved_page_count) AS reserved_page_count,
SUM(p.used_page_count) AS used_page_count,
SUM(
	CASE WHEN (p.index_id<2) THEN (p.in_row_data_page_count+p.lob_used_page_count+p.row_overflow_used_page_count)
	ELSE p.lob_used_page_count+p.row_overflow_used_page_count
	END
	) AS Datapages,
SUM(
	CASE WHEN (p.index_id<2) THEN row_count
	ELSE 0
	END
	) AS RowCounts
FROM sys.dm_db_partition_stats p 
INNER JOIN sys.objects o ON p.object_id = o.object_id
GROUP  BY o.name


DBCC SHOWCONTIG 
/*
可以精确到到区/页，是最准备的，但对性能有影响
*/

---------------------

--我想看日志文件，但对它没谱
/*
物理日志文件，按段来分隔，每一段称为虚拟日志单元，这个管理员不能配置和设置虚拟日志单元的
大小和数量，日志文件每自劝增长一次，会至少增加一个虚拟日志单元，所以，如果一个日志文件经历了
多次小的自动增长，里面的虚拟日志单元数目会比正常的日志文件多很多，这种情况会影 响到日志文件管理的
效率，甚至造成数据库启协要花很长时间。
日志文件是一种回绕文件，物理日志文件用虚拟日志单元分段，逻辑日志文件从物理日志文件的始端
开始，新日志被添加到逻辑日志的末端，当逻辑日志的末端到达物理日志文件的末端时，新的日志记录
将回绕到物理日志文件的始端。
*/
DBCC SQLPERF(LOGSPACE)

--数据库的空间占用有一部份是系统数据库的，比如临时表，变量，所以要在系统数据库中看些跟当前库有关的信息

--当前数据库那些信息会存放到tempdb中
/*
1,由用户显式创建的用户对象
	用户定义的表和索引
	系统表和索引
	全局临时表和索引
	局部临时表和索引
	table变量
	表值函数中返回的表
2，用于处理sqlserver语句的内部对象
	用于游标或假脱机操作以及临时大型对象lob存储的工作表
	用于哈希联接或哈希聚合操作的工作文件
	用于创建或重新生成索引等操作(如果指定了sort_in_tempdb)的中间排序结果，或者某些group by ,orderby ,union查询的中间排序结果
每个内部对象至少使用9页：一个IAM页，一个8页的区。
*/

SELECT * FROM sys.dm_db_file_space_usage
/*
通过监视这个视图，就能知道tempdb的空间是被那一块对象使用掉的，
是用户对象 user_ojbect_reserved_page_count
还是系统对象 internal_object_reserved_page_count
还是版本存储区 version_store_reserved_page_count
*/

--tempdb 突然增长了很多，你怎么解释，是正常还是异常

/*测试*/
--连接A
SELECT @@SPID
GO
USE AdventureWorks
GO
SELECT GETDATE()
GO
SELECT * 
INTO #mysalesorderDetail
FROM sales.SalesOrderDetail
--创建一个临时表，这个操作应该 会申请用户对象页面
go
WAITFOR DELAY '0:0:2'
SELECT GETDATE()
go
SELECT TOP 100000 * 
FROM sales.SalesOrderDetail
INNER JOIN sales.salesorderheader ON sales.salesorderheader.SalesOrderID=sales.salesorderheader.salesorderid
--这里做了一个比较大的联接，应该会有系统对象的申请
GO
SELECT GETDATE()
--join 语句做完以后系统对象页面数目应该下降
GO

--跟踪tempdb
USE tempdb
--每隔1秒钟运行一次，直到用户手工终止脚本运行
WHILE 1=1
BEGIN 
	SELECT GETDATE()
	--从文件级看tempdb使用情况
	DBCC showfilestats
	--query 1
	--返回所有做过空间申请的会话信息
	SELECT 'Tempdb' AS DB,GETDATE() AS times,
	SUM(user_object_reserved_page_count)*8 AS user_objects_kb,
	SUM(internal_object_reserved_page_count)*8 as internal_objects_kb,
	SUM(version_store_reserved_page_count) *8 AS version_store_kb,
	SUM(unallocated_extent_page_count)*8 AS freespace_kb
	FROM sys.dm_db_file_space_usage
	WHERE database_id = 2
	--query 2
	--这个管理视图能够反映当时tempdb空间的总体分配
	SELECT t1.session_id,t1.internal_objects_alloc_page_count,t1.user_objects_alloc_page_count,
	 t1.internal_objects_dealloc_page_count,t1.user_objects_dealloc_page_count,
	 t3.*
	FROM sys.dm_db_session_space_usage t1,
	--反映每个会话累计空间申请
	sys.dm_exec_sessions AS t3
	--每个会话的信息
	WHERE t1.session_id=t3.session_id
	AND (t1.internal_objects_alloc_page_count>0
		OR t1.user_objects_alloc_page_count>0
		OR t1.internal_objects_alloc_page_count>0
		OR t1.user_objects_dealloc_page_count>0
	)
	--query3
	--返回正在运行并且做过空间申请的会话正在运行的语句
	select * 
	FROM sys.dm_db_session_space_usage AS t1,
	sys.dm_exec_requests AS t4
	CROSS APPLY sys.dm_exec_sql_text(t4.sql_handle) AS st
	WHERE t1.session_id = t4.session_id
		AND t1.session_id>50
		AND (t1.internal_objects_alloc_page_count>0
		OR t1.user_objects_alloc_page_count>0
		OR t1.internal_objects_alloc_page_count>0
		OR t1.user_objects_alloc_page_count>0)
	WAITFOR DELAY '0:0:1'
END
/*
从结果看出，sqlserver需要空间存放一些内部对象，来完成 inner join 
*/

--不同的存储结构以空间有什么影响
DBCC SHOWCONTIG
/*
可以看出，在同样的字段上，建立聚集索引并没有增加表格的大小，而建立非聚集索引去增加了不小的
空间。
有一种说法，当一个表格经常发生变化时，如果在这张表上建立聚集索引，会容易遇到页拆分，所以建立
聚集索引会影 响性能，基于这种考虑，很多数据库设计者不愿意在sqlserver的表格上建 立聚集索引。
但是一张表不建索引性能又不能接受，所以他们又加了一些非聚集索引，以期得到好的性能。
sql serer这种堆和树的存储方式，决定了上面这种设计是一个即浪费空间，性能也不一定好的设计。
刚才的测试就说明了空间上的浪费，最近sqlerver产品组在sqlserver2005上做了一个比较，对比有聚
集索引和没有聚集索引的表格在sleect ,insert update,delete上的性能，因为select ,update,delete
有记录搜寻的动作，所以很自然的，有聚集索引大大提高了性能，但出人意料的是，在insert这一项上，
两者也没什么差别，并没有出现聚集索引影响insert速度的现象，所以再次强烈建议，在一个大的表格上
一定要建一个聚集索引。
*/

--delete 和truncate对数据空间有什么区别
DBCC SHOWCONTIG('sales.salesorderdetail')
/*
用命令对比操作前后的页面，区的数量
从测试可以看出，delete命令并不能完全释放表格或索引的数据结构以及它们申请的页面，

优缺点
1，所用的事务日志空间较少
delete语句每次删除一行，并在事务日志中为所删除的每行记录一个项，truncate通过释放用于
于储表数据的数据页来删除数据，并且在事务日志中只记录页释放这个动作，而不记录每一行。

2，使用的锁通常较少
当使用行锁执行delete语句时，将锁定表中各行以便删除，truncate如终锁定表和页，页不是锁定行。
3，表中将毫无例外的不留下任何页
执行delete语句后，表仍会包含 空页，例如，必须至少使用一个排他lck_m_x表锁，才能释放堆中的空页。
对于索引，删除操作会留下一些空页。尽管这些页会通后后台清除进程迅速释放。
truncate 删除表中的所有行，但表结构及其列，约束，索引等保持不变
*/

--删除数据后，如何释放空间，减少碎片呢
/*
1,在表格上建立聚集索引
2，如果所有数据都不要了，要使用truncate
3,如果表格本身不要了，用drop
4,重建下索引（聚集索引）
5，倒表的方式生成新的表
*/

----------------
--数据库是比较大了，现在我想收缩下，但好像效果不明显
/*
首先了解数据库收缩的一些机制
shrinkdatatabe 一次运行会同时影响所有的文件（包括数据文件和日志文件），使用者不能指定每个
文件的目标大小，其结果可能不能达到预期的要求，所以建议还是先做好规划，对每个文件确定预期目标，
然后使用dbcc shrinkfile来一个文件一个文件地做比较稳妥。

计划收缩数据文件时，要考虑到以下几点：
1，首先要了解数据文件当前的使用情况
收缩量的大小不可能超过当前文件的空闲空间的大小，如果想要压缩数据库的大小，首先就要确认数据
文件里的确有相应末被使用的空间，如果空间都在使用中，那就要先确认大量占用空间的对象（表格或索引）
然后爱过归档历史数据，先把空间释放出来。
2，主数据文件是不能被清空的，能被完全清空的只有辅助数据文件。
3，如果要把一个文件组整个清空，要删除分配在这个文件组上的对象（表格或索引），或者把它们移到
其它文件组上，dbcc shrinkfile不会帮你做这个工作。

注：dbcc shrinkfile 是区一级的动作，它会把使用过的区前移，把没在使用中的区从移除，但不会把一
个区里面的空页移除，合并区，也不会把页面里的空间移除，合并页面。所以一个数据库中有很多只使用
了一两个页面的区，shrinkfile的效果会不明显。
*/

--通过测试，观察，学会看表占用的区，和页面


use test
go  

--创建一个每一行都会占用一个页面的表格，表格上没有聚集索引，是堆，插入8000条记录
if OBJECT_ID('test') is not null  
drop table test  
go  
create table test  
(  
    a int,  
    b nvarchar(3900)  
)  
go  
declare @i int  
set @i=1  
while @i<=1000  
begin  
    insert into test VALUES( 1,REPLICATE(N'a',3900))  
    insert into test VALUES( 2,REPLICATE(N'b',3900))  
    insert into test VALUES( 3,REPLICATE(N'c',3900))  
    insert into test VALUES( 4,REPLICATE(N'd',3900))  
    insert into test VALUES( 5,REPLICATE(N'e',3900))  
    insert into test VALUES( 6,REPLICATE(N'f',3900))  
    insert into test VALUES( 7,REPLICATE(N'g',3900))  
    insert into test VALUES( 8,REPLICATE(N'h',3900))  
    set @i=@i+1  
end  
--select * from test  
--使用DBCC SHOWCONTIG命令来查看这个表的数据结构
dbcc showcontig('test')  
  
--从上述结果中可以看到这个表的数据的存储申请了8000页  
  
--现在删除每个区里面的7个页面,只保留a=5的这些记录  
delete test where a<>5  
go  
  
--使用系统存储过程sp_spaceused 查看表的空间信息  
  
sp_spaceused test  
go  
/*  
name    rows    reserved    data    index_size  unused  
-------- ----------- -- -------------------------------------------  
test    1000        64008 KB    32992 KB    8 KB    31008 KB  
*/  
  
--使用DBCC SHOWCONTIG命令查看存储情况  
DBCC SHOWCONTIG(test)  

--通过上面的表的数据的对比我们容易发现还有将近一半的页面没有被释放  
  
这时我们来对我们去对文件进行收缩:  
  
DBCC SHRINKFILE(1,40)  
  
/*  
DbId    FileId  CurrentSize MinimumSize UsedPages   EstimatedPages  
------------------------------------------------------------------------------  
9   1   8168    288 1160    1160  
*/  
  
--通过这个结果,我们来计算一下数据文件中正在被使用的大小  
  R
--(8168*8.0)/1024=63.812500M  
--正好是1000个区大小  
  
--这种情况就证明了我们收缩数据库的DBCC SHRINKFILE(1,40)  
--指令并没有起到应有的作用  
  
  
--那么我们如何解决这个问题呢?  

--如果这个标有聚集索引,我们可以通过重建索引把页面从排一次,  
--但这个表没有聚集索引  
  
--接下来我创建聚集索引:  
create clustered index test_a_idx on test(a)  
go  
--使用DBCC SHOWCONTIG(test)命令查看表的存储情况  
DBCC SHOWCONTIG(test)  

  
--通过上述结果可以发现,创建聚集索引之后,原先存放在  
--堆里的数据以B树的方式从新存放。  
--原先的页面被释放出来了，占用的分区也被释放出来了。  
--这个时候再使用DBCC SHRINKFILE就有效果了  
  
DBCC SHRINKFILE(1,40) 
SELECT  5424*8/1024
  
 /* 
以上现象是因为数据存储页面分散在区里，造成了SHRINKFILE效果不佳。  
在一个有聚集索引的表上，这个问题可以通过重建索引来解决。  
  
如果这些去里面放的是text或者image类型的数据，  
SQL Server会用单独的页面来存储这些数据。  
  
  
如果存储这一类页面的区发生了这样的问题，和堆一样  
做索引重建也不会影响到他们。简单的方法就是把这些可能有问题的对象  
都找出来，然后重建他们。可以使用DBCC EXTENTINFO这个命令打开数据  
文件里区的分配信息。然后计算每个对象理论上的区的数目和实际的数目，  
  
如果实际数目远远大于理论数目，那这个对象就是碎片过多，  
可以考虑重建对象  
*/
  
--还是以刚才的数据为例演示如何找出这些需要重建的对象  
drop table test  
go  
  
if OBJECT_ID('test') is not null  
drop table test  
go  
create table test  
(  
    a int,  
    b nvarchar(3900)  
)  
go  
declare @i int  
set @i=1  
while @i<=1000  
begin  
    insert into test VALUES( 1,REPLICATE(N'a',3900))  
    insert into test VALUES( 2,REPLICATE(N'b',3900))  
    insert into test VALUES( 3,REPLICATE(N'c',3900))  
    insert into test VALUES( 4,REPLICATE(N'd',3900))  
    insert into test VALUES( 5,REPLICATE(N'e',3900))  
    insert into test VALUES( 6,REPLICATE(N'f',3900))  
    insert into test VALUES( 7,REPLICATE(N'g',3900))  
    insert into test VALUES( 8,REPLICATE(N'h',3900))  
    set @i=@i+1  
end  
go  
delete from test where a<>5  
go  
  
--创建表extentinfo用来存放分区信息  
  
if OBJECT_ID('extentinfo') is not null  
drop table extentinfo  
go  
create table extentinfo  
(  
    file_id smallint,  
    page_id int,  
    pg_alloc int,  
    ext_size int,  
    obj_id int,  
    index_id int,  
    partition_number int,  
    partition_id bigint,  
    iam_chain_type varchar(50),  
    pfs_bytes varbinary(10)  
)  
go  
create proc inport_extentinfo  
as dbcc extentinfo('test')  
go  
insert extentinfo  
exec inport_extentinfo  
go  
  
select  
    FILE_ID,  
    obj_id,  
    index_id,  
    partition_id,  
    ext_size,  
    'actual_extent_count'=COUNT(*),  
    'actual_page_count'=SUM(pg_alloc),  
    'possible_extent_count'=CEILING(SUM(pg_alloc)*1.0/ext_size),  
    'possible_extents/actual_extents'=(CEILING(SUM(pg_alloc)*1.00/ext_size)*100.00)/COUNT(*)  
from  
    extentinfo  
group by  
    FILE_ID,  
    obj_id,  
    index_id,  
    partition_id,  
    ext_size  
having COUNT(*)-CEILING(SUM(pg_alloc)*1.0/ext_size)>0  
order by  
    partition_id,  
    obj_id,  
    index_id,  
    FILE_ID  
/*  
FILE_ID obj_id  index_id    partition_id    ext_size    actual_extent_count actual_page_count   possible_extent_count   possible_extents/actual_extents  
------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
1   2137058649  0   72057594038976512   8   998 4115    515 51.603206412  
*/  
select object_name(533576939) as TName  
/*  
60
245575913
293576084
469576711
533576939
*/  
--此时我们可以找到这个存在未被释空间放的表，  
--这时我们就需要对这些对象进行重建处理


--日志文件为什么会不停的增长
/*
首先了解下日志的工作流程
日志用于记录所有事务以及每个事务对数据库所做的修改，为了提高数据库的整 体性能，sqlserver检索
数据时，将数据页读入缓冲区高速缓存。数据修改不是直接在磁盘上进行，而是修改高速缓存中的页副本。
直到数据库中出现<检查点>,或者必须将修改写入磁盘才能使用缓冲区来容纳新页时，才将修改写入磁盘。
将修改后的数据页从高速缓冲存储器写入磁盘的操作称为刷新页，在高速缓存中修改但尚未写入磁盘的
页称为“脏页”。

当对缓冲区中的页进行修改时，会在日志高速缓存中生成一条日志记录。sqlserfer 具有防止在写入关联
的日志记录前刷新脏页的逻辑，会确保日志记录在提交事务时，或者在此之前，一定已经被写入磁盘。

也就是说，sqlserver对数据页的插入，修改和删除，都是只在内存中完成后，就提交事务，这些修改
并不立该同步到硬 盘的数据页上，而sqlserver又必须保证事务的一致性，哪怕发生了一sqlserver
异常终止（例如sqlserver服务崩溃，机器掉电）,内存中的修改没有来得及写入硬盘，下次sqlserver重
启的时候，要能够恢复到一个事务一致的时间点，已经提交的修改要在硬盘中的页面重新宛成，为了做
到这一点，sqlserver必须依赖于事务日志。

从这个流程，可以看出，什么样的日志数据会一直保留着

1,所有没有经过“检查点”的日志记录
定期的检查点(checkpoint)保证所有的“脏页”都被写入硬盘，未做检查点的修改，可能是仅是内存中修改
，数据文件还没有同步，sqlserver要在硬盘上的日志文件里有一份记录，以便在异常重启后重新修改。

2,所有没有提交的事务所产生的日志及其后续的日志记录
为没有提交的事务回滚作准备，在sqlserver里面，所有的日志记录都有严格顺序，中间不可以有任何跳路。
所以如果某个数据库有没有提交的事务，sqlserver会标记所有从这个事务开始的日志记录（不管和这个）
事务有没有关系）为活动事务日习，直到事务被提交或回滚。

3,要做备份的日志记录
如果数据库设的恢复模式不是简单模式，那sqlserver就假设用户是要去备份日志记录的，所有未被 备份
的记录，slqserver都会为用户保留，哪怕这些记录对数据库本身已经没有其他用途了。

4,有其他需要读取日志的数据库功能
*/

--观察日志
DBCC LOG (6,3)
--db_id:目标数据库编号，可以用sp_helpdb得到。、
--<format_id>:命令翻释和解释日志记录的方式 3比较详细

USE Test
go
CREATE TABLE a(a int)
go
CHECKPOINT
go
BACKUP LOG test WITH truncate_only
go 
DBCC LOG(6,3)
--sp_helpdb

--找到日志的最后一条记录
--通过插入一条记录，并进行观察对比
--从这些记录可以看出，sqlserv并没有记录语句本身，它记录的是两条被修改的数据原来的值和现在的值。

/*
日志特点
1,日志记录的是数据的变化化，而不是记录用户发过来的操作。
2，每条记录它唯一的编号lsn,并且记录了它属于的事务号。
3，日志记录的行数和实际修改的数据量有关，sqlserver会为每一条记录的修改保存日志记录。
如果单个语句修改的行数非常多，那它所带来的日志行数也就会非常多。所以日志增长的速度不仅和
事务有关，还和事务所带来的数据的修改量有关。
4，日志记录了事务发生的时间，但是不保证记录下了发起这个事务的用户名，更不记录发起者的程序
名称。
5，sqlserver能够从日志记录里面读到数据修改前的值和修改后的值，但是对管理者来讲，直接从日志
记录里面很难了解其修改过程的

总结下那些原因会造成日志文件越来越大
1,数据库恢复模式不是简单模式，但是没有安排日志备份
对于非简单模式的数据库，只有做完日志备份后记录才会被截断，做完整备份和差异备份不会起这个作用。

2，数据库上有一个很长时间都没有提交的事务
SQLServer不会干预前端程序的连接遗留事务在SQLServer中的行为。只要不退出，事务会一直存在，
直到前端主动提交或者回滚。此时做日志备份也没用了。

3,数据库上有一个很大的事务在运行
如建立、重建索引。或者insert/delete大量数据。或者是服务器端游标没有把数据及时取走。

 4,数据库复制或镜像出了异常
 要避免上述现象，来防止日志不断增长。对于不会做日志备份的数据库，设为简单模式即可。
 如果是完整模式，一定要定期做日志备份。如果镜像或复制除了问题，要及时处理，如果没有处理，
 那么要暂时拆除复制或镜像。程序设计时，也要避免事务时间过长、过多。
*/

--处理方法
/*
1，检查日志现在使用情况和数据库状态
检查日志使用百分比、恢复模式和日志重用等待状态。从2005以后，sys.databases加入了
log_reuse_wait(log_reuse_wait_desc)来反映不能阶段日志的原因
*/
    DBCC SQLPERF(LOGSPACE)  
    GO  
    SELECT name,recovery_model_desc,log_reuse_wait,log_reuse_wait_desc  
    FROM sys.databases  
    GO  
 /*
 如果Log Space Used(%)很高，就要马上定位为什么不能被清除。
 如果状态为：LOG_BACKUP，就意味着SQLServer等待着日志备份。要检查是否需要做日志备份,如果并
 不期望做日志备份，可以直接把恢复模式改成简单，这样sqlserver会在下一个检查点的时候做日志
 
记录截断的工作，等以后要安排日志备份任务的时候，再把恢复模式改回来。

2，检查最久的活动事务
如果大部分日志都在使用中且重用状态为：ACTIVE_TRANSACTION，那么要看看最久的事务是谁申请的
 */   
     DBCC OPENTRAN  --返回最久未提交的事务
    GO  
    SELECT  *  
    FROM    sys.dm_exec_sessions AS t2 ,  
            sys.dm_exec_connections AS t1  
            CROSS APPLY sys.dm_exec_sql_text(t1.most_recent_sql_handle) AS st  
    WHERE   t1.session_id = t2.session_id  
            AND t1.session_id > 50  