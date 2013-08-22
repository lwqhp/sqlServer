


 
 


--日期增减函数
dateadd(datepart,number,date)

--日期信息获取函数:获取日期指定部分
DATENAME(datepart,date)--返回nvarchar,与 SET DATEFIRST 和 SET DATELANGUAGE选项的设置有关。
DATEPART(datepart,date)--返回int
DATEPART(weekday,date)--返回星期计算方式，以星期日为一周的第一天，与SET DATEFIRST选项有关
year(date)--返回int
month(date)--返回int
day(date)--返回int

--日期差值计算函数:计算两个给定日期指定部分的边界数
DATEDIFF(datepart,startdate,enddate)--返回integer

--其它日期函数
getdate()
isdate(expression)
--由于直接提供的日期均是以日期格式的字符串提供，所以在使用convert进行日期格式转换时，要先把日期格式的字符串转换为日期型，然后才能利用convert进行日期格式转换。
CONVERT(data_type,expression,style)
cast(expression)


/*
-----------日期格式化---------------------
*/
--短日期格式： yyyy-m-d
replace(CONVERT(nvarchar(10),getdate(),120),N'-0','-')
--长日期格式：yyyy年mm月dd日[stuff删除指定长度的字符并在指定的起始点插入另一组字符]
stuff(stuff(CONVERT(char(8),getdate(),112),5,0,N'年'),8,0,N'月')+N'日'
datename(year,getdate())+N'年'+datename(month,getdate())+N'月'+datename(day,getdate())+N'日'--set language设置对此方法有影响
--长日期格式：yyyy年m月d日
datename(year,getdate())+N'年'+cast(datepart(month,getdate()) as varchar)+N'月'+datename(day,getdate())+N'日'
--完整日期+时间格式：yyyy-mm-dd hh:mi:ss:mmm [了解convert的样式即可]
CONVERT(char(11),getdate(),120) + CONVERT(char(12),getdate(),114)

/*
--------------日期推算处理----------------------
*/

--指定日期的该年的第一天和最后一天
CONVERT(char(5),getdate(),120) +N'1-1'
CONVERT(char(5),getdate(),120) +N'12-31'

--指定日期所在季度的第一天和最后一天
CONVERT(datetime,
	CONVERT(char(8),
	dateadd(month,
		datepart(quarter,getdate())*3-month(getdate())-2,
		getdate())
	,120)
+'1')
--最后一天
convert(datetime,
	convert(char(8),
	dateadd(month,
		datepart(quarter,getdate())*3-month(getdat()),
		getdate())
	,120)
	+ case when datepart(quarter,getdate()) in(1,4)
	then '31' else '30' end
)
dateadd(day,-1,
	convert(char(8),
	dateadd(month,
		1+datepart(quarter,getdate())*3-month(getdate()),
		getdate())
		,120 )+'1')

--作业，当前日期所在月的第一天和最后一天



--指定日期所在周的任意一天 number 为天
dateadd(day,number-datepart(weekday,getdate()),getdate())
--指定日期所在周的任意星期几
dateadd(day,number-(datepart(weekday,getdate())+@@DATEFIRST-2)%7-1,getdate())


/*
-------日期加减处理----------------------
常用dateadd函数运算。
处理在指定日期中，加上或减去多个日期部分。
思路：最主要的就是把要加减的日期字符分解，然后根据分解的结果在指定日期的对应日期部分加上相应的值。
先定义格式：y-m-d h:m:s.m | -y-m-d h:m:m.m
要加减的日期字符输入方式与日期字符串相同。日期与时间部分用空格分隔，最前面的一字符如果是减号的话，
表示做减法处理，否则做加法处理。如果日期字符只包含数字，则视为日期字符中，仅包含天的信息。

确定了日期字符格式后，处理方法就可以这样确定：获取日期字符的第一个字符。判断处理方式，
然后将要加减的日期字符按空格分析为日期和时间两部分，对于日期部分从低位到高位琢个截取日期数据进行处理，
对于时间从高位到低位琢个处理.
*/

