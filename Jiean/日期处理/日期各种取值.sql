

--日期
--利用系统默认1900-01-01，通过月份的差减，而得到当月1号,时间是00.减-3毫秒，可以得到上个月最后一天最后秒

SELECT DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)
SELECT DATEADD(ms,-3,DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0))

SELECT DATEADD(dd,DATEDIFF(dd,0,getdate()), 0)
--获取本月的第一天，然后加一个月，然后用下一个月的第一天减去1天即可。
select dateAdd(month,1,dateAdd(day,1-datepart(day,GETDATE()),GETDATE()))-1
SELECT DATEADD(day,1-datepart(day,GETDATE()),GETDATE())-1