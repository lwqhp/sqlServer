
BEGIN
/*作业：
1,按照p462页的说明对每一个事件组练习
2,离线分析SQL Trace文件
3,使用工具分析SQL Trace文件

--系统管理视图跟踪

作业:
1,了解动态视图的每一个字段含议
2,跟踪动态视图
*/
END
--玩转sql profiler 跟踪
/*

http://technet.microsoft.com/zh-cn/library/ms191206.aspx
>>>>>使用每一种方法，熟知每一个事件和数据列的作用。

sql Profiler主要还是用于‘语句’的跟踪，也可以用于‘资源’和‘错误’的跟踪。

Profiler模板，定义自己常用的模板，但前期每个手工建

输出：有到‘文件’和到‘数据库’以及脚本文件

时间：控制输出时间段

数据筛选,分组

-------------------
“启用文件滚动更新”，以便当文件大小达到最大值时自动创建新文件。 
“服务器处理跟踪数据”，由正在运行跟踪的服务而不是客户端应用程序来处理跟踪数据。 
	在服务器处理跟踪数据时，即使是在压力较大的情况下也不会跳过事件，但是服务器性能可能会受到影响。
-------------------
profiler工具捕捉的事件进入内存中的缓冲以便通过网络反馈给GUI，GUI依赖网络，网络流量可能降低系统的速度并异致缓冲
被填满，这将在较小的程序上影禹服务器的性能，进一步地，当缓冲被填满，服务器将开始丢弃事件以避免严重地影禹服务器性能。

1，定义跟踪脚本
服务器端脚本跟踪，占用系统资源更少
1,新建一个跟踪并设置好，然后导出 脚本文件。
2，手动修改一些参数：sp_trace_create 改成服务器上要存放trace文件的地方
EXEC sp_trace_setstatus @TraceID,1; 开始执行
select TraceID=@TraceID 返回trace 编号

3关闭跟踪
EXEC sp_trace_setstatus @TraceID,0;
EXEC sp_trace_setstatus @TraceID,2;--跟踪关闭并且从服务器中删除


2，存储过程捕捉跟踪
SELECT * FROM ::fn_trace_getinfo(default);

导入性能数据的同时，可以加入计数器

1，限制事件和数据列
2，丢弃性能分析所用的启动事件
3，限制跟踪输出大小
4，避免在线数据列排序
5，远程运行profiler
6,限制使用某些事件


*/
--把trace文件里的记录像一张表格一样查询出来
select * INTO T FROM ::fn_trace_GETTABLE('dfdf.tc',DEFAULT)

