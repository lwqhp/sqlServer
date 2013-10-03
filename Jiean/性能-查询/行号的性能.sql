
CREATE TABLE dbo.Sales
(
  empid VARCHAR(10) NOT NULL PRIMARY KEY,
  mgrid VARCHAR(10) NOT NULL,
  qty   INT         NOT NULL
);

INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('A', 'Z', 300);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('B', 'X', 100);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('C', 'X', 200);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('D', 'Y', 200);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('E', 'Z', 250);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('F', 'Z', 300);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('G', 'X', 100);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('H', 'Y', 150);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('I', 'X', 250);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('J', 'Z', 100);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('K', 'Y', 200);

CREATE INDEX idx_qty_empid ON dbo.Sales(qty, empid);
CREATE INDEX idx_mgrid_qty_empid ON dbo.Sales(mgrid, qty, empid);
GO

--�кŵ�����
/*
�кţ��ǰ�ָ��˳��Ϊ��ѯ������е��з��������������

Row_number()  ������ָ��˳��Ϊ��ѯ������е��з�������������������ѡ����ÿ�������ڵ����ط�����
�������������������ڷ����У������У��������ϴ���������
*/


--SELECT * FROM dbo.Sales;

SELECT empid, qty,
  ROW_NUMBER() OVER(ORDER BY qty) AS rownum
FROM dbo.Sales
ORDER BY qty;
/*
��������ֵ���Ż�����Ҫ�Ȱ��������ٰ������ж���������
����Ѿ���һ�������������˳��ά����Щ���ݣ���ֱ�Ӱ�����ʽɨ���������Ҷ�������򣬽�ɨ������ݲ����������������

Sequence Project ����������������ֵ��
����ÿһ�������У�������Ҫ��������ǡ�
1,�����Ƿ��Ƿ����еĵ�һ�У�������ǣ�sequence project ���������������ֵ
2,�����е�����ֵ�Ƿ�ͬ����һ�У������ǣ�sequence project ���㽫����ָ��������������ָʾ����������������ֵ��

Segment �������Ҫ����ȷ������߽硣
�����ڴ��б���һ�У�������һ�бȽϣ�������ǲ�ͬ������һ��ֵ�������ͬ����һ����ͬ��ֵ��

Ϊ������һ����ǣ�ָʾ�����Ƿ��Ƿ����е�һ�еı�ǣ�,Segment������Ƚϵ�ǰ�к���һ�е�partition by ��ֵ�������ԣ�
���ڵ�һ�У����ᷢ��true,���ں�����У��������ȡ����partition by��ֵ�Ƿ��б仯��
*/

--һ����׼���������
SELECT empid,
  (SELECT COUNT(*)
   FROM dbo.Sales AS S2
   WHERE S2.empid <= S1.empid) AS rownum
FROM dbo.Sales AS S1
ORDER BY empid;

/*
������empid �õ��Ǿۼ��������üƻ���������ɨ�������(clustered index scan)������������
����������ɨ�������ص�ÿһ�У�nested loops�����->����ͨ��ͳ�����������кŵĲ�����
(ÿ���кż��㶼�����һ�ζԾۼ������Ĳ��Ҳ���,Ȼ����ִ�оֲ�ɨ�����(�������б��Ҷ����ʼ���ڲ�Ա��IDС��
������ⲿԱ��ID�����һ��))

���ܷ���
�ƻ�����������ͬ�������ʹ���˾ۼ���������һ��������ɨ���Է���������,�ڶ����������Ϊÿ���ⲿ��ִ�в��ң���
ִ�оֲ�ɨ�裬�����ͳ�ơ�
��������е�һ�е�rownum��sqlserver��Ҫɨ�������е�1�У����ڵڶ��У�����Ҫɨ��2�У����ڵ����У�����Ҫɨ��3��
ɨ�����������1+2+3+4+....n�������һ���Ȳ�����,��͹�ʽ:Sn=(a1+an)*n/2

������û������ʱ������͸��㣬ÿ����һ���кŶ���Ҫɨ��������

�����α�Ľ��
һ��������Ӧ�ñ���ʹ���α꣬��Ϊ�α������࿪������Ӱ�����ܣ�Ȼ���������ʾ���У����Ƿ����ǳ�С�������α���
������sqlserver 2005֮ǰ�汾�л��ڼ��Ϸ������ٶȸ��죬��Ϊ��ֻɨ������һ�Σ�����ζ�����ű�Խ��Խ���α�������
�����ܳ������½�����������ڼ��Ϸ���������n^2���ٶ��½�

*/

