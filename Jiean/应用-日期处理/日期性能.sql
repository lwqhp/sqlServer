/*
一般在日期处理上出现的性能效率问题：
1）索引失效：缺少索引或索引用不上
2）循环生成日期区间：大部份的问题都可以改为以其他非循环方式解决
3)数据类型误用，字符型和日期类型间出现隐式转换，字符型不能直接应用系统的日期函数。

a.相同的日期类型或同一类日期类型间比较不用类型转换，不同的数据类型比较会有类型转换

b.日期格式是固定长度的，所以在转换成字符型时用char

常见的性能低下查询
1,采用时间差函数datediff计算日期差值再做比较
2,采用转换函数convert 转换字段后再比较
3,采用时间函数把日期折成年，月，日后再比较

*/

--日期类型转换
/*
dateadd返回的是smalldatetime格式
保存到datetime类型变量中，全部保存，没有转换
保存到smallDatetime类型变量中，因sdt只精确到分钟，会对秒部份作四舍五入处理
保存到字符类型中，没有显示的类型转换的话，sql会按系统默认日期格式隐式转成字符，比如这样：02 28 2014 11:59PM
*/
declare @dt datetime,@dt1 smalldatetime,@dt2 varchar(30)

 SELECT @dt=DATEADD(ms,-3,DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)),
	@dt1=DATEADD(ms,-3,DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)),
	@dt2=DATEADD(ms,-3,DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0))
select @dt,@dt1,@dt2


--日期转成数字
/*将一个数字转成日期，本质是在系统默认时间(1900-01-01)加上数字天数。
同理，取日期的天数也可用数字来表示日期。*/
declare @dt datetime
set @dt = datediff(day,0,getdate())
select  @dt

select datediff(day,0,getdate())

select datepart(minute,getdate())

select datename(minute,getdate())

--低效率日期处理
/*在查询字段上作了计算，意味着必须对每条记录的查询字段做计算，并判断计算结果的值是否与第件匹配*/

--查询当日的数据
where datediff(day,datefield,getdate())=0

--查询最近分钟的记录
where datediff(minute,datefield,getdate()) between 0 and 5

--查询指定年月的数据
where year(datefield) = 2009 and month(datefield) =4
where convert(varchar(6),datefield,112) = '200904'

--查询指定时间段内的记录
where convert(varchar(8),datefield,112) between '20050505' and '20090909'

/*优化的查询*/

--查询当日的数据
where datefields >= convert(varchar(10),getdate(),120) 
and datefields < convert(varchar(10),getdate()+1,120)
--查询最近分钟的记录
where datefields between dateadd(minute,-5,getdate()) and getdate() 
--查询指定年月的数据
where datefields >='20050505' and datefields <'20090909'
--查询指定时间段内的记录
where datefields >='20050505' and datefields <'20090909'


/*
日期类型比字符类型的日期更具有处理优势，不要把日期转成字符类型后再作比较
下面的两种格式都可和日期类型比较，生成的执行计划一样一样的。
*/

CREATE TABLE #tmp(
t1 DATETIME
)

INSERT INTO #tmp
VALUES('2014-01-01 23:50:50.934'),('2014-01-02 23:50:50.934'),('2014-01-03')

SET STATISTICS PROFILE ON 
SELECT * FROM #tmp
WHERE t1>=CAST(2014*10000+1*100+1 AS CHAR(8)) AND t1<=CAST(2014*10000+1*100+2 AS CHAR(8))
SET STATISTICS PROFILE OFF 


SET STATISTICS PROFILE ON 
SELECT * FROM #tmp
WHERE t1>='20140101' AND t1<='20140102'
SET STATISTICS PROFILE OFF 