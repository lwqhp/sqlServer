
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

--行号的性能
/*
行号：是按指定顺序为查询结果集中的行分配的连续整数。

Row_number()  函数按指定顺序为查询结果集中的行分配连续的整数，并可选择在每个分区内单独地分区。
排名计算的最佳索引是在分区列，排序列，覆盖列上创建的索引
*/


--SELECT * FROM dbo.Sales;

SELECT empid, qty,
  ROW_NUMBER() OVER(ORDER BY qty) AS rownum
FROM dbo.Sales
ORDER BY qty;
/*
计算排名值，优化吕需要先按分区列再按排序列对数据排序
如果已经有一个索引按请求的顺序维护这些数据，将直接按有序方式扫描该索引的叶级，否则，将扫描该数据并用排序运算符排序。

Sequence Project 运算符负责计算排名值。
对于每一个输入行，它都需要两个“标记”
1,该行是否是分区中的第一行，如果是是，sequence project 运算符将重置排名值
2,该行中的排序值是否不同于上一行？发果是，sequence project 运算将将按指定的排名函数据指示的那样递增该排名值。

Segment 运算符主要用于确定分组边界。
它在内存中保持一行，并与下一行比较，如果它们不同，则发送一个值，如果相同则发送一个不同的值。

为了生成一个标记（指示该行是否是分区中第一行的标记）,Segment运算符比较当前行和上一行的partition by 列值。很明显，
对于第一行，它会发送true,对于后面的行，它的输出取决于partition by列值是否有变化，
*/

--一个标准的排序语句
SELECT empid,
  (SELECT COUNT(*)
   FROM dbo.Sales AS S2
   WHERE S2.empid <= S1.empid) AS rownum
FROM dbo.Sales AS S1
ORDER BY empid;

/*
排序列empid 用的是聚集索引，该计划先完整地扫描这个表(clustered index scan)，返回所有行
对于由完整扫描所返回的每一行，nested loops运算符->调用通过统计行数生成行号的操作。
(每次行号计算都会调用一次对聚集索引的查找操作,然后再执行局部扫描操作(从链接列表的叶级开始到内部员工ID小于
或等于外部员工ID的最后一行))

性能分析
计划中有两个不同的运算符使用了聚集索引，第一个是完整扫描以返回所有行,第二个运算符先为每个外部行执行查找，再
执行局部扫描，以完成统计。
当计算表中第一行的rownum，sqlserver需要扫描索引中的1行，对于第二行，它需要扫描2行，对于第三行，它需要扫描3行
扫描的总行数是1+2+3+4+....n，这就是一个等差数列,求和公式:Sn=(a1+an)*n/2

当表中没有索引时，情况就更糟，每计算一个行号都需要扫描整个表。

基于游标的解决
一般来讲，应该避免使用游标，因为游标包含许多开销，会影响性能，然而，在这个示例中，除非分区非常小，否则游标解决
方案比sqlserver 2005之前版本中基于集合方法的速度更快，因为它只扫描数据一次，这意味着随着表越来越大，游标解决方案
的性能呈线性下降，而不像基于集合方案那样按n^2的速度下降

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


--比较计算行号的各种方法的基准测试
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