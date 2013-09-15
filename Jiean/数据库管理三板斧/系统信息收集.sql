
/*
系统信息收集

window事件日志
命令：eventvwr.msc
保存日志到文件 *.evt ,*.txt

sqlServer作为window的一个应用程序，window系统日志会记录sqlserver这个服务的启动，正常关闭，异常关闭等信息。
应用程序日志记录sqlServer一些概要信息。
所以，window事件日志是一个很好的界定问题性质的工具，当管理员要对sqlserver做健康检查时，首先要检查window事件日志，
当确定window日志里没有明显的错误和警告后，再去看sqlserver日志.

window主要有三种日志:application,security , system


-----SqlServer ErrorLog日志
检查sqlServer,建议第一个要检查sqlservr日志

日志文件默认放在安装路径下的\log子目录，或者在sqlserver服务的高级属性里的“启动参数” -e的参数

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


---性能监视器
命令：perfmon.exe

后台文件收集


----SQL Trace-

--系统管理视图跟踪
*/