

--Insert表记录的性能
/*
insert 语句的数量对事务有影响，通过最小化insert语句的数量实现对事务日志的写操作(insert语句的数量是ceiling(log2(@max))+1)

*/
select ceiling(log(1000000))+1


/*
@rc中保存已插入到该表的行数，它先把n=1的行插入nums,然后@rc*2<=@max成立时执行循环，在每次迭代中，该过程把nums中所
有行的n值加上@rc后插入nums该方法每次迭代都会使nums表中的行数加倍，即先插入主{1}，然后是{2},{34},{5678}
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
  INSERT INTO dbo.Nums 
  SELECT n + @rc FROM dbo.Nums;
  SET @rc = @rc * 2;
END

INSERT INTO dbo.Nums 
  SELECT n + @rc FROM dbo.Nums WHERE n + @rc <= @max;
GO

--select count(*) from Nums


--性能比较
DECLARE @n AS BIGINT;
SET @n = 1000000;

WITH Nums AS
(
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM Nums WHERE n < @n
)
SELECT n FROM Nums
OPTION(MAXRECURSION 0);
GO

--优化方案1
/*
生成一个行数等于目标行数平方根的CTE（称之为base）,先交叉联接base的两个实例以得到目标行数，最后为结果生成用作
序号的行号。
*/
select SQRT(16) --开平方

DECLARE @n AS BIGINT;
SET @n = 1000000;

WITH Base AS
(
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM Base WHERE n < CEILING(SQRT(@n))
),
Expand AS
(
  SELECT 1 AS c
  FROM Base AS B1, Base AS B2
),
Nums AS
(
  SELECT ROW_NUMBER() OVER(ORDER BY c) AS n
  FROM Expand
)
SELECT n FROM Nums WHERE n <= @n
OPTION(MAXRECURSION 0);
GO


--优化方案3
/*
创建一个包含两行的cte,通过交叉联接上一个cte的两个实例，后面的每个cte都会倍增行的数量，对于N级的CTE（以0开始）
将得到2^2n个行
另一个cte用于生成行号，最后，外部查询筛选期望数量的行(where行号列<=input)。当你筛选行号<=某个值时，sqlserver
不会生成大于该值之后的行号。
*/
DECLARE @n AS BIGINT;
SET @n = 1000000;

WITH
L0   AS(SELECT 1 AS c UNION ALL SELECT 1),
L1   AS(SELECT 1 AS c FROM L0 AS A, L0 AS B),
L2   AS(SELECT 1 AS c FROM L1 AS A, L1 AS B),
L3   AS(SELECT 1 AS c FROM L2 AS A, L2 AS B),
L4   AS(SELECT 1 AS c FROM L3 AS A, L3 AS B),
L5   AS(SELECT 1 AS c FROM L4 AS A, L4 AS B),
Nums AS(SELECT ROW_NUMBER() OVER(ORDER BY c) AS n FROM L5)
SELECT n FROM Nums WHERE n <= @n;
GO

--优化方案4
/*
在UDF中封装逻辑，该解决方案的价值在于，在UDF的定义中无法修改maxrecursion,而该方案永远不会接近maxrecursion的限制
*/
IF OBJECT_ID('dbo.fn_nums') IS NOT NULL
  DROP FUNCTION dbo.Nums;
GO
CREATE FUNCTION dbo.fn_nums(@n AS BIGINT) RETURNS TABLE
AS
RETURN
  WITH
  L0   AS(SELECT 1 AS c UNION ALL SELECT 1),
  L1   AS(SELECT 1 AS c FROM L0 AS A, L0 AS B),
  L2   AS(SELECT 1 AS c FROM L1 AS A, L1 AS B),
  L3   AS(SELECT 1 AS c FROM L2 AS A, L2 AS B),
  L4   AS(SELECT 1 AS c FROM L3 AS A, L3 AS B),
  L5   AS(SELECT 1 AS c FROM L4 AS A, L4 AS B),
  Nums AS(SELECT ROW_NUMBER() OVER(ORDER BY c) AS n FROM L5)
  SELECT n FROM Nums WHERE n <= @n;
GO

-- Test function
SELECT * FROM dbo.fn_nums(8000) AS F;
GO

-----插入创建行号
/*
当要在插入的记录中创建行号时，先创建表，然后再加载数据，没有 select into方法快，因为insert select 总是被完
整记录日志
*/

create table #salern(emid varchar(5),rn int identity)
insert into #salern
select '1'