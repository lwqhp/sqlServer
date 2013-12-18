

--内存历史使用情况


---内存相关动态视图DMV-------------------------------

/*
sqlServer2005以后，sqlserver使用Memory Clerk的方式统一管理sqlServer内存的分配和回收。所有sqlserver 代码要申请或释放内存，都需
要通过它们的Clerk.通过这种机制，sqlserver 可以知道每个clerk 使用了多少内存，从而也能够知道自己总共用了多少内存。这些信息动态的
保存在内存动态管理视图里.

开始
sys.dm_os_memory_clerks:返回sqlServer实例中当前处于活动状态的全部内存clerk的集合,也就是说，从这个视图里，可以看到内存是怎么被
sqlServer使用掉的，需要说明的是，运行在sql进程里的第三方代码所申内存是不能被这个视图跟踪的，也就是说，从这个视图可以看到
所有的buffer pool的使用，以及multi-page里被sqlserver代码使用掉的代码，multi-page里的另一部份内存（第三方代码）将不会被包含。


*/
select type,
sum(virtual_memory_reserved_kb) as vm_reserved, --内存clerk Reserve 的虚拟内存量
sum(virtual_memory_committed_kb) as vm_committed,--相对于reserve内存，memory clerk commit 的虚拟内存量
sum(awe_allocated_kb) as awe_allocated,--内存clerk使用地址窗口化扩展插件(awe)分配的内存量
sum(shared_memory_reserved_kb) as sm_reserved,--内存clerk保留的共享内存量。保留以供共享内存和文件映射使用的内存量
sum(shared_memory_committed_kb) as sm_committed,--内存clerk提交的共享内存量，这两个字段可以追踪shardmemory的大小
--sum(multi_pages_kb) as mu_page_allocator,--通过stolen 分配的单页存量,也就是buffer pool 里stolen memory的大小
--SUM(single_pages_kb) AS sinlgepage_all,--分配的多页内存量，此内存在缓冲池外分配，也就是我们传说的sqlserver自己的代码使用的memtoleave的大小。
sum(pages_kb) AS sinlgepage_all,
[Reserved/COMMIT]=sum(virtual_memory_reserved_kb)/NULLIF(sum(virtual_memory_committed_kb),0)
--[Stolen]=SUM(single_pages_kb)+sum(multi_pages_kb),
--[Buffer Pool(single page)]=sum(virtual_memory_committed_kb) +SUM(single_pages_kb),
--[Memtoleave(Multi-page)]=sum(multi_pages_kb)
from sys.dm_os_memory_clerks 
group by type
ORDER BY type



/*
内存中的数据页面由哪些表格组成，各占多少？
sys.dm_os_buffer_descriptors : 记录了sqlserver 缓冲池中当前所有数据页的信息，可以使用该视图的输出，根据数据库，对象或类型来确定缓冲
汇内数据库页的分布。

这个视图可以回答
1,一个应用经常要访问的数据到底有哪些表，有多大
2，如果以间隔很短的时间运行上面的脚本，前后返回的结果有很大差异，说明sqlServer刚刚为新的数据作了paging,sql的缓冲区有压力。而在后面那次
运行出现的新数据，就是刚刚page in进来的数据。
3,在一条语句第一次执行前后各运行一遍上面的脚本，就能够知道这句话要读入多少数据到内存里

*/
select b.database_id,db=db_name(b.database_id),p.object_id,p.index_id,buffer_count=count(*) 
from master.sys.allocation_units a, master.sys.dm_os_buffer_descriptors b,master.sys.partitions p
	where a.allocation_unit_id = b.allocation_unit_id
	and a.container_id = p.hobt_id
	and b.database_id = db_id('master')
	group by b.database_id,p.object_id,p.index_id
	order by b.database_id,buffer_count desc

--显示当前内存里缓存的所有页面的统计信息
declare @name nvarchar(100)
declare @cmd nvarchar(1000)
declare dbnames cursor for
select name from master.dbo.sysdatabases

open dbnames
fetch next from dbnames into @name
while @@FETCH_STATUS =0
begin 
	set @cmd = 'select b.database_id,db=db_name(b.database_id),p.object_id,p.index_id,buffer_count=count(*) from '+
	@name +'.sys.allocation_units a, '
	+@name+'.sys.dm_os_buffer_descriptors b,'+@name+'.sys.partitions p
	where a.allocation_unit_id = b.allocation_unit_id
	and a.container_id = p.hobt_id
	and b.database_id = db_id('''+@name+''')
	group by b.database_id,p.object_id,p.index_id
	order by b.database_id,buffer_count desc'
	print @cmd
	exec(@cmd)
fetch next from dbnames into @name
end
close dbnames
deallocate dbnames

-----3这句话要读入多少数据到内存里

dbcc dropcleanbuffers

