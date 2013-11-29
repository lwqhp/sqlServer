

--执行计划的取舍

/*
执行计划的查看有两种方式：SSMS中开关设置和SQL Trace 跟踪

执行计划运行模式
a,在SQL语句执行前返回：Sqlserver在语句编译好或者找到可重用的执行计划后，就输出它，语句本身不会被执行。
	SET SHOWPLAN_ALL ON
	SET showplan_xml ON --和菜单上“显示预估的执行计划” 一样
	
	Event -> Performance -> showplan all
	Event -> Performance -> showplan xml statistcs profile

b,在SQL语句执行后返回：除了预估每一步返回行数，还返回实际每一步的返回行数，会占用一定的性能，如果语句没做完就
	被用户停止掉了，不会得到执行计划输出。
	SET STATISTICS PROFILE ON 
	
	Event -> Performance -> showplan statistics profile

对比：
1，有些信息，比如是不是reuse了一个执行计划，sql server有没有觉得缺少索引，只能在xml的输出里看到。	
2，在生产数据库，包含数据更改的语句，只能使用执行前返回，得到一个预估的执行计划。
*/

