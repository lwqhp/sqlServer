
/*
ʹ��CASE����������ʾ����ͨ���ۺϺ����ϲ���¼
*/
DECLARE @t TABLE(
	Year int,
	Quarter int,
Amount decimal(10,1)
)
INSERT @t SELECT 1990, 1, 1.1
UNION ALL SELECT 1990, 2, 1.2
UNION ALL SELECT 1990, 3, 1.3
UNION ALL SELECT 1990, 4, 1.4
UNION ALL SELECT 1991, 1, 2.1
UNION ALL SELECT 1991, 2, 2.2
UNION ALL SELECT 1991, 3, 2.3
UNION ALL SELECT 1991, 4, 2.4

--��ѯ����
SELECT 
	Year,
	Q1 = SUM(
			CASE Quarter
				WHEN 1 THEN Amount
			END),
	Q2 = SUM(
			CASE Quarter
				WHEN 2 THEN Amount
			END),
	Q3 = SUM(
			CASE Quarter
				WHEN 3 THEN Amount
			END),
	Q4 = SUM(
			CASE Quarter
				WHEN 4 THEN Amount
			END)
FROM @t
GROUP BY Year