IF OBJECT_ID('dbo.Nums') IS NOT NULL
  DROP TABLE dbo.Nums;
GO
CREATE TABLE dbo.Nums(n INT NOT NULL PRIMARY KEY);
DECLARE @max AS INT, @rc AS INT;
SET @max = 1000000;
SET @rc = 1;

INSERT INTO Nums VALUES(1);
WHILE @rc * 2 <= @max
BEGIN
  INSERT INTO dbo.Nums SELECT n + @rc FROM dbo.Nums;
  SET @rc = @rc * 2;
END

INSERT INTO dbo.Nums 
  SELECT n + @rc FROM dbo.Nums WHERE n + @rc <= @max;
GO


--�Ƚϼ����кŵĸ��ַ����Ļ�׼����
SET NOCOUNT ON;
USE tempdb;
GO
IF OBJECT_ID('dbo.RNBenchmark') IS NOT NULL
  DROP TABLE dbo.RNBenchmark;
GO
IF OBJECT_ID('dbo.RNTechniques') IS NOT NULL
  DROP TABLE dbo.RNTechniques;
GO
IF OBJECT_ID('dbo.SalesBM') IS NOT NULL
  DROP TABLE dbo.SalesBM;
GO
IF OBJECT_ID('dbo.SalesBMIdentity') IS NOT NULL
  DROP TABLE dbo.SalesBMIdentity;
GO
IF OBJECT_ID('dbo.SalesBMCursor') IS NOT NULL
  DROP TABLE dbo.SalesBMCursor;
GO

CREATE TABLE dbo.RNTechniques
(
  tid INT NOT NULL PRIMARY KEY,
  technique VARCHAR(25) NOT NULL
);
INSERT INTO RNTechniques(tid, technique) VALUES(1, 'Set-Based 2000');
INSERT INTO RNTechniques(tid, technique) VALUES(2, 'IDENTITY');
INSERT INTO RNTechniques(tid, technique) VALUES(3, 'Cursor');
INSERT INTO RNTechniques(tid, technique) VALUES(4, 'ROW_NUMBER 2005');
GO

CREATE TABLE dbo.RNBenchmark
(
  tid       INT    NOT NULL REFERENCES dbo.RNTechniques(tid),
  numrows   INT    NOT NULL,
  runtimems BIGINT NOT NULL,
  PRIMARY KEY(tid, numrows)
);
GO

CREATE TABLE dbo.SalesBM
(
  empid INT NOT NULL IDENTITY PRIMARY KEY,
  qty   INT NOT NULL
);
CREATE INDEX idx_qty_empid ON dbo.SalesBM(qty, empid);
GO
CREATE TABLE dbo.SalesBMIdentity(empid INT, qty INT, rn INT IDENTITY);
GO
CREATE TABLE dbo.SalesBMCursor(empid INT, qty INT, rn INT);
GO

DECLARE
  @maxnumrows    AS INT,
  @steprows      AS INT,
  @curnumrows    AS INT,
  @dt            AS DATETIME;

SET @maxnumrows    = 100000;
SET @steprows      = 10000;
SET @curnumrows    = 10000;

