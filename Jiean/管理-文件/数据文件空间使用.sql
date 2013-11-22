

--数据文件空间使用
/*

只是粗略的了解数据文件和日志文件的使用空间
*/
--主要针对普通数据库，不能保证实时更新空间使用统计信息，对tempdb数据库里存储的一些系统临时数据对象，无法统计
sp_spaceused @updateusage ='true'

/*
unallocated space：未分配使用空间(
数据库的可用空间，也就是可分配空间，没有了会按设置自动增长，但如果未分配使用空间很大，有可能是数据库设置的太大，
或者数据文件有问题，不能正确统计到。

)
reserved:被用过但后来释放的空间（
	这是被用过而释放出来的空间，比如删除记录，更改表结构，日志截断后所留下来的空间，这部份空间可以重新使用，
如果这部份空间太多，可以重建聚集索引，收缩减少整个数据库的容积。
）
database-size:当前数据库的大小,包括数据文件和日志文件
data:不是数据文件，而是表里的数据占用的空间（不包含索引）
unused : 没被用过的空间（
	为数据库中对象保留的，尚未使用的空间总量
）


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

/*
sys.dm_db_partition_stats :分区信息视图,每个分区对应一行。
显示用于存储和管理数据库中全部分区的 '行内数据'  'LOB 数据'和'行溢出数据'的 空间的有关信息。
 
*/

--按分区明细统计
SELECT 
o.name,
SUM(p.reserved_page_count) AS reserved_page_count,
SUM(p.used_page_count) AS used_page_count,
SUM(CASE WHEN p.index_id<2 THEN p.in_row_data_page_count+p.lob_used_page_count+p.row_overflow_used_page_count
	ELSE p.lob_used_page_count+p.row_overflow_used_page_count END )AS Datpages,
SUM(CASE WHEN p.index_id<2 THEN row_count ELSE 0 end) AS RowCounts 
 FROM sys.dm_db_partition_stats p 
INNER JOIN sys.objects o ON p.object_id = o.object_id
where o.name = 'BC_Sal_OrderMaster'
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

--精确统计

DBCC SHOWCONTIG --是显示指定的表的数据和索引的碎片信息
/*
统计 描述 
扫描页数                 
表或索引的页数。 
 
扫描扩展盘区数           
表或索引中的扩展盘区数。
  
扩展盘区开关数           
遍历索引或表的页时，DBCC 语句从一个扩展盘区移动到其它扩展盘区的次数。 
 
平均扩展盘区上的平均页数 
页链中每个扩展盘区的页数。 
 
扫描密度[最佳值:实际值] 
最佳值是指在一切都连续地链接的情况下，扩展盘区更改的理想数目。实际值是指扩展盘区更改的实际次数。如果一切都连续，则扫描密度数为 100；如果小于 100，则存在碎片。扫描密度为百分比值。
  
逻辑扫描碎片 
对索引的叶级页扫描所返回的无序页的百分比。该数与堆集和文本索引无关。无序页是指在 IAM 中所指示的下一页不同于由叶级页中的下一页指针所指向的页。 
 
扩展盘区扫描碎片 
无序扩展盘区在扫描索引叶级页中所占的百分比。该数与堆集无关。无序扩展盘区是指：含有索引的当前页的扩展盘区不是物理上的含有索引的前一页的扩展盘区后的下一个扩展盘区。 
 
平均每页上的平均可用字节数 
所扫描的页上的平均可用字节数。数字越大，页的填满程度越低。数字越小越好。该数还受行大小影响：行大小越大，数字就越大。
  
平均页密度（完整） 
平均页密度（为百分比）。该值考虑行大小，所以它是页的填满程度的更准确表示。百分比越大越好。 

*/
Create table #showContigResults 
        (ObjectName sysname,
         Objectid bigint,
         IndexName sysname,
         indexid int,
         [level] int,
         pages int , --扫描页数
         [rows] bigint,
         minRecsize int,
         maxRecsize int,
         avgRecSize real ,
         ForwardRecs int,
         Extents int, --扫描区数
         ExtentSwitches int, --区切换次数
         AvgFreeBytes real, --每页的平均可用字节数
         AvgPageDensity real, --平均页密度(满)
         ScanDensity decimal(5,2), --扫描密度 [最佳计数:实际计数]
         BestCount int,
         ActCount int,
         LogicalFrag decimal (5,2), 
         ExtentFragmentation decimal (5,2))  --区扫描碎片
insert into #showContigResults
exec('DBCC SHOWCONTIG (''Test'') with tableresults')
select * from #showContigResults



SELECT * FROM sys.dm_db_index_physical_stats(
DB_ID(N'HK_ERP_HP'), OBJECT_ID(N'sd_pos_saledetail'), NULL, NULL , 'DETAILED'
)

/*
http://technet.microsoft.com/zh-cn/library/ms188917.aspx

SQL Server从整体性能的角度出发，不可能一直维护这样底层的统计信息。为了完成这个命令，
SQL Server必须要对数据库进行扫描。所以说，这种方式虽然精确，但是在数据库处于工作高峰时，还是需要避免使用。
*/