/*
格式：y-m-d h:m:s.m | -y-m-d h:m:m.m
日期默认是天，时间默认是小时，空格分隔日期和时间
*/
CREATE FUNCTION dbo.f_DateADD(
@Date     datetime,
@DateStr   varchar(23)
)RETURNS datetime
AS
BEGIN
 DECLARE @bz int,@s varchar(12),@i int
 IF @DateStr IS NULL OR @Date IS NULL
  OR(CHARINDEX('.',@DateStr)>0
   AND @DateStr NOT LIKE '%[:]%[:]%.%')
   
  RETURN(NULL)
 IF @DateStr='' RETURN(@Date)
 --判断加减,格式化字符串
 SELECT @bz=CASE
   WHEN LEFT(@DateStr,1)='-' THEN -1
   ELSE 1 END,
  @DateStr=CASE
   WHEN LEFT(@Date,1)='-'
   THEN STUFF(RTRIM(LTRIM(@DateStr)),1,1,'')
   ELSE RTRIM(LTRIM(@DateStr)) END
   --有日期部份
 IF CHARINDEX(' ',@DateStr)>1
  OR CHARINDEX('-',@DateStr)>1
  OR(CHARINDEX('.',@DateStr)=0
   AND CHARINDEX(':',@DateStr)=0)
 BEGIN
  SELECT @i=CHARINDEX(' ',@DateStr+' ')
   ,@s=REVERSE(LEFT(@DateStr,@i-1))+'-'
   ,@DateStr=STUFF(@DateStr,1,@i,'')
   ,@i=0
  WHILE @s>'' and @i<3
   SELECT @Date=CASE @i
     WHEN 0 THEN DATEADD(Day,@bz*REVERSE(LEFT(@s,CHARINDEX('-',@s)-1)),@Date)
     WHEN 1 THEN DATEADD(Month,@bz*REVERSE(LEFT(@s,CHARINDEX('-',@s)-1)),@Date)
     WHEN 2 THEN DATEADD(Year,@bz*REVERSE(LEFT(@s,CHARINDEX('-',@s)-1)),@Date)
    END,
    @s=STUFF(@s,1,CHARINDEX('-',@s),''),
    @i=@i+1   
 END
 --有时间部份
 IF @DateStr>''
 BEGIN
  IF CHARINDEX('.',@DateStr)>0
   SELECT @Date=DATEADD(Millisecond
     ,@bz*STUFF(@DateStr,1,CHARINDEX('.',@DateStr),''),
     @Date),
    @DateStr=LEFT(@DateStr,CHARINDEX('.',@DateStr)-1)+':',
    @i=0
  ELSE
   SELECT @DateStr=@DateStr+':',@i=0
  WHILE @DateStr>'' and @i<3
   SELECT @Date=CASE @i
     WHEN 0 THEN DATEADD(Hour,@bz*LEFT(@DateStr,CHARINDEX(':',@DateStr)-1),@Date)
     WHEN 1 THEN DATEADD(Minute,@bz*LEFT(@DateStr,CHARINDEX(':',@DateStr)-1),@Date)
     WHEN 2 THEN DATEADD(Second,@bz*LEFT(@DateStr,CHARINDEX(':',@DateStr)-1),@Date)
    END,
    @DateStr=STUFF(@DateStr,1,CHARINDEX(':',@DateStr),''),
    @i=@i+1
 END
 RETURN(@Date)
END
GO


/*-------计算年龄--------------

将出生日期的年份增加到与当前日期相同，然后再与当前日期比较，如果是大于，
则年龄为当前日期减去出生日期的结果再减一年，否则是两个日期直接相减

作业：工龄计算
*/

datediff(year,'1999-09-09',getdate())
	-CASE WHEN
	dateadd(year,datediff(year,'1999-09-09',getdate()),'1999-09-09')>getdate()
	THEN 1 ELSE 0 END 


/*
查询指定时间段内过生日的人
思路：将出生日期的年份转换到开始日期后，出生日期在开始日期和结束日期的记录.
将出生日期的年份转换到结束日期后，出生日期在开始日期和结束日期的记录
*/
SELECT @dt1 ='2003-12-05',@dt2 ='2004-02-28'
SELECT * FROM @t
WHERE dateadd(year,datediff(year,birthday,@dt1),birthday)
	BETWEEN @dt1 AND @dt2
OR dateadd(year,datediff(year,birthday,@dt2),birthday)
	BETWEEN @dt1 AND @dt2
	
	
/*
--生成日期列表-------------
生成指定年份的工作日/休息日列表

*/
CREATE FUNCTION dbo.f_getdate(
@year int,    --要查询的年份
@bz bit       --@bz=0 查询工作日,@bz=1 查询休息日,@bz IS NULL 查询全部日期
)RETURNS @re TABLE(id int identity(1,1),Date datetime,Weekday nvarchar(3))
AS
BEGIN
    DECLARE @tb TABLE(ID int IDENTITY(0,1),Date datetime)
    INSERT INTO @tb(Date) SELECT TOP 366 DATEADD(Year,@YEAR-1900,'1900-1-1')
    FROM sysobjects a ,sysobjects b
    UPDATE @tb SET Date=DATEADD(DAY,id,Date)
    DELETE FROM @tb WHERE Date>DATEADD(Year,@YEAR-1900,'1900-12-31')
    
    IF @bz=0
        INSERT INTO @re(Date,Weekday)
        SELECT Date,DATENAME(Weekday,Date)
        FROM @tb
        WHERE (DATEPART(Weekday,Date)+@@DATEFIRST-1)%7 BETWEEN 1 AND 5
    ELSE IF @bz=1
        INSERT INTO @re(Date,Weekday)
        SELECT Date,DATENAME(Weekday,Date)
        FROM @tb
        WHERE (DATEPART(Weekday,Date)+@@DATEFIRST-1)%7 IN (0,6)
    ELSE
        INSERT INTO @re(Date,Weekday)
        SELECT Date,DATENAME(Weekday,Date)
        FROM @tb
        
    RETURN
