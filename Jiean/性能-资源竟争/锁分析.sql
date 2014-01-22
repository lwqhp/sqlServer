
USE AdventureWorks
go

BEGIN TRAN 
SELECT productID,modifieddate
FROM production.ProductDocument WITH (TABLOCK)

rollback tran 

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

-------------------------------------------------------------------------------------------------------------

--B����

/*
sys.dm_tran_locks ����ͼ������ѯ�����Ժ�����A�����е���
*/
USE AdventureWorks
GO


SELECT request_session_id	--������Դ����
,resource_type --��Դ��������
,request_status
,request_mode	--��������
,b.index_id  --����ID
,b.object_id,OBJECT_NAME(b.object_id),
* FROM sys.dm_tran_locks a
LEFT JOIN sys.partitions b ON a.resource_associated_entity_id= b.hobt_id
ORDER BY a.request_session_id,a.resource_type

/*
1,database ��Ϊ�������ڷ������ݿ�adventureworks,�����������ݿ�һ������һ�����������Է�ֹ���˽����ݿ�ɾ����
2��object ��Ϊ���ڷ��ʱ�������ڱ���ϼ���һ�������������Է������޸ı�Ķ��塣
3��key,Page ��ѯ��1����¼���أ�������������¼���ڵľۼ��������ϣ�����һ��������������������ڵ�ҳ���ϣ�����һ������������

�ܽ᣺�����ѯ����������Ŀ�Ǻ��ٵġ������û�����ͬһ�ű�ֻҪ������������¼���Ͳ��ᱻӰ�쵽��������Ϊ��ѯ
ʹ����clustered index seek �Ĺ�ϵ��
*/

-----------------

--��ѯ2
/*
��Ϊ��Empoyee_demo_Heap��EmployeeID����һ���Ǿۼ�����������SQLServer���÷Ǿۼ������ҵ�������¼�󣬱����ٵ�
����ҳ���ϰ�������������������ҳ���(��ν��Bookmark Lookup),��Ȼֻ����һ����¼����������PK_employee_demo_heap
��������һ��KEY������RID��data page �ϵ�row��������һ��row��������������Դ���ڵ�ҳ���ϸ�������һ��page��������

�ܽ᣺��Ȼ���صĽ���Ͳ�ѯ1һ��������������ʹ�õ��ǷǾۼ�����+bookmark lookup,���������������ĿҪ�Ȳ�ѯ1�ࡣ
һ����ѯҪʹ�õ�������(����RID)��ĿԽ�࣬���������Ҳ�ͻ�Խ�࣬û��ʹ�õ��������ϲ������빲������
*/


--��ѯ3
SET STATISTICS PROFILE ON

BEGIN TRAN 
SELECT employeeid,loginID,title 
FROM employee_demo_heap WHERE employeeID IN(3,30,200)

/*
����Ҫ����3���ֲ��ڲ�ͬ����ҳ�ϵļ�¼��SQLServer��Ϊ���Ǿۼ�����+Bookmark Lookup��������һ����ɨ��죬������
ֱ��ѡ����һ����ɨ�裬������ִ�мƻ������ʲô����Ч���أ�

��ѯ3��1:4621:22 4621ҳ��Ķ�����22�У������ҳ��������һ��������������������������Ϊ��һ�������
�޸���һ�еļ�¼���Ѿ������һ�����������������Բ�ѯ3�������ˡ�

����һ�α�ɨ����������ҳ������ĺ����

��ѯ3�����ڼ�¼ҳ�������������������ڱ�������ҳ���϶�����������������ѯ3��ɨ��ÿһ��ҳ���ʱ�䣬��Զ�����
ÿһ�����ݼ�¼����һ����������������������¼�ͻ��ͷţ����õȵ���������������ֻҪ���κ�һ����¼�ϵ���û������
������ѯ�ͻᱻ����ס��
*/

ROLLBACK TRAN 

--ͬ���Ĳ�ѯ��������employee_demo_Btree��
BEGIN TRAN 
SELECT employeeid,loginID,title 
FROM employee_demo_Btree WHERE employeeID IN(3,30,200)

