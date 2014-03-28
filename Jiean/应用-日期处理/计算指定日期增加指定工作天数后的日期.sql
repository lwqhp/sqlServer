/*
将指定的日期先加上整周的天数，再循环处理乘余的工作天数
--[将指定的日期先加上整周的天数，再循环处理剩余的工作天数即可]
/*这个要求与推算指定日期所在周的任意一天的处理有所不同，推算指定日期所在周的任意一天严格按照
SET DATEFIRST设置的一周的第一天是星期几来推算。例如，根据指定日期推算一周的第2天，如果SET DATEFIRST 7，
推算出的第一天是星期一；如果，SET DATEFIRST 1，那么推算出的将是星期二。

推算出指定日期所在的周的星期几，推算的结果不受SET DATEFIRST设置的影响，即无论SET DATEFIRST的设置如何
，推算指定日期的星期二，推算出的结果应该是固定的。

要推算出指定日期所在周的任意星期几，首先，要把指定日期转换为指定日期所在周的星期日
（如果是按中国的日期处理习惯，则是转换为指定日期所在周的星期一）。在SQL Server中，
没有得到指定日期为星期几这个数字的函数，要得到指定日期为星期几这个数字，
可以使用DATEPART（Weekday,date）函数，配合系统变量@@DATEFIRST来获取。
在SET DATEFIRST 1的时候，星期几和DATEPART（Weekday,Date）得到的结果是一致的，
所以要避免推算出的日期受SET DATEFIRST设置的影响，首先就要将DATEPART（Weekday,date）
的结果换算为SET DATEFIRST 1时的DATEPART（Weekday ,date）值：当SET DATEFIRST 2时，DATEPART（Weekday,date）
把星期二放在了一周的第一天的位置，星期一被向左移了一位，所以DATEPART（Weekday,date）
的结果再加上1就可以把DATEPART（Weekday,date）的结果换算为SET DATEFIRST 1时的结果，
同理SET DATEFIRST 3时，只需要把DATEPART（Weekday,date）的结果加上2，就可以把结果换算为SET DATEFIRST 1时
的DATEPART（Weekday,date）值，而通过@@DATEFIRST可以得到当前SET DATEFIRST设置的值，
所以通过DATEADD（Day,DATEPART（Weekday,date)+@@DATEFIRST,date)可以推算出指定日期前一周的最后一个星期日，
然后再加上要得到的星期几的天数，就是所要的结果。

在这个推算赛程中，还要处理一个问题，一个星期是7天，DATEPART（Weekday，date）的结果始终是1～7，
所以SET DATEFIRST n，并不是把星期n之前的星期向左移，而是做循环移动，所以还要做补位处理，
处理方法是把DATEPART（Weekday,date)+@@DATEFIRST-1的结果MOD 7，这样便得到了指定日期的星期几这个数字。
*/
*/

CREATE FUNCTION dbo.f_WorkDayADD(
	@date    datetime,  --基础日期
	@workday int        --要增加的工作日数(如果为负数,表示减少指定的工作天数)
)RETURNS datetime
AS
BEGIN
	DECLARE 
		@bz int

	--增加整周的天数
	SELECT 
		-- 增加或者减少工作天数的标志
		@bz = CASE WHEN @workday < 0 THEN -1 ELSE 1 END,
		-- 增加(或者减少)整周数
		@date=DATEADD(Week, @workday / 5, @date),
		-- 剩余的非整周的工作天数
		@workday = @workday % 5

	-- 增加(或者减少不是整周的工作天数
	WHILE @workday <> 0 
		SELECT
			@date = DATEADD(Day, @bz, @date),
			@workday = CASE 
						WHEN (@@DATEFIRST + DATEPART(Weekday, @date) - 1) % 7 BETWEEN 1 AND 5
							THEN @workday - @bz
						ELSE @workday 
					END
	--避免处理后的日期停留在非工作日上
	WHILE (@@DATEFIRST+DATEPART(Weekday, @date) - 1) % 7 IN(0, 6) 
		SET @date = DATEADD(Day, @bz, @date)
	RETURN(@date)
END
GO

/*-----有节假日表的处理方法-----------*/

/*将指定日期D直接加上工作天数，得到日期D1，然后计算D到D1这段时间内的节假日天数N，
如果N=0，表示这段时间内都是工作日，那就不需要继续处理，如果N》0，表示少增加了N个工作日，
那就计算D1增加N个工作日后的日期，循环到N为0*/
create table dbo.tb_Holiday(
	HDate	smalldatetime	--节假日期
		PRIMARY key,
	Name	nvarchar(50)	not null	--节假名称
)

create function dbo.f_workDayADD(
	@date	datetime,	--基础日期
	@workday int		--要增加的工作天数
)returns datetime
as
begin
	if @workday >0	--增加
		while @workday >0
			select 
				@date = @date + @workday,
				@workday = count(*)
			from dbo.tb_Holiday
			where Hdate between @date and @date+@workday
	else
		while @workday <0
			select 
				@date = @date + @workday,
				@workday = -count(*)
			from dbo.tb_Holiday
			where Hdate between @date and @date+@workday
	return(@date)
end


