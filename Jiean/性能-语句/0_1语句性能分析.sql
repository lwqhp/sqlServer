

--语句性能分析
/*
语句的性能主要有三个指标：执行时间(Duration)，逻辑读(reads),cpu时间(time)

cpu时间过高：可能是存储过程重编译，总计函数，数据排序，hash连接。
逻辑读过大：可能返回的数据集太大，表扫描，不准确的执行计划使用了不合理的连接

注意单次执行和多次执行的区别，一个语句，即使单次执行很快，但如果有同时多次执行，用时就是以毫秒来计算了。

使用的工具指令:         实时对语句的运行状态进行记录，对服务器资源有一定的影响
sql Profiler
statistics IO on
statistics time on
statistics profile on

动态视图：              查询历史上语句执行的性能记录
sys.dm_exec_query_stats


*/