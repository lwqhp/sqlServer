

--�ҳ�ȱʧֵ��Χ

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

--������У��ɲ�����
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
    
    --ʱ�����У���4СʱΪһ���̶����
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


--�����ظ�ֵ����������
IF OBJECT_ID('dbo.NumSeqDups', 'U') IS NOT NULL DROP TABLE dbo.NumSeqDups;

CREATE TABLE dbo.NumSeqDups
(
  seqval INT NOT NULL
);
CREATE CLUSTERED INDEX idx_seqval ON dbo.NumSeqDups(seqval);

INSERT INTO dbo.NumSeqDups(seqval) VALUES
  (2),(2),(2),(3),(11),(12),(12),(13),(27),(27),(27),(27),
  (33),(34),(34),(35),(35),(35),(42),(42);
  
  
--�Ӳ�ѯ����
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
 ��Ҫ��ִ�мƻ���
 �ؼ����Ż�������ʲô��ʽ�������ⲿ��ѯ����not existsν�ʴ����"���֮ǰ��ֵ"����������merge join���������
 ������sequal�ϵ�����������������ɨ�裬���ڽ�1ǧ���У���ȶ�ÿһ�н���һ�β��Ҳ���Ҫ��Ч�öࡣ����ֻΪɸ 
 ѡ������ֵ����������ʹ���������Ҳ�����ȡ����һ������ֵ��
 */
 
 
 --------------------
 --����2
 SELECT cur + 1 AS start_range, nxt - 1 AS end_range
FROM (SELECT
        seqval AS cur,
        (SELECT MIN(B.seqval)
         FROM dbo.BigNumSeq AS B
         WHERE B.seqval > A.seqval) AS nxt
      FROM dbo.BigNumSeq AS A) AS D
WHERE nxt - cur > 1;
/*
Ϊ��ȡ����������ֵ����Ҫ�Թ�����ִ��һ��������ɨ�裬����ÿһ�У���ʹ��һ���������Ҳ�������������һ��ֵ��ÿ��
���Ҳ����뻨��3���߼���ȡ����������3���������Բ��Ҿ͵���Ҫ��Լ3000000���߼���ȡ��
*/

--����3
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
�����merge join �����൱�����ǰ���Զ����ӽ��д���ġ�
*/


--���ص���ȱʧֵ
SELECT n FROM dbo.Nums
WHERE n BETWEEN (SELECT MIN(seqval) FROM dbo.NumSeq)
            AND (SELECT MAX(seqval) FROM dbo.NumSeq)
  AND n NOT IN(SELECT seqval FROM dbo.NumSeq);
  
 --------------------------------- ---------------------------------
 --���з�Χ
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
    
  ---��õĴ�����
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

--ʱ��ε�
WITH D AS
(
  SELECT seqval, DATEADD(hour, -4 * ROW_NUMBER() OVER(ORDER BY seqval), seqval) AS grp
  FROM dbo.TempSeq
)
SELECT MIN(seqval) AS start_range, MAX(seqval) AS end_range
FROM D
GROUP BY grp;

--���ظ�ֵ��
WITH D AS
(
  SELECT seqval, seqval - DENSE_RANK() OVER(ORDER BY seqval) AS grp
  FROM dbo.NumSeqDups
)
SELECT MIN(seqval) AS start_range, MAX(seqval) AS end_range
FROM D
GROUP BY grp;


--һ������
/*���ھ�����ͬ״��ֵ��ÿ���������䣬�ҳ���IDֵ�ķ�Χ��*/  
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
