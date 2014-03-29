
/*
使用rollup的排序
利用grouping()返回0,1
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
-- 统计及显示
SELECT
	Groups = CASE 
		WHEN GROUPING(Color) = 0 THEN Groups
		WHEN GROUPING(Groups) = 1 THEN N'总计'
		ELSE '' END,
	Item = CASE 
		WHEN GROUPING(Color) = 0 THEN Item
		WHEN GROUPING(Item) = 1 AND GROUPING(Groups) = 0
			THEN Groups + N' 合计'
		ELSE '' END,
	Color=CASE 
		WHEN GROUPING(Color) = 0 THEN Color
		WHEN GROUPING(Color) = 1 AND GROUPING(Item) = 0
			THEN Item + N' 小计'
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

/*--结果
Groups Item       Color         Quantity
------ ---------- ------------- -----------
bb     Table      Red           -23
                  Table 小计      -23
bb     Cup        Green         -23
                  Cup 小计        -23
       bb 合计                    -46
aa     Table      Blue          124
                  Table 小计      124
aa     Chair      Red           -90
aa     Chair      Blue          101
                  Chair 小计      11
       aa 合计                    135
总计                              89
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
		WHEN GROUPING(Groups) = 1 THEN N'总计'
		ELSE '' END,
	Item = CASE 
		WHEN GROUPING(Color) = 0 THEN Item
		WHEN GROUPING(Item) = 1 AND GROUPING(Groups) = 0
			THEN Groups + N' 合计'
		ELSE '' END,
	Color=CASE 
		WHEN GROUPING(Color) = 0 THEN Color
		WHEN GROUPING(Color) = 1 AND GROUPING(Item) = 0
			THEN Item + N' 小计'
		ELSE '' END,
	Quantity=SUM(Quantity)
FROM @t
GROUP BY Groups, Item, Color
	WITH ROLLUP
HAVING GROUPING(Item) = 0 OR GROUPING(Groups) = 1

/*--结果
Groups Item       Color           Quantity
------ ---------- --------------- -----------
aa     Chair      Blue            101
aa     Chair      Red             -90
                  Chair 小计        11
aa     Table      Blue            124
                  Table 小计        124
bb     Cup        Green           -23
                  Cup 小计          -23
bb     Table      Red             -23
                  Table 小计        -23
总计                                89
--*/