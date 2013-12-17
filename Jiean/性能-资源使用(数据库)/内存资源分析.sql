

--Sql Server内存分析

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