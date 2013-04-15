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