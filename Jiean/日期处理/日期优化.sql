

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
	
--年月是分开保存的 preyear,premonth
--合并成201308

SELECT * FROM #dateList  WHERE '201308'=billdate