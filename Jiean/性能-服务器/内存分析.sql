

--Sql Server内存分析

/*
一，SqlServer 提供的内存调节接口

1,Min Server Memory(MB) sp_configure配置
定义sqlserver 的最小内存值，这是一个逻辑概念产，控制sqlserver total server memory的大小，至于数据是放在物理内存
还是缓冲文件时在，是由window决定的，所以这个值不能保证sqlserver使用的最小物理内存数。

在sqlserver的地址空间增长到这个值以后，就不会再小于这个值。并不是sqlserver启动分配的最小内存值。

2，Max Server Memory(MB) sp_configure 配置
定义sqlserver 的最大内存值，同样，这也是一个逻辑概念，控制sqlserver total server memory的大小，至于数据是放在物理内存
还是缓冲文件时在，是由window决定的。

这个设定只能控制一部份sqlserver的内存使用量。

3，Set working Set Size (sp_configure 配置)
sqlServer的执行代码通过调用一个windows参数，试图将sqlserver在物理内存中使用的内存数固定下来。但是现在的windows版本
已经不再尊重这个请求，且有副作用。

4，AWE enabled (sp_configure 配置)
让sqlserver开启用AWE方法申请内存，以突破32位windows的2GB用户寻址空间。但在slqserver2012版本中，32位的sqlserver已
取消这个功能。

5，Lock pages in memory(企业版会自动启动)
这个开关倒是能在一定程序上确保sqlserver的物理内存数，但是也不十分可靠。

二，内存管理模式
sqlserver 根据不同功能区分出不同的模块，针对不同的内存模块采用不同的处理方式。

a)Database Cache:存放数据页的缓存区，这是一块先Reserve 再Commit 的存储区，而在databaseCahce中，也会作些细分：
比如小于8Kb的数据，统计分配一个8KB的页面，集中放在Buffer Pool块，而对于大于8KB的数据，则存放在multi-page块中，

当用户修改了某个页面上的数据时，sqlserver会在内存中将这个页面修改，但是不会立刻将这个页面写回硬盘，而是等到后
面的checkpoint或lazy write的时候集中处理。

b)Consumer区，用于完成sqlserver其它功能组件的任务，比如:
	connection连接缓冲区，general元数据处理区，Query Plan:语句和存储过程的执行计划区。

c)线程区：sqlserver会为进程内的每个线程分配0.5MB的内存，以存放线程的数据结构和相关信息。

d)另还有一部份是第三代码申请的内存，这些内存sqlserv是管不到的，但是作为一个进程，windows能够知道sqlserver申请的
所有内存，所以也能计算这一部份的内存使用。


>>>>>>>>>>>>>-----------------------------------------------------------------------------------------------

windows 提供的SQL性能计数器

以实例名开头:Memory manager:监视服务器内存总体情况的计数器
	1,Total Server Memory : 从缓冲池提交的内存，这不是sqlserver使用的总内存，而是buffer pool的大小
	2，target Server Memory:服务器能够使用的内存总量。
	
两者的观察：当total 小于target,说明sqlserver还没有用足系统能够给sqlserver的所有内存。sqlserverw会不断地缓存新的
数据页面和执行计划，而不会对这两部份缓存作清理。这样sqlserver的内存使用量会悬渐增加。
当target因为系统内存压力而变小时，它可能会小于 total。只要这样的事情发生，sqlserver会很努力地清理缓存，降低内存
使用量，直到total 和target一样在为止.

	反映内存的分布情况
	1，Optimizer memory : 服务器正在用于查询优化的动态内存总数。
	2，sql Cache Memory 服务器正在用于动态sqlserver高速缓存的动态内存总数
	3,lock Memory:服务器用于锁的动态内存总量。
	4，connection memory：服务器正在用来维护连接的动态内存总量。
	5，Granted workspace memory : 当前给预执行哈希，排序，大容量复制和索引创建操作等进程的内存总量
	6，memory grants pending : 等待工作空间内存授权的进程总数。

观察：	如果memory grants pending这个值不等于0，就说明当前有一个用户的内存申请由于内存压力而被延迟，
一般来讲，这就意味着有比较严重的内存瓶颈，通过内存总量的分布，了解sqlserver内存那部份操作占的比较多。、
？记录一些指标。

-----------------
以实例名开头:Buffer manager:提供了计数器，用于监视sqlserver如何使用内存存储数据页，内部数据结构和过程缓存。
	1，Buffer Cache Hit Ratio:在缓冲区高速缓存中找到而不需要从磁盘中读取的页的百分比。
观察：该比率是缓存命中总次数与过去几千闪页面访问的缓存查找总次数之比，基本在99%%从上，如果小于95%,通常就有了
内存不足的问题，可以通过增加sqlserver的可用内存量来提高缓冲区高速缓存命中率。
	
	2，Checkpoint pages/sec:由要求刷新所有脏页的检查点或其他操作每秒刷新到磁盘的页数。
观察：如果用户的操作主要是读，就不会有很多数据改动的脏页，checkpoint的值就比较小，相反，如果用户做了很多insert/
update/delete,那么内存中修改过的数据脏页就会比较多，每次checkpoint的量也会比较大，
这个值在分析disk io问题的时候反而用得比较多。

	3，Database pages : 缓冲池中数据库内容的页数。也就是所谓的database cache的大小。
	
	4，Free Pages : 所有空闲可用的总页数。(2012取消)
观察：当这个值降低时，就说明sqlserver正在分配内存给一些用户，当这个值下降到比较低的值时，slqserver就会开始做lazywrites,
把一些内存腾出来。所以一般这个值不会为0.但是如果它反复降低，就说明sqlserver存在内存瓶颈。一个没有内存瓶颈的sqlserver
的FREE Pages会维持在一个稳定的值。

	5，lazy writes/sec:每秒被缓冲区管理器的惰性编写器写入的缓冲区数。
观察：当sqlserver感到内存压力的时候，就会将最久没有被重用到的数据页和执行计划清理出内存，使它们可再用于用户进程。
如果sqlserver内存压力不大，lazy writer就不会被经常触发，如果被经常触发，那么应该是有内存的瓶颈。
一个正常的sqlServer 会偶尔有一些lazy writes,但是在内存吃紧的时候，会连续发生lazy writes.

	6，Page Life expectancy : 页若不被引用，将在缓冲池中停留的秒数。
观察： 如果sqlserver没有新的内存需求，或者有空余的空间来完成新的内存需求，那么lazy writer就不会被触发，页面会一直
放在缓冲池里，那么pagelife expectancy就会维持在一个比较高的水平，如果sqlserver出现了内存压力，lazy writer就会被触发
page life expectancy也会突然下降，所以，如果一个sqlserver 的page life expectancy总是高高低低，不能稳定在水平上，那么
这个sqlserver应该是有内存压力的。
对于一个正常的SqlServer,难免会有用户访问没有缓存在内存里的数据，所以page life expectancy 时不时降下来也是难免的。
但是在内存始终不足的情况下，而面会被反复地换进换出，page life expectancy会始终升不上去。

	7，page reads/sec:每秒发出的物理数据加页读取数。此统计信息显示的是所有数据库间的物理页读取总数。
观察：如果数据全部缓存在内存里，不需要再做任何page read操作，而当sqlserv需要读这些页面旱，必须要为它们腾出内存空间来，
所在当pagereads/sec比较高时，一般page life expectancy会下降，lazy writes会上升，这几个计数器是联动的。
sqlServer 从数据文件读取的数据量，可以被其跟踪下来，正常的sqlserver,这个计数器的值应该始终接近于0,偶尔有值，也应该
很快降回0.一直不为0的状态，是会严重影响性能的。

由于物理io开销大，page reads 动作一定会影响sqlserver的性能，可以通过使用更大的数据缓存，智能索引，更有效的查询或
更改数据库设计等方法，将page reads降低。

	8，page writes/sec:每秒执行的物理数据库页写入数。
	
	9，Stolen pages :(2012取消) 用于非database pages(包括执行计划缓存)的页数，这里就是stole memory在buffer pool里的大小
相对于数据页面，sqlServer 会比较优先的清除内存里地执行计划。所以当Buffer Pool发生内存压力的时候，也会看到Stolen pages
降低。反过来，如果Stolen pages 的数目没什么变化，一般来讲，就意味着sqlServer 还有足够的内存存放database  pages(但是请注
意，并不一定意味着buffer pool里的stolen 内存和multi-page 内存没有问题)
	
	10,target pages:缓冲池中理想的页数。乘以8kb,就应该是target server memory的值。
	
	11，total pages:（2012取消）缓冲池中的页数(包括数据库页，可用页和stolen页) 乘以8kb,就应该是total server memory 的值。


---内存相关动态视图DMV-------------------------------
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
sum(multi_pages_kb) as mu_page_allocator,--通过stolen 分配的单页存量,也就是buffer pool 里stolen memory的大小
SUM(single_pages_kb) AS sinlgepage_all,--分配的多页内存量，此内存在缓冲池外分配，也就是我们传说的sqlserver自己的代码使用的memtoleave的大小。
[Reserved/COMMIT]=sum(virtual_memory_reserved_kb)/NULLIF(sum(virtual_memory_committed_kb),0),
[Stolen]=SUM(single_pages_kb)+sum(multi_pages_kb),
[Buffer Pool(single page)]=sum(virtual_memory_committed_kb) +SUM(single_pages_kb),
[Memtoleave(Multi-page)]=sum(multi_pages_kb)
from sys.dm_os_memory_clerks 
group by type
ORDER BY type



/*
内存中的数据页面由哪些表格组成，各占多少？
sys.dm_os_buffer_descriptors : 记录了sqlserver 缓冲泄中当前所有数据页的信息，可以使用该视图的输出，根据数据库，对象或类型来确定缓冲
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

	
	
/*
sqlServer的内存按分配大小和申请方式，主要分三块
数据页面 database page
buffer pool 里的stolen部份
multi-page

Stolen内存描述缓冲区正在使用排序或哈希操作 （查询工作区内存），
或为那些被用作分配的通用内存存储区来存储内部数据结构 （如锁、 事务上下文和连接信息的缓冲区。
惰性写入器进程中不允许刷新Stolen从缓冲池中的缓冲区。

<针对数据页缓冲区的内存分析>

如果sqlserver经常要在内存和硬盘间倒数据，以完成不同用户对不同数据页的访问请求，那么sqlserver的整体性能会受到极大的影响，
可以说，这种性能问题是除了阻塞以外，sqlserver 最常见的性能问题原因，一般管理员看一个sqlServer性能，DataBase Page 是否有
瓶颈是要优先检查的.

如果一个sqlServer 没有足够的内存存放经常要访问的数据页面，sqlServer 就会发生下面行为
1,sqlServer需要经常触发Lazy Writes,按访问的频度，把最近没有访问的数据页面回写到硬盘上的数据文件里，把最近没有使用的
执行计划从内存里清除。
2,SqlServer需要经常从数据文件里读数据页面，所以会有很多硬盘读。
3，由于硬盘读取相对内存读来讲，是件很慢的事，所以用户的语句会经常等待硬盘读写完成。
4，由于执行计划会被经常清除，所以buffer pool里的stolen内存部分应该不会很多。
5，由于数据页会被经常清除，所以Page Life Expectancy不会很高，而且会经常下降。

sys.sysprocesses 动态管理视图中出现一些连接等待i/0完成的现象。
当sqlserver出现database page内存瓶颈的时候，往往会伴随着发生硬盘瓶颈问题。这是因为
1）sqlserver数据页paging 动作会带来大量的硬盘读写，使得硬盘跟着忙碌起来，
2）如果一个连接要等sqlserer从硬盘上读数据，这个等待会比从内存里读要长得多，时间花费不在一个数量级上。哪怕硬盘再
快，也比不上内存。所以从连接的等待状态来持，它们会经常等硬盘。

当确定了数据页面缓冲区有内存压力后，分析压力来源和解决方法

1,外部压力
当window层面出现内存不够的时候，sqlserver会压缩自己的内存使用，这时间database pages 会首当其冲，被压缩，所以自己
然会发生内存瓶颈。这时候压力来自 sqlServer的外部

a,sqlserverMemory Manager  - Total Server Memory 有没有被压缩
b,memory:available mbytes 有没有下降一一个比较低的值
c,如果sqlServer没有使用AWE或lock page in memory技术，process 上的内存计数器还是准的，可以看看process:private bytes-sqlserver
和process:working Set -sqlservr的值是不是也有了急剧的下降。

解决办法
即然压力来自sqlserer 之外，那管理员就要做出选反，是给sqlserver多一点内存资源呢，还是让sqlserver自己节衣缩食，多留一些内存给系统,
这个调整可以通过设置sqlserver的max server memory值做到。

为了最大程度上预防外部压力对 sqlserver的性能造成致命影响，还是建议重要的sqlserver服务最好安装在专门的服务器上，不要和其他服务混在一起。

2，来自sqlserver自身database page使用需求的压力
sqlserver的totalserver memory已经到达了用户设定的max servermemory上限，或者sqlserver已经没有办法从windows那里再申请到新内存，而
用户经常访问的数据量又远大于物理内存用来存放数据页面的大小，迫使sqlserver不断地将内存里的数据page out 又page in,以完成眼前用户请求

主要表现在
1)sqlServer:memory manager-Total Server Memory 一直维持在一个比较高的值，和sqlserver memory manager-target server memory相等。不会
有total server memory 大于target server memory的现象。
这一点是区别内部压力和外部压力的最明显差别.

2,其它共同特征
sqlserver:buffer manager - lazy writes/sec : 经常出现不为0.
....page Life expectancy:经常有显著下降
....page reads/sec : 经常不为0
....Stolen pages :维持在一个比较低的水平，应该比database page 要小很多。
sys.sysprocesses 动态管理视图中出现一些连接等待i/o完成的现象。

解决办法
即然sqlserver自己没有足哆的内存空间放database pages,那解决问题的思路有两个：或者想办法给sqlserver更多的内存，
或得想办法让sqlserver少用一点内存。
a,在32位服务器上开启awe功能，扩展使用4G以上内存。
b,如果sql已经充分使用了服务器的内存，便不是不够，增加内存。
c,如果scale up不容易，可以考虑scale out,分数据库到其它服务器上。
d,跟踪sqlserver的运行，找到读取数据页最多的语句进行评估。如果这些语句天生就要读很多数据，那就要和应用开发人员商量，
为什么每次要从sqlserver上读取这么多数据，是否有这个必要。如果语句只是要返回部份数据，但是因为表格上没有合适的索引，
使得sql选择了一个表扫描的执行计划，事实上很多数据是没必要读的，那就要优化数据库它引的设计，以估化语句的执行，减少
内存使用。


3，来自buffer pool里的stolen memory的压力
正常情况下，buffer pool里的stolen memory 是不应该给database pages 造成太大的压力的，因为如果database pages 有压力，
就会触发lazy writes,同时sql也会清除stolen 内存的执行计划缓存部份。所以在一个buffer pool有内存压力的sqlserver上，是不
有太多的stolen memory的，但是在有些sqlserver上，用户可能开启了一些sqlserver对象而没有及时关闭，例如，声明了很多游档，
用宛了以后不关，或者prepare 了很多执行计划但是不un-prepare,这些对象绝大部份是放在buffer pool里的，如果用户始终不释放
它们，也不登出sqlserver,那这部份内存就永锭放不掉，当这部份内存涨到足够大时，会反过来压缩database page 的使用。

检查stolen memory使用量也比较简单，可以直接查询 sys.dm_os_memory_clerks 这个系统管理视图的single_pages_kb字段，看是
哪个clerk用掉了比较多的stolen内存方向比较清楚。

4，来自multi-page（memtoleave）的压力
由于 multi-page和buffer pool共享sqlserve的虚拟地址空间，如果multi-page使用得太多，buffer pool的地址空间就小了，这也会
压缩database page的大小，由于sqlserver使用multi-page的量一般不大，所以这种问题比较少发生。

64位的sqlserver上，对multi-page使用已经没有上限。sqlserver需要使用多少，就能够申请到多少。如果sqlserver 调用了一些
内存泄漏很历害的第三方代码，64位上的内存虽然比较充裕，但也有被漏完的可能。

查询sys.dm_os_memory_clerks.multi-page，看是那clerk用掉了内存。


5，当物理内存使用量固定，又没有外部压力，sqlserver的内存压力主要来自database pages 时，管理员要做的就是要找出sqlserver
为什么要用这么多databse page缓存，在内存有压力的情况下，sqlserver是不会无纯无故地缓顾存数据页面的。一定是有用户在用这些
数据。

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


--Stolen Memory缓存压力分析------------------------------
/*
在sqlServer 里，除了dataBase Pages,其它的内存分配基本都不是遵从先reserve,再commit的方法，而是直接从地址空间里申请
所以这些内存基本都是Stolen Memory.对一般的SqlServer,Stolen 内存也主要以8KB为单位分配，分布在BUffer Pool 里

Stolen 内存虽然不缓存数据页面，但是对sqlserver正常的运行也是必不可缺的，任何一条语句的执行，都需要stolen内存来做语
句的分析，优化，执行计划的缓存，也可能需要内存来做排序，计算。任何一个连接的建立，也南非要分配stolen内存给它建立数
据结构和输入、输出缓冲区。所以如果stolen内存申请不到，sqlServer的任何操作都有可能遇到问题。

如果一个sqlServer能够缓存这么多不同的执行计划，说明它内部运行的大多数是动态t-sql语句，很少能重用。

表现：
当stolen内存有压力的时候，会产生两类问题。一类是用户提交的请求因为缺少内存而不能完成，sqlserver返回错误信息。
这类问题对sqlserver的影响会比较严重，但是症状也比较明显。
另一类是 sqlserver内存空间申请出现了瓶颈，但是sqlserver可以通过压缩某些clerk申请的内存数量，或者清理掉一些缓存来
得到空余的内存，或者让用户等待一会，最终能完成用户提交的请求。

当sqlserver遇到这方面的瓶颈时，可以通过sys.sysprocesses.waittype字段不等于0x0000来观察

1，CMEMthREAD(0x00B9)等待 
高并发sqlserer,同时申请的人太多，而这些并发的连接，在大量地使用需要每次都做编译的动态t-sql语句。解决方法不是增加内存，
而是修改客户的连接行为，尽可能更多地使用存储过程，或者使用参数化的t-sql语句调用，减少语句编译量，增加执行计划的重用。
避免大量连接同时申请内存做语句编译的现象。

2，SOS_RESERVEDMEMBLOCKLIST(0X007B)
当用户发过来的语句内含有大量的参数，或者有一个很长的in子句时，它的执行计划在8kb 的single pages 可能会放不下，需要用
multi-page来存储，所以sqlserver需要在mumtoleave里申请空间，造成的后果可能是随着缓存的执行计划越来越多，不但buffer pool
里的stolen内存在不断增长，memtoleav里用来存储执行计划的stolen内存也在不断增长。当用户要申请这块内存而暂时不能得到满足
时的等待状态。

解决方法：
a,避免使用这种带大量参数，或者长in子句的语句
b,使用64位的sqlserver
c,定期运行dbcc freeproccache


3,RESOURCE_SEMAPHORE_QUERY_COMPILE(0X011a)
当一个batch或存储过程非常冗长复杂的时候，sqlserver需要很多的内存在进行编译，为了防止太多内存被用来做编译，sql
server为编译内存设了一个上限。当有太多复杂的语句同时在做编译时，可能编译内存使用会达到这个上限，而后面的语句
将不得不进入等待状态。

解决方法：
a,修改客户连接的行为，尽可能更多的使用存储过程或者是使用参数化的t-sql语句调用，减少语句编译量，增加执行计划的重用。
避免大量连接同时申请内存做语句编译的现象
b,简化每次需要编译的语句的复杂度，降低编译需要的内存量。
c,定期运行dbcc freeproccache


--Multi-Page 缓存区压力分析------------------------------------

对multi-page内存解析：
a,小于等于8Kb数据放在buffer pool内存里，大于8KB,或者是加载在sqlserver进程内的第三方代码所申请的内存，放在mulit-page内存里
b,在32位系统里，multi-page的数目是有限制的，但到了64位系统，已不再做限制，而sqlserver的max server memory设置 仅对
buffer pool起作用。
c,multi-page主要用于每个sql进程thread要用0.5MB,sqlserver自己申请的超过8kb的stolen内存，以及sql进程里加载的第三方代码所
申请的内存。

产生的原因：
1，客户端连接因超过8bk而大量的使用了这些内存，比如 带大量参数，或者长in的语句，把连接的network packet size设成8kb或更高。
2,客户端应用调用了一些复杂或数量巨大的xml功能。
3，大量使用了clr等功能。

*/