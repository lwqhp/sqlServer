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
-- a. 在统计时间段内无发生额的数据(如果这个不是查询需要的,去掉这段查询)
SELECT
	产品 = Item,
	日期 = CONVERT(char(10), @date_start, 120),	
	期初数 = SUM(
				CASE
					WHEN Flag = 1 THEN Quantity
					ELSE - Quantity
				END),
	本期入库 = 0,
	本期入库退货 = 0,
	本期出库 = 0,
	本期出库退货 = 0,
	期末数 = SUM(
				CASE
					WHEN Flag = 1 THEN Quantity
					ELSE - Quantity
				END)
FROM tb A
WHERE Date < @date_start  -- 仅统计在统计时间开始时间之前有交易的数据
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
	产品 = Item,
	日期 = CONVERT(char(10), Date, 120),	
	期初数 = ISNULL((
				-- 期初数为小于当前统计记录时间的所有与当前记录 Item 相同的记录的入库之和 - 出库之和
				SELECT
					SUM(CASE
							WHEN Flag = 1 THEN Quantity
							ELSE - Quantity
					END)
				FROM tb
				WHERE Item = A.Item
					AND Date < MIN(A.Date)
			), 0),
	本期入库 = ISNULL(
						SUM(CASE
								WHEN Flag = 0 AND Quantity > 0 THEN Quantity
							END),
						0),
	本期入库退货 = ISNULL(
						SUM(CASE
								WHEN Flag = 0 AND Quantity < 0 THEN - Quantity
							END),
						0),
	本期出库 = ISNULL(
						SUM(CASE
								WHEN Flag = 0 AND Quantity > 0 THEN Quantity
							END),
						0),
	本期出库退货 = ISNULL(
						SUM(CASE
								WHEN Flag = 0 AND Quantity < 0 THEN - Quantity
							END),
						0),
	期末数 = ISNULL((
			-- 期末数为统计截止记录时间的所有与当前记录 Item 相同的记录的入库之和 - 出库之各
				SELECT
					SUM(CASE
							WHEN Flag = 1 THEN Quantity
							ELSE - Quantity
					END)
				FROM tb
				WHERE Item = A.Item
					AND Date <= MAX(A.Date)
			), 0)
FROM tb A
WHERE Date >= @date_start
	AND Date < DATEADD(Day, 1, @date_stop)
GROUP BY Item, CONVERT(char(10), Date,120)
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
DROP TABLE tb