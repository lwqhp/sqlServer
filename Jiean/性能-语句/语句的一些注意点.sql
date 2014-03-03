

--语句的一些注意点
/*
1,delete不支持直接跟表变量删除，比如
delete from @tb where ....
改成：
 delete from tb
 from @tb as tb where ....
*/

--更新大值数据类型
/*
对于varchar(max),narchar(max),varbinary(max)等大值数据类型，使用update更新，需要对操作进行完全日志记录(会
重写整个字符串)，这对于大值类型来说是非常低效的，用write方法可以只修改字符串中的某一部份，不用重写整个字
符串。
写法
update tb set column.write('要替换的内容',开始位置(0开始)，长度）
null 表示不计算， 0,表示截断
*/

--更新的同时给变量赋值
/*
 这种写法，只扫描一次数据，速度非常快
 update tb set @i = col = @i+1 where ....
*/

--子查询语句
/*相关子查询引用外部查询中的出现的列的子查询，从逻辑上讲，子查询会为外部查贸易的每一行进行一次计算。*/