

--���ݿ�ռ���֯�ܹ�


--���ݿ���ļ����Ǽ���
/*
���ݿ��������ļ��������ļ�����־�ļ�
*/

--����ô�ҳ������ļ�
/*
���ļ���β .mdf ���������ļ��������.
����.ndf �������ݿ⸨�������ļ����ɰ����ж����
*/

--�����ݿ�ϵͳ�У�����ô�������ļ�����Ϣ��
/*

*/

--����ļ�¼��ô�浽�����ļ��е��أ�����˵�����ļ�����ô�����¼��
/*
�������ļ��У���¼���ǰ�ҳ������ģ�ҳ�����ݴ洢�Ļ�����λ��ҳ�Ĵ�СΪ8K.ҳ���ϣ����ǰ�������ҳ��
��������Ч����ҳ�����е�ҳ���洢�����У�1��������8��������������ҳ���ϡ�
*/

ҳ�����ķ���

--�����ļ��Ƚϴ󣬶����ƺ�����¼�����е㲻�������ҵļ�¼�����࣬��ɾ����һЩ�����ռ仹����ô��,���뿴���ռ��ʹ�����
/*
ssms�ṩ��4�ּ�ֱ�ӵı�������ͳ�Ƴ��Ӳ�ͬ�Ƕȷ��������ݿ�ռ�ʹ�������
1������ʹ�����
2, ����ǰ��ı�Ĵ���ʹ�����
3������Ĵ���ʹ�����
4���������Ĵ���ʹ�����
*/

/* �����鿴
��Ϊsqlserver�������ʱ�䶼�ǰ�����Ϊ��λ�������¿ռ�ģ��Ա�һ�������ļ� �������� ����ʹ�ù�������
��Ŀ�����Կ����ж������ǿ��õġ�
*/
DBCC showFileStats
/*
����������ֱ�Ӵ�gam ��sgam������ϵͳ����ҳ�������ȡ���ķ�����Ϣ���ٶȿ죬��׼ȷ�ɿ����ڷ�������
�غܸߵ������Ҳ�ܰ�ȫִ�С�

ע�� GAM(ȫ�ַ���λͼ)�����ڱ�ʶSQL Server�ռ�ʹ�õ�λͼ��ҳ��λ�����ݿ�ĵ�3��ҳ��Ҳ����ҳ����2��ҳ��
*/

--�����֪������������ʹ���˶��ٿռ�
/*
��ҳ����������

����
*/
/*����sys.allocation_units��sys.partitions���Ź�����ͼ������洢�ռ�,��һ���ܼ�����ӳ�����ݿ��
׼ȷ��Ϣ������ updateusage ��������̫����Դ������һ��ֻ�ܲ�ѯһ������*/
sp_spaceused 

/*
dm_db_partition_stats
������ͼ��ӳ��ĳ�ű���������˶���ҳ�棬������������ҳ���ϵ�ƽ��������������Щֵ�������
һ�ű��ռ���˶��ٿռ䡣���ݲ�ͬ��ɨ��ģʽ��������Դ��ͬ.
*/
select o.name,SUM(p.reserved_page_count) AS reserved_page_count,
SUM(p.used_page_count) AS used_page_count,
SUM(
	CASE WHEN (p.index_id<2) THEN (p.in_row_data_page_count+p.lob_used_page_count+p.row_overflow_used_page_count)
	ELSE p.lob_used_page_count+p.row_overflow_used_page_count
	END
	) AS Datapages,
SUM(
	CASE WHEN (p.index_id<2) THEN row_count
	ELSE 0
	END
	) AS RowCounts
FROM sys.dm_db_partition_stats p 
INNER JOIN sys.objects o ON p.object_id = o.object_id
GROUP  BY o.name


DBCC SHOWCONTIG 
/*
���Ծ�ȷ������/ҳ������׼���ģ�����������Ӱ��
*/

---------------------

