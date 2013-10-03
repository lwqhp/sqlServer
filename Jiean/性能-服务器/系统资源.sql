
--sqlserver 是怎么样使用一台服务器上的系统资源的

/*
作为一个window操作系统上的应用程序，sql server首先接受window的管理，利用window开放出的各种API
来申请和调度各项资源的使用。而作为一个数据引擎系统，sqlserver有它自己一套的系统资源管理理念。
尤其是对内顾和cpu资源。

也就是说在资源调度上，一层是window层面上，由window决定调度多少系统资源给sqlserver,第二层在sqlserver
内部，由sqlserver调度自己掌控的资源到底怎么用。

内存管理
作为一个须要反复访问数据的应用，sqlserver必须在内存中缓存很多信息，才能具有良好的性能。

1，sqlServer所占用的内存数量从启动以后，就不停地增长。
要解决这种现象，须要了解sqlserver与window，以及与运行在window之上的其它服务和应用是怎么相互办调，
共享服务器上的内存的，我们也须要了解怎么才能比较准确地分析一台服务器上window和包括sqlserver在内
的所有应用进程的内存使用。

2，在window2003以上版本上运行的slqserver,内存使用量突然急剧下降。

3，用户在做操作时，遇到内存申请失败。

4，内存压力导致的性能下降

从操作系统层面看sql server内存分配
 sqlserver和其它应用程序在请求内存上没有什么区别，都是通过virtualalloc之类的API向windows申请内存。
 window要协调并尽量满足各个应用的请求，还要保证这些请求不会危及window自身的安全。
 
 Virtual Address Space 虚拟地址空间
 就是内存寻址空间，每一个内存单元都有一个对应的访问地址，寻址空间的大小决定了应用程序能够申请访问的
 的最大地址空间，32位的服务器上，由于地址单元的长度是32位，寻址空间最大2^32,即4GB，再大的空间也无法
 被应用程序使用到。
 注：虚拟地址空间里存放的数据信息不一定都在物理内存里，window会根据其使用情况，决定它们什么时放在物理
 内存里，什么时候放在内存文件里(paging file)

 Page Hard Fault(硬错误)
 当访问一个存在于虚拟地址空间，但不存在于物理内存的页面，就会发生一次page Fault.windows内存管理组件会处理
 每一个页面访问错误，首先它要判断是不是访问越界，如果不是，如果目标页面存在于硬盘上(例如,在page file里)，
 这种访问会带来一次硬盘读写，我们称其为Hard Fault.另一种页面已尼桑在物理内存中，但是还没有直接放在这个进程
 的working Set 下，需要windows重新定向一次，这种访问不会带来硬盘操作，我们称之为Soft Fault.

 Reserved Memory（保留内存）
 应用程序在内存中保留一出一块内存寻址空间，以供将来使用,但不会实际去分配内存空间。

 Committed Memory(提交内存)
 将预先保留的内存寻址正式提交使用，存入数据。也就是说，正式在物理内存中申请一段空间，向页面中存入数据。

 Working Set(工作集)
 某个进程的地址空间中，存放在物理内存的那一部份。
 
 shared Memory(可共享)
 windows提供了在进程和操作系统间共享内存的机制。共享内存可以定义为对一个以上的进程都是可见的内存，或存
 在于多个进程的虚拟地址空间。
 
 private bytes(专用)
 某个进程提交的地址空间(Committed Memory)中，非共享的部分。
 

 Memory Leak(内存泄漏)
 当应用程序中出现某种循环，一直不断地保留(Reserve)或提交(Commit)内存资源，哪怕它们不再被使用，也不释放给其他用户重用。
 就会出现内存泄漏。sqlServer的内存泄漏有两种：一种是SqlServer 作为一个进程，不断地向windows申请内存资源，直到整个window内存耗尽。
 另一种是在sqlServr内部，某个sql Server 组件不断地申请内存，直到把sqlServer能申请到的所有内存都耗尽，使得其他sqlServer的功能
 组件不能正常使用内存。

 特别了解下32位下的寻址范围
 32位window 下用户 进程会有4G的寻址空间，其中2GB是给核心态(Kernel Mode)留下的，剩下2GB是给用户态(user Mode)留下的，window不会因
 为其中某一块内存地址空间用尽而将另外一块的空间让出。

 /3GB参数
 在boot.ini文件中使用/3GB参数可以把核心态的寻址空间降到1G,用户态寻址空间升到3G.

 AWE(Address Windowsing Extensions 地址空间扩展)
 这是一种允许 32位应用程序分配64GB物理内存，并把视图或窗口映射2GB虚拟地址空间的机制。

 注：sqlserver是通过一些特殊函数调用，去申请2G以外内存地址保留Reserve，然后通过Commit的内存调用，让它们使用扩展的内存，而
 一般的方式申请的内存，还是只能使用2GB的.

 启用AWE
 1)需要sqlserver启动帐户在window上有lock pages in memory权限。
 2)登陆用户有服务器权限
 3) sp_configure 'awe enabled',1
 4)确认 sql日志中有
	server Address Windowing Extensions enabled.
	失败：Cannot use Address Windowing Extensions Because lock memory Privilege was not granted.
 

 --------windows 内存检查------------------------------------------------
 windows层面没有明显的内存压力，是sqlServer正常运行的前提。
 检查：
 1)windows系统自身内存使用数量及内存分布。
 2）服务器上每一个进程的内存使用情况， 了解那些进程内存使用得最多，那些进程遇到了内存压力。

 监视windows 系统使用情况
 
 资源监视器
1）任务管理器中看到的内存数量是进程的专享内存大小
2）工作集=可共享+专用
3）提交~=专享内存+页文件大小,操作系统预留了一部分物理内存给自己使用

a) 为硬件保留的内存：除了显存以外，还有没开或者根本没有内存重映射技术主板，由硬件占用的一部分低端地址空间。
b) 正在使用：	供进程、驱动程序或操作系统使用的内存
c) 已修改：其内容必须在进入磁盘后才能用作其他目的的内存。指进程已经完成了操作，等待写入磁盘那部份内存。
d) 备用：	包含未活跃使用的缓存数据和代码的内存，也就是已处理完或弃用的死数据的内存空间，可重新申请使用。
e) 可用：即空闲内存，不包含任何有价值数据，以及当进程、驱动程序或操作系统需要更多内存时将首先使用的内存。

 1,整体使用分析
Committed Bytes
整个windows系统，包括windows自身及所有用户进程使用的内存总数，包括物理内存里的数据和文件缓存中的数据。

计算器的内存总量-资源监视器中的正在使用内存-为硬件保留的内存=使用的页面文件数量

2,Commit Limit
整个windows系统能够申请的最大内存数，其值等于物理内存加上文件缓存的大小。

如果Committed Bytes已经接近或等于Commit Limit,说明系统的内存使用已经接近极限，如果缓
存文件不能自动增长，系统将不能提供更多的内存空间。

3,Available Mbytes
现在系统空闲的物理内存数，这个指标能够直接反映出windows层面上有没有内存压力。
比较：这个数值跟“资源监视器”里的可用总数是对得上的。但计数器能反映出某段时间最大，最小，平均值。

4，Page File:%Usage 和Page File:%Peak Usage
这两个是百分比数，反应缓存文件使用量的多少，数据在文件级存中存得越多，说明物理内存数量和实际需求
量的差距越大，性能也越差。

5，pages/sec
Hard Page Fault 每秒钟需要从磁盘上读取或写入的页面数目。这里包括windows系统和所有应用进程的所有磁
盘paging动作，是Memory:pages input/sec 和memory:pages output/sec 的和。

对于一个调整良好，有足够内存资源的系统来讲，它所要处理的数据应该比较长期地保存在物理内存里，如果频繁
地被换进换出(page in/page/out)，势必会严重影响性能，所以如果一个系统不缺内存，pages/sec不能长时间地保
持在一个比较高的值。

总结：了解现有内存地址空间的使用大小，以及有多少数据期实级存在硬盘上的缓存文件里。
有多少空闲的物理内存还能被使用。对于一台sqlserver服务器，如果长期小于10MB，一般来讲物理内存是不太够的。
确认系统是否因为物理内存不足，而频繁做页面换进换出动作。如果是，也说明物理内存不富裕。


----Windows系统自身内存使用情况------------------------------------
一般32位的windows 系统，windows正常的内存使用在几百Mb,64位机器上，可能会达到1-2GB,但是如果windows在做一些
特殊的操作，或者是在windows层面出现内存泄漏（一般是由一些硬件驱动造成的）。windows可能会用到几个G甚至十几GB，
反过来挤压了应用程序的物理内存使用。

Memory:Cache Bytes
系统的working Set ,也就是系统使用的物理内存数目。包括高速缓存，页交换区，可调页的ntoskrnl.exe 和驱动程序代码，以及
系统映射视图等。
等于以下计数器的总和
Memory:Ststem cache Resident bytes(system cache)
系统高速缓存消耗的物理内存。

Memory:Pool paged resident bytes
页交换区消耗的物理内存

Memory:System Driver Resident Bytes
可调页的设备驱动程序代码消耗的物理内存。

Memory:System Code Resident Bytes
Ntoskrnl.exe 中可调页代码消耗的内存。

----System Pool------------------------------------
windows里面有两块重要的交换区(pool),如果这两块内存出现泄漏，或者空间用尽，windows会出现一些奇怪
的不正常行为，进而影响sqlServer的稳定运行，所以这两块内存的使用情况也要检查一下。
memory:pool Nonpaged bytes(非页交换区) 
Memory:Pool paged resident Bytes(页交换区)

--单个proecss 进程的使用情况
当Available MBytes看出服务器的内存基本用尽，但是从Memory:Cache Bytes 的值看，window自己没有使用多少，现在就要分析
到底是哪些个应用进程把物理内存都占用了。

Process:%processor Time 指的是目标进程消耗的cpu资源数，包括用户态和核心态的时间,也就是处理器用来执行非闲置线程时间
的百分比。

Process:Page Faults/sec 指的是目标进程上发生的Page Faults的数目。

Process:Handle Count 指的是目标进程Handle(指向object的指针)数目。如果进程内部有对象老是创建，不及时回收，就会发生Handle Leak.

Process:Thread Count 指的是目标进程的线程数目。如果进程总是创建新线程，不释放老线程，就会发生Thread Leak.

Process:Pool Paged Bytes 指的是目标进程所使用的Paged Pool 大小.

Process:Pool Nonpaged Bytes 指的是目标进程所使用的Non-Paged Pool 大小.


Process:Working Set :某个进程的地址空间中，存放在物理内存的那一部份。
Process: Virtual Bytes:某个进程所申请的虚拟地址空间大小，包括reserved  Memory和Committed Memory.
Process:Private Bytes:某个进程的提交了的地址空间(committed Memory)中，非共享的部份。

目标：
使用内存最多的进程
内存使用量在不断增长的进程
出现问题的那个时间段里，内存使用数量发生过突变的进程.


SqlServer内存使用特性

默认最大的用户态地址空间是2GB,如果使用了/3GB参数或开启了 AWE，或者是在64位的机器上，sqlserver可以
使用更多的内存，sqlserver是个很喜欢内存资源的程序，它的理想状态，就是把所有可能会用到的数据和结构
都缓存在物理内存里，以达到最优的性能。

默认情况下，建议sqlServer 动态使用内存，它会定期查询系统以确定可用物理内存量


释放内存机制
Total Server Memory :SqlServer 自己分配的Buffer Pool 内存总和
Target Server Memory : sqlServer在理论上能够使用的最多的内存数目。

当sqlserver启动的时候，它会检查一下自己的虚拟地址空间，是否开启了AWE,sp_configure里的"max Server Memory"值，以及当
前服务器的可用物理内存数，其中取一个最小值，作为自己的Target server memory值。

在sqlServer运行的过程中，如果它感知到windows层面的内存压力，就会降低Target ServerMemory的大小，而sql Server又会定期
比较TotalServerMemory和TargetServerMemory两个值.

当Total Server Memory小于TargetServerMemory时，sqlserver知道系统还有足够的内存，所以在须要缓存任何新的数据时，就会分配新
的内存地址空间。从计数器上看，totalServerMemory的值会不断变大.

当Total Server Memory等于TargetServerMemory时，sqlServer 知道自己已经用足了系统能够给予的内存空间，如果需要缓存任何新的数
据，它不会再去分配新的内存空间，反过来，它会在自己现在的内存空间里清理动作，腾出空间来给新的数据使用。

当sqlServer收到windows内存压力信号，调小target ServerMemory值，使得Total Server Memory大于target Server Memory时，sqlserver
开始内存清理动作，调小自己的地址空间大小，释放内存。

-----------内存分类---------------------------------------


---内存相关动态视图DMV
sqlServer2005以后，sqlserver使用Memory Clerk的方式统一管理sqlServer内存的分配和回收。所有sqlserver 代码要申请或释放内存，都需
要通过它们的Clerk.通过这种机制，sqlserver 可以知道每个clerk 使用了多少内存，从而也能够知道自己总共用了多少内存。这些信息动态的
保存在内存动态管理视图里.

开始
sys.dm_os_memory_clerks:返回sqlServer实例中当前处于活动状态的全部内存clerk的集合,也就是说，从这个视图里，可以看到内存是怎么被
sqlServer使用掉的

内存中的数据页面由哪些表格组成，各占多少？
sys.dm_os_buffer_descriptors : 记录了sqlserver 缓冲泄中当前所有数据页的信息，可以使用该视图的输出，根据数据库，对象或类型来确定缓冲
汇内数据库页的分布。

这个视图可以回答
1,一个应用经常要访问的数据到底有哪些表，有多大
2，如果以间隔很短的时间运行上面的脚本，前后返回的结果有很大差异，说明sqlServer刚刚为新的数据作了paging,sql的缓冲区有压力。而在后面那次
运行出现的新数据，就是刚刚page in进来的数据。
3,在一条语句第一次执行前后各运行一遍上面的脚本，就能够知道这句话要读入多少数据到内存里

sys.dm_exec_cached_plans :了解执行计划都缓存了些什么，哪些些比较占内存
*/
select type,
sum(virtual_memory_reserved_kb) as vm_reserved,
sum(virtual_memory_committed_kb) as vm_committed,
sum(awe_allocated_kb) as awe_allocated,
sum(shared_memory_reserved_kb) as sm_reserved,
sum(shared_memory_committed_kb) as sm_committed,
sum(pages_kb) as mu_page_allocator
from sys.dm_os_memory_clerks 
group by type