END
GO

/*
--生成列表-----------
    生成指定日期段的日期列表
*/

CREATE FUNCTION dbo.f_getdate(
@begin_date Datetime,  --要查询的开始日期
@end_date Datetime,    --要查询的结束日期
@bz bit                --@bz=0 查询工作日,@bz=1 查询休息日,@bz IS NULL 查询全部日期
)RETURNS @re TABLE(id int identity(1,1),Date datetime,Weekday nvarchar(3))
AS
BEGIN
    DECLARE @tb TABLE(ID int IDENTITY(0,1),a bit)
    INSERT INTO @tb(a) SELECT TOP 366 0
    FROM sysobjects a ,sysobjects b
    
    IF @bz=0
        WHILE @begin_date<=@end_date
        BEGIN
            INSERT INTO @re(Date,Weekday)
            SELECT Date,DATENAME(Weekday,Date)
            FROM(
                SELECT Date=DATEADD(Day,ID,@begin_date)
                FROM @tb                
            )a WHERE Date<=@end_date
                AND (DATEPART(Weekday,Date)+@@DATEFIRST-1)%7 BETWEEN 1 AND 5
            SET @begin_date=DATEADD(Day,366,@begin_date)
        END
    ELSE IF @bz=1
        WHILE @begin_date<=@end_date
        BEGIN
            INSERT INTO @re(Date,Weekday)
            SELECT Date,DATENAME(Weekday,Date)
            FROM(
                SELECT Date=DATEADD(Day,ID,@begin_date)
                FROM @tb                
            )a WHERE Date<=@end_date
                AND (DATEPART(Weekday,Date)+@@DATEFIRST-1)%7 in(0,6)
            SET @begin_date=DATEADD(Day,366,@begin_date)
        END
    ELSE
        WHILE @begin_date<=@end_date
        BEGIN
            INSERT INTO @re(Date,Weekday)
            SELECT Date,DATENAME(Weekday,Date)
            FROM(
                SELECT Date=DATEADD(Day,ID,@begin_date)
                FROM @tb                
            )a WHERE Date<=@end_date
            SET @begin_date=DATEADD(Day,366,@begin_date)
        END
    RETURN
END
GO

select @@DATEFIRST

set datefirst 1

---给一个日期,生成本周的日期列表:
declare @date datetime
set @date=getdate()
select @date+1-datepart(dw,@date) --取指定日期所在周的星期一,默认星期日是一周的第一天

select dateadd(dd,a.number,DATEADD(Day,1-(DATEPART(Weekday,GETDATE())+@@DATEFIRST-2)%7-1,GETDATE()))
from master..spt_values a
where type='p'
    and number<=6


declare @d datetime
set @d = getdate()
select dateadd(d,n,@d) as t
from (select -1 as n union all select -2 union all select -3 union all select -4 union all select -5 union all select -6 union all
      select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 0) t
where datepart(wk,@d)=datepart(wk,dateadd(d,n,@d)) 


DECLARE @dt datetime
SET @dt=GETDATE()
 
DECLARE @number int
SET @number=3 --指定星期几
--指定日期所在周的任意星期几
--A.  星期天做为一周的第1天
SELECT DATEADD(Day,1-(DATEPART(Weekday,GETDATE())+@@DATEFIRST-1)%7,GETDATE())
 
--B.  星期一做为一周的第1天
SELECT DATEADD(Day,1-(DATEPART(Weekday,GETDATE())+@@DATEFIRST-2)%7-1,GETDATE())
/*
生成月份列表
实现统计每个月份的money合计，对于没有数据的月份，显示为0，在统计中，为了补齐缺少的月份，使用select
配合union all语句构造一个包含1-12共12条记录的虚拟表
*/
select @@datefirst
set datefirst 1

/*
查询给定日期是当月的第几周
给定日期是当年的第几周-给定日期所在月第一天是当年的第几周
跟一周的开始是周日还是周一，不影响
*/
declare @date datetime;
set @date = getdate()

select datepart(week,@date)-datepart(week,dateadd(month,datediff(month,0,@date),0))+1 
select datepart(week,@date)-datepart(week,dateadd(day,1-datepart(day,@date),@date))+1 

SELECT a.[month],[month]=isnull(b.[monty],0)
FROM (
	SELECT [month] =1 UNION ALL
	SELECT [month] =2 )a
	LEFT JOIN (
		SELECT [month]=month(date),[month] = sum([month])
		FROM @t
		GROUP BY month(date)
		)b ON a.[month] = b.[month]