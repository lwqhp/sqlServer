
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

--由于直接提供的日期均是以日期格式的字符串提供，所以在使用convert进行日期格式转换时，
--要先把日期格式的字符串转换为日期型，然后才能利用convert进行日期格式转换。
CONVERT(data_type,expression,style)
cast(expression)

--取日期部份
select year(getdate())
select Month(getdate())
select day(getdate())

--返回日期指定部份
/*
DATENAME(datepart,date)--返回nvarchar,与 SET DATEFIRST 和 SET DATELANGUAGE选项的设置有关。
DATEPART(datepart,date)--返回int
DATEPART(weekday,date)--返回星期计算方式，以星期日为一周的第一天，与SET DATEFIRST选项有关
year(date)--返回int
month(date)--返回int
day(date)--返回int
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
select dateAdd(day,2,getdate())

--日期差值计算函数:计算两个给定日期指定部分的边界数
SELECT DATEDIFF(datepart,startdate,enddate)--返回integer

--取日期范围
 between '2010-9-9' and '2012-9-9'


 ---日期格式化------------------------------------------------------------------------------
 
--短日期格式： yyyy-m-d
select replace(CONVERT(nvarchar(10),getdate(),120),N'-0','-')

--长日期格式：yyyy年mm月dd日[stuff删除指定长度的字符并在指定的起始点插入另一组字符]
SELECT stuff(stuff(CONVERT(char(8),getdate(),112),5,0,N'年'),8,0,N'月')+N'日'
SELECT datename(year,getdate())+N'年'+datename(month,getdate())+N'月'+datename(day,getdate())+N'日'--set language设置对此方法有影响

--长日期格式：yyyy年m月d日
SELECT datename(year,getdate())+N'年'+cast(datepart(month,getdate()) as varchar)+N'月'+datename(day,getdate())+N'日'

--完整日期+时间格式：yyyy-mm-dd hh:mi:ss:mmm [了解convert的样式即可]
SELECT CONVERT(char(11),getdate(),120) + CONVERT(char(12),getdate(),114)
