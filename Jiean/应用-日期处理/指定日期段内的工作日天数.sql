/*
首先计算开始日期与结束日期相差的天数，将这个天数除以7后得到的整数再乘以5,就得到指定时间内整周的工作天数，然后计算非整周内的工作日天数
*/

CREATE FUNCTION dbo.f_WorkDay(
	@date_begin datetime,  --计算的开始日期
	@date_end  datetime    --计算的结束日期
)RETURNS int
AS
BEGIN
	DECLARE 
		@weeks int,
		@workday int

	-- 计算整周的工作天数
	SELECT
		-- 计算的开始和结束日期之间的周数(仅整周)
		@weeks = (DATEDIFF(Day, @date_begin, @date_end) + 1) / 7,
		-- 整周的工作天数
		@workday = @weeks * 5,
		-- 最后一个不完整周的开始日期
		@date_begin = DATEADD(Day, @weeks * 7, @date_begin)

	-- 计算最后一个不完整周的工作天数
	WHILE @date_begin <= @date_end
	BEGIN
		SELECT 
			@workday = CASE 
						WHEN (@@DATEFIRST + DATEPART(Weekday, @date_begin) - 1) % 7 BETWEEN 1 AND 5
							THEN @workday + 1 
						ELSE @workday 
					END,
			@date_begin = @date_begin + 1
	END
	RETURN(@workday)
END
GO


/*-----有节假日表的处理方法-----------*/
--使用指定时间段内的天数，减去指定时间段内，节假日表中的记录数即可
create table dbo.tb_Holiday(
	HDate	smalldatetime	--节假日期
		PRIMARY key,
	Name	nvarchar(50)	not null	--节假名称
)

create function dbo.f_workDay(
	@date_begin datetime,	--计算的开始日期
	@date_end	datetime	--计算的结束日期
)returns int 
as
begin 
	return(
	datediff(day,@date_begin,@date_end)+1
	-(
	select count(*) from dbo.tb_holiday
	where Hdate between @date_begin and @date_end)	
)	
end
Go