/*
û�з���������������Ϊ��ѯʹ�õ���index seek,����Ҫÿ����¼����һ�飬���ԾͲ���ȥ��employeeid=70,Ҳ�Ͳ��ᱻ����ס
*/


/*
�ܽ᣺

�ڷǡ�δ�ύ���� �ĸ��뼶����

1,��ѯ�����еĹ����У����ÿһ�������ļ�¼���ֵ�ӹ������������¼���÷��أ������ͻᱻ�ͷţ������¼��Ҫ���أ�
���Ӹ��뼶������������"���ύ��"����Ҳ�ͷţ������ͷš�

2����ÿһ��ʹ�õ�������sqlserverҲ�������ļ�ֵ�ӹ�������

3����ÿһ��������ҳ�棬sqlserver���һ����������

4����ѯ��Ҫɨ���ҳ��ͼ�¼Խ�࣬������ĿҲ��Խ�࣬��ѯ�õ�������Խ�࣬������ĿҲ��Խ�ࡣ

���ԣ���������һ����ѯ����������������ȥ�����˵ĸ������ݿ�����������������У�

a,���������ٵļ�¼�������صĽ��Խ�࣬��Ҫ����Ҳ��Խ�ࡣ
b,������ؽ����ֻ�Ǳ�����м�¼��һС���ݣ�Ҫ����ʹ��index seek,����ȫ��ɨ������ִ�мƻ���
c,���ܵĻ�����ƺú��ʵ�����������sqlServerͨ������������ҵ����ݡ�

��Ȼ��Щ���Ƕ��ڡ����ύ�������ϵĸ��뼶����ԡ����ѡ�á�δ�ύ������sqlServer�Ͳ���������Щ������������Ҳ�Ͳ��ᷢ����
*/

--��ѯĳ�����ݿ��������������Щ�����Щ��������.
select request_session_id,resource_type,resource_associated_entity_id,
request_status,request_mode,resource_description,p.object_id,object_name(p.object_id) as object_name,p.*
 from sys.dm_tran_locks a
left join sys.partitions p on a.resource_associated_entity_id = p.hobt_id
where a.resource_database_id = db_id('adventureworks2012')
order by request_session_id,resource_type,resource_associated_entity_id

/*
���¼�������lock:accquired ��lock:released ������������������ͷ�
*/


/*
����
*/

select BusinessEntityID, NationalIDNumber, LoginID, OrganizationNode, OrganizationLevel, 
JobTitle, 
BirthDate, 
MaritalStatus, 
Gender, 
HireDate, SalariedFlag, VacationHours, SickLeaveHours, CurrentFlag, rowguid,
ModifiedDate
into Employee_Demo_Btree
from HumanResources.Employee


alter table Employee_Demo_Btree add constraint PK_Employee_Demo_Btree primary key clustered (BusinessEntityID)
create nonclustered index IX_Employee_Demo_Btree on Employee_Demo_Btree(LoginID)
create nonclustered index IX_Employee_Demo_Btree_MD on Employee_Demo_Btree(ModifiedDate)


select BusinessEntityID, NationalIDNumber, LoginID, OrganizationNode, OrganizationLevel, 
JobTitle, 
BirthDate, 
MaritalStatus, 
Gender, 
HireDate, SalariedFlag, VacationHours, SickLeaveHours, CurrentFlag, rowguid,
ModifiedDate
into Employee_Demo_Heap
from HumanResources.Employee

alter table Employee_Demo_Heap add constraint PK_Employee_Demo_Heap primary key nonclustered (BusinessEntityID)
create nonclustered index IX_Employee_Demo_Heap on Employee_Demo_Heap(LoginID)
create nonclustered index IX_Employee_Demo_Heap_EH on Employee_Demo_Heap(ModifiedDate)

/*
�ڿ��ظ����ļ����£�������Ҫ�����������ύ��ʱ����ͷţ������ڲ��Ի����£���������˸��뼶���¿���һ������������һ����ѯ
��䣬���ܿ��������ѯ���������Ҫ��������
*/

