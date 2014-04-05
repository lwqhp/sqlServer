CREATE TABLE Bas_InterCompany(
	CompanyID VARCHAR(20),
	vendcustID VARCHAR(30),
	ParentID VARCHAR(30)
)
go
INSERT INTO Bas_InterCompany(CompanyID,vendcustID,ParentID)
VALUES('PT','PT0001',NULL),('PT','PT0002',NULL),('PT','PT0003','PT0001'),('PT','PT0004','PT0003')

--SELECT * FROM Bas_InterCompany

--添加一个节点
INSERT INTO Bas_InterCompany(CompanyID,vendcustID,ParentID)
SELECT 'PT','PT0007','PT0003'

--添加节点包含深度和路径
go
CREATE PROC dbo.AddEmp
  @empid   INT,
  @mgrid   INT,
  @empname VARCHAR(25),
  @salary  MONEY
AS

SET NOCOUNT ON;

-- 新员工没有经理(根节点)
IF @mgrid IS NULL
  INSERT INTO dbo.Employees(empid, mgrid, empname, salary, lvl, path)
    VALUES(@empid, @mgrid, @empname, @salary,
      0, '.' + CAST(@empid AS VARCHAR(10)) + '.');
-- 下属(非根节点)
ELSE
  INSERT INTO dbo.Employees(empid, mgrid, empname, salary, lvl, path)
    SELECT @empid, @mgrid, @empname, @salary, 
      lvl + 1, path + CAST(@empid AS VARCHAR(10)) + '.'
    FROM dbo.Employees
    WHERE empid = @mgrid;
GO