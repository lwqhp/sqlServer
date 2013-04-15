-- 结存表
CREATE TABLE Stocks(
	Item varchar(10),
	YearMonth int,
	Quantity int)
INSERT Stocks SELECT 'aa', 200501, 100
UNION  ALL    SELECT 'cc', 200501, 100

-- 明细帐数据
CREATE TABLE tb(
	ID int IDENTITY
		PRIMARY KEY,
	Item varchar(10),  -- 产品编号
	Quantity int,      -- 交易数量
	Flag bit,          -- 交易标志, 1 代表入库, 0 代表出库,这样可以有效区分退货(负数)
	Date datetime)     -- 交易日期
INSERT tb SELECT 'aa', 100, 1, '2005-1-1'
UNION ALL SELECT 'aa', 90 , 1, '2005-2-1'
UNION ALL SELECT 'aa', 55 , 0, '2005-2-1'
UNION ALL SELECT 'aa', -10, 1, '2005-2-2'
UNION ALL SELECT 'aa', -5 , 0, '2005-2-3'
UNION ALL SELECT 'aa', 200, 1, '2005-2-2'
UNION ALL SELECT 'aa', 90 , 1, '2005-2-1'
UNION ALL SELECT 'bb', 95 , 1, '2005-2-2'
UNION ALL SELECT 'bb', 65 , 0, '2005-2-3'
UNION ALL SELECT 'bb', -15, 1, '2005-2-5'
UNION ALL SELECT 'bb', -20, 0, '2005-2-5'
UNION ALL SELECT 'bb', 100, 1, '2005-2-7'
UNION ALL SELECT 'cc', 100, 1, '2005-1-7'
GO

-- 查询时间段定义
DECLARE
	@date_start datetime,
	@date_stop datetime
SELECT
	@date_start = '2005-2-1',
	@date_stop = '2005-2-10'

-- 查询
-- a. 期初库存年月及计算期初数的开始时间)
DECLARE
	@YearMonth int,
	@date datetime
SELECT
	@YearMonth = CONVERT(CHAR(6),DATEADD(Month, - 1, @date_start), 112),
	@date = DATEADD(Day, 1 - Day(@date_start), @date_start)

-- b. 结果查询
SELECT
	产品 = ISNULL(A.Item, B.Item),
	日期 = ISNULL(B.Date, CONVERT(char(10), @date_start, 120)),
	期初数 = ISNULL(A.Quantity, 0) + ISNULL(B.Init, 0),
	本期入库 = ISNULL(B.[IN], 0),
	本期入库退货 = ISNULL(B.[IN_Retrun], 0),
	本期出库 = ISNULL(B.[OUT], 0),
	本期出库退货 = ISNULL(B.[OUT_Return], 0),
	期末数 = ISNULL(A.Quantity, 0) + ISNULL(B.Init, 0) + ISNULL(B.Finish, 0)
FROM(
	--期初数
	SELECT
		Item, Quantity
	FROM Stocks
	WHERE YearMonth = @YearMonth
)A
	FULL JOIN(
		-- a. 在统计时间段内无发生额的数据(如果这个不是查询需要的,去掉这段查询)
		SELECT
			Item,
			Date = CONVERT(char(10), @date_start, 120),	
			Init = SUM(
						CASE
							WHEN Flag = 1 THEN Quantity
							ELSE - Quantity
						END),
			[IN] = 0,
			[IN_Retrun] = 0,
			[OUT] = 0,
			[OUT_Return] = 0,
			Finish = SUM(
						CASE
							WHEN Flag = 1 THEN Quantity
							ELSE - Quantity
						END)
		FROM tb A
		WHERE Date >= @date         -- 仅统计在结存时间之后, 统计开始时间之前的记录
			AND Date < @date_start 
			AND NOT EXISTS(
					-- 仅包含在统计时间段内不存在的 Item
					SELECT * FROM tb
					WHERE Item = A.Item
						AND Date > @date_start
						AND Date < DATEADD(Day, 1, @date_stop))
		GROUP BY Item
		UNION ALL
		-- b. 指定时间段内有交易发生的数据
		SELECT
			Item = Item,
			Date = CONVERT(char(10), Date, 120),	
			Init = ISNULL((
						-- 期初数为小于当前统计记录时间的所有与当前记录 Item 相同的记录的入库之和 - 出库之和
						SELECT
							SUM(CASE
									WHEN Flag = 1 THEN Quantity
									ELSE - Quantity
							END)
						FROM tb
						WHERE Item = A.Item
							-- 仅统计在结存时间之后, 统计开始时间之前的记录
							AND  Date >= @date
							AND Date < MIN(A.Date)
					), 0),
			[IN] = ISNULL(
								SUM(CASE
										WHEN Flag = 0 AND Quantity > 0 THEN Quantity
									END),
								0),
			[IN_Retrun] = ISNULL(
								SUM(CASE
										WHEN Flag = 0 AND Quantity < 0 THEN - Quantity
									END),
								0),
			[OUT] = ISNULL(
								SUM(CASE
										WHEN Flag = 0 AND Quantity > 0 THEN Quantity
									END),
								0),
			[OUT_Return] = ISNULL(
								SUM(CASE
										WHEN Flag = 0 AND Quantity < 0 THEN - Quantity
									END),
								0),
			-- 仅计算入库数量和出库数量之间的差异, 显示最终结果时再处理期末数量
			Finish = SUM(CASE
							WHEN Flag = 1 THEN Quantity
							ELSE - Quantity
						END)
		FROM tb A
		WHERE Date >= @date_start
			AND Date < DATEADD(Day, 1, @date_stop)
		GROUP BY Item, CONVERT(char(10), Date,120)
	)B
		ON A.Item = B.Item
ORDER BY 产品, 日期
/*--结果
产品	日期		期初数	本期入库	本期入库退货	本期出库	本期出库退货	期末数
------- ----------- ------- ----------- --------------- ----------- --------------- ----------
aa		2005-02-01	100		55			0				55			0				225
aa		2005-02-02	225		0			0				0			0				415
aa		2005-02-03	415		0			5				0			5				420
bb		2005-02-02	0		0			0				0			0				95
bb		2005-02-03	95		65			0				65			0				30
bb		2005-02-05	30		0			20				0			20				35
bb		2005-02-07	35		0			0				0			0				135
cc		2005-02-01	100		0			0				0			0				100
--*/
GO

-- 删除测试环境
DROP TABLE tb, Stocks