--���뿴��־�ļ���������û��
/*
������־�ļ����������ָ���ÿһ�γ�Ϊ������־��Ԫ���������Ա�������ú�����������־��Ԫ��
��С����������־�ļ�ÿ��Ȱ����һ�Σ�����������һ��������־��Ԫ�����ԣ����һ����־�ļ�������
���С���Զ������������������־��Ԫ��Ŀ�����������־�ļ���ܶ࣬���������Ӱ �쵽��־�ļ������
Ч�ʣ�����������ݿ���ЭҪ���ܳ�ʱ�䡣
��־�ļ���һ�ֻ����ļ���������־�ļ���������־��Ԫ�ֶΣ��߼���־�ļ���������־�ļ���ʼ��
��ʼ������־����ӵ��߼���־��ĩ�ˣ����߼���־��ĩ�˵���������־�ļ���ĩ��ʱ���µ���־��¼
�����Ƶ�������־�ļ���ʼ�ˡ�
*/
DBCC SQLPERF(LOGSPACE)

--���ݿ�Ŀռ�ռ����һ������ϵͳ���ݿ�ģ�������ʱ������������Ҫ��ϵͳ���ݿ��п�Щ����ǰ���йص���Ϣ

--��ǰ���ݿ���Щ��Ϣ���ŵ�tempdb��
/*
1,���û���ʽ�������û�����
	�û�����ı������
	ϵͳ�������
	ȫ����ʱ�������
	�ֲ���ʱ�������
	table����
	��ֵ�����з��صı�
2�����ڴ���sqlserver�����ڲ�����
	�����α����ѻ������Լ���ʱ���Ͷ���lob�洢�Ĺ�����
	���ڹ�ϣ���ӻ��ϣ�ۺϲ����Ĺ����ļ�
	���ڴ������������������Ȳ���(���ָ����sort_in_tempdb)���м�������������ĳЩgroup by ,orderby ,union��ѯ���м�������
ÿ���ڲ���������ʹ��9ҳ��һ��IAMҳ��һ��8ҳ������
*/

SELECT * FROM sys.dm_db_file_space_usage
/*
ͨ�����������ͼ������֪��tempdb�Ŀռ��Ǳ���һ�����ʹ�õ��ģ�
���û����� user_ojbect_reserved_page_count
����ϵͳ���� internal_object_reserved_page_count
���ǰ汾�洢�� version_store_reserved_page_count
*/

--tempdb ͻȻ�����˺ܶ࣬����ô���ͣ������������쳣

/*����*/
--����A
SELECT @@SPID
GO
USE AdventureWorks
GO
SELECT GETDATE()
GO
SELECT * 
INTO #mysalesorderDetail
FROM sales.SalesOrderDetail
--����һ����ʱ���������Ӧ�� �������û�����ҳ��
go
WAITFOR DELAY '0:0:2'
SELECT GETDATE()
go
SELECT TOP 100000 * 
FROM sales.SalesOrderDetail
INNER JOIN sales.salesorderheader ON sales.salesorderheader.SalesOrderID=sales.salesorderheader.salesorderid
--��������һ���Ƚϴ�����ӣ�Ӧ�û���ϵͳ���������
GO
SELECT GETDATE()
--join ��������Ժ�ϵͳ����ҳ����ĿӦ���½�
GO

--����tempdb
USE tempdb
--ÿ��1��������һ�Σ�ֱ���û��ֹ���ֹ�ű�����
WHILE 1=1
BEGIN 
	SELECT GETDATE()
	--���ļ�����tempdbʹ�����
	DBCC showfilestats
	--query 1
	--�������������ռ�����ĻỰ��Ϣ
	SELECT 'Tempdb' AS DB,GETDATE() AS times,
	SUM(user_object_reserved_page_count)*8 AS user_objects_kb,
	SUM(internal_object_reserved_page_count)*8 as internal_objects_kb,
	SUM(version_store_reserved_page_count) *8 AS version_store_kb,
	SUM(unallocated_extent_page_count)*8 AS freespace_kb
	FROM sys.dm_db_file_space_usage
	WHERE database_id = 2
	--query 2
	--���������ͼ�ܹ���ӳ��ʱtempdb�ռ���������
	SELECT t1.session_id,t1.internal_objects_alloc_page_count,t1.user_objects_alloc_page_count,
	 t1.internal_objects_dealloc_page_count,t1.user_objects_dealloc_page_count,
	 t3.*
	FROM sys.dm_db_session_space_usage t1,
	--��ӳÿ���Ự�ۼƿռ�����
	sys.dm_exec_sessions AS t3
	--ÿ���Ự����Ϣ
	WHERE t1.session_id=t3.session_id
	AND (t1.internal_objects_alloc_page_count>0
		OR t1.user_objects_alloc_page_count>0
		OR t1.internal_objects_alloc_page_count>0
		OR t1.user_objects_dealloc_page_count>0
	)
	--query3
	--�����������в��������ռ�����ĻỰ�������е����
	select * 
	FROM sys.dm_db_session_space_usage AS t1,
	sys.dm_exec_requests AS t4
	CROSS APPLY sys.dm_exec_sql_text(t4.sql_handle) AS st
	WHERE t1.session_id = t4.session_id
		AND t1.session_id>50
		AND (t1.internal_objects_alloc_page_count>0
		OR t1.user_objects_alloc_page_count>0
		OR t1.internal_objects_alloc_page_count>0
		OR t1.user_objects_alloc_page_count>0)
	WAITFOR DELAY '0:0:1'
