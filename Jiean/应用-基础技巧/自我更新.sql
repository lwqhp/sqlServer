

--һ����Ȥ�����Ҹ���
CREATE TABLE tb(
	Item varchar(10),
	Color varchar(10),
	Quantity int
)
INSERT tb SELECT 'Table', 'Blue',   124
UNION ALL SELECT 'Table', 'Red',    60
UNION ALL SELECT 'Table', 'Red',    99
UNION ALL SELECT 'Table', 'Green',  120
UNION ALL SELECT 'Table', 'Green',  110
UNION ALL SELECT 'Chair', 'Yellow', 101
UNION ALL SELECT 'Chair', 'Yellow', 131
UNION ALL SELECT 'Chair', 'Red',    90
UNION ALL SELECT 'Chair', 'White',  55
GO

SELECT 
	Item, Color,
	No = 0
INTO # FROM tb
GROUP BY Item, Color
ORDER BY Item, Color
---------�ű�-------------------------------------------------------------
DECLARE
	@Notem varchar(10),
	@No varchar(10)
UPDATE tb SET 
	@No = CASE
			WHEN @Notem = Item THEN @No + 1
			ELSE 1
		END,
	No = @No,
	@Notem = Item


--------------------------------
--���µ����´��ݼ���
--DROP TABLE tb
CREATE TABLE tb(
	col1 varchar(10),
	col2 int)
INSERT tb SELECT 'a',1
UNION ALL SELECT 'a',2
UNION ALL SELECT 'b',1
UNION ALL SELECT 'b',2
UNION ALL SELECT 'b',3
/*
a	1
a	1,2
b	1
b	1,2
b	1,2,3
*/
--�ϲ�����
-- a. �������ݲ��洢�������ʱ��
SELECT
	col1,
	col2 = CAST(col2 as varchar(100)) 
INTO #t FROM tb
ORDER BY col1,col2

DECLARE
	@col1 varchar(10),
	@col2 varchar(100)

-- b. ͨ�������ۼ�ÿ�� col1 �� col2 ��ֵ
UPDATE #t SET 
	@col2 = CASE
				WHEN @col1 = col1 THEN @col2 + ',' + col2
				ELSE col2
			END,
	@col1 = col1,
	col2 = @col2

SELECT * FROM #t

SELECT 
	col1,
	col2 = MAX(col2)
FROM #t
GROUP BY col1