/*
����Inner join�Ǳ�ͱ�����Ӳ�ѯ����Cross apply�Ǳ�ͱ�ֵ���������Ӳ�ѯ�� ����ͨ��inner joinʵ����ͬ��cross apply��ѯ��
ִ�й��̣�
Cross apply����ִ��TVF��table-valued functions����Ȼ��Ա�Studnet����ȫ��ɨ�裬����ͨ������sID����ƥ��ֵ��

Inner join�Ա�Student��Apply����ȫ��ɨ�裬Ȼ��ͨ����ϣƥ�����ƥ���sIDֵ��
�������������ܴ���ôInner join��ȫ��ɨ��ķ�ʱ���CPU��Դ��������
��Ȼ���������Cross applyʵ�ֵĲ�ѯ������ͨ��Inner joinʵ�֣���Cross apply���ܲ������õ�ִ�мƻ��͸��ѵ����ܣ���Ϊ������������ִ��֮ǰ���Ƽ��ϼ��롣 

SQL Server 2005 ���� cross apply �� outer apply ������䣬����������������ɶ�����أ� 
 
����֪���и� SQL Server 2000 ���и� cross join �����ڽ������ӵġ�
ʵ�������� cross apply �� outer apply �����ڽ������ӱ�ֵ���������ر������ĺ������ģ� 
����Ҫ������������Ĳ�������һ�����е��ֶΡ�������Ϳ�����Щ���첻�룬�뿴��������ӣ� 

cross apply�ǿ������ӱ�ֵ������ ��inner join������ ����������� ��Ȼ�������ӵĲ��Ǻ�����ʱ�� cross apply ����ģ��inner join 
 */
-- 1. cross join ����������
select *
  from TABLE_1 as T1
 cross join TABLE_2 as T2
 
-- 2. cross join ���ӱ�ͱ�ֵ��������ֵ�����Ĳ����Ǹ���������
select *
  from TABLE_1 T1
 cross join FN_TableValue(100)
 
-- 3. cross join  ���ӱ�ͱ�ֵ��������ֵ�����Ĳ����ǡ���T1�е��ֶΡ�
select *
  from TABLE_1 T1
 cross join FN_TableValue(T1.column_a)
 
Msg 4104, Level 16, State 1, Line 1
The multi-part identifier "T1.column_a" could not be bound.
���������ѯ���﷨�д����� cross join ʱ����ֵ�����Ĳ��������Ǳ� T1 ���ֶΣ� Ϊɶ�����������أ��Ҳ¿���΢��ʱû�м�������ܣ����������пͻ���Թ�� ����΢��������� cross apply �� outer apply �����ƣ��뿴 cross apply, outer apply �����ӣ� 
 
 
-- 4. cross apply
select *
  from TABLE_1 T1
 cross apply FN_TableValue(T1.column_a)
 
-- 5. outer apply
select *
  from TABLE_1 T1
 outer apply FN_TableValue(T1.column_a)
 
cross apply �� outer apply ���� T1 �е�ÿһ�ж�����������ֵ��������T1��ǰ���������ɵĶ�̬�������
 ����һ���������ӡ�cross apply �� outer apply ���������ڣ� 
 ������� T1 ��ĳ���������ɵ�������Ϊ�գ�cross apply ��Ľ���� �Ͳ����� T1 �е��������ݣ�
 �� outer apply �Ի�����������ݣ�����������������ֶ�ֵ��Ϊ NULL�� 
 
���������ժ��΢�� SQL Server 2005 �������������������չ���� cross apply �� outer apply �Ĳ�֮ͬ���� 
 
ע�� outer apply ������ж�������һ�С� �� Departments �����һ���ڽ��н�������ʱ��deptmgrid Ϊ NULL��fn_getsubtree(D.deptmgrid) ���ɵ���������û�����ݣ��� outer apply �Ի������һ�����ݣ���������� cross join �Ĳ�֮ͬ���� 
 

 ----------------------------------------------------------------------------------------------------
-- create Employees table and insert values
IF OBJECT_ID('Employees') IS NOT NULL
 DROP TABLE Employees
GO
CREATE TABLE Employees
(
 empid INT NOT NULL,
 mgrid INT NULL,
 empname VARCHAR(25) NOT NULL,
 salary MONEY NOT NULL
)
GO
IF OBJECT_ID('Departments') IS NOT NULL
 DROP TABLE Departments
GO
-- create Departments table and insert values
CREATE TABLE Departments
(
 deptid INT NOT NULL PRIMARY KEY,
 deptname VARCHAR(25) NOT NULL,
 deptmgrid INT
)
GO

