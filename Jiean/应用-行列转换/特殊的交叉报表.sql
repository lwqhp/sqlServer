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

-- a. ���ɷ�����Ϣ��ʱ��
SELECT 
	Item, Color,
	No = 0
INTO # FROM tb
GROUP BY Item, Color
ORDER BY Item, Color

select * from #

-- b. ���ɸ��� Item �� Color ���
DECLARE
	@Notem varchar(10),
	@No varchar(10)
UPDATE # SET 
	@No = CASE
			WHEN @Notem = Item THEN @No + 1
			ELSE 1
		END,
	No = @No,
	@Notem = Item

-- c. ���ɽ������ݱ��������
/*
�е���˼��ת���������ݵ���.
ʹ�����ȷ��ת�ɵ�������������ѭ������ƴ�ӳ�ÿ�е���ת�е����
�����union ll�Ѹ��кϲ���һ��
*/

DECLARE
	@sql_Color nvarchar(4000),
	@sql_Quantity nvarchar(4000),
	@fd nvarchar(4000)
SELECT
	@sql_Color = N'',
	@sql_Quantity = N'',
	@fd = N'',
	@No = MAX(No) --ת����
FROM #
GROUP BY Item

WHILE @No > 0
	SELECT 
		@fd = N', '
			+ QUOTENAME(N'col' + @No) + N' = ' + QUOTENAME(@No)
			+ @fd,
		@sql_Color = @sql_Color + N',
	' + QUOTENAME(@No) + N' = MAX(
							CASE No 
								WHEN ' + @No + N' THEN Color
							END)',
		@sql_Quantity = @sql_Quantity + N',
	' + QUOTENAME(@No) + N' = CONVERT(varchar, SUM(
							CASE B.No
								WHEN ' + @No + N' THEN A.Quantity
							END))',
		@No = @No - 1


EXEC(N'
SELECT
	Item = Item ' + @fd + '
FROM(
	SELECT
		Item ' + @sql_Color + ',
		s = 0
	FROM #
	GROUP BY Item
	UNION ALL
	SELECT
		A.Item ' + @sql_Quantity + ',
		s = 1 
	FROM tb A, # B
	WHERE A.Item = B.Item
		AND A.Color = B.Color
	GROUP BY A.Item
)A
ORDER BY Item, s
')
DROP TABLE #
/*--���
Item       col1     col2     col3
---------- -------- -------- --------
Chair      Red      White    Yellow
Chair      90       55       232
Table      Blue     Green    Red
Table      124      230      159
--*/
GO

-- ɾ������
DROP TABLE tb
