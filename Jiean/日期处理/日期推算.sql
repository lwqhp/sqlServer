
--根据一个指定的日期，推算出另一个日期点

DECLARE @dt datetime
SET @dt=GETDATE()

DECLARE @number int
SET @number=3

/*----年----*/
--1．该年的第一天或最后一天
--A. 年的第一天
SELECT CONVERT(char(5),@dt,120)+'1-1'

--B. 年的最后一天
SELECT CONVERT(char(5),@dt,120)+'12-31'

/*----季度----*/
--2．指定日期所在季度的第一天或最后一天
--A. 季度的第一天
SELECT CONVERT(datetime,
	CONVERT(char(8),
		DATEADD(Month,
			DATEPART(Quarter,@dt)*3-Month(@dt)-2,
			@dt),
		120)+'1')

--B. 季度的最后一天（CASE判断法）
SELECT CONVERT(datetime,
	CONVERT(char(8),
		DATEADD(Month,
			DATEPART(Quarter,@dt)*3-Month(@dt),
			@dt),
		120)
	+CASE WHEN DATEPART(Quarter,@dt) in(1,4)
		THEN '31'ELSE '30' END)

--C. 季度的最后一天（直接推算法）
SELECT DATEADD(Day,-1,
	CONVERT(char(8),
		DATEADD(Month,
			1+DATEPART(Quarter,@dt)*3-Month(@dt),
			@dt),
		120)+'1')


/*----月份----*/
--3．指定日期所在月份的第一天或最后一天
--A. 月的第一天
SELECT CONVERT(datetime,CONVERT(char(8),@dt,120)+'1')

--B. 月的最后一天
SELECT DATEADD(Day,-1,CONVERT(char(8),DATEADD(Month,1,@dt),120)+'1')

--C. 月的最后一天（容易使用的错误方法）
SELECT DATEADD(Month,1,DATEADD(Day,-DAY(@dt),@dt))


--4．指定日期所在周的任意一天
SELECT DATEADD(Day,@number-DATEPART(Weekday,@dt),@dt)



/*----周----*/

DECLARE @dt datetime
SET @dt=GETDATE()

DECLARE @number int
SET @number=3
--5．指定日期所在周的任意星期几
--A.  星期天做为一周的第1天
SELECT DATEADD(Day,@number-(DATEPART(Weekday,@dt)+@@DATEFIRST-1)%7,@dt)

--B.  星期一做为一周的第1天
SELECT DATEADD(Day,@number-(DATEPART(Weekday,@dt)+@@DATEFIRST-2)%7-1,@dt)