--��������뼶����ɿ��ظ���(repeatable Read)
--����'����
set transaction isolation level repeatable read

set statistics profile on

begin tran 
select BusinessEntityID,LoginID,JobTitle from Employee_Demo_Btree where BusinessEntityID=3
begin tran 
select BusinessEntityID,LoginID,JobTitle from Employee_Demo_Heap where BusinessEntityID=3

rollback tran 
--����һ��������ִ��
select request_session_id,resource_type, resource_associated_entity_id,
request_status,request_mode,resource_description,p.index_id,p.object_id,object_name(p.object_id) as object_name,p.*
 from sys.dm_tran_locks a
left join sys.partitions p on a.resource_associated_entity_id = p.hobt_id
--where a.resource_database_id = db_id('adventureworks2012')
order by request_session_id,resource_type

/*
��Ϊ�������ڷ������ݿ⣬�����������ݿ�һ������һ�����������Է�ֹ���˽����ݿ�ɾ��
��Ϊ���ڷ��ʱ��,�����ڱ���ϼ���һ�������������Է������޸ı�Ķ���
��ѯ����1����¼��������������¼���ڵľۼ��������ϣ�����һ��������������������ڵ�ҳ���ϣ�����һ����������.
request_session_id resource_type                                                resource_associated_entity_id request_status                                               request_mode                                                 resource_description                                                                                                                                                                                                                                             index_id    object_id   object_name                                                                                                                      partition_id         object_id   index_id    partition_number hobt_id              rows                 filestream_filegroup_id data_compression data_compression_desc
------------------ ------------------------------------------------------------ ----------------------------- ------------------------------------------------------------ ------------------------------------------------------------ ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- ----------- ----------- -------------------------------------------------------------------------------------------------------------------------------- -------------------- ----------- ----------- ---------------- -------------------- -------------------- ----------------------- ---------------- ------------------------------------------------------------
51                 DATABASE                                                     0                             GRANT                                                        S                                                                                                                                                                                                                                                                                                                             NULL        NULL        NULL                                                                                                                             NULL                 NULL        NULL        NULL             NULL                 NULL                 NULL                    NULL             NULL
53                 DATABASE                                                     0                             GRANT                                                        S                                                                                                                                                                                                                                                                                                                             NULL        NULL        NULL                                                                                                                             NULL                 NULL        NULL        NULL             NULL                 NULL                 NULL                    NULL             NULL
54                 DATABASE                                                     0                             GRANT                                                        S                                                                                                                                                                                                                                                                                                                             NULL        NULL        NULL                                                                                                                             NULL                 NULL        NULL        NULL             NULL                 NULL                 NULL                    NULL             NULL
56                 DATABASE                                                     0                             GRANT                                                        S                                                                                                                                                                                                                                                                                                                             NULL        NULL        NULL                                                                                                                             NULL                 NULL        NULL        NULL             NULL                 NULL                 NULL                    NULL             NULL
58                 DATABASE                                                     0                             GRANT                                                        S                                                                                                                                                                                                                                                                                                                             NULL        NULL        NULL                                                                                                                             NULL                 NULL        NULL        NULL             NULL                 NULL                 NULL                    NULL             NULL
58                 KEY                                                          72057594058506240             GRANT                                                        S                                                            (98ec012aa510)                                                                                                                                                                                                                                                   1           935674381   Employee_Demo_Btree                                                                                                              72057594058506240    935674381   1           1                72057594058506240    290                  0                       0                NONE
58                 OBJECT                                                       935674381                     GRANT                                                        IS                                                                                                                                                                                                                                                                                                                            NULL        NULL        NULL                                                                                                                             NULL                 NULL        NULL        NULL             NULL                 NULL                 NULL                    NULL             NULL
58                 PAGE                                                         72057594058506240             GRANT                                                        IS                                                           1:24312                                                                                                                                                                                                                                                          1           935674381   Employee_Demo_Btree                                                                                                              72057594058506240    935674381   1           1                72057594058506240    290                  0                       0                NONE
59                 DATABASE                                                     0                             GRANT                                                        S                                                                                                                                                                                                                                                                                                                             NULL        NULL        NULL                                                                                                                             NULL                 NULL        NULL        NULL             NULL                 NULL                 NULL                    NULL             NULL


��ѯ2,һ����ѯҪʹ�õ�������(RID)��ĿԽ�࣬���������Ҳ�ͻ�Խ�࣬û��ʹ�õ��������ϲ������빲������
*/


