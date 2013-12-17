

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
order by objtype desc