-------
select b.database_id,db=db_name(b.database_id),p.object_id,p.index_id,buffer_count=count(*) 
from master.sys.allocation_units a, master.sys.dm_os_buffer_descriptors b,master.sys.partitions p
	where a.allocation_unit_id = b.allocation_unit_id
	and a.container_id = p.hobt_id
	and b.database_id = db_id('master')
	group by b.database_id,p.object_id,p.index_id
	order by b.database_id,buffer_count desc


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


---
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

数据页缓冲区压力分析
如果sqlserver经常要在内存和硬盘间倒数据，以完成不同用户对不同数据页的访问请求，那么sqlserver的整体性能会受到极大的影响，
可以说，这种性能问题是除了阻塞以外，sqlserver 最常见的性能问题原因，一般管理员看一个sqlServer性能，DataBase Page 是否有
瓶颈是要优先检查的.

如果一个sqlServer 没有足够的内存存放经常要访问的数据页面，sqlServer 就会发生下面行为
1,sqlServer需要经常触发Lazy Writes,按访问的频度，把最近没有访问的数据页面回写到硬盘上的数据文件里，把最近没有使用的
执行计划从内存里清除。
2,SqlServer需要经常从数据文件里读数据页面，所以会有很多硬盘读。
3，由于硬盘读取相对内存读来讲，是件很慢的事，所以用户的语句会经常等待硬盘读写完成。
4，由于执行计划会被经常清除，所以Page Life Expectancy不会很高，而且会经常下降。