--�ǲ������еĲ�ѯ��ֻ�ڷ��صļ�¼�ϼ�����

begin tran 
update Employee_Demo_Heap set JobTitle='aaa' where BusinessEntityID=70

begin tran
select  BusinessEntityID,loginID,jobTitle from Employee_Demo_Heap where BusinessEntityID in(3,30,200)

rollback tran 
/*
��dmv��ʾ��in��ѯ������1:7581:24,����BusinessEntityID 70 �������Ǿ�update����޸��ˣ���û���ύ������in��ѯ�ͱ�������
in���˲�������3�ڼ�¼���ڵ�ҳ����������IS�������ڱ�������ҳ���϶������� IS���������һ��ȫ��ɨ��ɨ�������е�����ҳ�滹����
����������ص��ǣ�in��ѯ��ɨ��ÿһ��ҳ���ʱ�򣬻�Զ�����ÿ�����ݼ�¼����һ������������������ڼ�¼�ͻ��ͷţ������Խ�ȵ�������
�������ֻҪ���κ�һ����¼�ϵ���û�����뵽����ѯ�ͻᱻ�����ء�

����(�ڷ�'δ�ύ��'�ĸ��뼶����)
1)��ѯ�����еĹ����У����ÿһ�������ļ�¼���ֵ�ӹ������������¼���÷��أ������ͻᱻ�ͷţ������¼��Ҫ�����أ����Ӹ��뼶��
�����������'���ύ��'����Ҳ�ͷţ������ͷ�
2)��ÿһ��ʹ�õ���������sqlserverҲ�������ļ�ֵ�ӹ�����
3)��ÿһ��������ҳ�棬sqlserver���һ��������
4)��ѯ��Ҫɨ���ҳ��ͼ�¼Խ�࣬������ĿҲ��Խ�࣬��ѯ�õ�����Խ�࣬������ĿҲ��Խ�࣬���ԣ���������һ����ѯ������������
�������˵ĸ��ʣ����ݿ���ƶ����������У�
1,���������ٵļ�¼�������صĽ��Խ�࣬��Ҫ����Ҳ��Խ��
2��������ؽ����ֻ�Ǳ�����м�¼��һС���ݣ�Ҫ����ʹ��index seek ,����ȫ��ɨ������ִ�мƻ���
3�����ܵĻ�����ƺú��ʵ�����������sqlserverͨ������������ҵ�����.
��Ȼ��Щ���Ƕ��ڡ����ύ�������ϵĸ��뼶����ԣ����ѡ��'δ�ύ��',�Ͳ���������Щ�������������ز��ᷢ����


update �Ĺ���
1)��ÿһ��ʹ�õ���������sqlserver�������ļ�ֵ��U��
2)sqlserverֻ��Ҫ���޸ĵļ�¼���ֵ��x��
3)ʹ�õ�Ҫ�޸ĵ��е�����Խ�࣬������ĿҲ��Խ��
4)ɨ�����ҳ��Խ�࣬������Ҳ��Խ�࣬��ɨ��Ĺ��̣�������ɨ�赽�ļǵ�Ҳ���������������û���޸�
����ע��㣺
1�������޸��ٵļ�¼�����޸ĵļ�¼Խ�࣬��Ҫ����Ҳ��Խ��
2������������ν����������������ĿԽ�࣬��Ҫ����Ҳ����Խ��


delete �Ĺ���
1)delte�Ĺ��������ҵ����������ļ�¼��Ȼ����ɾ����������������һ��select��Ȼ����delete,���ԣ�����к��ʵ���������һ���������
�ͱȽ���
2)delete�����ǰ������б���ɾ������Ҫɾ��������ص�������������һ�ű���������ĿԽ�࣬������Ŀ�ͻ�Խ�࣬Ҳ��Խ���׷�������

insert �Ĺ���

1)���ݿ��ϵ�S��(resource_type=datebase)
2)���ϵ�IX��(resource_type=object)
3)ÿ�������϶�Ҫ����һ�������ݣ�������һ��key�ϵ�x����
4����ÿ�������Ϸ����仯���Ǹ�ҳ�棬������һ��IX����
*/