END
/*
�ӽ��������sqlserver��Ҫ�ռ���һЩ�ڲ���������� inner join 
*/

--��ͬ�Ĵ洢�ṹ�Կռ���ʲôӰ��
DBCC SHOWCONTIG
/*
���Կ�������ͬ�����ֶ��ϣ������ۼ�������û�����ӱ��Ĵ�С���������Ǿۼ�����ȥ�����˲�С��
�ռ䡣
��һ��˵������һ����񾭳������仯ʱ����������ű��Ͻ����ۼ�����������������ҳ��֣����Խ���
�ۼ�������Ӱ �����ܣ��������ֿ��ǣ��ܶ����ݿ�����߲�Ը����sqlserver�ı���Ͻ� ���ۼ�������
����һ�ű������������ֲ��ܽ��ܣ����������ּ���һЩ�Ǿۼ����������ڵõ��õ����ܡ�
sql serer���ֶѺ����Ĵ洢��ʽ���������������������һ�����˷ѿռ䣬����Ҳ��һ���õ���ơ�
�ղŵĲ��Ծ�˵���˿ռ��ϵ��˷ѣ����sqlerver��Ʒ����sqlserver2005������һ���Ƚϣ��Ա��о�
��������û�оۼ������ı����sleect ,insert update,delete�ϵ����ܣ���Ϊselect ,update,delete
�м�¼��Ѱ�Ķ��������Ժ���Ȼ�ģ��оۼ����������������ܣ����������ϵ��ǣ���insert��һ���ϣ�
����Ҳûʲô��𣬲�û�г��־ۼ�����Ӱ��insert�ٶȵ����������ٴ�ǿ�ҽ��飬��һ����ı����
һ��Ҫ��һ���ۼ�������
*/

--delete ��truncate�����ݿռ���ʲô����
DBCC SHOWCONTIG('sales.salesorderdetail')
/*
������ԱȲ���ǰ���ҳ�棬��������
�Ӳ��Կ��Կ�����delete���������ȫ�ͷű������������ݽṹ�Լ����������ҳ�棬

��ȱ��
1�����õ�������־�ռ����
delete���ÿ��ɾ��һ�У�����������־��Ϊ��ɾ����ÿ�м�¼һ���truncateͨ���ͷ�����
�ڴ������ݵ�����ҳ��ɾ�����ݣ�������������־��ֻ��¼ҳ�ͷ����������������¼ÿһ�С�

2��ʹ�õ���ͨ������
��ʹ������ִ��delete���ʱ�����������и����Ա�ɾ����truncate�����������ҳ��ҳ���������С�
3�����н���������Ĳ������κ�ҳ
ִ��delete���󣬱��Ի���� ��ҳ�����磬��������ʹ��һ������lck_m_x�����������ͷŶ��еĿ�ҳ��
����������ɾ������������һЩ��ҳ��������Щҳ��ͨ���̨�������Ѹ���ͷš�
truncate ɾ�����е������У�����ṹ�����У�Լ���������ȱ��ֲ���
*/

--ɾ�����ݺ�����ͷſռ䣬������Ƭ��
/*
1,�ڱ���Ͻ����ۼ�����
2������������ݶ���Ҫ�ˣ�Ҫʹ��truncate
3,��������Ҫ�ˣ���drop
4,�ؽ����������ۼ�������
5������ķ�ʽ�����µı�
*/