WHILE @curnumrows <= @maxnumrows
BEGIN

  TRUNCATE TABLE dbo.SalesBM;
  INSERT INTO dbo.SalesBM(qty)
    SELECT CAST(1+999.9999999999*RAND(CHECKSUM(NEWID())) AS INT)
    FROM dbo.Nums
    WHERE n <= @curnumrows;

  -- 'Set-Based 2000'
  
  DBCC FREEPROCCACHE WITH NO_INFOMSGS;
  DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS;

  SET @dt = GETDATE();

  SELECT empid, qty,
    (SELECT COUNT(*)
     FROM dbo.SalesBM AS S2
     WHERE S2.qty < S1.qty
         OR (S2.qty = S1.qty AND S2.empid <= S1.empid)) AS rn
  FROM dbo.SalesBM AS S1
  ORDER BY qty, empid;

  INSERT INTO dbo.RNBenchmark(tid, numrows, runtimems)
    VALUES(1, @curnumrows, DATEDIFF(ms, @dt, GETDATE()));

  -- 'IDENTITY'
  
  TRUNCATE TABLE dbo.SalesBMIdentity;

  DBCC FREEPROCCACHE WITH NO_INFOMSGS;
  DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS;

  SET @dt = GETDATE();

  INSERT INTO dbo.SalesBMIdentity(empid, qty)
    SELECT empid, qty FROM dbo.SalesBM ORDER BY qty, empid;

  SELECT empid, qty, rn FROM dbo.SalesBMIdentity;

  INSERT INTO dbo.RNBenchmark(tid, numrows, runtimems)
    VALUES(2, @curnumrows, DATEDIFF(ms, @dt, GETDATE()));

  -- 'Cursor'

  TRUNCATE TABLE dbo.SalesBMCursor;

  DBCC FREEPROCCACHE WITH NO_INFOMSGS;
  DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS;

  SET @dt = GETDATE();

  DECLARE @empid AS INT, @qty AS INT, @rn AS INT;

  BEGIN TRAN

  DECLARE rncursor CURSOR FAST_FORWARD FOR
    SELECT empid, qty FROM dbo.SalesBM ORDER BY qty, empid;
  OPEN rncursor;

  SET @rn = 0;

  FETCH NEXT FROM rncursor INTO @empid, @qty;
  WHILE @@fetch_status = 0
  BEGIN
    SET @rn = @rn + 1;
    INSERT INTO dbo.SalesBMCursor(empid, qty, rn)
      VALUES(@empid, @qty, @rn);
    FETCH NEXT FROM rncursor INTO @empid, @qty;
  END

  CLOSE rncursor;
  DEALLOCATE rncursor;

  COMMIT TRAN

  SELECT empid, qty, rn FROM dbo.SalesBMCursor;

  INSERT INTO dbo.RNBenchmark(tid, numrows, runtimems)
    VALUES(3, @curnumrows, DATEDIFF(ms, @dt, GETDATE()));

  -- 'ROW_NUMBER 2005'

  DBCC FREEPROCCACHE WITH NO_INFOMSGS;
  DBCC DROPCLEANBUFFERS WITH NO_INFOMSGS;

  SET @dt = GETDATE();

  SELECT empid, qty, ROW_NUMBER() OVER(ORDER BY qty, empid) AS rn
  FROM dbo.SalesBM;

  INSERT INTO dbo.RNBenchmark(tid, numrows, runtimems)
    VALUES(4, @curnumrows, DATEDIFF(ms, @dt, GETDATE()));

  SET @curnumrows = @curnumrows + @steprows;

END
GO

-- Query Benchmark Results
SELECT numrows,
  [Set-Based 2000], [IDENTITY], [Cursor], [ROW_NUMBER 2005]
FROM (SELECT technique, numrows, runtimems
      FROM dbo.RNBenchmark AS B
        JOIN dbo.RNTechniques AS T
          ON B.tid = T.tid) AS D
PIVOT(MAX(runtimems) FOR technique IN(
  [Set-Based 2000], [IDENTITY], [Cursor], [ROW_NUMBER 2005])) AS P
ORDER BY numrows;
GO