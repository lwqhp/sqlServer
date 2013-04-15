
/*
把表中字段记录根据一定的要求合并成一个字符串字段
*/

--3.3.1 使用游标法进行字符串合并处理的示例。
--处理的数据
CREATE TABLE tb(
	col1 varchar(10),
	col2 int)
INSERT tb SELECT 'a',1
UNION ALL SELECT 'a',2
UNION ALL SELECT 'b',1
UNION ALL SELECT 'b',2
UNION ALL SELECT 'b',3

--合并处理
--定义结果集表变量
DECLARE @t TABLE(
	col1 varchar(10),
	col2 varchar(100))

--定义游标并进行合并处理
DECLARE tb CURSOR LOCAL
FOR
SELECT 
	col1,col2 
FROM tb
ORDER BY  col1,col2
DECLARE 
	@col1_old varchar(10),
	@col1 varchar(10),
	@col2 int,
	@s varchar(100)
OPEN tb
FETCH tb INTO @col1,@col2
WHILE @@FETCH_STATUS = 0
BEGIN
	-- 如果 col 的当前记录值与上条记录一致, 表示仅需要做合并处理, 合并结果存入变量 @s 中
	IF @col1 = @col1_old  
		SELECT 
			@s = @s + ',' + CAST(@col2 as varchar)
	ELSE
	BEGIN
		-- 如果 col 的当前记录值与上条记录不一致, 则将之前的合并结果插入结果表
		INSERT @t
		SELECT
			@col1_old, @s
		WHERE @s IS NOT NULL

		-- 开始新的合并处理
		SELECT 
			@s = CAST(@col2 as varchar),
			@col1_old = @col1
	END
	FETCH tb INTO @col1,@col2
END
CLOSE tb
DEALLOCATE tb

-- 在结果表中插入最后一次合并的结果
INSERT @t
SELECT
	@col1_old, @s
WHERE @s IS NOT NULL

--显示结果并删除测试数据
SELECT * FROM @t
DROP TABLE tb
/*--结果
col1       col2
---------- -----------
a          1,2
b          1,2,3
--*/



/*==============================================*/


--3.3.2 使用用户定义函数，配合SELECT处理完成字符串合并处理的示例
--处理的数据
--处理的数据
CREATE TABLE tb(
	col1 varchar(10),
	col2 int)
INSERT tb SELECT 'a',1
UNION ALL SELECT 'a',2
UNION ALL SELECT 'b',1
UNION ALL SELECT 'b',2
UNION ALL SELECT 'b',3
GO

--合并处理函数
CREATE FUNCTION dbo.f_str(
	@col1 varchar(10)
)RETURNS varchar(100)
AS
BEGIN
	DECLARE
		@re varchar(100)
	SET @re = ''
	SELECT
		@re = @re + ',' + CAST(col2 as varchar)
	FROM tb
	WHERE col1 = @col1

	RETURN(STUFF(@re, 1, 1, ''))
END
GO

--调用函数
SELECT
	col1,
	col2 = dbo.f_str(col1)
FROM tb
GROUP BY col1

--删除测试
DROP TABLE tb
DROP FUNCTION dbo.f_str
/*--结果
col1       col2
---------- -----------
a          1,2
b          1,2,3
--*/


/*==============================================*/


--3.3.3 使用临时表实现字符串合并处理的示例
--处理的数据
CREATE TABLE tb(
	col1 varchar(10),
	col2 int)
INSERT tb SELECT 'a',1
UNION ALL SELECT 'a',2
UNION ALL SELECT 'b',1
UNION ALL SELECT 'b',2
UNION ALL SELECT 'b',3

--合并处理
-- a. 排序数据并存储结果到临时表
SELECT
	col1,
	col2 = CAST(col2 as varchar(100)) 
INTO #t FROM tb
ORDER BY col1,col2

DECLARE
	@col1 varchar(10),
	@col2 varchar(100)

-- b. 通过更新累计每组 col1 的 col2 列值
UPDATE #t SET 
	@col2 = CASE
				WHEN @col1 = col1 THEN @col2 + ',' + col2
				ELSE col2
			END,
	@col1 = col1,
	col2 = @col2
-- 显示更新处理后的临时表
SELECT * FROM #t
/*-- 结果
col1       col2
---------- -------------
a          1
a          1,2
b          1
b          1,2
b          1,2,3
--*/
--得到最终结果
SELECT 
	col1,
	col2 = MAX(col2)
FROM #t
GROUP BY col1
/*--结果
col1       col2
---------- -----------
a          1,2
b          1,2,3
--*/
--删除测试
DROP TABLE tb,#t

/*==============================================*/

--3.3.4.1 每组 <=2 条记录的合并
--处理的数据
CREATE TABLE tb(col1 varchar(10),col2 int)
INSERT tb SELECT 'a',1
UNION ALL SELECT 'a',2
UNION ALL SELECT 'b',1
UNION ALL SELECT 'b',2
UNION ALL SELECT 'c',3

--合并处理
SELECT col1,
    col2=CAST(MIN(col2) as varchar)
        +CASE 
            WHEN COUNT(*)=1 THEN ''
            ELSE ','+CAST(MAX(col2) as varchar)
        END
FROM tb
GROUP BY col1
DROP TABLE tb
/*--结果
col1       col2      
---------- ----------
a          1,2
b          1,2
c          3
--*/

--3.3.4.2 每组 <=3 条记录的合并
--处理的数据
CREATE TABLE tb(col1 varchar(10),col2 int)
INSERT tb SELECT 'a',1
UNION ALL SELECT 'a',2
UNION ALL SELECT 'b',1
UNION ALL SELECT 'b',2
UNION ALL SELECT 'b',3
UNION ALL SELECT 'c',3

--合并处理
SELECT col1,
    col2=CAST(MIN(col2) as varchar)
        +CASE 
            WHEN COUNT(*)=3 THEN ','
                +CAST((SELECT col2 FROM tb WHERE col1=a.col1 AND col2 NOT IN(MAX(a.col2),MIN(a.col2))) as varchar)
            ELSE ''
        END
        +CASE 
            WHEN COUNT(*)>=2 THEN ','+CAST(MAX(col2) as varchar)
            ELSE ''
        END
FROM tb a
GROUP BY col1
DROP TABLE tb
/*--结果
col1       col2
---------- ------------
a          1,2
b          1,2,3
c          3
--*/
GO
