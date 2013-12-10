

--玩转sql profiler 跟踪
/*
sql Profiler主要还是用于语句的跟踪，他也可以用物资源和错误的跟踪。

Profiler模板，定义自己常用的模板，但前期每个手工建

输出：有到文件和到数据库

时间：控制输出时间段

使用每一种方法，熟知每一个事件和数据列的作有。

profiler工具捕捉的事件进入内存中的缓冲以便通过网络反馈给GUI，GUI依赖网络，网络流量可能降低系统的速度并异致缓冲
被填满，这将在较小的程序上影禹服务器的性能，进一步地，当缓冲被填满，服务器将开始丢弃事件以避免严重地影禹服务器性能。

1，定义跟踪脚本
2，存储过程捕捉跟踪

*/
SELECT * FROM ::fn_trace_getinfo(default);
EXEC sp_trace_setstatus 1,0;
EXEC sp_trace_setstatus 1,2;--跟踪关闭并且从服务器中删除

/*
导入性能数据的同时，可以加入计数器

1，限制事件和数据列
2，丢弃性能分析所用的启动事件
3，限制跟踪输出大小
4，避免在线数据列排序
5，远程运行profiler
6,限制使用某些事件

语句的历史执行信息
select * from dm_exec_query_stats
*/
slect * INTO T FROM ::fn_trace_GETTABLE()

1,开销大
2,执行慢