
/*
查询考虑
1,是否跨年段，如果有跨年，则分段，先查询开始日期到12-31日止的，另一段是1-1日起，到结束日期
2,2月份29日只在闰年存在，平年时，一般视为28号生日，解决这个问题的方法是把出生日期切换到查询起止日间段所在的年份。dateadd(year,1,'20080929')结果：2009-2-28
*/

--测试数据
DECLARE @t TABLE(
	ID int,Name varchar(10),
	Birthday datetime)
INSERT @t SELECT 1,'aa','1999-01-01'
UNION ALL SELECT 2,'bb','1996-02-29'
UNION ALL SELECT 3,'bb','1934-03-01'
UNION ALL SELECT 4,'bb','1966-04-01'
UNION ALL SELECT 5,'bb','1997-05-01'
UNION ALL SELECT 6,'bb','1922-11-21'
UNION ALL SELECT 7,'bb','1989-12-11'

--查询 2003-12-05 至 2004-02-28 生日的记录
DECLARE 
	@date_start datetime,
	@date_stop datetime
SELECT 
	@date_start = '2003-12-05',
	@date_stop = '2004-02-28'

SELECT * FROM @t
WHERE DATEADD(Year, DATEDIFF(Year, Birthday, @date_start), Birthday)--把日期年份调到指定开始日期的年份
		BETWEEN @date_start 
				AND CASE 
						WHEN DATEDIFF(Year, @date_start, @date_stop) = 0 THEN @date_stop--不跨年
						ELSE DATEADD(Year, DATEDIFF(Year, '19001231', @date_start), '19001231')--跨年
					END
	OR DATEADD(Year, DATEDIFF(Year, Birthday, @date_stop), Birthday)--把日期年份调到指定结束日期的年份[跨年]
		BETWEEN CASE 
					WHEN DATEDIFF(Year, @date_start, @date_stop) = 0 THEN @date_start
					ELSE DATEADD(Year, DATEDIFF(Year, '19000101', @date_stop), '19000101')
				END
			AND @date_stop


/*--结果
ID         Name       Birthday
---------------- ---------------- --------------------------
1           aa         1999-01-01 00:00:00.000
7           bb         1989-12-11 00:00:00.000
--*/

SELECT @dt1 ='2003-12-05',@dt2 ='2004-02-28'
SELECT * FROM @t
WHERE dateadd(year,datediff(year,birthday,@dt1),birthday)
	BETWEEN @dt1 AND @dt2
OR dateadd(year,datediff(year,birthday,@dt2),birthday)
	BETWEEN @dt1 AND @dt2