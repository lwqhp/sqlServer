
--分析cpu的使用率
/*
sqlServer会使用cpu的地方
1，编译和重编译

2，排序和聚合计算

3，表格连接join操作

和cpu额关的设置（sp_configure）
1,priority boost
sqlserver进程在window上的优先级，如果设成1,sqlserver 进程会以较高的优先级创建，从而使之在windows进程调度里被优先运行。

2，affinity mask
设置 sqlserver固定使用某几个cpu

3,lightweight pooling 
设置sqlserver是否要使用纤程技术

4，max degree of parallelism
定义sqlserver最多用多少个线程来并行执行一条指令

5，cost threshold of parallelism
由它的值来决定语句的复杂度

6，max worker threads
定义sqlserver进程最多线程数。


检查整个服务器cpu使用情况
processor : processor time
			privileged tme
			user time
system : processor queue length
context switches/sec
Batch Requests/sec
SQL Compilations/sec
SQL Recompilations/sec

processor Queue Length :处理器队列长度，是处理器队列中的线程数量，即使计算机有多个处理器，也只有一个处理器
队列，计数器只记录没有运行的线程，如果持续大于2,一般表示一个处理器拥塞。

context Switches/sec : 每秒上下文切换数，，计数器监视计算机上的所有处理器从一个线程切换到另一个的综合速率。
上下文切换发生在运行中的线程由于被更高优先级的就绪线程抢先而自动释放处理器时，或者从用户模式切换到核心模
式以使用一个执行程序或子系统服务时，这是以切换数量度量的，在计臬机所有处理器上运行的所有线程的总和 
合理范围 是每个处理器300-1000，由于内存短缺引起的页面错误可能引起不正常的高值>20000

batch requests/sec :每秒批请求数，它直接与处理器上的负载相关，每秒1000个请求应该被考虑为繁忙的系统。了解该
值对于系统所代表的意义的最佳方法是建立一个基线，然后进行监视。

Sql Compilations/sec : 每秒sql编译数，计数器显示了批编译和语句重编译的总和，这是一个自服务器启动以来的总和
每秒100或更多的编译将显地表示处理器的问题

sql Recompilations/sec 每秒sql重编译数，是批和语句重编译数量的一个度量，大量的重编译将公导致处理器压力

检查每个进程的cpu使用情况
process : processor time
			privileged time
			user time

processor Time 不应该保持高值>75%,如果processorTime较高，而磁盘和网络计数器值较低，首先要做的肯定是降低处
理器上的压力，如果 磁盘diskTime 50%,那么很可能处理器时间主要花费在管理磁盘活动。这将会反映在privilegedtime
计数器上，在这种情况下，优化磁盘瓶颈更有利，再进一步，磁盘瓶颈可能是由于内存瓶颈。

在windowServer上处理以两种模式完成：用户模式和核心模式，所有系统级活动，包括磁盘访问，均在核心模式中完成，
如果发现在一个专用的sqlserver系统上的privileged Time（核心时间百分比）为20%以上，那么系统可能正在进行大量
的io,可能超过所需要的，正常不应该超过5%-10% 

2,确定当时sqlserver是否工作正常，看有没有17883/17884之类的问题发生，有没有访问越界(access violation)之类的严重问题发生


3，找出cpu100%的时候sqlserver 里正在运行的最耗cpu资源的语句，对它们进行优化。			

4,降低系统负载，或者升级硬件
*/