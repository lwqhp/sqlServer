
/*
ʹ��rollup������
����grouping()����0,1
*/

create TABLE #t (
	Groups char(2),
	Item varchar(10),
	Color varchar(10),
	Quantity int)
INSERT #t SELECT 'aa', 'Table', 'Blue',  124
UNION ALL SELECT 'bb', 'Table', 'Red',   -23
UNION ALL SELECT 'bb', 'Cup'  , 'Green', -23
UNION ALL SELECT 'aa', 'Chair', 'Blue',  101
UNION ALL SELECT 'aa', 'Chair', 'Red',   -90

select * from  #t
-- ͳ�Ƽ���ʾ
SELECT
	Groups = CASE 
		WHEN GROUPING(Color) = 0 THEN Groups
		WHEN GROUPING(Groups) = 1 THEN N'�ܼ�'
		ELSE '' END,
	Item = CASE 
		WHEN GROUPING(Color) = 0 THEN Item
		WHEN GROUPING(Item) = 1 AND GROUPING(Groups) = 0
			THEN Groups + N' �ϼ�'
		ELSE '' END,
	Color=CASE 
		WHEN GROUPING(Color) = 0 THEN Color
		WHEN GROUPING(Color) = 1 AND GROUPING(Item) = 0
			THEN Item + N' С��'
		ELSE '' END,
	Quantity=SUM(Quantity)
FROM #t
GROUP BY Groups, Item, Color
	WITH ROLLUP
ORDER BY 
	GROUPING(Groups), 
	CASE WHEN GROUPING(Groups) = 1 THEN '' ELSE Groups END DESC,
	GROUPING(Item), 
	CASE WHEN GROUPING(Item) = 1 THEN '' ELSE Item END DESC,
	GROUPING(Color), 
	CASE WHEN GROUPING(Color)=1 THEN '' ELSE Color END DESC,
	Quantity DESC

/*--���
Groups Item       Color         Quantity
------ ---------- ------------- -----------
bb     Table      Red           -23
                  Table С��      -23
bb     Cup        Green         -23
                  Cup С��        -23
       bb �ϼ�                    -46
aa     Table      Blue          124
                  Table С��      124
aa     Chair      Red           -90
aa     Chair      Blue          101
                  Chair С��      11
       aa �ϼ�                    135
�ܼ�                              89
--*/



DECLARE @t TABLE(
	Groups char(2),
	Item varchar(10),
	Color varchar(10),
	Quantity int)
INSERT @t SELECT 'aa', 'Table', 'Blue',  124
UNION ALL SELECT 'bb', 'Table', 'Red',   -23
UNION ALL SELECT 'bb', 'Cup'  , 'Green', -23
UNION ALL SELECT 'aa', 'Chair', 'Blue',  101
UNION ALL SELECT 'aa', 'Chair', 'Red',   -90

SELECT
	Groups = CASE 
		WHEN GROUPING(Color) = 0 THEN Groups
		WHEN GROUPING(Groups) = 1 THEN N'�ܼ�'
		ELSE '' END,
	Item = CASE 
		WHEN GROUPING(Color) = 0 THEN Item
		WHEN GROUPING(Item) = 1 AND GROUPING(Groups) = 0
			THEN Groups + N' �ϼ�'
		ELSE '' END,
	Color=CASE 
		WHEN GROUPING(Color) = 0 THEN Color
		WHEN GROUPING(Color) = 1 AND GROUPING(Item) = 0
			THEN Item + N' С��'
		ELSE '' END,
	Quantity=SUM(Quantity)
FROM @t
GROUP BY Groups, Item, Color
	WITH ROLLUP
HAVING GROUPING(Item) = 0 OR GROUPING(Groups) = 1

/*--���
Groups Item       Color           Quantity
------ ---------- --------------- -----------
aa     Chair      Blue            101
aa     Chair      Red             -90
                  Chair С��        11
aa     Table      Blue            124
                  Table С��        124
bb     Cup        Green           -23
                  Cup С��          -23
bb     Table      Red             -23
                  Table С��        -23
�ܼ�                                89
--*/