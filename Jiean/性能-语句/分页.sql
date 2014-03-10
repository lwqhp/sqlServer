

--分页

/*
如果不物理地从第1页访问到第n-1页，就不能访问第n页。
访问某一页：需要页号和页大小
*/

DECLARE @pagesize AS INT, @pagenum AS INT;
SET @pagesize = 5;
SET @pagenum = 2;

WITH SalesRN AS
(
  SELECT ROW_NUMBER() OVER(ORDER BY qty, empid) AS rownum,
    empid, mgrid, qty
  FROM dbo.Sales
)
SELECT rownum, empid, mgrid, qty
FROM SalesRN
WHERE rownum > @pagesize * (@pagenum-1)
  AND rownum <= @pagesize * @pagenum
ORDER BY rownum;
GO

/*
这个查询初看起来像是先做一次全表扫描，为所有的行计算行号，然后只筛选请求页中的行。
但从查询计划中可以看出，并非如此：
计划从sequence Project运算符(负责分配行号)开始左边的一部份，top运算答只扫描了表的前10行，然后filter运算符
只筛选出属于第2页的行.即使是对于通常“顺序向前移动”的多页请求(1,2,3页)，也具有良好的性能。
*/

--多页访问 
IF OBJECT_ID('tempdb..#SalesRN') IS NOT NULL
  DROP TABLE #SalesRN;
GO
SELECT ROW_NUMBER() OVER(ORDER BY qty, empid) AS rownum,
  empid, mgrid, qty
INTO #SalesRN
FROM dbo.Sales;

CREATE UNIQUE CLUSTERED INDEX idx_rn ON #SalesRN(rownum);
GO

-- Run for each page request
DECLARE @pagesize AS INT, @pagenum AS INT;
SET @pagesize = 5;
SET @pagenum = 2;

SELECT rownum, empid, mgrid, qty
FROM #SalesRN
WHERE rownum BETWEEN @pagesize * (@pagenum-1) + 1
                 AND @pagesize * @pagenum
ORDER BY rownum;
GO

-- Cleanup
DROP TABLE #SalesRN;
GO

/*
这是一个非常高效的计划查询，它在索引中搪行一个查找操作，以找到下边界所在的行，然后执行一次局部扫描，直到
到达上边界所在的行，整个过程整个在索引中扫描了被请页的行。也可以考虑表变量。
*/

--一个伤脑的子查询排名
SELECT empid, qty,
  (SELECT COUNT(*) FROM dbo.Sales AS S2
   WHERE S2.qty < S1.qty) + 1 AS rnk,
  (SELECT COUNT(DISTINCT qty) FROM dbo.Sales AS S2
   WHERE S2.qty < S1.qty) + 1 AS drnk
FROM dbo.Sales AS S1
ORDER BY qty;

--高效生成数字辅助表
SET NOCOUNT ON;
USE InsideTSQL2008;

IF OBJECT_ID('dbo.Nums') IS NOT NULL DROP TABLE dbo.Nums;

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

--函数
IF OBJECT_ID('dbo.GetNums') IS NOT NULL
  DROP FUNCTION dbo.GetNums;
GO
CREATE FUNCTION dbo.GetNums(@n AS BIGINT) RETURNS TABLE
AS
RETURN
  WITH
  L0   AS(SELECT 1 AS c UNION ALL SELECT 1),
  L1   AS(SELECT 1 AS c FROM L0 AS A CROSS JOIN L0 AS B),
  L2   AS(SELECT 1 AS c FROM L1 AS A CROSS JOIN L1 AS B),
  L3   AS(SELECT 1 AS c FROM L2 AS A CROSS JOIN L2 AS B),
  L4   AS(SELECT 1 AS c FROM L3 AS A CROSS JOIN L3 AS B),
  L5   AS(SELECT 1 AS c FROM L4 AS A CROSS JOIN L4 AS B),
  Nums AS(SELECT ROW_NUMBER() OVER(ORDER BY (SELECT 0)) AS n FROM L5)
  SELECT n FROM Nums WHERE n <= @n;
GO

-- Test function
SELECT * FROM dbo.GetNums(10) AS Nums;
GO