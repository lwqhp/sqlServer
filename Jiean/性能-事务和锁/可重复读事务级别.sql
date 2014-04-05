
USE AdventureWorks
GO


SELECT EmployeeID, NationalIDNumber, ContactID, LoginID, ManagerID, Title, BirthDate, 
MaritalStatus, Gender, HireDate,  ModifiedDate 
INTO employee_demo_Btree
FROM HumanResources.Employee

ALTER TABLE employee_demo_Btree ADD CONSTRAINT PK_employee_demo_Btree PRIMARY KEY CLUSTERED(EmployeeID) 

CREATE NONCLUSTERED INDEX IX_employee_demo_Btree  ON employee_demo_Btree(ManagerID)

CREATE NONCLUSTERED INDEX IX_Employee_ModifiedDate_Demo_BTree ON employee_demo_Btree(ModifiedDate)

------

SELECT EmployeeID, NationalIDNumber, ContactID, LoginID, ManagerID, Title, BirthDate, MaritalStatus, Gender,
 HireDate,  ModifiedDate 
 INTO Employee_Demo_Heap
 FROM HumanResources.Employee
 
 ALTER TABLE Employee_Demo_Heap ADD CONSTRAINT PK_Employee_EmployeeID_Demo_Heap PRIMARY KEY NONCLUSTERED (EmployeeID)
 
 CREATE NONCLUSTERED INDEX IX_Employee_ManagerID_Demo_Heap ON Employee_Demo_Heap(ManagerID)
 
 CREATE NONCLUSTERED INDEX IX_Employee_ModifiedDate_Demo_Heap ON Employee_Demo_Heap(ModifiedDate)
 
 
 ------------
 /*
 注：在可重复读的级别下，共享锁要保留到事务提交的时候才释放
 */
 
 --A连接
 SET TRAN ISOLATION LEVEL REPEATABLE READ --可重复读
 GO
 SET STATISTICS PROFILE ON 
 GO
 
 --查询1
 BEGIN TRAN 
 SELECT * FROM employee_demo_btree WHERE employeeid =3
 
 ROLLBACK TRAN
 
 --查询2
 BEGIN TRAN 
 SELECT employeeid,loginid,title FROM employee_demo_heap WHERE employeeid=70
 
  ROLLBACK TRAN
  
 --查询3
 BEGIN TRAN 
	UPDATE employee_demo_heap SET title = 'aaa' WHERE employeeid =70

ROLLBACK TRAN 

--同样的语句运行在employee_demo_BTee上
 BEGIN TRAN 
	UPDATE employee_demo_Btree SET title = 'aaa' WHERE employeeid =70

ROLLBACK TRAN 