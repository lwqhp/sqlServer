--�ڳ�����
DECLARE @stock TABLE(
	id int,
	num decimal(5, 2))

INSERT @stock SELECT 1, 100 
UNION  ALL    SELECT 3, 500
UNION  ALL    SELECT 4, 800

--�������
DECLARE @in TABLE(
	id int,
	num decimal(5, 2))
INSERT @in SELECT 1, 100 
UNION  ALL SELECT 1, 80
UNION  ALL SELECT 2, 800

--��������
DECLARE @out TABLE(
	id int,
	num decimal(5, 2))
INSERT @out SELECT 2, 100
UNION  ALL  SELECT 3, 100
UNION  ALL  SELECT 3, 200

-- ͳ��
-- a. ʹ�� UNION ALL ͳ��
SELECT
	id,
	stock_opening = SUM(stock_opening),
	stock_in = SUM(stock_in),
	stock_out = SUM(stock_out),
	stock_closing = SUM(stock_closing)
FROM(
	SELECT 
		id,
		stock_opening = num,  -- �ڳ�����
		stock_in = 0,         -- ���ڳ����ݱ���, �������Ϊ 0 
		stock_out = 0,        -- ���ڳ����ݱ���, ���ڳ���Ϊ 0 
		stock_closing = num   -- �ڳ�������������ĩʱ, Ϊ������
	FROM @stock
	UNION ALL
	SELECT
		id,
		stock_opening = 0,   -- ��������ݱ���, �ڳ�����Ϊ 0 
		stock_in = num,
		stock_out = 0,       -- ��������ݱ���, ���ڳ���Ϊ 0
		stock_closing = num  -- �������������ĩʱ, Ϊ������
	FROM @in
	UNION ALL
	SELECT
		id,
		stock_opening = 0,    -- �ڳ������ݱ���, �ڳ�����Ϊ 0 
		stock_in = 0,         -- �ڳ������ݱ���, �������Ϊ 0 
		stock_out = num,
		stock_closing = - num -- ��������������ĩʱ, Ϊ������
	FROM @out
)A
GROUP BY id

-- b. ʹ�� FULL JOIN ͳ��
SELECT 
	id = ISNULL(A.id, ISNULL(B.id, C.id)),
	stock_opening = ISNULL(A.num, 0),
	stock_in = ISNULL(B.num, 0),
	stock_out = ISNULL(C.num, 0),
	stock_closing = ISNULL(A.num, 0)
					+ ISNULL(B.num, 0)
					- ISNULL(C.num, 0)
FROM @stock A   -- �ڳ��������Ѿ����ܵĽ��, �����������ܴ���
	FULL JOIN(  -- ������ݻ���
		SELECT
			id,
			num = SUM(num)
		FROM @in
		GROUP BY id
	)B
		ON A.id = B.id		
	FULL JOIN(  -- �������ݻ���(һ����˵, ��������� LEFT JOIN, ��ΪҪ����Ķ���Ҫô�������ڳ�����, Ҫô������������)
		SELECT
			id,
			num = SUM(num)
		FROM @out
		GROUP BY id
	)C
		ON A.id = C.id
			OR B.id = C.id
ORDER BY id

/*--���
id          stock_opening    stock_in     stock_out      stock_closing
---------------- ----------------------- ----------------- -------------------- --------------------
1           100.00           180.00       .00          280.00
2           .00              800.00       100.00       700.00
3           500.00           .00          300.00       200.00
4           800.00           .00          .00          800.00
--*/
	