----------------
--���ݿ��ǱȽϴ��ˣ��������������£�������Ч��������
/*
�����˽����ݿ�������һЩ����
shrinkdatatabe һ�����л�ͬʱӰ�����е��ļ������������ļ�����־�ļ�����ʹ���߲���ָ��ÿ��
�ļ���Ŀ���С���������ܲ��ܴﵽԤ�ڵ�Ҫ�����Խ��黹�������ù滮����ÿ���ļ�ȷ��Ԥ��Ŀ�꣬
Ȼ��ʹ��dbcc shrinkfile��һ���ļ�һ���ļ������Ƚ����ס�

�ƻ����������ļ�ʱ��Ҫ���ǵ����¼��㣺
1������Ҫ�˽������ļ���ǰ��ʹ�����
�������Ĵ�С�����ܳ�����ǰ�ļ��Ŀ��пռ�Ĵ�С�������Ҫѹ�����ݿ�Ĵ�С�����Ⱦ�Ҫȷ������
�ļ����ȷ����Ӧĩ��ʹ�õĿռ䣬����ռ䶼��ʹ���У��Ǿ�Ҫ��ȷ�ϴ���ռ�ÿռ�Ķ��󣨱���������
Ȼ�󰮹��鵵��ʷ���ݣ��Ȱѿռ��ͷų�����
2���������ļ��ǲ��ܱ���յģ��ܱ���ȫ��յ�ֻ�и��������ļ���
3�����Ҫ��һ���ļ���������գ�Ҫɾ������������ļ����ϵĶ��󣨱��������������߰������Ƶ�
�����ļ����ϣ�dbcc shrinkfile������������������

ע��dbcc shrinkfile ����һ���Ķ����������ʹ�ù�����ǰ�ƣ���û��ʹ���е������Ƴ����������һ
��������Ŀ�ҳ�Ƴ����ϲ�����Ҳ�����ҳ����Ŀռ��Ƴ����ϲ�ҳ�档����һ�����ݿ����кܶ�ֻʹ��
��һ����ҳ�������shrinkfile��Ч���᲻���ԡ�
*/

--ͨ�����ԣ��۲죬ѧ�ῴ��ռ�õ�������ҳ��


use test
go  

--����һ��ÿһ�ж���ռ��һ��ҳ��ı�񣬱����û�оۼ��������Ƕѣ�����8000����¼
if OBJECT_ID('test') is not null  
drop table test  
go  
create table test  
(  
    a int,  
    b nvarchar(3900)  
)  
go  
declare @i int  
set @i=1  
while @i<=1000  
begin  
    insert into test VALUES( 1,REPLICATE(N'a',3900))  
    insert into test VALUES( 2,REPLICATE(N'b',3900))  
    insert into test VALUES( 3,REPLICATE(N'c',3900))  
    insert into test VALUES( 4,REPLICATE(N'd',3900))  
    insert into test VALUES( 5,REPLICATE(N'e',3900))  
    insert into test VALUES( 6,REPLICATE(N'f',3900))  
    insert into test VALUES( 7,REPLICATE(N'g',3900))  
    insert into test VALUES( 8,REPLICATE(N'h',3900))  
    set @i=@i+1  
end  
--select * from test  
--ʹ��DBCC SHOWCONTIG�������鿴���������ݽṹ
dbcc showcontig('test')  
  
--����������п��Կ������������ݵĴ洢������8000ҳ  
  
--����ɾ��ÿ���������7��ҳ��,ֻ����a=5����Щ��¼  
delete test where a<>5  
go  
  
--ʹ��ϵͳ�洢����sp_spaceused �鿴��Ŀռ���Ϣ  
  
sp_spaceused test  
go  
/*  
name    rows    reserved    data    index_size  unused  
-------- ----------- -- -------------------------------------------  
test    1000        64008 KB    32992 KB    8 KB    31008 KB  
*/  
  
--ʹ��DBCC SHOWCONTIG����鿴�洢���  
DBCC SHOWCONTIG(test)  

--ͨ������ı�����ݵĶԱ��������׷��ֻ��н���һ���ҳ��û�б��ͷ�  
  
��ʱ������������ȥ���ļ���������:  
  
DBCC SHRINKFILE(1,40)  
  
/*  
DbId    FileId  CurrentSize MinimumSize UsedPages   EstimatedPages  
------------------------------------------------------------------------------  
9   1   8168    288 1160    1160  
*/  
  