select * from Departments
select * from Employees

 
-- fill datas
INSERT  INTO employees VALUES  (1,NULL,'Nancy',00.00)
INSERT  INTO employees VALUES  (2,1,'Andrew',00.00)
INSERT  INTO employees VALUES  (3,1,'Janet',00.00)
INSERT  INTO employees VALUES  (4,1,'Margaret',00.00)
INSERT  INTO employees VALUES  (5,2,'Steven',00.00)
INSERT  INTO employees VALUES  (6,2,'Michael',00.00)
INSERT  INTO employees VALUES  (7,3,'Robert',00.00)
INSERT  INTO employees VALUES  (8,3,'Laura',00.00)
INSERT  INTO employees VALUES  (9,3,'Ann',00.00)
INSERT  INTO employees VALUES  (10,4,'Ina',00.00)
INSERT  INTO employees VALUES  (11,7,'David',00.00)
INSERT  INTO employees VALUES  (12,7,'Ron',00.00)
INSERT  INTO employees VALUES  (13,7,'Dan',00.00)
INSERT  INTO employees VALUES  (14,11,'James',00.00)
 
INSERT  INTO departments VALUES  (1,'HR',2)
INSERT  INTO departments VALUES  (2,'Marketing',7)
INSERT  INTO departments VALUES  (3,'Finance',8)
INSERT  INTO departments VALUES  (4,'R&D',9)
INSERT  INTO departments VALUES  (5,'Training',4)
INSERT  INTO departments VALUES  (6,'Gardening',NULL)
GO
--SELECT * FROM departments
 
-- table-value function
IF OBJECT_ID('fn_getsubtree') IS NOT NULL
 DROP FUNCTION  fn_getsubtree
GO
CREATE  FUNCTION dbo.fn_getsubtree(@empid AS INT) 
RETURNS TABLE 
AS 
RETURN(
  WITH Employees_Subtree(empid, empname, mgrid, lvl)
  AS 
  (
    -- Anchor Member (AM)
    SELECT empid, empname, mgrid, 0
    FROM employees
    WHERE empid = @empid   
    UNION ALL
    -- Recursive Member (RM)
    SELECT e.empid, e.empname, e.mgrid, es.lvl+1
    FROM employees AS e
       join employees_subtree AS es
          ON e.mgrid = es.empid
  )
    SELECT * FROM Employees_Subtree
)
GO
 
-- cross apply query
SELECT  *
FROM Departments AS D
    CROSS APPLY fn_getsubtree(D.deptmgrid) AS ST
 
 
 
-- outer apply query
SELECT  *
FROM Departments AS D
    OUTER APPLY fn_getsubtree(D.deptmgrid) AS ST
    
    
---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------
create table #T(���� varchar(10))
insert into #T values('����')
insert into #T values('����')
insert into #T values(NULL )
 
 
create table #T2(���� varchar(10) , �γ� varchar(10) , ���� int)
insert into #T2 values('����' , '����' , 74)
insert into #T2 values('����' , '��ѧ' , 83)
insert into #T2 values('����' , '����' , 93)
insert into #T2 values(NULL , '��ѧ' , 50)
 
 SELECT * FROM #T
  SELECT * FROM #T2
--drop table #t,#T2
go
 
select 
    * 
from 
    #T a
cross apply
    (select �γ�,���� from #t2 where ����=a.����) b
 
/*
����         �γ�         ����
---------- ---------- -----------
����         ����         74
����         ��ѧ         83
����         ����         93
 
(3 ����Ӱ��)
 
*/
 
select 
    * 
from 
    #T a
outer apply
    (select �γ�,���� from #t2 where ����=a.����) b
/*
����         �γ�         ����
---------- ---------- -----------
����         ����         74
����         ��ѧ         83
����         ����         93
����         NULL       NULL
NULL       NULL       NULL
 
(5 ����Ӱ��)
 
 
*/ 
 
 ---------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------

 -- ��ʾ����
CREATE table  #A (
    id int)
INSERT #A
SELECT id = 1 UNION ALL
SELECT id = 2
 
CREATE table #B (
    id int)
INSERT #B
SELECT id = 1 UNION ALL
SELECT id = 3
 
 SELECT * FROM #A
  SELECT * FROM #b
-- 1. ������Ϊ��ʱ, APPLY��������CROSS JOIN�Ľ��һ��
SELECT *
FROM #A
    CROSS APPLY #B
 
-- 2. ������Ϊ������ʱ, ������APPLY������ģ��JOIN
-- 2.a ģ�� INNER JOIN
SELECT *
FROM #A A
    CROSS APPLY(
        SELECT * FROM #B
        WHERE id = A.id
    )B
 
-- 2.b ģ�� LEFT JOIN
SELECT *
FROM #A A
    OUTER APPLY(
        SELECT * FROM #B
        WHERE id = A.id
    )B
