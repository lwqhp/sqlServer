
/*日期信息*/
/*
 SQL Server 中的日期类型包括datetime 和smalldatetime，仅能处理可以识别为 1753年--9999年间的日期的值，没有单独的日期型或时间型。
 
 datetime:类型处理从1753年1月1日-9999年12月31日的日期和时间数据，精确度为百分之三秒。
			存储长度为8字节，日期和时间各用4个字节存储。
 smalldatetime:类型处理从1900年1月1日-2079年6月6日的时期和时间数据。精确到分钟。
			存储长度为4字节。
			
SqlServer语言环境对日期格式的影响

SET LANGUAGE 指定SqlServer语言
SET DATEFIRST {number | @number_var} 设置一周的第一天是星期几，对所有用户均有效。
	1~表示一周的第一天是星期一，7~表示一周的第一天对应为星期日。
*/

--取当前日期
SELECT getdate()

--输入表达式是否为有效日期
isdate(expression)

--取日期部份
select year(getdate())
select Month(getdate())
select day(getdate())

--返回日期指定部份
/*
	datepart 函数返回 int 型
	datename 函数返回 nvarchar 型
*/
select datename(year,getdate())
select datename(month,getdate())--'01'

select datepart(year,getdate())
select datepart(month,getdate())--1

select datepart(minute,getdate())
/*
	year 	yy, yyyy
	quarter 	qq, q 季度
	month 	mm, m
	dayofyear 	dy, y
	day 	dd, d
	week 	wk, ww 自年初开邕的第几个星期
	weekday 	dw 星期几
	Hour 	hh
	minute 	mi, n
	second 	ss, s
	millisecond 	ms 毫秒
*/


/*-------------------日期运算------------------*/

--日期增减函数
select dateAdd(day,+2,getdate())

--两个日期间的差值
select dateDiff(day,getdate(),'2012-2-1')

--取日期范围
 between '2010-9-9' and '2012-9-9'


 -------==========================================================================================
 
--日期
--利用系统默认1900-01-01，通过月份的差减，而得到当月1号,时间是00.减-3毫秒，可以得到上个月最后一天最后秒

SELECT DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)
SELECT DATEADD(ms,-3,DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0))
select dateadd(mm,datediff(mm,-1,getdate()),-1)

SELECT DATEADD(dd,DATEDIFF(dd,0,getdate()), 0)
--获取本月的第一天，然后加一个月，然后用下一个月的第一天减去1天即可。
select dateAdd(month,1,dateAdd(day,1-datepart(day,GETDATE()),GETDATE()))-1
SELECT DATEADD(day,1-datepart(day,GETDATE()),GETDATE())-1

select dateadd(mm,1,dateadd(day,-day('2013-08-31'),'2013-08-31'))