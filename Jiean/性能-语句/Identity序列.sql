

--Identity序列
/*
有两种序弄机制方式：锁定和不锁定
锁定机制确保不出现间隔的序号，当需要递增时，锁定序列资源，当事务完成后才释放锁定。
*/

IF OBJECT_ID('dbo.Sequence') IS NOT NULL DROP TABLE dbo.Sequence;
CREATE TABLE dbo.Sequence(val INT);
GO
INSERT INTO dbo.Sequence VALUES(0);
GO
IF OBJECT_ID('dbo.GetSequence') IS NOT NULL
  DROP PROC dbo.GetSequence;
GO

--取序号存储过程
CREATE PROC dbo.GetSequence
  @val AS INT OUTPUT
AS
UPDATE dbo.Sequence
  SET @val = val = val + 1; --这是一种原子操作，@val和val同时作val+1操作
GO

--取序号
DECLARE @key AS INT;
EXEC dbo.GetSequence @val = @key OUTPUT;
SELECT @key;

-- 重置
UPDATE dbo.Sequence SET val = 0;
GO


--一次返回多个序号
ALTER PROC dbo.GetSequence
  @val AS INT OUTPUT,
  @n   AS INT = 1
AS
UPDATE dbo.Sequence
  SET @val = val = val + @n; --更新到最大值

SET @val = @val - @n + 1; --返回第一个值
GO

DECLARE @firstkey AS INT, @rc AS INT;

IF OBJECT_ID('tempdb..#CustsStage') IS NOT NULL DROP TABLE #CustsStage;

SELECT custid, ROW_NUMBER() OVER(ORDER BY (SELECT 0)) AS rownum
INTO #CustsStage 
FROM Performance.dbo.Customers
WHERE custname = N'Cust_1';

SET @rc = @@rowcount;
EXEC dbo.GetSequence @val = @firstkey OUTPUT, @n = @rc;

SELECT custid, @firstkey + rownum - 1 AS keycol
FROM #CustsStage;
GO


-----不锁定序号------------------------------------
/*
不锁定可以解决一定的并发问题，但有可能会出现间隔。
本质是只在递增序列值时锁定片该，防止多个进程获得相同的值，但不在事务持续期间被锁定。
*/

IF OBJECT_ID('dbo.Sequence') IS NOT NULL DROP TABLE dbo.Sequence;
CREATE TABLE dbo.Sequence(val INT IDENTITY);
GO


IF OBJECT_ID('dbo.GetSequence') IS NOT NULL
  DROP PROC dbo.GetSequence;
GO

CREATE PROC dbo.GetSequence
  @val AS INT OUTPUT
AS
BEGIN TRAN
  SAVE TRAN S1; --打开事务，只为创建一个保存点，
  INSERT INTO dbo.Sequence DEFAULT VALUES;
  SET @val = SCOPE_IDENTITY();
  ROLLBACK TRAN S1;--回滚不会撤销对变量的赋值，也不会撤销标识值的递增。
COMMIT TRAN--标识资源不会在外部事务持 续期间被锁定，而是只在递增时锁定片该。
GO

--取回序号
DECLARE @key AS INT;
EXEC dbo.GetSequence @val = @key OUTPUT;
SELECT @key;

-- 重置
TRUNCATE TABLE dbo.Sequence;
GO

/*
注：也可以不加事务，那样会造成序号的不断增长，需要清理
*/