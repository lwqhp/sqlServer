-- 图书销售数据表

CREATE TABLE tb(
	Books nvarchar(30), -- 书名
	Date datetime,      -- 销售日期
	Sales int           -- 销售数量
)
-- 生成测试数据(生成随机数据)
INSERT tb
SELECT 
	char(65 + ABS(CHECKSUM(NEWID())) % 26),
	DATEADD(Day, 1 - ABS(CHECKSUM(NEWID())) % 500, GETDATE()),
	ABS(CHECKSUM(NEWID()) % 360) + 1
FROM dbo.sysobjects A, dbo.sysobjects B
--显示数据
SELECT * FROM tb
GO

--排行榜处理的存储过程
CREATE PROC dbo.p_Qry
	@Type  nchar(1) = N'日',  -- 排行榜处理类型(日、周、月、季、年)
	@Date  datetime = NULL,   -- 排行榜日期, 不指定为当前日期
	@TopN int = 10            -- 显示的记录数
AS
SET NOCOUNT ON
DECLARE
	@date_begin_previous datetime,
	@date_begin datetime

-- 参数检测
IF CHARINDEX(@Type, N'日周月季年') = 0
	SET @Type = N'日'

-- 去掉日期中的时间部分
SET @Date = DATEDIFF(Day, 0, ISNULL(@Date, GETDATE()))

IF ISNULL(@TopN, 0) < 1
	SET @TopN = 10

-- 根据 @Type 决定计算的起始日期
IF @Type = N'日'
	SELECT
		@date_begin = @Date,
		@Date = DATEADD(Day, 1, @Date),
		@date_begin_previous = DATEADD(Day, -1, @date_begin)
ELSE IF @Type = N'周'
	SELECT
		-- 查询日期所在周的第一天
		@date_begin = DATEADD(Day, - (DATEPART(Weekday, @Date) + @@DATEFIRST - 2) % 7, @Date),
		@Date = DATEADD(Week, 1, @date_begin),
		@date_begin_previous = DATEADD(Week, - 1, @date_begin)
ELSE IF @Type = N'月'
	SELECT 
		-- 查询日期所在月的第一天
		@date_begin = CONVERT(char(6), @Date, 112) + '01',
		@Date = DATEADD(Month, 1, @date_begin),
		@date_begin_previous = DATEADD(Month, -1, @date_begin)
ELSE IF @Type = N'季'
	SELECT 
		-- 查询日期所在季的第一天
		@date_begin = CONVERT(char(6),
						DATEADD(Month, DATEPART(Quarter, @Date) * 3 - Month(@Date) - 2, @Date),
						112) + '01',
		@Date = DATEADD(Month, 3, @date_begin),
		@date_begin_previous = DATEADD(Month, -3, @date_begin)
ELSE
	SELECT 
		@date_begin = CONVERT(char(4), @Date,112) + '0101',
		@Date = DATEADD(Year, 1, @date_begin),
		@date_begin_previous = DATEADD(Year, -1, @date_begin)

SELECT
	@Date, @date_begin, @date_begin_previous

-- 取排名数据到临时表
SET ROWCOUNT @TopN
-- a. 本期销售数据
SELECT
	Books,
	Sales_Amount = SUM(Sales)
INTO #1
FROM tb
WHERE Date >= @date_begin
	AND Date < @Date
GROUP BY Books
ORDER BY Sales_Amount DESC

-- b. 上期销售数据
SELECT
	Books,
	Sales_Amount = SUM(Sales)
INTO #2
FROM tb
WHERE Date >= @date_begin_previous
	AND Date < @date_begin
GROUP BY Books
ORDER BY Sales_Amount DESC

-- c. 显示结果
SELECT 
	A.Books,
	A.Sales_Amount,
	A.Place,
	Description = CASE 
					WHEN B.Books IS NULL THEN N'↑新上榜'
					WHEN A.Place = B.Place THEN N'－'
					WHEN A.Place > B.Place THEN N'↓' + RTRIM(A.Place - B.Place) + N'位'
					ELSE N'↑' + RTRIM(B.Place - A.Place) + N'位'
				END,
	Sales_Amount_previous = B.Sales_Amount,
	Place_previous = B.Place
FROM(
	SELECT
		Books,
		Sales_Amount,
		Place = 1 + (
					SELECT
						COUNT(Sales_Amount)
					FROM #1
					WHERE Sales_Amount > AA.Sales_Amount)
	FROM #1 AA
)A
	LEFT JOIN(
		SELECT
			Books,
			Sales_Amount,
			Place = 1 + (
						SELECT
							COUNT(Sales_Amount)
						FROM #2
						WHERE Sales_Amount > BB.Sales_Amount)
		FROM #2 BB
	)B
		ON A.Books = B.Books
ORDER BY A.Place
GO

-- 调用示例
EXEC dbo.p_Qry N'日'
EXEC dbo.p_Qry N'周'
EXEC dbo.p_Qry N'月'
EXEC dbo.p_Qry N'季'
EXEC dbo.p_Qry N'年'
GO

-- 删除测试环境
DROP PROC dbo.p_Qry
DROP TABLE tb