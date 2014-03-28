
/*
常规处理没有考虑工作时间定义表中定义的时间区间会存在跨天问题
处理方法：
	采用调整工作时间表的方法，即将上面的所有时间减去7.5小时，将时间调整到一天之内，
	在计算工作时间时，将计算的起始时间也减去7.5小时，这样就在工作时间的计算上就不用作特殊处理了。
*/

-- 工作时间配置表
CREATE TABLE dbo.tb_worktime(
	ID int IDENTITY
		PRIMARY KEY,
	time_start smalldatetime,  --工作的开始时间
	time_end smalldatetime,   --工作的结束时间
	worktime AS DATEDIFF(Minute,time_start,time_end) --工作时数(分钟)
)
INSERT dbo.tb_worktime(
	time_start,time_end)
SELECT '1900-1-1 00:30','1900-1-1 07:00' UNION ALL
SELECT '1900-1-1 08:30','1900-1-1 17:30' UNION ALL
SELECT '1900-1-2 18:00','1900-1-2 23:30'
GO

-- 根据工作时间配置表, 计算指定时间段内的工作时间
CREATE FUNCTION dbo.f_WorkTime(
	@date_begin datetime,  --计算的开始时间
	@date_end datetime     --计算的结束时间
)RETURNS int
AS
BEGIN
	DECLARE
		@worktime int,
		@time_begin smalldatetime,
		@time_end smalldatetime

	-- 开始和结束时间的时间部分
	SELECT
		@time_begin = CONVERT(VARCHAR, @date_begin, 108),
		@time_end = CONVERT(VARCHAR, @date_end, 108)
	
	-- 不跨天的工作时间计算
	IF DATEDIFF(Day, @date_begin, @date_end) = 0
		SELECT 
			@worktime = SUM(
					DATEDIFF(Minute,
						-- 每个时间段的开始时间
						CASE 
							WHEN @time_begin > time_start THEN @time_begin
							ELSE time_start 
						END,
						-- 每个时间段的结束时间
						CASE 
							WHEN @time_end < time_end THEN @time_end
							ELSE time_end
						END
					))
		FROM dbo.tb_worktime 
		WHERE time_end > @time_begin
			AND time_start < @time_end
	ELSE
		SELECT
			@worktime = 
				(   -- 开始时间(第一天)
					SELECT 
						SUM(CASE
								WHEN time_start > @time_begin THEN worktime
								ELSE DATEDIFF(Minute, @time_begin, time_end)
							END)
					FROM dbo.tb_worktime 
					WHERE time_end > @time_begin
				)
				+ ( -- 结束时间(最后一天)
					SELECT
						SUM(CASE
								WHEN time_end < @time_end THEN worktime
								ELSE DATEDIFF(Minute, time_start, @time_end)
							END)
					FROM dbo.tb_worktime 
					WHERE time_start < @time_end
				)				
			+ (  -- 整天
				(DATEDIFF(Day, @date_begin, @date_end) - 1)
				* ( SELECT SUM(worktime) FROM dbo.tb_worktime)
				)

	RETURN(@worktime)
END
GO