sqlServer:buffer Manager -lazy writes/sec
一个正常的sqlServer 会偶尔有一些lazy writes,但是在内存吃紧的时候，会连续发生lazy writes.

sqlServer:buffer Manager - page life expectancy
对于一个正常的SqlServer,难免会有用户访问没有缓存在内存里的数据，所以page life expectancy 时不时降下来也是难免的。
但是在内存始终不足的情况下，而面会被反复地换进换出，page life expectancy会始终升不上去。

3,sqlServer:buffer Manager - page reads/sec
sqlServer 从数据文件读取的数据量，可以被其跟踪下来，正常的sqlserver,这个计数器的值应该始终接近于0,偶尔有值，也应该
很快降回0.一直不为0的状态，是会严重影响性能的。

4,sqlServer:Buffer Manager - Stolen Pages
相对于数据页面，sqlServer 会比较优先的清除内存里地执行计划。所以当Buffer Pool发生内存压力的时候，也会看到Stolen pages
降低。反过来，如果Stolen pages 的数目没什么变化，一般来讲，就意味着sqlServer 还有足够的内存存放database  pages(但是请注
意，并不一定意味着buffer pool里的stolen 内存和multi-page 内存没有问题)

5，sys.sysprocesses 动态管理视图中出现一些连接等待i/0完成的现象。
当sqlserver出现database page内顾瓶颈的时候，往往会伴随着发生硬盘瓶颈问题。这是因为
1）sqlserver数据页paging 动作会带来大量的硬盘读写，使得硬盘跟着忙碌起来，
2）如果一个连接要等sqlserer从硬盘上读数据，这个等待会比从内存里读要长得多，时间花费不在一个数量级上。哪怕硬盘再
快，也比不上内存。所以从连接的等待状态来持，它们会经常等硬盘。

