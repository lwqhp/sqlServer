
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

检查每个进程的cpu使用情况
process : processor time
			privileged time
			user time

2,确定当时sqlserver是否工作正常，看有没有17883/17884之类的问题发生，有没有访问越界(access violation)之类的严重问题发生


3，找出cpu100%的时候sqlserver 里正在运行的最耗cpu资源的语句，对它们进行优化。			

4,降低系统负载，或者升级硬件
*/