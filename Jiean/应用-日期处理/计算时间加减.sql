if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[f_DateADD]') and xtype in (N'FN', N'IF', N'TF'))
	drop function [dbo].[f_DateADD]
GO

/*--特殊日期加减函数

	对于日期指定部分的加减，使用DATEADD函数就可以轻松实现。
	在实际的处理中，还有一种比较另类的日期加减处理
	就是在指定的日期中，加上（或者减去）多个日期部分
	比如将2005年3月11日，加上1年3个月11天2小时。
	对于这种日期的加减处理，DATEADD函数的力量就显得有点不够。

	本函数实现这样格式的日期字符串加减处理：
	y-m-d h:m:s.m | -y-m-d h:m:s.m
	说明：
	y-年,m-月,d-日 h-小时,m-分钟,s-秒,m-毫秒
	要加减的日期字符输入方式与日期字符串相同。日期与时间部分用空格分隔
	最前面一个字符如果是减号（-）的话，表示做减法处理，否则做加法处理。
	如果日期字符只包含数字，则视为日期字符中，仅包含天的信息。
--*/

/*--调用示例

	SELECT dbo.f_DateADD(GETDATE(),'11:10')
--*/
CREATE FUNCTION dbo.f_DateADD(
	@Date	datetime,      -- 日期
	@DateStr varchar(23)   -- 在 @Date 基础上要增加或者减少的多部分日期字符串
                           -- 要求的格式: y-m-d h:m:s.m | -y-m-d h:m:s.m
)RETURNS datetime
AS
BEGIN
	DECLARE
		@bz int,
		@temp_str varchar(12),
		@pos int

	-- 判断参数是否符合要求
	IF @DateStr IS NULL 
			OR @Date IS NULL 
			OR(
				CHARINDEX('.', @DateStr) > 0 AND @DateStr NOT LIKE '%[:]%[:]%.%')
		RETURN(NULL)

	IF @DateStr = ''
		RETURN(@Date)

	SELECT 
		@DateStr = LTRIM(RTRIM(@DateStr)),  -- 去掉首尾空格
		@bz = CASE                          -- 设置加减标志
				WHEN LEFT(@DateStr,1) = '-' THEN - 1
				ELSE 1 
			END,
		@DateStr = CASE                      -- 去掉日期字符串中的加减标志位
				WHEN @DateStr LIKE '[+-]%' THEN STUFF(@DateStr, 1, 1, '')
				ELSE @DateStr
			END

	-- 处理日期部分的加(或者减)
	IF PATINDEX('%[- ]%', @DateStr) > 1
		OR PATINDEX('%[.:]%', @DateStr) = 0
	BEGIN
		SELECT
			@pos = CHARINDEX(' ', @DateStr + ' '),
			-- 取日期部分, 并转换为四部分对象名称格式, 以便使用 PARSENAME 取得各部分值
			@temp_str = REPLACE(LEFT(@DateStr, @pos - 1), '-', '.'),
			@DateStr = STUFF(@DateStr, 1, @pos, ''),
			-- 加日期部分: 日-月-年
			@Date = DATEADD(Day, ISNULL(@bz * CONVERT(int, PARSENAME(@temp_str, 1)), 0), @Date),
			@Date = DATEADD(Month, ISNULL(@bz * CONVERT(int, PARSENAME(@temp_str, 2)), 0), @Date),
			@Date = DATEADD(Year, ISNULL(@bz * CONVERT(int, PARSENAME(@temp_str, 3)), 0), @Date)
	END

	-- 处理时间部分的加(或者减)
	IF @DateStr > ''
	BEGIN
		SELECT
			-- 将时间部分转换为四部分对象名称格式, 以便使用 PARSENAME 取得各部分值
			@temp_str = REPLACE(@DateStr, ':', '.'),
			-- 加时间部分: 毫秒-秒-分钟-小时
			@Date = DATEADD(Millisecond, ISNULL(@bz * CONVERT(int, PARSENAME(@temp_str, 1)), 0), @Date),
			@Date = DATEADD(Second, ISNULL(@bz * CONVERT(int, PARSENAME(@temp_str, 2)), 0), @Date),
			@Date = DATEADD(Minute, ISNULL(@bz * CONVERT(int, PARSENAME(@temp_str, 3)), 0), @Date),
			@Date = DATEADD(Hour, ISNULL(@bz * CONVERT(int, PARSENAME(@temp_str, 4)), 0), @Date)
	END

	RETURN(@Date)
END
GO



/*
-------日期加减处理----------------------------------------------------------------------
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