declare @name nvarchar(100)
declare @cmd nvarchar(1000)
declare dbnames cursor for
select name from master.dbo.sysdatabases

open dbnames
fetch next from dbnames into @name
while @@FETCH_STATUS =0
begin 
	set @cmd = 'select b.database_id,db=db_name(b.database_id),p.object_id,p.index_id,buffer_count=count(*) from '+
	@name +'.sys.allocation_units a, '
	+@name+'.sys.dm_os_buffer_descriptors b,'+@name+'.sys.partitions p
	where a.allocation_unit_id = b.allocation_unit_id
	and a.container_id = p.hobt_id
	and b.database_id = db_id('''+@name+''')
	group by b.database_id,p.object_id,p.index_id
	order by b.database_id,buffer_count desc'
	print @cmd
	exec(@cmd)
fetch next from dbnames into @name
end
close dbnames
deallocate dbnames

11	AdventureWorks2012	60	1	30
11	AdventureWorks2012	69	3	2
11	AdventureWorks2012	3	1	1
11	AdventureWorks2012	93	1	1

11	AdventureWorks2012	373576369	1	345
11	AdventureWorks2012	60	1	31
11	AdventureWorks2012	1589580701	1	7
11	AdventureWorks2012	7	2	5
11	AdventureWorks2012	245575913	0	5
11	AdventureWorks2012	74	2	4
11	AdventureWorks2012	55	2	3
11	AdventureWorks2012	5	1	3

select * from person.Address


---sys.dm_exec_cached_plans :了解执行计划都缓存了些什么，哪些些比较占内存
select objtype,sum(size_in_bytes) as sum_size_in_bytes,
count(bucketid) as cache_counts
from sys.dm_exec_cached_plans
group by objtype

--查看具体存储了那些对象
select usecounts,refcounts,size_in_bytes,cacheobjtype,objtype,text
from sys.dm_exec_cached_plans cp
cross apply sys.dm_exec_sql_text(plan_handle)
order by objtype DESC

/*
找出读取数据页面最多的语句出来

1,使用DMV分析sqlserver启动以个来做read最多的语句
sys.dm_exec_query_stats :返回缓存查询计划的聚合性能统计信息。
缓存计划中的每个查询语句在该视图中对一行。sqlserver会统计使用这个执行计划的语句从上次sqlserver启动以来的信息

*/
--按照物理读的页面数排序
SELECT TOP 50 
qs.total_physical_reads,qs.execution_count,
qs.total_physical_reads/qs.execution_count as [avg IO],
substring(qt.text,qs.statement_start_offset/2,(
case when qs.statement_end_offset = -1 then len(convert(nvarchar(max),qt.text))*2
else qs.statement_end_offset end -qs.statement_start_offset)/2) as query_text,
qt.dbid,dbname=DB_NAME(qt.dbid),
qt.objectid,
qs.sql_handle,
qs.plan_handle
 FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
order by qs.total_physical_reads DESC

--按照逻辑读的页面数排序
SELECT TOP 50 
qs.total_logical_reads,qs.execution_count,
qs.total_logical_reads/qs.execution_count as [avg IO],
substring(qt.text,qs.statement_start_offset/2,(
case when qs.statement_end_offset = -1 then len(convert(nvarchar(max),qt.text))*2
else qs.statement_end_offset end -qs.statement_start_offset)/2) as query_text,
qt.dbid,dbname=DB_NAME(qt.dbid),
qt.objectid,
qs.sql_handle,
qs.plan_handle
 FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
order by qs.total_logical_reads DESC

/*
DMV有两个缺点：
a，视图里每一个语句记录的生存期与执行计划本身相关联，如果sqlserver有内存压力，把一部份执行计划从缓存中删除时，这
些记录也会从该视图中删除，所以查询得到的结果不能保证其可靠性。

b，视图里的是历史信息，从sqlserver启动就开始收集了，但是很多时候问题是在每天某个特定时间段里发生的。


2,使用sql Trace文件来分析某一段时间内做read最多的语句
*/
SELECT * INTO SAMPLE
FROM fn_trace_gettable('c:\sample\a.trc',default)
WHERE eventclass IN(10,12)
--10,RPC:Completed 在完成了远程过程调用(RPC)时发生，一般是一些存储过程调用
--12，sql:batchcompleted 在完成了transact-sql批处理时发生。

--找到是哪台客户端服务器上的那个应用发过来的语句从整体上廛在烽据库上引起的reads最多
SELECT databaseid,hostname,applicationname,SUM(reads) FROM SAMPLE 
GROUP BY databaseid,hostname,applicationname
ORDER BY SUM(reads) DESC 

--按照reads从大到小排序最大的的语句
SELECT TOP 1000 
textdata,databaseid,hostname,applicationname,loginname,spid
 FROM SAMPLE
ORDER BY reads DESC 


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