--ͨ��������,����������һ�������ļ������ڱ�ʹ�õĴ�С  
  R
--(8168*8.0)/1024=63.812500M  
--������1000������С  
  
--���������֤���������������ݿ��DBCC SHRINKFILE(1,40)  
--ָ�û����Ӧ�е�����  
  
  
--��ô������ν�����������?  

--���������оۼ�����,���ǿ���ͨ���ؽ�������ҳ�����һ��,  
--�������û�оۼ�����  
  
--�������Ҵ����ۼ�����:  
create clustered index test_a_idx on test(a)  
go  
--ʹ��DBCC SHOWCONTIG(test)����鿴��Ĵ洢���  
DBCC SHOWCONTIG(test)  

  
--ͨ������������Է���,�����ۼ�����֮��,ԭ�ȴ����  
--�����������B���ķ�ʽ���´�š�  
--ԭ�ȵ�ҳ�汻�ͷų����ˣ�ռ�õķ���Ҳ���ͷų����ˡ�  
--���ʱ����ʹ��DBCC SHRINKFILE����Ч����  
  
DBCC SHRINKFILE(1,40) 
SELECT  5424*8/1024
  
 /* 
������������Ϊ���ݴ洢ҳ���ɢ����������SHRINKFILEЧ�����ѡ�  
��һ���оۼ������ı��ϣ�����������ͨ���ؽ������������  
  
�����Щȥ����ŵ���text����image���͵����ݣ�  
SQL Server���õ�����ҳ�����洢��Щ���ݡ�  
  
  
����洢��һ��ҳ��������������������⣬�Ͷ�һ��  
�������ؽ�Ҳ����Ӱ�쵽���ǡ��򵥵ķ������ǰ���Щ����������Ķ���  
���ҳ�����Ȼ���ؽ����ǡ�����ʹ��DBCC EXTENTINFO������������  
�ļ������ķ�����Ϣ��Ȼ�����ÿ�����������ϵ�������Ŀ��ʵ�ʵ���Ŀ��  
  
���ʵ����ĿԶԶ����������Ŀ����������������Ƭ���࣬  
���Կ����ؽ�����  
*/
  
--�����Ըղŵ�����Ϊ����ʾ����ҳ���Щ��Ҫ�ؽ��Ķ���  
drop table test  
go  
  
if OBJECT_ID('test') is not null  
drop table test  
go  
create table test  
(  
    a int,  
    b nvarchar(3900)  
)  
go  
declare @i int  
set @i=1  
while @i<=1000  
begin  
    insert into test VALUES( 1,REPLICATE(N'a',3900))  
    insert into test VALUES( 2,REPLICATE(N'b',3900))  
    insert into test VALUES( 3,REPLICATE(N'c',3900))  
    insert into test VALUES( 4,REPLICATE(N'd',3900))  
    insert into test VALUES( 5,REPLICATE(N'e',3900))  
    insert into test VALUES( 6,REPLICATE(N'f',3900))  
    insert into test VALUES( 7,REPLICATE(N'g',3900))  
    insert into test VALUES( 8,REPLICATE(N'h',3900))  
    set @i=@i+1  
end  
go  
delete from test where a<>5  
go  
  
--������extentinfo������ŷ�����Ϣ  
  
if OBJECT_ID('extentinfo') is not null  
drop table extentinfo  
go  
create table extentinfo  
(  
    file_id smallint,  
    page_id int,  
    pg_alloc int,  
    ext_size int,  
    obj_id int,  
    index_id int,  
    partition_number int,  
    partition_id bigint,  
    iam_chain_type varchar(50),  
    pfs_bytes varbinary(10)  
)  
go  
create proc inport_extentinfo  
as dbcc extentinfo('test')  
go  
insert extentinfo  
exec inport_extentinfo  
go  
  
select  
    FILE_ID,  
    obj_id,  
    index_id,  
    partition_id,  
    ext_size,  
    'actual_extent_count'=COUNT(*),  
    'actual_page_count'=SUM(pg_alloc),  
    'possible_extent_count'=CEILING(SUM(pg_alloc)*1.0/ext_size),  
    'possible_extents/actual_extents'=(CEILING(SUM(pg_alloc)*1.00/ext_size)*100.00)/COUNT(*)  
from  
    extentinfo  