/*
���ⶨλ�ͽ��
�����������������ĵĲ���
*/

begin tran
update Employee_Demo_Heap set JobTitle = 'aaa' where BusinessEntityID =70
update Employee_Demo_Btree set JobTitle ='aaa' where BusinessEntityID =70

select * from master.sys.sysprocesses


select request_session_id,resource_type, resource_associated_entity_id,
request_status,request_mode,resource_description,p.index_id,p.object_id,object_name(p.object_id) as object_name,p.*
 from sys.dm_tran_locks a
left join sys.partitions p on a.resource_associated_entity_id = p.hobt_id
--where a.resource_database_id = db_id('adventureworks2012')
order by request_session_id,resource_type



--��ζ�λһ������
select * from master.sys.sysprocesses

/*
1)���ݿ�����û��������������Щ�ӽӷ�������������˭������˭

�������û���Ǹ�����blocked �ֶβ�Ϊ0,Ҳ����-2,-3,-4,�������Ǳ���spid��������ֶ�ֵ���Ǹ����Ӹ�����ס�ˡ�
����㷢��һ�����ӵ�blocked �ֶε�ֵ�������Լ����ǵ���˵��ʲô���⣬������Ϊ������������������̶�д����Ҫ���Լ���I/o���ꡣ

2)ʲôʱ��ʼ��
ֻҪ��waittime,�����ȴ�ʱ��

3)���Ǹ����ݿ���
һ����dbid��
select * from master.sys.sysdatebases

4)��������Щ������Щ����ϣ���Щ��Դ��
��sp_lock�����������״̬��wait����Դ
select object_name(951674438)
select * from sys.indexes where object_id = 951674438
RID:��ʽΪ��fileid:pagenumber:rid �ı�ʶ��������fileid��ʶ����ҳ���ļ���pagenumber��ʶ�����е�ҳ��rid��ʶҳ�ϵ��ض��С�
fileid ��sys.database_files Ŀ¼��ͼ�е�file_id����ƥ��.
KEY:���ݿ������ڲ�ʹ�õ�ʮ�������������ֵ��sys.partitions.hobt_id���Ӧ������������Դ˵��������һ����������ģ�ͨ����ѯ
sys.partitions��ͼ����Ӧ��object_id��index_id�����ҵ����������

PAG:��ʽΪfileid:pagenumber
EXT:��ʶ���еĵ�һҳ�����֣������ֵĸ�ʽΪfileid:pagenumber
TAB:û���ṩ��Ϣ����Ϊ�Ѿ���objid���б�ʶ�˱�
DB:û���ṩ��Ϣ����Ϊ�Ѿ���dbid���б�ʶ�˱�
FIL:�ļ��ı�ʶ������sys.database_filesĿ¼��ͼ�е�file_id����ƥ��.

5)���������ص������Ǵ���ЩӦ������
sys.sysprocesses
hostname,program_name,hostprocess
loginame,nt_domain,nt_username...

6)Ϊʲô�����ᷢ��
a,������Դͷ�����������ʱ����������������Ϊʲô��������Щ��
�������ǻỰ���������е��������ģ���Ҳ����������Ự����ǰ������һ������û���ύ������Դ������������κ�ʱ���������ģ�
��ʱ�������ܻ�û�з���.


*/

