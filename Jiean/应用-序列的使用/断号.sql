

--找出缺失值范围

-- dbo.NumSeq (numeric sequence with unique values, interval: 1)
IF OBJECT_ID('dbo.NumSeq', 'U') IS NOT NULL DROP TABLE dbo.NumSeq;

CREATE TABLE dbo.NumSeq
(
  seqval INT NOT NULL
    CONSTRAINT PK_NumSeq PRIMARY KEY
);

INSERT INTO dbo.NumSeq(seqval) VALUES
  (2),(3),(11),(12),(13),(27),(33),(34),(35),(42);
  
  SELECT * FROM NumSeq

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


--包含重复值的数字序列
IF OBJECT_ID('dbo.NumSeqDups', 'U') IS NOT NULL DROP TABLE dbo.NumSeqDups;

CREATE TABLE dbo.NumSeqDups
(
  seqval INT NOT NULL
);
CREATE CLUSTERED INDEX idx_seqval ON dbo.NumSeqDups(seqval);

INSERT INTO dbo.NumSeqDups(seqval) VALUES
  (2),(2),(2),(3),(11),(12),(12),(13),(27),(27),(27),(27),
  (33),(34),(34),(35),(35),(35),(42),(42);
  
  
--子查询方法
SELECT
  seqval + 1 AS start_range,
  (SELECT MIN(B.seqval)
   FROM dbo.BigNumSeq AS B
   WHERE B.seqval > A.seqval) - 1 AS end_range
FROM dbo.BigNumSeq AS A
WHERE NOT EXISTS(SELECT *
                 FROM dbo.BigNumSeq AS B
                 WHERE B.seqval = A.seqval + 1)
  AND seqval < (SELECT MAX(seqval) FROM dbo.BigNumSeq);
 
 /*
 主要看执行计划：
 关键看优化器采用什么方式来处理外部查询中由not exists谓词代表的"间断之前的值"。这里用了merge join运算符进行
 处理，对sequal上的索引进行两次有序扫描，对于近1千万行，这比对每一行进行一次查找操作要高效得多。接着只为筛 
 选出来的值，优倾听器使用索引查找操作，取回下一个序列值。
 */
 
 
 --------------------
 --方法2
 SELECT cur + 1 AS start_range, nxt - 1 AS end_range
FROM (SELECT
        seqval AS cur,
        (SELECT MIN(B.seqval)
         FROM dbo.BigNumSeq AS B
         WHERE B.seqval > A.seqval) AS nxt
      FROM dbo.BigNumSeq AS A) AS D
WHERE nxt - cur > 1;
/*
为了取回所的序列值，须要对过索引执行一次完整的扫描，对于每一行，再使用一个索引查找操作，返回其下一个值，每个
查找操作须花费3次逻辑读取，（索引有3级），所以查找就得需要大约3000000次逻辑读取。
*/

--方法3
WITH C AS
(
  SELECT seqval, ROW_NUMBER() OVER(ORDER BY seqval) AS rownum
  FROM dbo.BigNumSeq
)
SELECT Cur.seqval + 1 AS start_range, Nxt.seqval - 1 AS end_range
FROM C AS Cur
  JOIN C AS Nxt
    ON Nxt.rownum = Cur.rownum + 1
WHERE Nxt.seqval - Cur.seqval > 1;
/*
这里的merge join 开销相当大，这是按多对多联接进行处理的。
*/


--返回单个缺失值
SELECT n FROM dbo.Nums
WHERE n BETWEEN (SELECT MIN(seqval) FROM dbo.NumSeq)
            AND (SELECT MAX(seqval) FROM dbo.NumSeq)
  AND n NOT IN(SELECT seqval FROM dbo.NumSeq);
  
 --------------------------------- ---------------------------------
 --现有范围
 WITH StartingPoints AS
(
  SELECT seqval, ROW_NUMBER() OVER(ORDER BY seqval) AS rownum
  FROM dbo.BigNumSeq AS A
  WHERE NOT EXISTS
    (SELECT *
     FROM dbo.BigNumSeq AS B
     WHERE B.seqval = A.seqval - 1)
),
EndingPoints AS
(
  SELECT seqval, ROW_NUMBER() OVER(ORDER BY seqval) AS rownum
  FROM dbo.BigNumSeq AS A
  WHERE NOT EXISTS
    (SELECT *
     FROM dbo.BigNumSeq AS B
     WHERE B.seqval = A.seqval + 1)
)
SELECT S.seqval AS start_range, E.seqval AS end_range
FROM StartingPoints AS S
  JOIN EndingPoints AS E
    ON E.rownum = S.rownum;
    
  ---最好的处理方法
  SELECT seqval, ROW_NUMBER() OVER(ORDER BY seqval) AS rownum
FROM dbo.NumSeq;

SELECT seqval, seqval - ROW_NUMBER() OVER(ORDER BY seqval) AS diff
FROM dbo.NumSeq;

WITH D AS
(
  SELECT seqval, seqval - ROW_NUMBER() OVER(ORDER BY seqval) AS grp
  FROM dbo.BigNumSeq
)
SELECT MIN(seqval) AS start_range, MAX(seqval) AS end_range
FROM D
GROUP BY grp;

--时间段的
WITH D AS
(
  SELECT seqval, DATEADD(hour, -4 * ROW_NUMBER() OVER(ORDER BY seqval), seqval) AS grp
  FROM dbo.TempSeq
)
SELECT MIN(seqval) AS start_range, MAX(seqval) AS end_range
FROM D
GROUP BY grp;

--有重复值的
WITH D AS
(
  SELECT seqval, seqval - DENSE_RANK() OVER(ORDER BY seqval) AS grp
  FROM dbo.NumSeqDups
)
SELECT MIN(seqval) AS start_range, MAX(seqval) AS end_range
FROM D
GROUP BY grp;


--一种特例
/*对于具有相同状诚值的每个连续区间，找出其ID值的范围。*/  
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