---确定压力来源和解决办法

1,外部压力
当window层面出现内存不够的时候，sqlserver会压缩自己的内丰使用，这时间database pages 会首当其冲，被压缩，所以自己
然会发生内存瓶颈。这时候压力来自 sqlServer的外部

a,sqlserverMemory Manager  - Total Server Memory 有没有被压缩
b,memory:available mbytes 有没有下降一一个比较低的值
c,如果sqlServer没有使用AWE或lock page in memory技术，process 上的内存计数器还是准的，可以看看process:private bytes-sqlserver
和process:working Set -sqlservr的值是不是也有了急剧的下降。

解决办法
即然压力来自sqlserer 之外，那管理员就要做出选反，是给sqlserver多一点内存资源呢，还是让sqlserver自己节衣缩食，多留一些内存给系统,
这个调整可以通过设置sqlserver的max server memory值做到。

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
即然sqlserver自己没有足哆的内存空间放database pages,那解决问题的思路有两个：或者想办法给sqlserverg更多的内存，
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

4，来自multi-page（memtoleave）的压力
由于 multi-page和buffer pool共享sqlserve的虚拟地址空间，如果multi-page使用得太多，buffer pool的地址空间就小了，这也会
压缩database page的大小，由于sqlserver使用multi-page的量一般不大，所以这种问题比较少发生。

