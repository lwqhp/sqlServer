

--内存模块和配置
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
*/