
/*
系统信息收集

window事件日志

sqlServer作为window的一个应用程序，window系统日志会记录sqlserver这个服务的启动，正常关闭，异常关闭等信息。
应用程序日志记录sqlServer一些概要信息。

所以，window事件日志是一个很好的界定问题性质的工具，当管理员要对sqlserver做健康检查时，首先要检查window事件日志，
当确定window日志里没有明显的错误和警告后，再去看sqlserver日志.

window主要有三种日志:应用程序(application),安全(security) , 系统(system)

window日志能反映的sql事件
应用程序:	
	1)sqlServer服务的启动，关闭信息
	2)连接的协议,启动参数
系统：服务的状态信息

命令：eventvwr.msc
保存日志到文件 *.evt ,*.txt


作业：
1，另存事件到文件，并在事件组件中打开。
2,日志导入到数据库中

-----SqlServer ErrorLog日志
检查sqlServer,建议第一个要检查sqlservr日志

日志文件默认放在安装路径下的\log子目录，或者在sqlserver服务的高级属性里的“启动参数” -e的参数

sql日志除了常规的开启，运行，终止记录信息外，当遇到了比较严重的问题，会在errorlog里有所显示。
errorlog文件里会记录的内容有
1,sqlServer的版本，以及window和Processor基本信息。
2，sqlserver的启动参数，以及认证模式，内存分配模式。
3，每个数据库是否能够被正常打开。
4，数据库损坏相关的错误。
5，数据库备份与恢复动作记录。
6，dbcc checkdb记录
7，内存相关的错误和警告。
8，sqlserver调度出现异常时的警告。
9，sqlserver I/O操作遇到长时间延迟的警告。
10，sqlserver在运行过程中遇到的其它级别比较高的错误。
11，sqlserver内部的访问越界错误。
12，sqlserver服务关闭时间。

作业
1,用文本打开日志文件
2,把日志文件导入数据库
3,分析日志的每一条记录，保证日志的干净.

---性能监视器
命令：perfmon.exe

监视包括:
性能计数器，事件跟踪数据，系统配置配置信息,性能计数器警报

一般的sqlServer问题，可以选择下面这些对象
1,memory,process,physicaldisk,processor,system
2,所有以"SqlServer"开头的性能监视对象
3,如果要监视CPU类问题，最好还包含"Thread" 下面的所有计数器，以及它所有的instance


作业：
1，日志保存到文件,间隔15秒,设置文件大小200M和路径,时间段


--SQL Trace-

作业：
1,按照p462页的说明对每一个事件组练习
2,离线分析SQL Trace文件
3,使用工具分析SQL Trace文件

--系统管理视图跟踪

作业:
1,了解动态视图的每一个字段含议
2,跟踪动态视图
*/