--��ѯ����
select convert(smallint,req_spid) as spid,
rsc_dbid as dbid,
rsc_objid as objID,
rsc_indid as indid,
substring(v.name,1,4) as type,
substring(rsc_text,1,32) as resource,
substring(u.name,1,8)as mode,
substring(x.name,1,5) as status
from master.dbo.syslockinfo,
master.dbo.spt_values v,
master.dbo.spt_values x,
master.dbo.spt_values u
where master.dbo.syslockinfo.rsc_type = v.number
and v.type = 'LR'
and master.dbo.syslockinfo.req_status = x.number
and x.type = 'LS'
and master.dbo.syslockinfo.req_mode +1 = u.number
and u.type = 'L'
and substring(x.name,1,5) ='WAIT'
order by spid

--��ѯ���������е����
/*�����������������е����Ӻ����������е���䣬���һ�����Ӵ��ڿ���״̬��Ϊ�������ᱻ�淵��*/
select 
p.session_id,p.request_id,p.start_time,
p.status,p.command,p.blocking_session_id,p.wait_type,p.wait_time,
p.wait_resource,p.total_elapsed_time,p.open_transaction_count,
p.transaction_isolation_level,
substring(qt.text,p.statement_start_offset/2,
	(case when p.statement_end_offset = -1
	then len(convert(nvarchar(max),qt.text))*2
	else p.statement_end_offset
	end - p.statement_start_offset)/2) as 'sql statement',
	p.statement_start_offset,p.statement_end_offset,bach=qt.text
 from master.sys.dm_exec_requests p
cross apply sys.dm_exec_sql_text(p.sql_handle) as qt
where p.session_id>50

--���������ϴ����е����һ�����
/*
dbcc inputbuffer(<spid>)
���Ի�ôӿͻ��˷��͵�sqlserverʵ�������һ����������䣬���������ŵ��ǲ��������Ƿ��������У����᷵�ؽ����ȱ���������ص���������������䣬�����ǵ�ǰ����
ִ�е��Ӿ䣬���Զ����������е����ӣ���һ��ֲ�����ȽϺá�

������������ڱ�a�ϣ�����ǰ��仰��������������ϼ���Ӧ�ģ��ǻ����Ͽ��Զ϶�����������һ����ǰ�����������µġ�

2��������Դͷ��ʱ��״̬��ʲô����һֱ��ִ�У������Ѿ��������״̬.
һ����򵥵ķ������ǿ�sysprocesses �����kpid ��waittype�����ֶΣ������������0,����һ�����ڿ���״̬�����ӡ����������0������
�������������У���������Ϊ��Դ�ȴ�����ʱ����

3)�����һֱ��ִ�У�ΪʲôҪִ����ô��
���һ�����ӵ�kpidֵ����0�������õ���һ���߳���Դ����waittypeֵ��0��������Ҫ�ȴ��κ���Դ������״̬�ͻ���runnable ��running.
���һ�����ӵ�kpidֵ����0,waittypeֵҲ����0,��˵����Ҫ�ȴ�ĳ����Դ���ܼ���ִ�С���ʱ�����ӵ�״̬һ����suspended.

4)����Ѿ��������״̬����Ϊʲôû���ͷ�����Դ
���һ�����ӵ�kpidֵ��0(����û��ռ���߳���Դ),waittypeֵҲ��0(������Ҫ�ȴ��κ���Դ),��ô��������Ѿ�����˿ͻ��˷�������������
�����ڽ����˿���״̬�����ڵȴ��ͻ��˷����µ�����.

���������������������Ӧ���ͷ���ǰ���������Դ�Ŷԡ������ʱ������������Դͷ��һ������Ϊ�⾭����ǰ����������û�м�ʱ�����������ͨ�����sysprocesses
���open_tran����Ƿ����0ȷ�ϡ�ͨ��inputbufferҲ����֪�����������󷢹������Ǿ仰��ʲô��

5������������������������Ҫ��ʲô��ΪʲôҲҪ������Щ����Դ��
ʹ�ò���a����Ľű���Ҳ�ܹ�֪�����������������������е���䡣Ȼ����ȥ�Ƚ�sp_lock�Ľ�������ܴ����ж���������������Ƿ����
������Ǻܺ�������ͨ���Ż���䣬�Ӻ��ʵ����������

*/
