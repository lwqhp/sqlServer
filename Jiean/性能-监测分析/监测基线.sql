


--服务器设定
/*
1)服务器进程的优先级
在同一个服务器上有另一个资源密集型的应用程序可能限制sqlServer可用的资源，即使一个应用程序作为服务器运行，
也可能消费相当一部份系统资源并限制sqlServer可用的资源，比如，不建议在服务器上连续运行windows任务管理器,
任务管理器也是一个应用程序-长歌典型的。taskmgr.exe,它运行在比sqlServer进程更高的优先级，优先级是给预一个
资源的权重，使处理器在运行时给它更多的优先权。

2）内存的设置
最小，最大值
64位处理器
32位服务器开启/3gb和 AWE功能
*/

--入手
/*
首先查看内存-存储-cpu 顺序进行
例如，在低内存条件下，很有可能出现存储活动增加，因为系统开始使用页面文件作为提交的内存的临时存储，这一活动
也会提升cpu的使用率，因为windows需要管理分页的过程。

page life expectancy ms推荐的ple值是至少300秒


存储性能
avg.disk sec /transfer
测量的是windows进行一次磁盘传输消乱的时间，单位为秒，对于包含sqlserver数据库文件的磁盘来说，磁盘传输时间应该
稳定在20毫秒之内，理想情况应该小于10毫秒。
如果没有达到这个性能水平，那么应该继续深入分解查看读和写的计数器
avg.disk sec /read
avg.disk sec/write

如果读性能和写性能拥有显著差异，那么应该检查控制器缓存和raid级别，看是否能想办法重新均衡缓存的设置，或者推
荐一个更快的raid类型。

sys.dm_io_virtual_file_stats  可以查看所有数据库文件的io细节
*/
SELECT 
DB_NAME(database_id),file_id,id_stal_read_ms/num_of_reads,
io_stall_write_ms/num_of_writes
 FROM sys.dm_io_virtual_file_stats(-1,-1)
WHERE num_of_reads >0 AND num_of_writes>0

/*
检查cpu使用状况，主要关注点在于区分用户模式和内核模式的cpu使用率，以及sqlserver服务消砂的cpu时间。
processor time 
反映的是cpu 的繁忙程度，>90%不好，没有额外的工作负荷留有空间。

privileged time
表明cpu执行内核模式操作时间的百分比，阈值是30%
当内存不足时，数据将开始被分页到磁盘，cpu要在内核、特权模式处理这些工作，而这个计数器值会增长。

user time
和上一个处理理构成了总的处理时间，阈值是>70%

processor time:sqlservr
在测量cpu使用率的时候，如果发现了高比例的处理器时间，而且发现大部份时间都消砂在执行用户模式应用程序上，这个时间最
好检查一下是否sqlserver 在使用大量的处理器时间。

查看sqlserver内部正在发生的事情，首先是sqlserver等待

sys.dm_os_waiting_tasks
只有任务在发生等待的时候才会在这个动态管理视图中有一个条目，因此，该动态管理视图最有效的使用方法是作为一系列的
快照，或在长时间运行的任务或大量任务在等待的时候诊断现场问题。

sys.dm_os_wait_stats
这个是所有查询的所有等待时间，非常合服务器级别的监视和性能调优。
*/