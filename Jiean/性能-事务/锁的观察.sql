

--���Ĺ۲�ʼ�

/*
?�鿴ǰ��sqlServer�����е����ӳ��е��������
*/
sp_lock

SELECT 
	resource_database_id --���ݿ�ID
	,resource_associated_entity_id --����ID
,* FROM sys.dm_tran_locks

/*
?����鿴ĳ���������ϳ�����Щ��

sys.dm_tran_locks ��sqlServer�����е�������������
sys.partitions    : ÿһ�������еı����������������
*/

SELECT 
b.object_id,OBJECT_NAME(b.object_id),
* FROM sys.dm_tran_locks a
LEFT JOIN sys.partitions b ON a.resource_associated_entity_id= b.hobt_id

/*
?�۲����ִ�й���������������ͷŹ���

SQL Server Profiler 
	Lock:Accquired
	Lock:Released
*/