

--生成序列连续区间

--生成测试数据:

if object_id('tbl')is not null drop table tbl
go
create table tbl(
id int not null
)
go
insert tbl
values(2),(3),(11),(12),(13),(27),(33),(34),(35),(42)


with startpoints as(
	--取出连续区间(孤岛)开始节点:已经不存在该节点的前一个连续节点
	select id,row_number()over(order by id) as rownum
	from tbl as a 
	where not exists(select 1 from tbl as b where b.id=a.id-1)
),
endpoinds as(
	--取出连续区间(孤岛)结束节点：已经不存在该节点的后一个连续节点
	select id,row_number()over(order by id) as rownum
	from tbl as a 
	where not exists(select 1 from tbl as b where b.id=a.id+1) 
)
select s.id as start_range,e.id as end_range
from startpoints as s
inner join endpoinds as e on e.rownum=s.rownum   

--子查询方法
/*
重点在于对连续空间的分组标识
1 2
2 2
4 5
5 5
找出连续空间：比当前id要大，但已不存在一个连续的ID就是这个连续空间的最大值(还有更好的方法)
*/
with tmp as(
  select id,
	(select min(b.id) 
	 from tbl b 
	 where b.id>=a.id and not exists (select * from tbl c where c.id=b.id+1)
     ) as grp
  from tbl a
)
select min(id) as start_range,max(id) as end_range
from tmp 
group by grp



--连续区间分组法
/*
对序列数据进行排序并生成序值列
通过连续数据对序值列的差都将是一个恒定值，来区分连续空间
1  1	0
2  2	0
4  3	1
5  4	1
10 5	5
11 6	5
*/
;with tmp as(
  select id,id-row_number()over(order by id) as diff from tbl
)
select min(id) as start_range,max(id) as end_range 
from tmp
group by diff

--有重复值的
;with tmp as(
  select id,id-DENSE_RANK()over(order by id) as diff from tbl
)
select min(id) as start_range,max(id) as end_range 
from tmp
group by diff



--时间序列，以4小时为一个固定间隔
IF OBJECT_ID('dbo.TempSeq', 'U') IS NOT NULL DROP TABLE dbo.TempSeq;

CREATE TABLE dbo.TempSeq
(
  seqval DATETIME NOT NULL
    CONSTRAINT PK_TempSeq PRIMARY KEY
);

INSERT INTO dbo.TempSeq(seqval) VALUES
  ('20090212 00:00'),
  ('20090212 04:00'),
  ('20090212 12:00'),
  ('20090212 16:00'),
  ('20090212 20:00'),
  ('20090213 08:00'),
  ('20090213 20:00'),
  ('20090214 00:00'),
  ('20090214 04:00'),
  ('20090214 12:00');
 
 --时间段的
WITH D AS
(
  SELECT seqval, DATEADD(hour, -4 * ROW_NUMBER() OVER(ORDER BY seqval), seqval) AS grp
  FROM dbo.TempSeq
)
SELECT MIN(seqval) AS start_range, MAX(seqval) AS end_range
FROM D
GROUP BY grp;



--一种特例--------------------------------------------------------------------------------------------

/*对于具有相同值的每个连续区间，找出其ID值的范围。
min	max	val
2	5	a
7	11	b
13	19	a
23	29	c
31	43	a
47	59	c
*/  
IF OBJECT_ID('dbo.T3') IS NOT NULL DROP TABLE dbo.T3;
CREATE TABLE dbo.T3
(
  id  INT         NOT NULL PRIMARY KEY,
  val VARCHAR(10) NOT NULL
);
GO

INSERT INTO dbo.T3(id, val) VALUES
  (2, 'a'),
  (3, 'a'),
  (5, 'a'),
  (7, 'b'),
  (11, 'b'),
  (13, 'a'),
  (17, 'a'),
  (19, 'a'),
  (23, 'c'),
  (29, 'c'),
  (31, 'a'),
  (37, 'a'),
  (41, 'a'),
  (43, 'a'),
  (47, 'c'),
  (53, 'c'),
  (59, 'c');

SELECT * FROM T3

SELECT id, val,
  ROW_NUMBER() OVER(ORDER BY id) AS rn_id,
  ROW_NUMBER() OVER(ORDER BY val, id) AS rn_val_id
FROM dbo.T3
ORDER BY id;

SELECT id, val,
  ROW_NUMBER() OVER(ORDER BY id)
    - ROW_NUMBER() OVER(ORDER BY val, id) AS diff
FROM dbo.T3
ORDER BY id;

WITH C AS
(
  SELECT id, val,
    ROW_NUMBER() OVER(ORDER BY id)
      - ROW_NUMBER() OVER(ORDER BY val, id) AS grp
  FROM dbo.T3
)
SELECT MIN(id) AS mn, MAX(id) AS mx, val
FROM C
GROUP BY val, grp
ORDER BY mn;
SELECT * FROM T3



--4）生成编号连续区间-------------------------------------------------------------------------------

/*--结果
a 2
a 3
a 6
a 8
col1       start_col2  end_col2    
---------- ----------- ----------- 
a          2           3
a          6           8
b          3           3
b          5           7
--*/

--测试数据
CREATE TABLE tb(
	col1 varchar(10),
	col2 int)
INSERT tb SELECT 'a', 2
UNION ALL SELECT 'a', 3
UNION ALL SELECT 'a', 6
UNION ALL SELECT 'a', 7
UNION ALL SELECT 'a', 8
UNION ALL SELECT 'b', 3
UNION ALL SELECT 'b', 5
UNION ALL SELECT 'b', 6
UNION ALL SELECT 'b', 7
GO

SELECT * FROM tb
-- 已用编号分布查询 - 临时表法
-- a. 开始编号
SELECT
	id = IDENTITY(int),
	col1,
	col2
INTO #1
FROM tb A
WHERE NOT EXISTS(
		SELECT * FROM tb
		WHERE col1 = A.col1
			AND col2 = A.col2 - 1)

SELECT * FROM #1
-- b. 结束编号
SELECT
	id = IDENTITY(int),
	col2
INTO #2
FROM tb A
WHERE NOT EXISTS(
		SELECT * FROM tb
		WHERE col1 = A.col1
			AND col2 = A.col2 + 1)
SELECT * FROM #2
-- c. 查询结果
SELECT
	A.col1, 
	start_col2 = A.col2,
	end_col2 = B.col2
FROM #1 A, #2 B
WHERE A.id = B.id
DROP TABLE #1, #2

GO


--B. 已用编号 - 子查询法
SELECT
	col1,
	start_col2 = col2,
	end_col2=(
			SELECT
				-- 最小一个结束编号即为当前记录开始编号之后的结束编号
				MIN(col2)
			FROM tb AA
			WHERE col1 = A.col1
				-- 开始编号之后的结束编号
				AND col2 >= A.col2
				AND NOT EXISTS(
						SELECT * FROM tb
						WHERE col1 = AA.col1
							AND col2 = AA.col2 + 1))
FROM tb A
WHERE NOT EXISTS( -- 筛选出开始编号的记录
		SELECT * FROM tb
		WHERE col1 = A.col1
			AND col2 = A.col2 - 1)
GO

-- 删除测试环境
DROP TABLE TB