

--����Ⱥ�·���Ĳ�ѯ

--����ָ�����ڵ������
SELECT REPLICATE(' | ', E.lvl - M.lvl) + E.empname
FROM dbo.Employees AS E
  JOIN dbo.Employees AS M
    ON M.empid = 3 -- root
    AND E.path LIKE M.path + '%'
ORDER BY E.path;

-- ��������ų������ĸ��ڵ�
SELECT REPLICATE(' | ', E.lvl - M.lvl - 1) + E.empname
FROM dbo.Employees AS E
  JOIN dbo.Employees AS M
    ON M.empid = 3
    AND E.path LIKE M.path + '_%'
ORDER BY E.path;

-- Ҫ����ָ�����ڵ��µ�Ҷ���ڵ�(������ڵ���Ҷ���ڵ㣬��������ڵ㱾��)����������һ��not existsֻ�ҳ�����
--����Ա���ľ������ЩԱ��
SELECT E.empid, E.empname
FROM dbo.Employees AS E
  JOIN dbo.Employees AS M
    ON M.empid = 3
    AND E.path LIKE M.path + '%'
WHERE NOT EXISTS
  (SELECT * 
   FROM dbo.Employees AS E2
   WHERE E2.mgrid = E.empid);

-- ����ָ�����ڵ�������������Ƽ���
SELECT REPLICATE(' | ', E.lvl - M.lvl) + E.empname
FROM dbo.Employees AS E
  JOIN dbo.Employees AS M
    ON M.empid = 3
    AND E.path LIKE M.path + '%'
    AND E.lvl - M.lvl <= 2
ORDER BY E.path;

-- ֻ����ָ�����ڵ�ĵ�n���ڵ�
SELECT E.empid, E.empname
FROM dbo.Employees AS E
  JOIN dbo.Employees AS M
    ON M.empid = 3
    AND E.path LIKE M.path + '%'
    AND E.lvl - M.lvl = 2;

-- ����ָ���ڵ�Ĺ�����
SELECT REPLICATE(' | ', M.lvl) + M.empname
FROM dbo.Employees AS E
  JOIN dbo.Employees AS M
    ON E.empid = 14
    AND E.path LIKE M.path + '%'
ORDER BY E.path;


/*
�������Ƚڵ���ӽڵ������ܷ������в���
E.path like M.path +'%',����M.path �ǳ������������������������E.path�ǳ�����������������������ɨ�����е�
·��������ȷ�������ܷ�ƥ���ϡ�

�ṩһ�ֱ�ͨ��������
*/
SET NOCOUNT ON;
USE tempdb;
GO
--������
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

-- splitPath����������һ��Ա��ID��Ϊ���룬�����·����Ȼ�󷵻�һ����·����ÿ���ڵ�idλ�ڵ�����һ�С�
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



-- �����Ӹñ������Ϊ·���е��ض�Ա��idִ���������Ҳ���
SELECT REPLICATE(' | ', lvl) + empname
FROM dbo.SplitPath(14) AS SP
  JOIN dbo.Employees AS E
    ON E.empid = SP.empid
ORDER BY path;

-- ������˳����ʾ����Ա��
SELECT REPLICATE(' | ', lvl) + empname
FROM dbo.Employees
ORDER BY path;