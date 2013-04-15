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
