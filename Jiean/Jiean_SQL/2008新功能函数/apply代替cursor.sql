SQLServer2005和游标cursor说再见—apply运算符

使用 APPLY 运算符可以为实现查询操作的外部表表达式返回的每个行调用表值函数。表值函数作为右输入，
外部表表达式作为左输入。通过对右输入求值来获得左输入每一行的计算结果，生成的行被组合起来作为最终输出。

APPLY 运算符生成的列的列表是左输入中的列集，后跟右输入返回的列的列表。
 
APPLY 有两种形式： CROSS APPLY 和 OUTER APPLY。CROSS APPLY 仅返回外部表中通过表值函数生成结果集的行。
OUTER APPLY 既返回生成结果集的行，也返回不生成结果集的行，其中表值函数生成的列中的值为 NULL。

--以上是SQLServer 2005帮助中的讲解,下面还是看个例子吧
-- apply运算符的主要用途就是和表值函数配合,用来替代SQLServer 2000中的游标
--Create Employees table and insert values
--员工表 共四列 员工id 部门主管id 员工姓名 佣金
CREATE TABLE Employees
(
  empid   int         NOT NULL,
  mgrid   int         NULL,
  empname varchar(25) NOT NULL,
  salary  money       NOT NULL,
  CONSTRAINT PK_Employees PRIMARY KEY(empid),
)
GO
INSERT INTO Employees VALUES(1 , NULL, Nancy   , $10000.00)
INSERT INTO Employees VALUES(2 , 1   , Andrew  , $5000.00)
INSERT INTO Employees VALUES(3 , 1   , Janet   , $5000.00)
INSERT INTO Employees VALUES(4 , 1   , Margaret, $5000.00)
INSERT INTO Employees VALUES(5 , 2   , Steven  , $2500.00)
INSERT INTO Employees VALUES(6 , 2   , Michael , $2500.00)
INSERT INTO Employees VALUES(7 , 3   , Robert  , $2500.00)
INSERT INTO Employees VALUES(8 , 3   , Laura   , $2500.00)
INSERT INTO Employees VALUES(9 , 3   , Ann     , $2500.00)
INSERT INTO Employees VALUES(10, 4   , Ina     , $2500.00)
INSERT INTO Employees VALUES(11, 7   , David   , $2000.00)
INSERT INTO Employees VALUES(12, 7   , Ron     , $2000.00)
INSERT INTO Employees VALUES(13, 7   , Dan     , $2000.00)
INSERT INTO Employees VALUES(14, 11  , James   , $1500.00)
GO
--Create Departments table and insert values
--部门表 共散列 部门id 部门名称 外键部门主管id
CREATE TABLE Departments
(
  deptid    INT NOT NULL PRIMARY KEY,
  deptname  VARCHAR(25) NOT NULL,
  deptmgrid INT NULL REFERENCES Employees
)
GO
INSERT INTO Departments VALUES(1, HR,           2)
INSERT INTO Departments VALUES(2, Marketing,    7)
INSERT INTO Departments VALUES(3, Finance,      8)
INSERT INTO Departments VALUES(4, R&D,          9)
INSERT INTO Departments VALUES(5, Training,     4)
INSERT INTO Departments VALUES(6, Gardening, NULL)
Go
select * from employees
select * from Departments
 
结果:
 
--表值函数 根据部门主管id 查询出该部门主管下属员工
--with是CTE语法,不了解的先查询SQLServer 2005帮助
CREATE FUNCTION dbo.fn_getsubtree(@empid AS INT) RETURNS @TREE TABLE
(
  empid   INT NOT NULL,
  empname VARCHAR(25) NOT NULL,
  mgrid   INT NULL,
  lvl     INT NOT NULL
)
AS
BEGIN
  WITH Employees_Subtree(empid, empname, mgrid, lvl)
  AS
  (
    -- Anchor Member (AM)
    SELECT empid, empname, mgrid, 0
    FROM employees
    WHERE empid = @empid
 
    UNION all
  
    -- Recursive Member (RM)
    SELECT e.empid, e.empname, e.mgrid, es.lvl+1
    FROM employees AS e
      JOIN employees_subtree AS es
        ON e.mgrid = es.empid
  )
  INSERT INTO @TREE
    SELECT * FROM Employees_Subtree
 
  RETURN
END
GO
-- 根据上面的表值函数我们可以很方便的查询出某个部门主管的下属都是谁
--但是,如果查询出所有部门主管的下属就麻烦了,需要使用游标
 
--定义表变量临时存放数据
declare @tem table(
empid   int,
mgrid   int,
empname varchar(25),
lvl int,
deptid    INT,
deptname  VARCHAR(25),
deptmgrid INT
)
 
DECLARE @ids int
 
DECLARE test_cursor CURSOR FOR
select deptmgrid FROM Departments
 
OPEN test_cursor
 
FETCH NEXT FROM test_cursor
INTO @ids
WHILE @@FETCH_STATUS = 0
begin
    insert into @tem select empid, mgrid, empname, lvl, deptid, deptname, deptmgrid from dbo.fn_getsubtree(@ids) left join Departments on deptmgrid=@ids
FETCH NEXT FROM test_cursor
INTO @ids
end
 
CLOSE test_cursor
DEALLOCATE test_cursor
 
select * from @tem
 
结果:
 
--游标效率太差,万不得已不要使用,SQLServer2005的apply运算符可以替代它
SELECT *
FROM Departments AS D
  CROSS APPLY fn_getsubtree(D.deptmgrid) AS ST
SELECT *
FROM Departments AS D
  OUTER APPLY fn_getsubtree(D.deptmgrid) AS ST
 
结果:
 
===================================================
最后一行数据体现出CROSS APPLY和OUTER APPLY的不同,这有点类似Inner join和left join的区别.