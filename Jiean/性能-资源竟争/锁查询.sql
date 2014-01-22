

USE AdventureWorks
go

BEGIN TRAN 
SELECT productID,modifieddate
FROM production.ProductDocument WITH (TABLOCK)

--�����ѯ
SELECT 
request_session_id,
resource_type,
resource_database_id,
OBJECT_NAME(resource_associated_entity_id,resource_database_id),
request_mode,
request_status
 FROM sys.dm_tran_locks
WHERE resource_type IN('database','object')
/*
resource_typeָ����������Դ���ͣ�����Χ�����ͣ�
resource_associated_entity_id ������Դ���ͣ�
1��������а�������ID��object���͵ģ�������sys.objects ��ͼ������
2��������а������䵥ԪID(������allocation_unit),��������sys.allocation_units ��container_id,Ȼ����Խ�
	container_id ���ᵽsys.partitions�ϣ���ʱ�Ϳ���ȷ������ID��
3)����ð���hobt ID(��Դ����Ϊkey,page,row,hobt),����ֱ������sys.partitions,Ȼ�������Ӧ�Ķ���ID
4������database,extent,application��metadata����Դ���ͣ�����ֵΪ0
*/

--���Ľ���
/*
1��table,����Ĭ����Ϊ��������Ϊ��ֵʱ�����ڱ����������������������Ƿ�Ϊ������
2��auto����Ǳ��ѷ��������ڷ������𣨶ѻ�B���������������������δ�������������������ڱ����ϡ�
3��disable�ڱ���ɾ����������ע�⣬��������tablock��ʾ��ʹ�ÿ����л����뼶���¶ѵĲ�ѯʱ������Ȼ���ܿ�������
*/
ALTER TABLE person.Address
SET (lock_escalation=auto)




SELECT request_session_id	--������Դ����
,resource_type --��Դ��������
,request_status
,request_mode	--��������
,b.index_id  --����ID
,b.object_id,OBJECT_NAME(b.object_id),
* FROM sys.dm_tran_locks a
LEFT JOIN sys.partitions b ON a.resource_associated_entity_id= b.hobt_id
ORDER BY a.request_session_id,a.resource_type


---���ű�

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
 ע���ڿ��ظ����ļ����£�������Ҫ�����������ύ��ʱ����ͷ�
 */
 
 --A����
 SET TRAN ISOLATION LEVEL REPEATABLE READ --���ظ���
 GO
 SET STATISTICS PROFILE ON 
 GO
 
 --��ѯ1
 BEGIN TRAN 
 SELECT * FROM employee_demo_btree WHERE employeeid =3
 
 ROLLBACK TRAN
 
 --��ѯ2
 BEGIN TRAN 
 SELECT employeeid,loginid,title FROM employee_demo_heap WHERE employeeid=70
 
  ROLLBACK TRAN
  
 --��ѯ3
 BEGIN TRAN 
	UPDATE employee_demo_heap SET title = 'aaa' WHERE employeeid =70

ROLLBACK TRAN 

--ͬ�������������employee_demo_BTee��
 BEGIN TRAN 
	UPDATE employee_demo_Btree SET title = 'aaa' WHERE employeeid =70

ROLLBACK TRAN 