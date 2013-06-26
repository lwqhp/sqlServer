
/*
一般生成专门的定义上限与下限的表，，只需将区间范围与要查询的资料表join即可
*/
/*
区间统计
使用union all配合select语句构建一个包含统计数据的上限与下限的虚拟表，如果不限制上限,
则对上限使用null值，如果不限制下限，则对下限使用null值，然后关联基础数据表进行记录数统计处理
*/
-- 测试数据
create TABLE #t (
	ID int PRIMARY KEY,
	col decimal(10,2)
)
INSERT #t SELECT 1 ,26.21
UNION ALL SELECT 2 ,88.19
UNION ALL SELECT 6 ,53.01
UNION ALL SELECT 7 ,18.55
UNION ALL SELECT 8 ,84.90
UNION ALL SELECT 9 ,95.60

select * from #t

-- 统计
-- a. 统计需求字符串
DECLARE
	@areas varchar(100)
SET @areas = '50, 75, 95'

-- b. 拆分统计需求字符串, 生成上/下限定义表
declare  @tb_area TABLE(
	min_limit decimal(10, 2),
	max_limit decimal(10, 2),
	name varchar(20)
)

DECLARE
	@value_pre int,
	@value int
WHILE @areas > ''
BEGIN
	SELECT
		-- 取出统计需求字符串中的第一个值
		@value = CONVERT(int,
						LEFT(@areas, CHARINDEX(',', @areas + ',') - 1)),
		@areas = STUFF(@areas, 1, CHARINDEX(',', @areas + ','), '')
	INSERT @tb_area(
		min_limit, max_limit,
		name)	
	SELECT
		@value_pre, @value,
		CASE
			WHEN @value_pre IS NULL THEN '< ' + RTRIM(@value)
			ELSE '>= ' + RTRIM(@value_pre) + ' AND < ' + RTRIM(@value)
		END
	SELECT
		@value_pre = @value
END
INSERT @tb_area(
	min_limit, max_limit, name)	
SELECT
	@value, NULL, '>= ' + RTRIM(@value)
select * from @tb_area

--select *
--FROM #t A, @tb_area B
--WHERE (B.min_limit IS NULL OR A.col >= B.min_limit)
--	AND ( B.max_limit IS NULL OR A.col < B.max_limit)

-- c. 统计
SELECT
	area = B.name,
	rows = COUNT(*),
	sums = SUM(A.col)
FROM #t A, @tb_area B
WHERE (B.min_limit IS NULL OR A.col >= B.min_limit)
	AND ( B.max_limit IS NULL OR A.col < B.max_limit)
GROUP BY B.name
/*--结果:
area                    rows       sums
-------------------- --------- ----------
< 50                    2           44.76
>= 50 AND < 75        1           53.01
>= 75 AND < 95        2           173.09
>= 95                   1           95.60
--*/


create TABLE #t1 (ID int PRIMARY KEY,col decimal(10,2))
INSERT #t1 SELECT 1 ,26.21
UNION ALL SELECT 2 ,88.19
UNION ALL SELECT 3 , 4.21
UNION ALL SELECT 4 ,76.58
UNION ALL SELECT 5 ,58.06
UNION ALL SELECT 6 ,53.01
UNION ALL SELECT 7 ,18.55
UNION ALL SELECT 8 ,84.90
UNION ALL SELECT 9 ,95.60

select * from #t1
--统计
SELECT a.Description,
	Record_count=COUNT(b.ID),
	[Percent]=CASE 
		WHEN Counts=0 THEN '0.00%'
		ELSE CAST(CAST(
			COUNT(b.ID)*100./c.Counts
			as decimal(10,2)) as varchar)+'%'
		END
FROM(
	SELECT sid=1,a=NULL,b=30  ,Description='<30' UNION ALL
	SELECT sid=2,a=30  ,b=60  ,Description='>=30 and <60' UNION ALL
	SELECT sid=3,a=60  ,b=75  ,Description='>=60 and <75' UNION ALL
	SELECT sid=4,a=75  ,b=95  ,Description='>=75 and <95' UNION ALL
	SELECT sid=5,a=95  ,b=NULL,Description='>=95' 
)a LEFT JOIN #t1 b 
	ON (b.col<a.b OR a.b IS NULL)
		AND(b.col>=a.a OR a.a IS NULL)
	CROSS JOIN(
		SELECT COUNTS=COUNT(*) FROM #t1
	)c
GROUP BY a.Description,a.sid,c.COUNTS
ORDER BY a.sid

