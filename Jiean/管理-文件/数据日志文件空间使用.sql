

--数据日志文件空间使用
/*

只是粗略的了解数据文件和日志文件的使用空间
*/
--主要针对普通数据库，不能保证实时更新空间使用统计信息，对tempdb数据库里存储的一些系统临时数据对象，无法统计
sp_spaceused @updateusage ='true'

/*
unallocated space：未分配使用空间(?)
reserved:被用过但后来释放的空间
data:不是数据文件，而是表里的数据占用的空间
unused : 没被用过的空间

重建聚集索引，可以释放reserved空间
*/

--sqlServer自带报表


--详细统计空间使用情况

--按区统计
DBCC showfilestats
/*
这个命令直接从系统分配页面上面读取区分配信息，能够快速准确地计算出一个数据库数据文件区的总数和已使用过的区的数目，
而系统分配页上的信息永远是实时更新的，所以这种统计方法比较准确可靠。在服务器负载很高的情况下也能安全执行，
不会增加额外系统负担。所以看数据库数据文件级的使用情况，它是个比较好的选择。

TotalExtents :当前数据库下所有数据文件里有多少个区
UsedExtents :使用过了的区
*/

--按页统计
SELECT 
o.name,
SUM(p.reserved_page_count) AS reserved_page_count,
SUM(p.used_page_count) AS used_page_count,
SUM(CASE WHEN p.index_id<2 THEN p.in_row_data_page_count+p.lob_used_page_count+p.row_overflow_used_page_count
	ELSE p.lob_used_page_count+p.row_overflow_used_page_count END )AS Datpages,
SUM(CASE WHEN p.index_id<2 THEN row_count ELSE 0 end) AS RowCounts 
 FROM sys.dm_db_partition_stats p 
INNER JOIN sys.objects o ON p.object_id = o.object_id
GROUP BY o.name

/*
外键
partition_id  分区 ID。 在数据库中是唯一的。 它的值与 sys.partitions 目录视图中的 partition_id 值相同。 
object_id 该分区的表或索引视图的对象 ID。
index_id 该分区的堆或索引的 ID  0 = 堆 1 = 聚集索引。> 1 = 非聚集索引 

reserved_page_count 为分区保留的总页数。 计算方法为 in_row_reserved_page_count + lob_reserved_page_count + row_overflow_reserved_page_count。 
used_page_count 用于分区的总页数。 计算方法为 in_row_used_page_count + lob_used_page_count + row_overflow_used_page_count。 

http://technet.microsoft.com/zh-cn/library/ms187737.aspx

SQL Server在使用数据页的时候，为了提高速度，会先把一些页面一次预留”reserve”给表格，然后真正有数据插入的时候，
再使用。所以这里有两列，Reserved_page_count和Used_page_count。两列的结果相差一般不会很多。
所以粗略来讲，Reserved_page_count*8K，就是这张表格占用的空间大小。

DataPages是这张表数据本身占有的空间。因此，（Used_page_count – DataPages）就是索引所占有的空间。
索引的个数越多，需要的空间也会越多。

RowCounts，是现在这个表里有多少行数据
*/

--精确地统计出某张表格的空间使用量,了解每个页，区的使用情况，碎片程度
DBCC SHOWCONTIG
SELECT * FROM sys.dm_db_index_physical_stats(
DB_ID(N'HK_ERP_HP'), OBJECT_ID(N'sd_pos_saledetail'), NULL, NULL , 'DETAILED'
)

/*
http://technet.microsoft.com/zh-cn/library/ms188917.aspx

SQL Server从整体性能的角度出发，不可能一直维护这样底层的统计信息。为了完成这个命令，
SQL Server必须要对数据库进行扫描。所以说，这种方式虽然精确，但是在数据库处于工作高峰时，还是需要避免使用。
*/


--日志文件的使用情况 ---------------------------------------------------------------------------
DBCC SQLPERF(LOGSPACE)

--TempDB的空间使用---------------------------
/*
temdb保存的对象
1）用户对象
由用户显式创建，在用户会话中创建，或者是在用户例程(存储过程，触发器和用户定义函数)中创建，这些对象包含 ：
	用户定义的表和索引
	系统表和索引
	全局临时表和索引
	局部临时表和索引
	@table变量
	表值函数中返回的表

2）内部对象
 sqlserver用于处理sqlserver语句而创建的对象，包含：
	用于游标或假脱机操作以及临时大型对象(LOB)存储的工作表。
	用于哈希连接或哈希聚合操作的工作文件
	用于创建或重新生成索引等操作(如果指定了sort_in_tempdb)的中间排序结果，或者某些group by ,order by ，union 查询的中间排序结果。
	
每个内部对象致少使用9页，一个IAM页，8个页的区。

3）版本存储区
版本存储区是数据页的集合，它包含支持使用行版本控制的功能所需的数据行，主要用来支持快照事务隔离级别，以及一些
其它提高数据库并发度的新功能。
*/

--返回所有做过空间申请的会话信息
SELECT * FROM sys.dm_db_file_space_usage

--tempdb空间的总体分配
SELECT * FROM sys.dm_db_session_space_usage t1,sys.dm_exec_sessions t3
WHERE t1.session_id = t3.session_id


--返回正在运行并且做过空间申请的会话正在运行的语句
SELECT * FROM sys.dm_db_session_space_usage t1,
sys.dm_exec_requests t4
CROSS APPLY sys.dm_exec_sql_text(t4.sql_handle) st
WHERE t1.session_id = t4.session_id
AND t1.session_id>50

/*
分析日志使用
1，设置tempdb的自动增长
2，模拟各个单独的查询或工作任务，同时临视tempdb 空间使用
3，模拟执行一些系统维护操作，例如重新生成索引，同时临视tempdb空间
4，使用2,3中tempdb空间使用值 来预测总的工作负荷下，会使用多少空间，并针对计划的并发度调整 此值。比如，如果一个
任务会使用10GB的tempdb空间，而在生产环境里最多可能会有4个这样的任务同时运行，那要至少预留40GB的空间。
5，根据4得到的值，设置tempdb在生产环境下的初始大小，同时也开启自动增长。
*/

/*
多个数据库文件，并把它们放在不同的硬盘上，以达到分散i/0负载的目的，需要对数据文件必须保证同一个文件组里的所有数据
文件都有基本一样大小的空闲空间（不是这这些文件一样大就可以的），如果某个硬盘上的数据文件已经被写满了，sqlserver就
不会再往这个硬盘上写了，如果空闲空间相对比较少，sqlserver写的数目也会相对减少。
*/