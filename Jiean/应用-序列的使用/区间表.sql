
--区间表
/*
 把判断标准按区间划分，以判断数据在区间的分布情况，和找出对应的区间
 
 3）生成区间表
 4）生成连续编号区间

*/

--1）分数区间
SELECT sid=1,a=NULL,b=30  ,Description='<30' UNION ALL
	SELECT sid=2,a=30  ,b=60  ,Description='>=30 and <60' UNION ALL
	SELECT sid=3,a=60  ,b=75  ,Description='>=60 and <75' UNION ALL
	SELECT sid=4,a=75  ,b=95  ,Description='>=75 and <95' UNION ALL
	SELECT sid=5,a=95  ,b=NULL,Description='>=95' 
	
--2）容器分段区间
SELECT sid=1,a=NULL,b=200  ,Description='>200' UNION ALL
	SELECT sid=2,a=200  ,b=180  ,Description='<=200 and >180' UNION ALL
	SELECT sid=3,a=180  ,b=100  ,Description='<=180 and >100' UNION ALL
	SELECT sid=4,a=100  ,b=50  ,Description='<=100 and >50' UNION ALL
	SELECT sid=5,a=50  ,b=NULL,Description='<=95' 	

--3）生成脚本------------------------------------------------------------------------------

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



--大表序列，可测性能
IF OBJECT_ID('dbo.BigNumSeq', 'U') IS NOT NULL DROP TABLE dbo.BigNumSeq;

CREATE TABLE dbo.BigNumSeq
(
  seqval INT NOT NULL
    CONSTRAINT PK_BigNumSeq PRIMARY KEY
);

-- Populate table with values in the range 1 through to 10,000,000
-- with a gap every 1000 (total 9,999 gaps, 10,000 islands)
WITH
L0   AS(SELECT 1 AS c UNION ALL SELECT 1),
L1   AS(SELECT 1 AS c FROM L0 AS A, L0 AS B),
L2   AS(SELECT 1 AS c FROM L1 AS A, L1 AS B),
L3   AS(SELECT 1 AS c FROM L2 AS A, L2 AS B),
L4   AS(SELECT 1 AS c FROM L3 AS A, L3 AS B),
L5   AS(SELECT 1 AS c FROM L4 AS A, L4 AS B),
Nums AS(SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0)) AS n FROM L5)
INSERT INTO dbo.BigNumSeq WITH(TABLOCK) (seqval)
  SELECT n
  FROM Nums
  WHERE n <= 10000000
    AND n % 1000 <> 0;