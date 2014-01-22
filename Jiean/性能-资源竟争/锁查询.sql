

USE AdventureWorks
go

BEGIN TRAN 
SELECT productID,modifieddate
FROM production.ProductDocument WITH (TABLOCK)

--锁活动查询
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
resource_type指定锁定的资源类型（锁范围的类型）
resource_associated_entity_id 依赖资源类型，
1）如果该列包含对象ID是object类型的，可以用sys.objects 视图来关联
2）如果该列包含分配单元ID(类型是allocation_unit),可以引用sys.allocation_units 和container_id,然后可以将
	container_id 联结到sys.partitions上，此时就可以确定对象ID了
3)如果该包含hobt ID(资源类型为key,page,row,hobt),可以直接引用sys.partitions,然后查找相应的对象ID
4）对于database,extent,application或metadata的资源类型，该列值为0
*/

--锁的禁用
/*
1，table,这是默认行为，当设置为该值时，就在表级别启用了锁升级，不论是否为分区表
2，auto如果是表已分区，则在分区级别（堆或B树）启用锁升级，如果表未分区，锁升级将发生在表级别上。
3，disable在表级别删除锁升级，注意，对于用了tablock提示或使用可序列化隔离级别下堆的查询时，你仍然可能看到表锁
*/
ALTER TABLE person.Address
SET (lock_escalation=auto)




SELECT request_session_id	--锁的来源进程
,resource_type --来源锁的类型
,request_status
,request_mode	--锁的名称
,b.index_id  --索引ID
,b.object_id,OBJECT_NAME(b.object_id),
* FROM sys.dm_tran_locks a
LEFT JOIN sys.partitions b ON a.resource_associated_entity_id= b.hobt_id
ORDER BY a.request_session_id,a.resource_type


---锁脚本

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