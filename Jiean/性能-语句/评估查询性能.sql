

--捕捉和评估查询的性能
/*
通过sys.dm_exec_requests 视图可以捕捉当前所有在sqlServer实例上执行的查询

通过评估执行计划可以分析查询的性能分布
1,批处理中最高消耗的查询和最高消耗的运算符
2，索引或表扫描(访问堆或索引的所有页面)与使用查找(只访问选定的行)相比较
3，丢失的统计信息或其它警告
4，高消耗排序或计算活动
5，是否有书签查找
6，从运算符传递大量行数到另一运算符
7，隐式数据类型转换

*/
SELECT * FROM sys.dm_exec_requests a
CROSS APPLY sys.dm_exec_sql_text(a.sql_handle) 
WHERE a.status='running'