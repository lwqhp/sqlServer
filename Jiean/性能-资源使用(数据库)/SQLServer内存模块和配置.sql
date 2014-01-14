

--内存模块和配置
/*
一，内存管理模式
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


------------------------------------------------------------------------------------------------------
二，SqlServer 提供的内存调节接口

1,Min Server Memory(MB) sp_configure配置
定义sqlserver 的最小内存值，这是一个逻辑概念产，控制sqlserver total server memory的大小，至于数据是放在物理内存
还是缓冲文件时在，是由window决定的，所以这个值不能保证sqlserver使用的最小物理内存数。

在sqlserver的地址空间增长到这个值以后，就不会再小于这个值。并不是sqlserver启动分配的最小内存值。

exec sp_configure 'show advanced option','1'--使用sp_configure存储过程能影响/就哦就示高级选项
exec sp_configure 'min server memory(MB)'，100
ReConfigure with override --更新sp_configure的设置，默认是不实时更新包含内存配置值的系统目录，加上ovveride强制更新

2，Max Server Memory(MB) sp_configure 配置
定义sqlserver 的最大内存值，同样，这也是一个逻辑概念，控制sqlserver total server memory的大小，至于数据是放在物理内存
还是缓冲文件时在，是由window决定的。

这个设定只能控制一部份sqlserver的内存使用量。

exec sp_configure 'max server memory(MB)'

3，Set working Set Size (sp_configure 配置)
sqlServer的执行代码通过调用一个windows参数，试图将sqlserver在物理内存中使用的内存数固定下来。但是现在的windows版本
已经不再尊重这个请求，且有副作用。

4，AWE enabled (sp_configure 配置)
让sqlserver开启用AWE方法申请内存，以突破32位windows的2GB用户寻址空间。但在slqserver2012版本中，32位的sqlserver已
取消这个功能。

5，Lock pages in memory(企业版会自动启动)
这个开关倒是能在一定程序上确保sqlserver的物理内存数，但是也不十分可靠。

6，针对低配置的32位服务器的优化
1)启用3GB进程空间
在标准的32位地址可以映射最大4GB内存寻址空间，且默认高位2GB被操作系统保留，低位的2GB可用于应用程序。
在32位系统的boot.ini文件中指定/3GB开关，操作系统只保留1GB的地址空间，应用程序可以访问到3GB.
[boot loader]
timeout=30
default=multi(0)disk(0)rdisk(0)partition(1)\WINNT
[operation systems]
multi(0)disk(0)rdisk(0)partition(1)\WINNT="Microsoft windows server 2008 Advanced Server"/fastdetect /3GB

3)在32位sqlserver中使用4GB以上的内存
[boot loader]
timeout=30
default=multi(0)disk(0)rdisk(0)partition(1)\WINNT
[operation systems]
multi(0)disk(0)rdisk(0)partition(1)\WINNT="Microsoft windows server 2008 Advanced Server"/fastdetect /PAE

数据库中启用5GB的方法
sp_configure 'show advanced options',1
reconfigure
go
sp_configure 'awe enabled',1
reconfigure
go
sp_configure 'max server memory',5120
reconfigure
go

sqlserver 2008在AWE内存被启用时不动态管理内存空间大小，所以，使用AWE内存时必须设置sqlserver的服务器最大内存
配置参数，在专用的sqlserver机器上服务器最大内存可以设置为总物理内存-200MB,能为操作系统和其它重要的工具/应
用程序保留足够的物理内存
当在相同机器上运行多个slqserver2008实例时，必须确保
1，每个使用awe内存的实例均设置了服务器最大内存
2，设置服务器最大内存时，必须考虑sqlserver操作所需要的非缓冲池内存
3，所有实例 的服务器最大内存的总和应该小于计算机物理内存的总数。

如果使用/3GB特性和AEW,那么一个sqlserver实例将被限制在最大16GB的扩展内存，这是因为windowserver操作系统的
内部设计，使用/3GB开关将进程空间中的系统空间限制为1GB,允许window Server管理最多16GB的物理内存。

*/