group by  
    FILE_ID,  
    obj_id,  
    index_id,  
    partition_id,  
    ext_size  
having COUNT(*)-CEILING(SUM(pg_alloc)*1.0/ext_size)>0  
order by  
    partition_id,  
    obj_id,  
    index_id,  
    FILE_ID  
/*  
FILE_ID obj_id  index_id    partition_id    ext_size    actual_extent_count actual_page_count   possible_extent_count   possible_extents/actual_extents  
------------------------------------------------------------------------------------------------------------------------------------------------------------------------  
1   2137058649  0   72057594038976512   8   998 4115    515 51.603206412  
*/  
select object_name(533576939) as TName  
/*  
60
245575913
293576084
469576711
533576939
*/  
--��ʱ���ǿ����ҵ��������δ���Ϳռ�ŵı�  
--��ʱ���Ǿ���Ҫ����Щ��������ؽ�����


--��־�ļ�Ϊʲô�᲻ͣ������
/*
�����˽�����־�Ĺ�������
��־���ڼ�¼���������Լ�ÿ����������ݿ��������޸ģ�Ϊ��������ݿ���� �����ܣ�sqlserver����
����ʱ��������ҳ���뻺�������ٻ��档�����޸Ĳ���ֱ���ڴ����Ͻ��У������޸ĸ��ٻ����е�ҳ������
ֱ�����ݿ��г���<����>,���߱��뽫�޸�д����̲���ʹ�û�������������ҳʱ���Ž��޸�д����̡�
���޸ĺ������ҳ�Ӹ��ٻ���洢��д����̵Ĳ�����Ϊˢ��ҳ���ڸ��ٻ������޸ĵ���δд����̵�
ҳ��Ϊ����ҳ����

���Ի������е�ҳ�����޸�ʱ��������־���ٻ���������һ����־��¼��sqlserfer ���з�ֹ��д�����
����־��¼ǰˢ����ҳ���߼�����ȷ����־��¼���ύ����ʱ�������ڴ�֮ǰ��һ���Ѿ���д����̡�

Ҳ����˵��sqlserver������ҳ�Ĳ��룬�޸ĺ�ɾ��������ֻ���ڴ�����ɺ󣬾��ύ������Щ�޸�
��������ͬ����Ӳ �̵�����ҳ�ϣ���sqlserver�ֱ��뱣֤�����һ���ԣ����·�����һsqlserver
�쳣��ֹ������sqlserver����������������磩,�ڴ��е��޸�û�����ü�д��Ӳ�̣��´�sqlserver��
����ʱ��Ҫ�ܹ��ָ���һ������һ�µ�ʱ��㣬�Ѿ��ύ���޸�Ҫ��Ӳ���е�ҳ��������ɣ�Ϊ����
����һ�㣬sqlserver����������������־��

��������̣����Կ�����ʲô������־���ݻ�һֱ������

1,����û�о��������㡱����־��¼
���ڵļ���(checkpoint)��֤���еġ���ҳ������д��Ӳ�̣�δ��������޸ģ������ǽ����ڴ����޸�
�������ļ���û��ͬ����sqlserverҪ��Ӳ���ϵ���־�ļ�����һ�ݼ�¼���Ա����쳣�����������޸ġ�

2,����û���ύ����������������־�����������־��¼
Ϊû���ύ������ع���׼������sqlserver���棬���е���־��¼�����ϸ�˳���м䲻�������κ���·��
�������ĳ�����ݿ���û���ύ������sqlserver�������д��������ʼ����־��¼�����ܺ������
������û�й�ϵ��Ϊ�������ϰ��ֱ�������ύ��ع���

3,Ҫ�����ݵ���־��¼
������ݿ���Ļָ�ģʽ���Ǽ�ģʽ����sqlserver�ͼ����û���Ҫȥ������־��¼�ģ�����δ�� ����
�ļ�¼��slqserver����Ϊ�û�������������Щ��¼�����ݿⱾ���Ѿ�û��������;�ˡ�

4,��������Ҫ��ȡ��־�����ݿ⹦��
*/

--�۲���־
DBCC LOG (6,3)
--db_id:Ŀ�����ݿ��ţ�������sp_helpdb�õ�����
--<format_id>:����ͺͽ�����־��¼�ķ�ʽ 3�Ƚ���ϸ

