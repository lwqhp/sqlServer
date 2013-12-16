

--SqlServer I/O

/*
sqlServer与硬盘交互的场合----------------------------
1,对于内存中没有缓存的数据，第一次访问时需要将数据所在的页面从数据文件中读取到内存里

2，在任何insert update delete 提交之前，sqlserver需要保证日志记录能够写入到日志文件里。

3，当sqlserver做checkpoint的时候，需要将内存缓冲区中忆经发生过修改的数据页面同步到硬盘中的数据文件里

4,当sqlserver缓存区buffer pool空间不足时，会触发lazy writer，主动将内存里的一些很久没有使用过的数据页面和执行
计划清空。如果这些页面上发生的修改还未由检查点checkpoint写回硬盘，lazy writer将会把它写回。

5，一些特殊的操作，比如dbcc checkdb,reindex,update statistics 数据库备份等，会带来比较大的硬盘读写。

对IO有影响的一些sqlserver设置----------------------------
1，Sqlserver 的recovery interval(sp_configure) 设置sqlserver多长时间进行一次checkpoint .

2,数据日志文件的自动增长和自动收缩。

3，数据文件里页面碎片程序

4，表格上的索引结构

5，数据压缩

6，数据文件和日志文件放在同一块磁盘上

7，一个数据文件组是否有多个文件，并且放在不同的物理磁盘上。

从计数器观察sqlServer io操作----------------------------

Buffer Manager :能够反映和buffer pool 有关的i/o操作

1，page reads/sec page writes/sec:反映sqlserver每秒钟读写了多少页面。

2，lazy writes/sec :反映lazywrite为了清空buffer pool 每秒做了多少页面写入动作。

3，checkpoint writes/sec:每秒钟从buffer pool里写入到磁盘上的dirty page数目。

4，readahead pages/sec : 每秒钟sqlserver做的预读数目

access methods : 辅助sqlserver完成指令的工作也会带来i/o----------------------------

1,freespace scan/sec :在堆结构里找能够使用的空间，如果这个计数器很高，说明sqlserver在堆的管理上花费了很多资源。
应该考虑多建一些聚集索引。

2，page splits/sec : 当表格上有许多插入动作时，一些页面会被放满，为了维护索引上的顺序，sqlserver需要把一页劈成两
页，这个动就叫page split,如果这个值比较高，而你又觉得它的确对性能有影响的话，可以考虑定期重建索引。

3，page allocations/sec : 当sqlserver需要创建对象，例如表格，索引时，分配给新对象的页面数量。

4，workfiles/sec : 当sqlserver为了完成某些操作而在内存中建立一个hash结构时该计数器就加一，如果某些hash结构比较庞大，
sqlserver可能会将一部分数据写到硬盘里，可以通过这个值来了解数据库的索引是不是有优化的必要。

5，worktables/sec : 每秒创建的工作表数。例如工作表可用于存储查询假脱机(query spool),lob变量，xml变量，表变量和游标的临时结果。

6，Full scans/sec : 每秒sqlserver做的全表扫描数目。

7，index searches /sec : 每秒检索索引的次数，也就是利用索引完成指令的数目。

databases ：一些和日志写入有关系的计数器----------------------------

1，log flushes/sec : sqlserer每秒在这个数据库上做的日志写的次数。

2，log Bytes Flushed/sec : sqlserver每秒在这个数据库上做的日志写的量

3,log Flush wait time : 写入日志的动作曾经因为磁盘来不及响应而遇到的等待时间。这种等待会导致前端的事务不能提交，
所以会严重影响sqlserver的性能，正常的sqlserver这个值应该在绝大多数时间里都是0。

4,log flush waits/sec : 在每秒提交的事务里，有多少个事务曾经等待过日志写入完成。


*/

---从视图观察sqlserver io
SELECT 
wait_type,
waiting_tasks_count,
wait_time_ms
FROM sys.dm_os_wait_stats
/*
如果经常有连接处于等待磁盘io，一般来讲，服务器的io还是比较忙的，而这种繁忙已经影响到了语句的响应速度。
当sqlserver要去读写一个页面的时候，它首先会在buffer pool里寻找，如果在buffer pool里找到了，那么读、写操作会
继续进行，没有任何等待。如果没有找到，那么sqlserver就会设置连接的等待状态为
Pageiolatch_ex（写），PageIolatch_sh(读)，然后发起一个异步io操作，将页面读入buffer pool中，在io没做完之前，连
接都会保持这个状态，io消耗的时间越长，等待的时间也会越长。

Writelog 日志文件的等待状态，当sqlserver要写日志文件而磁盘来不及完成时，sqlserver会不得不进入等待状态，直到日志
记录被写入，才会提交当前的事务。如果sqlserver经常要等writelog,通常说明磁盘上的瓶颈还是比较严重的。
*/

--了解是那个数据库，那个文件在做io
SELECT 
db.name AS database_name,f.fileid AS FILE_ID,
f.filename AS FILE_NAME,
i.num_of_reads,i.num_of_bytes_read,i.io_stall_read_ms,
i.num_of_writes,i.num_of_bytes_written,i.io_stall_write_ms,
i.io_stall,i.size_on_disk_bytes
 FROM sys.databases db 
INNER JOIN sys.sysaltfiles f ON db.database_id = f.dbid
INNER JOIN sys.dm_io_virtual_file_stats(NULL,null) i ON i.database_id = f.dbid AND i.file_id = f.fileid

--检查当前sqlserver中每个处理挂起状态的io请求
SELECT 
database_id,file_id,io_stall,io_pending_ms_ticks,scheduler_address
FROM sys.dm_io_virtual_file_stats(NULL,NULL) t1, sys.dm_io_pending_io_requests AS t2
WHERE t1.file_handle = t2.io_handle