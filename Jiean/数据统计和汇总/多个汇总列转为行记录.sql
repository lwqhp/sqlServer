
/*
��ָ����ȷ����תΪ�е������ֶ�ֻ��һ���������������ת��Ϊ�м�¼�����ж������������Ϊ��һ��Ҫ־��Ϊ�е��ֶΣ�ʹ����ͬ������������
*/
DECLARE @t TABLE(
	Year int,
	Quarter int,
	Quantity decimal(10,1),
	Price decimal(10,2)
)
INSERT @t SELECT 1990, 1, 1.1, 2.5
UNION ALL SELECT 1990, 1, 1.2, 3.0
UNION ALL SELECT 1990, 2, 1.2, 3.0
UNION ALL SELECT 1990, 1, 1.3, 3.5
UNION ALL SELECT 1990, 2, 1.4, 4.0
UNION ALL SELECT 1991, 1, 2.1, 4.5
UNION ALL SELECT 1991, 2, 2.1, 4.5
UNION ALL SELECT 1991, 2, 2.2, 5.0
UNION ALL SELECT 1991, 1, 2.3, 5.5
UNION ALL SELECT 1991, 1, 2.4, 6.0

--��ѯ����
SELECT 
	Year,
	Q1_Amount = SUM(
					CASE Quarter
						WHEN 1 THEN Quantity
					END),
	Q1_Price = CONVERT(decimal(10, 2), AVG(
					CASE Quarter
						WHEN 1 THEN Price
					END)),
	Q1_Money = CONVERT(decimal(10, 2), SUM(
					CASE Quarter
						WHEN 1 THEN Quantity * Price
					END)),
	Q2_Amount = SUM(
					CASE Quarter
						WHEN 2 THEN Quantity
					END),
	Q2_Price = CONVERT(decimal(10, 2), AVG(
					CASE Quarter
						WHEN 2 THEN Price
					END)),
	Q2_Money = CONVERT(decimal(10, 2), SUM(
					CASE Quarter
						WHEN 2 THEN Quantity * Price
					END))
FROM @t
GROUP BY Year
/*--���
Year    Q1_Amount  Q1_Price  Q1_Money    Q2_Amount  Q2_Price  Q2_Money
------- ---------- --------- ----------- ---------- --------- ---------
1990    3.6        3.00      10.90       2.6        3.50      9.20
1991    6.8        5.33      36.50       4.3        4.75      20.45
--*/
