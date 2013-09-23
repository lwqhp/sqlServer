SQLServer2005���α�cursor˵�ټ���apply�����

ʹ�� APPLY ���������Ϊʵ�ֲ�ѯ�������ⲿ����ʽ���ص�ÿ���е��ñ�ֵ��������ֵ������Ϊ�����룬
�ⲿ����ʽ��Ϊ�����롣ͨ������������ֵ�����������ÿһ�еļ����������ɵ��б����������Ϊ���������

APPLY ��������ɵ��е��б����������е��м�����������뷵�ص��е��б�
 
APPLY ��������ʽ�� CROSS APPLY �� OUTER APPLY��CROSS APPLY �������ⲿ����ͨ����ֵ�������ɽ�������С�
OUTER APPLY �ȷ������ɽ�������У�Ҳ���ز����ɽ�������У����б�ֵ�������ɵ����е�ֵΪ NULL��

--������SQLServer 2005�����еĽ���,���滹�ǿ������Ӱ�
-- apply���������Ҫ��;���Ǻͱ�ֵ�������,�������SQLServer 2000�е��α�
--Create Employees table and insert values
--Ա���� ������ Ա��id ��������id Ա������ Ӷ��
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
--���ű� ��ɢ�� ����id �������� �����������id
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
 
���:
 
--��ֵ���� ���ݲ�������id ��ѯ���ò�����������Ա��
--with��CTE�﷨,���˽���Ȳ�ѯSQLServer 2005����
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
-- ��������ı�ֵ�������ǿ��Ժܷ���Ĳ�ѯ��ĳ���������ܵ���������˭
--����,�����ѯ�����в������ܵ��������鷳��,��Ҫʹ���α�
 
--����������ʱ�������
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
 
���:
 
--�α�Ч��̫��,�򲻵��Ѳ�Ҫʹ��,SQLServer2005��apply��������������
SELECT *
FROM Departments AS D
  CROSS APPLY fn_getsubtree(D.deptmgrid) AS ST
SELECT *
FROM Departments AS D
  OUTER APPLY fn_getsubtree(D.deptmgrid) AS ST
 
���:
 
===================================================
���һ���������ֳ�CROSS APPLY��OUTER APPLY�Ĳ�ͬ,���е�����Inner join��left join������.