


----(1)年的第一天或最后一天-----------------------------------------------------------------------------

/*该年的第一天或最后一天
一年的第一个月第一天和最后一个月最后一天都是固定的，取年份拼接即可
*/
--A. 年的第一天
SELECT CONVERT(char(5),getdate(),120)+'1-1'

--B. 年的最后一天
SELECT CONVERT(char(5),getdate(),120)+'12-31'


--(2)季度的第一天和最后一天------------------------------------------------------------------------
/*
一年有4个季度，一个季度3个月,datepart的quarter可返回日期所处的季度
季度数*3得到所在季度的最后一个月份,减去2则就是月季的第一个月了
第一个月份减去当前月份得到当前月份离第一个月份的偏移量
同理，最后一个月份减去当前月份得到当前月份离最后一个月的偏移量
*/
--A. 季度的第一天
SELECT CONVERT(datetime,
	CONVERT(char(8),
		DATEADD(Month,
			DATEPART(Quarter,getdate())*3-Month(getdate())-2,
			getdate()),
		120)+'1')

--B. 季度的最后一天（CASE判断法）
SELECT CONVERT(datetime,
	CONVERT(char(8),
		DATEADD(Month,
			DATEPART(Quarter,getdate())*3-Month(getdate()),
			getdate()),
		120)
	+CASE WHEN DATEPART(Quarter,getdate()) in(1,4)
		THEN '31'ELSE '30' END)

--C. 季度的最后一天（直接推算法）
SELECT DATEADD(Day,-1,
	CONVERT(char(8),
		DATEADD(Month,
			1+DATEPART(Quarter,getdate())*3-Month(getdate()),
			getdate()),
		120)+'1')


----(3)月份的第一天或最后一天-------------------------------------------------------------
/*利用系统默认1900-01-01，通过月份的减加(因为忽略日期部份)，而得到当月1号,时间是00.减-3毫秒，
可以得到上个月最后一天最后秒*/

--A. 月的第一天
SELECT CONVERT(datetime,CONVERT(char(8),getdate(),120)+'1')
SELECT DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)

--B. 月的最后一天
SELECT DATEADD(Day,-1,CONVERT(char(8),DATEADD(Month,1,getdate()),120)+'1')
select dateadd(mm,datediff(mm,-1,getdate()),-1)

--C. 月的最后一天（容易使用的错误方法）
SELECT DATEADD(Month,1,DATEADD(Day,-DAY(getdate()),getdate()))


--4．指定日期所在周的任意一天
SELECT DATEADD(Day,3-DATEPART(Weekday,getdate()),getdate())



IF object_id('tempdb..#dateList') IS NOT NULL DROP TABLE #dateList
CREATE TABLE #dateList(billdate DATETIME)
go
INSERT INTO #dateList
SELECT '2013-08-31' UNION ALL
SELECT '2013-08-01' UNION ALL 
SELECT '2013-08-08' UNION ALL 
SELECT '2013-08-12' UNION ALL 
SELECT '2013-07-21' UNION ALL 
SELECT '2013-07-05' UNION ALL 
SELECT '2012-08-01' UNION ALL 
SELECT '2012-08-31' UNION ALL 
SELECT '2013-05-03' UNION ALL 
SELECT '2013-05-04' 

--当月份
DECLARE @startdate varchar(30)
SET @startdate ='2013-08-15 23:36:34'

SELECT DATEADD(month,DATEDIFF(month,-1,dateadd(year,-1,@startdate)),0)
SELECT * FROM #dateList 
WHERE billdate >= DATEADD(month,DATEDIFF(month,0,@startdate),0)
	AND billdate < DATEADD(month,DATEDIFF(month,-1,@startdate),0)
	
--去年同月
SELECT * FROM #dateList 
WHERE billdate >= DATEADD(month,DATEDIFF(month,0,dateadd(year,-1,@startdate)),0)
	AND billdate < DATEADD(month,DATEDIFF(month,-1,dateadd(year,-1,@startdate)),0)

--(4)周的计算----------------------------------------------------------------------------------
select @@datefirst
SET DATEFIRST 7 --查看，设置周的第一天是星期几
select datepart(weekday,getdate()) --返回日期所在周的第几天
select datepart(week,getdate()) --返回日期所在年的第几周
/*
一周的第一天星期几是根据数据库设定而,默认是星期天作为一周的开始,@@datefirst=7
datepart(weekday,getdate())返回日期所在周的第几天
一周固定是7天，7-日期所在周的天数，等于日期离周最后一天的偏移量
*/

--根据当前日期与周最后一天的偏移量，生成周区间表
with tmp as(
	select 1 as dwnum,getdate() as startDate,dateadd(day,7-datepart(weekday,getdate()),getdate()) as endDate
	union all
	select a.dwnum+1 as dwnum,dateadd(day,1,a.enddate),dateadd(day,7,a.enddate) 
	from tmp a where a.startDate<='2014-03-05' 
)
select * from tmp


/*
查询给定日期是当月的第几周

跟一周的开始是周日还是周一，不影响
*/
--查询日期所在月的第几周:本年日期的第几周-给定日期所在月第一天是本年的第几周
declare @date datetime;
set @date = getdate()

select datepart(week,@date) --日期是当年的第几周
	-datepart(week,dateadd(month,datediff(month,0,@date),0))--给定日期所在月第一天是本年的第几周
	+1 
select datepart(week,@date)
	-datepart(week,dateadd(day,1-datepart(day,@date),@date))
	+1 

-- 查询日期所在周的第一天
SELECT	@date_begin = DATEADD(Day, - (DATEPART(Weekday, @Date) + @@DATEFIRST - 2) % 7, @Date),
	@Date = DATEADD(Week, 1, @date_begin),
	@date_begin_previous = DATEADD(Week, - 1, @date_begin)

---(5)天的最后一个时间点--------------------------------------------------------------
SELECT DATEADD(ms,-3,DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0))
SELECT DATEADD(dd,DATEDIFF(dd,0,getdate()), 0)

-- 去掉日期中的时间部分
SET @Date = DATEDIFF(Day, 0, ISNULL(@Date, GETDATE()))