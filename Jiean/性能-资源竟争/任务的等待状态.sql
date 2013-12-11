

--任务的等待状态


--目标：查看SqlServer所有的任务状态和等待的资源

/*
sys.dm_exec_requests :返回有关在sqlserver中执行的每个请求的信息，包括当前的等待状态

sys.dm_exec_sessions : 对于sqlserver中每个经过身份验证的会话都会返回相应的一行

sys.dm_exec_connections : 返回与sqlserver实例建立的连接有关的信息及每个连接的详细信息。
*/

SELECT 
s.session_id
,s.status
,s.login_time
,s.host_name
,s.program_name
,s.host_process_id
,s.client_version
,s.client_interface_name
,s.login_name
,s.last_request_start_time
,s.last_request_end_time
,c.connect_time
,c.net_transport
,c.net_packet_size
,c.client_net_address
,r.request_id
,r.start_time
,r.status
,r.command
,r.database_id
,r.user_id
,r.blocking_session_id
,r.wait_type
,r.wait_time
,r.last_wait_type
,r.wait_resource
,r.open_resultset_count
,r.transaction_id
,r.percent_complete
,r.cpu_time
,r.reads
,r.writes
,r.granted_query_memory
 FROM sys.dm_exec_requests r
RIGHT JOIN sys.dm_exec_sessions s ON r.session_id = s.session_id
RIGHT JOIN sys.dm_exec_connections c ON s.session_id = c.session_id
WHERE s.is_user_process=1

/*
内存缓冲池中的页面读写机制：
当sqlserver将数据页面从数据文件里读入内存时，为为防止其它用户对内存里的同一个数据页面进行访问，sqlserver
会在内存的数据页面上加一个排他的letch锁，而当有任务要读取缓存在内存里的页面时，会申请一个共享的latch.像
lock一样，latch也会出现阻塞垢现象。

常见的等待类型
 PageIOLatch :说明sqlserver一定是在等待某个i/o动作的完成，所以如果一个sqlserver经常出现这一类的等待，说明
 磁盘的速度不能满足sqlserver的需要，它已经成为了一个sqlserver的一个瓶颈。
 
 PageIOLatch_SH : 经常发生在用户正想要去访问一个数据页面，而同时sqlserver却要把这个页面从磁盘读往内存，如果这个
 页面是用户经常有可能访问到的，那么问题就是内存不够大，没有能够将数据页面始终缓存在内存里，所以，往往是先有内
 存压力，触发sqlserver做了很多读取页面的工作，才引发了磁盘读的瓶颈。这里的磁盘瓶颈常常是内存瓶颈的副产品。
 
 PageIOLatch_EX : 常常发生在用户对数据页面做了修改，sqlServer要向磁盘回写的时候，基本意味着磁盘的写入速度跟不上。
 
 PageLatch_x : 在高并发过程中，向同一个表插入记录时，申请的Latch
 解决：换一个数据列建聚集索引，而不要建在identity的字段上，这样表格里的数据就会按照共它方式排序，同一时间的插入就
 有机会分散在不同的页面上。
 
 2，如果实在是一定要在 identity的字段上建聚集索引，建议根据其他某个数据列在表格上建立若士个分区，把一个表格分
 成若干个分区，可以使用得接受新数据的页面数目增加。
 
 Runnable 可运行
可以运行，但是没有在运行，正常的sqlserver，哪怕非常繁忙，也不应该经常看见runnable的任务，连running 状态的任务，
都不应该很多
原因：
1,sqlServer cpu使用率已经接近100%,真的是没有足够的cpu资源及时处理用户的并发任务
2，sqlServerCPU使用率并不很高，小于50%,这种情况可能跟资源的自旋锁有关，有2008版本以后得到解决。

 TempDb上的PageLatch
存储过程在tempdb的建删表，SGAM,PFS和GAM页面也会生修改，这也会加latch,这些latch在某些情况下也有可能成为系统瓶颈。

解决方法
1）sqlServer使用几颗cpu在运行，就为tempdb创建几个数据文件
2)这些文件的大小必须一样。
3）要严格防止tempdb数据空间用尽，引发数据文件自动增长，因为自动增长只会增长其中一个文件，造成只有一个文件有空闲
空间，所有的任务就会都体育西路 在它的身上，它就又变成瓶颈了。
*/