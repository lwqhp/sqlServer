--期初数据
DECLARE @stock TABLE(
	id int,
	num decimal(5, 2))

INSERT @stock SELECT 1, 100 
UNION  ALL    SELECT 3, 500
UNION  ALL    SELECT 4, 800

--入库数据
DECLARE @in TABLE(
	id int,
	num decimal(5, 2))
INSERT @in SELECT 1, 100 
UNION  ALL SELECT 1, 80
UNION  ALL SELECT 2, 800

--出库数据
DECLARE @out TABLE(
	id int,
	num decimal(5, 2))
INSERT @out SELECT 2, 100
UNION  ALL  SELECT 3, 100
UNION  ALL  SELECT 3, 200

-- 统计
-- a. 使用 UNION ALL 统计
SELECT
	id,
	stock_opening = SUM(stock_opening),
	stock_in = SUM(stock_in),
	stock_out = SUM(stock_out),
	stock_closing = SUM(stock_closing)
FROM(
	SELECT 
		id,
		stock_opening = num,  -- 期初数据
		stock_in = 0,         -- 在期初数据表中, 本期入库为 0 
		stock_out = 0,        -- 在期初数据表中, 本期出库为 0 
		stock_closing = num   -- 期初数据体现在期末时, 为增加项
	FROM @stock
	UNION ALL
	SELECT
		id,
		stock_opening = 0,   -- 在入库数据表中, 期初数据为 0 
		stock_in = num,
		stock_out = 0,       -- 在入库数据表中, 本期出库为 0
		stock_closing = num  -- 入库数据现在期末时, 为增加项
	FROM @in
	UNION ALL
	SELECT
		id,
		stock_opening = 0,    -- 在出库数据表中, 期初数据为 0 
		stock_in = 0,         -- 在出库数据表中, 本期入库为 0 
		stock_out = num,
		stock_closing = - num -- 出库数据现在期末时, 为减少项
	FROM @out
)A
GROUP BY id

-- b. 使用 FULL JOIN 统计
SELECT 
	id = ISNULL(A.id, ISNULL(B.id, C.id)),
	stock_opening = ISNULL(A.num, 0),
	stock_in = ISNULL(B.num, 0),
	stock_out = ISNULL(C.num, 0),
	stock_closing = ISNULL(A.num, 0)
					+ ISNULL(B.num, 0)
					- ISNULL(C.num, 0)
FROM @stock A   -- 期初数据是已经汇总的结果, 故无需做汇总处理
	FULL JOIN(  -- 入库数据汇总
		SELECT
			id,
			num = SUM(num)
		FROM @in
		GROUP BY id
	)B
		ON A.id = B.id		
	FULL JOIN(  -- 出库数据汇总(一般来说, 这里可以用 LEFT JOIN, 因为要出库的东西要么存在于期初表中, 要么存在于入库表中)
		SELECT
			id,
			num = SUM(num)
		FROM @out
		GROUP BY id
	)C
		ON A.id = C.id
			OR B.id = C.id
ORDER BY id

/*--结果
id          stock_opening    stock_in     stock_out      stock_closing
---------------- ----------------------- ----------------- -------------------- --------------------
1           100.00           180.00       .00          280.00
2           .00              800.00       100.00       700.00
3           500.00           .00          300.00       200.00
4           800.00           .00          .00          800.00
--*/
	