USE Test
go
CREATE TABLE a(a int)
go
CHECKPOINT
go
BACKUP LOG test WITH truncate_only
go 
DBCC LOG(6,3)
--sp_helpdb

--�ҵ���־�����һ����¼
--ͨ������һ����¼�������й۲�Ա�
--����Щ��¼���Կ�����sqlserv��û�м�¼��䱾������¼�����������޸ĵ�����ԭ����ֵ�����ڵ�ֵ��

/*
��־�ص�
1,��־��¼�������ݵı仯���������Ǽ�¼�û��������Ĳ�����
2��ÿ����¼��Ψһ�ı��lsn,���Ҽ�¼�������ڵ�����š�
3����־��¼��������ʵ���޸ĵ��������йأ�sqlserver��Ϊÿһ����¼���޸ı�����־��¼��
�����������޸ĵ������ǳ��࣬��������������־����Ҳ�ͻ�ǳ��ࡣ������־�������ٶȲ�����
�����йأ��������������������ݵ��޸����йء�
4����־��¼����������ʱ�䣬���ǲ���֤��¼���˷������������û�����������¼�����ߵĳ���
���ơ�
5��sqlserver�ܹ�����־��¼������������޸�ǰ��ֵ���޸ĺ��ֵ�����ǶԹ�����������ֱ�Ӵ���־
��¼��������˽����޸Ĺ��̵�

�ܽ�����Щԭ��������־�ļ�Խ��Խ��
1,���ݿ�ָ�ģʽ���Ǽ�ģʽ������û�а�����־����
���ڷǼ�ģʽ�����ݿ⣬ֻ��������־���ݺ��¼�Żᱻ�ضϣ����������ݺͲ��챸�ݲ�����������á�

2�����ݿ�����һ���ܳ�ʱ�䶼û���ύ������
SQLServer�����Ԥǰ�˳������������������SQLServer�е���Ϊ��ֻҪ���˳��������һֱ���ڣ�
ֱ��ǰ�������ύ���߻ع�����ʱ����־����Ҳû���ˡ�

3,���ݿ�����һ���ܴ������������
�罨�����ؽ�����������insert/delete�������ݡ������Ƿ��������α�û�а����ݼ�ʱȡ�ߡ�

 4,���ݿ⸴�ƻ�������쳣
 Ҫ����������������ֹ��־�������������ڲ�������־���ݵ����ݿ⣬��Ϊ��ģʽ���ɡ�
 ���������ģʽ��һ��Ҫ��������־���ݡ����������Ƴ������⣬Ҫ��ʱ�������û�д���
 ��ôҪ��ʱ������ƻ��񡣳������ʱ��ҲҪ��������ʱ����������ࡣ
*/

--������
/*
1�������־����ʹ����������ݿ�״̬
�����־ʹ�ðٷֱȡ��ָ�ģʽ����־���õȴ�״̬����2005�Ժ�sys.databases������
log_reuse_wait(log_reuse_wait_desc)����ӳ���ܽ׶���־��ԭ��
*/
    DBCC SQLPERF(LOGSPACE)  
    GO  
    SELECT name,recovery_model_desc,log_reuse_wait,log_reuse_wait_desc  
    FROM sys.databases  
    GO  
 /*
 ���Log Space Used(%)�ܸߣ���Ҫ���϶�λΪʲô���ܱ������
 ���״̬Ϊ��LOG_BACKUP������ζ��SQLServer�ȴ�����־���ݡ�Ҫ����Ƿ���Ҫ����־����,�����
 ����������־���ݣ�����ֱ�Ӱѻָ�ģʽ�ĳɼ򵥣�����sqlserver������һ�������ʱ������־
 
��¼�ضϵĹ��������Ժ�Ҫ������־���������ʱ���ٰѻָ�ģʽ�Ļ�����

2�������õĻ����
����󲿷���־����ʹ����������״̬Ϊ��ACTIVE_TRANSACTION����ôҪ������õ�������˭�����
 */   
     DBCC OPENTRAN  --�������δ�ύ������
    GO  
    SELECT  *  
    FROM    sys.dm_exec_sessions AS t2 ,  
            sys.dm_exec_connections AS t1  
            CROSS APPLY sys.dm_exec_sql_text(t1.most_recent_sql_handle) AS st  
    WHERE   t1.session_id = t2.session_id  
            AND t1.session_id > 50  