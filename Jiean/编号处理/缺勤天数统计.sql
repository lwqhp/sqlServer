--计算两个日期之间相差的工作天数
CREATE FUNCTION dbo.f_WorkDateDiff(
	@dt_begin datetime,
	@dt_end datetime
)RETURNS int
AS
BEGIN
	DECLARE
		@workday int,
		@i int,
		@bz bit,
		@dt datetime

	-- 如果开始日期 > 结束时间, 则交换两个日期, 并设置标志
	-- 这样做的好处是后面的处理按照同一规则进行
	IF @dt_begin > @dt_end
		SELECT
			@bz=1,
			@dt = @dt_begin,
			@dt_begin = @dt_end,
			@dt_end=@dt
	ELSE
		SET @bz=0

	SELECT
		-- 整周周数
		@i = (DATEDIFF(Day, @dt_begin, @dt_end) + 1) / 7,
		@workday = @i * 5,  -- 整周工作天数
		@dt_begin = DATEADD(Day, @i * 7, @dt_begin)
	-- 计算非整周工作天数
	WHILE @dt_begin <= @dt_end
	BEGIN
		SELECT
			@workday = CASE 
						WHEN (@@DATEFIRST + DATEPART(Weekday, @dt_begin) - 1) % 7 BETWEEN 1 AND 5
							THEN @workday + 1
						ELSE @workday
					END,
			@dt_begin = @dt_begin + 1
	END

	RETURN(
		CASE
			WHEN @bz = 1 THEN - @workday
			ELSE @workday
		END)
END
GO

--测试数据
CREATE TABLE tb(
	Name varchar(10),
	WorkDate datetime)
INSERT tb SELECT 'aa', '2005-01-03'
UNION ALL SELECT 'aa', '2005-01-04'
UNION ALL SELECT 'aa', '2005-01-05'
UNION ALL SELECT 'aa', '2005-01-06'
UNION ALL SELECT 'aa', '2005-01-07'
UNION ALL SELECT 'aa', '2005-01-10'
UNION ALL SELECT 'aa', '2005-01-14'
UNION ALL SELECT 'aa', '2005-01-17'
UNION ALL SELECT 'bb', '2005-01-11'
UNION ALL SELECT 'bb', '2005-01-12'
UNION ALL SELECT 'bb', '2005-01-13'
UNION ALL SELECT 'bb', '2005-01-10'
UNION ALL SELECT 'bb', '2005-01-14'
UNION ALL SELECT 'bb', '2005-01-20'
GO

--缺勤统计
DECLARE
	@dt_begin datetime,
	@dt_end datetime
SELECT
	@dt_begin = '2005-1-1', --统计的开始日期
	@dt_end = '2005-1-20'   --统计的结束日期

--统计
SELECT
	Name,
	Days = SUM(Days)
FROM(
	SELECT
		Name,
		Days = dbo.f_WorkDateDiff(
				DATEADD(Day, 1, WorkDate),
				-- 缺勤日期的结束日期, 如果没有, 则为查询的结束日期
				ISNULL(
					(
						SELECT
							DATEADD(Day, -1, MIN(WorkDate))
						FROM tb AA
						WHERE Name = A.Name 
							AND WorkDate > A.WorkDate
								AND WorkDate <= @dt_end
					), @dt_end)
			)
	FROM(
		SELECT
			Name,
			WorkDate
		FROM tb
		WHERE WorkDate BETWEEN @dt_begin AND @dt_end
		UNION ALL --为每组编号补充查询起始编号是否缺号的辅助记录
		SELECT DISTINCT
			Name,
			DATEADD(Day, -1, @dt_begin)
		FROM tb
		WHERE WorkDate BETWEEN @dt_begin AND @dt_end
	)a
	WHERE 
		-- 仅计算工作日
		(@@DATEFIRST+DATEPART(Weekday, WorkDate) - 1) % 7 BETWEEN 1 AND 5
		AND NOT EXISTS(
				-- 没有下一天考勤记录的记录, 它的日期加1即为缺勤的开始日期
				SELECT * FROM tb 
				WHERE WorkDate BETWEEN @dt_begin AND @dt_end
					AND Name = A.Name 
					AND dbo.f_WorkDateDiff(WorkDate, A.WorkDate) = -2)
)AA
GROUP BY Name
/*--结果
Name       Days 
---------------- ----------- 
aa         6
bb         8
--*/
GO

-- 删除测试环境
DROP TABLE tb
DROP FUNCTION f_WorkDateDiff