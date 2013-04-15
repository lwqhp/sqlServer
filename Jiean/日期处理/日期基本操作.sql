
/*日期信息*/

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

