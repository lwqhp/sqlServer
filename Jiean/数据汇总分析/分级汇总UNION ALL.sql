
/*
合计行的排序
增加排序列,s1:总计行，s2:排序列，s3:小记行
s1,s2,s3
0,'A',0
0,'A',1--A列合计行
1,'A',0--最后的总计行

*/
/*
把复杂的汇总分级分层处理，再用union 汇总
*/
-- 示例数据
create table  #t (
	Item varchar(10),
	Color varchar(10),
	Quantity int)
INSERT #t SELECT 'Table', 'Blue', 124
UNION ALL SELECT 'Table', 'Red',  -23
UNION ALL SELECT 'Chair', 'Blue', 101
UNION ALL SELECT 'Chair', 'Red',  -90

select * from #t
-- 统计
SELECT Item,Color,Quantity
FROM(
	--明细
	SELECT
		Item,
		Color,
		Quantity = SUM(Quantity),
		s1=0, s2=Item, s3=0  -- 用于排序的列
	FROM #t
	GROUP BY Item, Color
	UNION ALL
	-- 各Item合计
	SELECT 
		Ittem = '',
		Color = Item + ' sub total',
		Quantity = SUM(Quantity),
		s1=0,s2=Item,s3=1  -- 用于排序的列
	FROM #t
	GROUP BY Item
	UNION ALL
	-- 总计
	SELECT 
		Item = 'total',
		Color = '',
		Quantity = SUM(Quantity),
		s1=1, s2 = '', s3=1 -- 用于排序的列
	FROM #t
)A
ORDER BY s1, s2, s3
/*--结果
Item       Color                Quantity
---------- -------------------- -----------
Chair      Blue                 101
Chair      Red                  -90
           Chair sub total      11
Table      Blue                 124
Table      Red                  -23
           Table sub total      101
total                           112
--*/
