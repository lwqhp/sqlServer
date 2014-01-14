

---SqlServer内部的运作
/*
3.1内部的运作有几个硬性标指，通过这几个标指，能直接反映出内存问题

1，Buffer Cache Hit Ratio: 在缓冲区高速缓存中找到而不需要从磁盘中读取的页的 百分比。
>观察：该比率是缓存命中总次数与过去几千闪页面访问的缓存查找总次数之比，基本在99%%从上，如果小于95%,通常就有了
内存不足的问题，可以通过增加sqlserver的可用内存量来提高缓冲区高速缓存命中率。

2，Checkpoint pages/sec:由要求刷新所有脏页的检查点或其他操作'每秒刷新到磁盘的页数'。一般在30个左右
观察：如果用户的操作主要是读，就不会有很多数据改动的脏页，checkpoint的值就比较小，相反，如果用户做了很多insert/
update/delete,那么内存中修改过的数据脏页就会比较多，每次checkpoint的量也会比较大，
这个值在分析disk io问题的时候反而用得比较多。

3，lazy writes/sec:每秒被缓冲区管理器的惰性编写器写入的缓冲区数。保持在20以下
观察：当sqlserver感到内存压力的时候，就会将最久没有被重用到的数据页和执行计划清理出内存，使它们可再用于用户进程。
如果sqlserver内存压力不大，lazy writer就不会被经常触发，如果被经常触发，那么应该是有内存的瓶颈。
一个正常的sqlServer 会偶尔有一些lazy writes,但是在内存吃紧的时候，会连续发生lazy writes.

4,memory grants pending : 等待工作空间内存授权的进程总数。
观察：	如果memory grants pending这个值不等于0，就说明当前有一个用户的内存申请由于内存压力而被延迟，
一般来讲，这就意味着有比较严重的内存瓶颈，通过内存总量的分布，了解sqlserver内存那部份操作占的比较多。、
？记录一些指标。

3.2------------------------------
内部运作另一个关注点是页的读写，sqlserver的最小操作单元是页，通过观察页的读写情况，可以了解内部工作的顺畅程序
以及潜在的问题。

以实例名开头:Buffer manager:提供了计数器，用于监视sqlserver如何使用内存存储数据页，内部数据结构 和 过程缓存。

1，Page Life expectancy : 页若不被引用，将在缓冲池中停留的秒数。至少在300秒以上

观察： 如果sqlserver没有新的内存需求，或者有空余的空间来完成新的内存需求，那么lazy writer就不会被触发，页面会一直
放在缓冲池里，那么pagelife expectancy就会维持在一个比较高的水平，如果sqlserver出现了内存压力，lazy writer就会被触发
page life expectancy也会突然下降，所以，如果一个sqlserver 的page life expectancy总是高高低低，不能稳定在水平上，那么
这个sqlserver应该是有内存压力的。
对于一个正常的SqlServer,难免会有用户访问没有缓存在内存里的数据，所以page life expectancy 时不时降下来也是难免的。
但是在内存始终不足的情况下，而面会被反复地换进换出，page life expectancy会始终升不上去。

2，page reads/sec:每秒发出的物理数据加页读取数。此统计信息显示的是所有数据库间的物理页读取总数。

观察：如果数据全部缓存在内存里，不需要再做任何page read操作，而当sqlserv需要读这些页面旱，必须要为它们腾出内存空间来，
所在当page reads/sec比较高时，一般page life expectancy会下降，lazy writes会上升，这几个计数器是联动的。
sqlServer 从数据文件读取的数据量，可以被其跟踪下来，正常的sqlserver,这个计数器的值应该始终接近于0,偶尔有值，也应该
很快降回0.一直不为0的状态，是会严重影响性能的。

由于物理io开销大，page reads 动作一定会影响sqlserver的性能，可以通过使用更大的数据缓存，智能索引，更有效的查询或
更改数据库设计等方法，将page reads降低。

3，page writes/sec:每秒执行的物理数据库页写入数。

4，Stolen pages :(2012取消) 用于非database pages(包括执行计划缓存)的页数，这里就是stole memory在buffer pool里的大小
相对于数据页面，sqlServer 会比较优先的清除内存里地执行计划。所以当Buffer Pool发生内存压力的时候，也会看到Stolen pages
降低。反过来，如果Stolen pages 的数目没什么变化，一般来讲，就意味着sqlServer 还有足够的内存存放database  pages(但是请注
意，并不一定意味着buffer pool里的stolen 内存和multi-page 内存没有问题)


3.3-------------------------------------------------
内存的使用分布状况

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

3，Database pages : 缓冲池中数据库内容的页数。也就是所谓的database cache的大小。

再细一些：
4，Free Pages : 所有空闲可用的总页数。(2012取消)
观察：当这个值降低时，就说明sqlserver正在分配内存给一些用户，当这个值下降到比较低的值时，slqserver就会开始做lazywrites,
把一些内存腾出来。所以一般这个值不会为0.但是如果它反复降低，就说明sqlserver存在内存瓶颈。一个没有内存瓶颈的sqlserver
的FREE Pages会维持在一个稳定的值。

5,target pages:缓冲池中理想的页数。乘以8kb,就应该是target server memory的值。

6，total pages:（2012取消）缓冲池中的页数(包括数据库页，可用页和stolen页) 乘以8kb,就应该是total server memory 的值。


*/