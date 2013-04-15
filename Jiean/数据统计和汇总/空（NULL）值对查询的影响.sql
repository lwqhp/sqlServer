
/*
空null 值表示数值未知，不可用或将在以后添加的数据，空值不同于空白或零值，没有两个相等的空值。比较两个空值，或将空值与任何其他数据想比较均返回未知nuknown
*/ 
-- NULL 对 IN 及 NOT IN 查询的影响测试

-- 测试数据
DECLARE @1 TABLE(
	col1 int)

INSERT @1 SELECT 1
UNION ALL SELECT NULL
UNION ALL SELECT 2

DECLARE @2 TABLE(
	col1 int)

INSERT @2 SELECT 1

-- 查询
SELECT
	[@1总记录数] = COUNT(*)
FROM @1
-- 结果: 3

SELECT
	[@1在@2表中存在的记录数] = COUNT(*)
FROM @1
WHERE col1 IN(
		SELECT col1 FROM @2)
-- 结果: 1

SELECT 
	[@1在@2表中存在的记录数] = COUNT(*)
FROM @1
WHERE col1 NOT IN(
		SELECT col1 FROM @2)
-- 结果: 1
-- 查询结果说明: NULL 值不会匹配 @2 中的任何记录, 故 NOT IN 的查询只会检查 @1 中非 NULL 的两条记录


-- 在@2中插入一条NULL值
INSERT @2 SELECT NULL

SELECT
	[@1在@2表中存在的记录数] = COUNT(*)
FROM @1
WHERE col1 IN(
		SELECT col1 FROM @2)
-- 结果: 1


SELECT
	[@1在@2表中存在的记录数] = COUNT(*)
FROM @1
WHERE col1 NOT IN(		
		SELECT col1 FROM @2)
-- 结果: 0
-- 查询结果说明: @2 中包含 NULL 值记录, 而 NOT IN 要检查所有的记录是否匹配, 所以任何一条 @1 的记录都会与 @2 的所有记录做是否匹配, 由于 @2 中 NULL 值记录的存在, 故每条 @1 记录与 @2 表匹配的结果是 NULL, 故此查询返回 0 条记录
GO




-- 使用 EXISTS 查询避免 NULL 值对查询结果的影响
-- 测试数据
DECLARE @1 TABLE(
	col1 int)

INSERT @1 SELECT 1
UNION ALL SELECT NULL
UNION ALL SELECT 2

DECLARE @2 TABLE(
	col1 int)

INSERT @2 SELECT 1
UNION ALL SELECT NULL

SELECT
	[@1在@2表中存在的记录数] = COUNT(*) 
FROM @1 A
WHERE EXISTS(
		SELECT * FROM @2
		WHERE col1 = A.col1)
-- 结果: 1

SELECT
	[@1在@2表中存在的记录数] = COUNT(*) 
FROM @1 a
WHERE NOT EXISTS(
		SELECT * FROM @2
		WHERE col1 = A.col1)
-- 结果: 2
