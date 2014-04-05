

--带深度和路径的查询

--返回指定根节点的子树
SELECT REPLICATE(' | ', E.lvl - M.lvl) + E.empname
FROM dbo.Employees AS E
  JOIN dbo.Employees AS M
    ON M.empid = 3 -- root
    AND E.path LIKE M.path + '%'
ORDER BY E.path;

-- 从输出中排除子树的根节点
SELECT REPLICATE(' | ', E.lvl - M.lvl - 1) + E.empname
FROM dbo.Employees AS E
  JOIN dbo.Employees AS M
    ON M.empid = 3
    AND E.path LIKE M.path + '_%'
ORDER BY E.path;

-- 要返回指定根节点下的叶级节点(如果根节点是叶级节点，则包含根节点本身)，则可以添加一个not exists只找出不是
--其他员工的经理的那些员工
SELECT E.empid, E.empname
FROM dbo.Employees AS E
  JOIN dbo.Employees AS M
    ON M.empid = 3
    AND E.path LIKE M.path + '%'
WHERE NOT EXISTS
  (SELECT * 
   FROM dbo.Employees AS E2
   WHERE E2.mgrid = E.empid);

-- 返回指定根节点的子树，并限制级数
SELECT REPLICATE(' | ', E.lvl - M.lvl) + E.empname
FROM dbo.Employees AS E
  JOIN dbo.Employees AS M
    ON M.empid = 3
    AND E.path LIKE M.path + '%'
    AND E.lvl - M.lvl <= 2
ORDER BY E.path;

-- 只返回指定根节点的第n级节点
SELECT E.empid, E.empname
FROM dbo.Employees AS E
  JOIN dbo.Employees AS M
    ON M.empid = 3
    AND E.path LIKE M.path + '%'
    AND E.lvl - M.lvl = 2;

-- 返回指定节点的管理链
SELECT REPLICATE(' | ', M.lvl) + M.empname
FROM dbo.Employees AS E
  JOIN dbo.Employees AS M
    ON E.empid = 14
    AND E.path LIKE M.path + '%'
ORDER BY E.path;


/*
请求祖先节点和子节点在性能方面是有差别的
E.path like M.path +'%',这里M.path 是常量，可以利用索引，但如果E.path是常量，则不能利用索引，必须扫描所有的
路径，才能确定它们能否匹配上。

提供一种变通方法处理：
*/
SET NOCOUNT ON;
USE tempdb;
GO
--辅助表
IF OBJECT_ID('dbo.Nums') IS NOT NULL
  DROP TABLE dbo.Nums;
GO
CREATE TABLE dbo.Nums(n INT NOT NULL PRIMARY KEY);
DECLARE @max AS INT = 1000000, @rc AS INT = 1;

INSERT INTO Nums VALUES(1);
WHILE @rc * 2 <= @max
BEGIN
  INSERT INTO dbo.Nums SELECT n + @rc FROM dbo.Nums;
  SET @rc = @rc * 2;
END

INSERT INTO dbo.Nums 
  SELECT n + @rc FROM dbo.Nums WHERE n + @rc <= @max;
GO

-- splitPath函数，接受一个员工ID作为输入，拆分其路径，然后返回一个表，路径的每个节点id位于单独的一行。
USE tempdb;
GO
IF OBJECT_ID('dbo.SplitPath') IS NOT NULL
  DROP FUNCTION dbo.SplitPath;
GO
CREATE FUNCTION dbo.SplitPath(@empid AS INT) RETURNS TABLE
AS
RETURN
  SELECT
    ROW_NUMBER() OVER(ORDER BY n) AS pos,
    CAST(SUBSTRING(path, n + 1,
           CHARINDEX('.', path, n + 1) - n - 1) AS INT) AS empid
  FROM dbo.Employees
    JOIN dbo.Nums
      ON empid = @empid
      AND n < LEN(path)
      AND SUBSTRING(path, n, 1) = '.';
GO



-- 再联接该表和树，为路径中的特定员工id执行索引查找操作
SELECT REPLICATE(' | ', lvl) + empname
FROM dbo.SplitPath(14) AS SP
  JOIN dbo.Employees AS E
    ON E.empid = SP.empid
ORDER BY path;

-- 按拓扑顺序显示所有员工
SELECT REPLICATE(' | ', lvl) + empname
FROM dbo.Employees
ORDER BY path;