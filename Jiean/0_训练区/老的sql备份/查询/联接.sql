-- 测试数据
DECLARE @a TABLE(
	id int)

INSERT @a SELECT 1
UNION ALL SELECT 2

DECLARE @b TABLE(
	id int)

INSERT @b SELECT 2
UNION ALL SELECT 3

-- 内联接
-- a. 使用 (INNER) JOIN 
SELECT
	* 
FROM @a A
	JOIN @b B
		ON A.id = B.id

-- b. 使用 WHERE 条件
SELECT
	*
FROM @a A, @b B
WHERE A.id = B.id
/*--结果(只返回两个表中 id 相同的记录)
id          id
----------- ----------- 
2           2
--*/

-- 左向外联接
-- a. 使用 LEFT JOIN
SELECT
	*
FROM @a A
	LEFT JOIN @b B
		ON A.id = B.id

-- B. 使用 *= (不建议再使用这种方式, 会产生不明确查询)
SELECT
	*
FROM @a A, @b B
WHERE A.id *= B.id 
/*--结果(返回@a(左边表)所有的记录,及@b(右边表)的id与@a表id匹配的记录),不匹配的用NULL表示
id          id 
----------- ----------- 
1           NULL
2           2
--*/

-- 右向外联接
-- a. 使用 RIGHT JOIN
SELECT
	*
FROM @a A
	RIGHT JOIN @b B
		ON A.id = B.id

-- b. 使用 = * (不建议再使用这种方式, 会产生不明确查询)
SELECT
	*
FROM @a A, @b B
WHERE A.id =* B.id
/*--结果(返回@b(右边表)所有的记录,及@a(左边表)的id与@b表id匹配的记录),不匹配的用NULL表示
id          id 
----------- ----------- 
2           2
NULL        3
--*/

-- 完整外部联接
SELECT
	*
FROM @a A
	FULL JOIN @b B
		ON A.id = B.id
/*--结果(返回@a与@b表所有的记录,id不匹配的用NULL表示
id          id 
----------- ----------- 
2           2
NULL        3
1           NULL
--*/

-- 交叉联接
-- a. 使用 CROSS JOIN
SELECT
	*
FROM @a A
	CROSS JOIN @b B

-- b. FROM 两个表, 不指定任何条件
SELECT
	*
FROM @a A, @b B
/*--结果(第一个表的每条记录与第二个表的所有记录匹配)
id          id 
----------- ----------- 
1           2
2           2
1           3
2           3
--*/