如何发现内存使用比较多的语句

1,使用DMV分析sqlserver启动以皇粮做read最多的语句
sys.dm_exec_query_stats :返回缓存查询计划的聚合性能统计信息。
*/
SELECT * FROM sys.dm_exec_query_stats

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
从这两个查询，可以大致知道sqlserver里喜欢读数据的语句是哪些了.

这个视图里每一个语句记录的生存期与执行计划本身相关联，如果sqlserver有内存压力，把一部份执行计划从级存中删除时，这些
记录也会从该视图中删除。

视图里的是历史信息，反映不出在某个时间段调用得比较频繁，针对性不是很强。

如果要准确知道在某个时间段里，哪些语句比较耗内存资源，sqlserver日志文件上场。


----Stolen Memory缓存压力分析
在sqlServer 里，除了dataBase Pages,其它的内存分配基本都不是遵从先reserve,再commit的方法，而是直接从地址空间里申请
所以这些内存基本都是Stolen Memory.对一般的SqlServer,Stolen 内存也主要以8KB为单位分配，分布在BUffer Pool 里

如果一个sqlServer能够缓存这么多不同的执行计划，说明它内部运行的大多数是动态t-sql语句，很少能重用。


CMEMthREAD(0x00B9)等待 sys.sysprocesses.waittype
高并发sqlserer,同时申请的人太多，而这些并发的连接，在大量地使用需要每次都做编译的动态t-sql语句。解决方法不是增加内存，
而是修改客户的连接行为，尽可能更多地使用存储过程，或者使用参数化的t-sql语句调用，减少语句编译量，增加执行计划的重用。
避免大量连接同时申请内存做语句编译的现象。
*/