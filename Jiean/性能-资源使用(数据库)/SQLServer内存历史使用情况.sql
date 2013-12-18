

--�ڴ���ʷʹ�����


---�ڴ���ض�̬��ͼDMV-------------------------------

/*
sqlServer2005�Ժ�sqlserverʹ��Memory Clerk�ķ�ʽͳһ����sqlServer�ڴ�ķ���ͻ��ա�����sqlserver ����Ҫ������ͷ��ڴ棬����
Ҫͨ�����ǵ�Clerk.ͨ�����ֻ��ƣ�sqlserver ����֪��ÿ��clerk ʹ���˶����ڴ棬�Ӷ�Ҳ�ܹ�֪���Լ��ܹ����˶����ڴ档��Щ��Ϣ��̬��
�������ڴ涯̬������ͼ��.

��ʼ
sys.dm_os_memory_clerks:����sqlServerʵ���е�ǰ���ڻ״̬��ȫ���ڴ�clerk�ļ���,Ҳ����˵���������ͼ����Կ����ڴ�����ô��
sqlServerʹ�õ��ģ���Ҫ˵�����ǣ�������sql������ĵ��������������ڴ��ǲ��ܱ������ͼ���ٵģ�Ҳ����˵���������ͼ���Կ���
���е�buffer pool��ʹ�ã��Լ�multi-page�ﱻsqlserver����ʹ�õ��Ĵ��룬multi-page�����һ�����ڴ棨���������룩�����ᱻ������


*/
select type,
sum(virtual_memory_reserved_kb) as vm_reserved, --�ڴ�clerk Reserve �������ڴ���
sum(virtual_memory_committed_kb) as vm_committed,--�����reserve�ڴ棬memory clerk commit �������ڴ���
sum(awe_allocated_kb) as awe_allocated,--�ڴ�clerkʹ�õ�ַ���ڻ���չ���(awe)������ڴ���
sum(shared_memory_reserved_kb) as sm_reserved,--�ڴ�clerk�����Ĺ����ڴ����������Թ������ڴ���ļ�ӳ��ʹ�õ��ڴ���
sum(shared_memory_committed_kb) as sm_committed,--�ڴ�clerk�ύ�Ĺ����ڴ������������ֶο���׷��shardmemory�Ĵ�С
--sum(multi_pages_kb) as mu_page_allocator,--ͨ��stolen ����ĵ�ҳ����,Ҳ����buffer pool ��stolen memory�Ĵ�С
--SUM(single_pages_kb) AS sinlgepage_all,--����Ķ�ҳ�ڴ��������ڴ��ڻ��������䣬Ҳ�������Ǵ�˵��sqlserver�Լ��Ĵ���ʹ�õ�memtoleave�Ĵ�С��
sum(pages_kb) AS sinlgepage_all,
[Reserved/COMMIT]=sum(virtual_memory_reserved_kb)/NULLIF(sum(virtual_memory_committed_kb),0)
--[Stolen]=SUM(single_pages_kb)+sum(multi_pages_kb),
--[Buffer Pool(single page)]=sum(virtual_memory_committed_kb) +SUM(single_pages_kb),
--[Memtoleave(Multi-page)]=sum(multi_pages_kb)
from sys.dm_os_memory_clerks 
group by type
ORDER BY type



/*
�ڴ��е�����ҳ������Щ�����ɣ���ռ���٣�
sys.dm_os_buffer_descriptors : ��¼��sqlserver ������е�ǰ��������ҳ����Ϣ������ʹ�ø���ͼ��������������ݿ⣬�����������ȷ������
�������ݿ�ҳ�ķֲ���

�����ͼ���Իش�
1,һ��Ӧ�þ���Ҫ���ʵ����ݵ�������Щ���ж��
2������Լ���̵ܶ�ʱ����������Ľű���ǰ�󷵻صĽ���кܴ���죬˵��sqlServer�ո�Ϊ�µ���������paging,sql�Ļ�������ѹ�������ں����Ǵ�
���г��ֵ������ݣ����Ǹո�page in���������ݡ�
3,��һ������һ��ִ��ǰ�������һ������Ľű������ܹ�֪����仰Ҫ����������ݵ��ڴ���

*/
select b.database_id,db=db_name(b.database_id),p.object_id,p.index_id,buffer_count=count(*) 
from master.sys.allocation_units a, master.sys.dm_os_buffer_descriptors b,master.sys.partitions p
	where a.allocation_unit_id = b.allocation_unit_id
	and a.container_id = p.hobt_id
	and b.database_id = db_id('master')
	group by b.database_id,p.object_id,p.index_id
	order by b.database_id,buffer_count desc

--��ʾ��ǰ�ڴ��ﻺ�������ҳ���ͳ����Ϣ
declare @name nvarchar(100)
declare @cmd nvarchar(1000)
declare dbnames cursor for
select name from master.dbo.sysdatabases

open dbnames
fetch next from dbnames into @name
while @@FETCH_STATUS =0
begin 
	set @cmd = 'select b.database_id,db=db_name(b.database_id),p.object_id,p.index_id,buffer_count=count(*) from '+
	@name +'.sys.allocation_units a, '
	+@name+'.sys.dm_os_buffer_descriptors b,'+@name+'.sys.partitions p
	where a.allocation_unit_id = b.allocation_unit_id
	and a.container_id = p.hobt_id
	and b.database_id = db_id('''+@name+''')
	group by b.database_id,p.object_id,p.index_id
	order by b.database_id,buffer_count desc'
	print @cmd
	exec(@cmd)
fetch next from dbnames into @name
end
close dbnames
deallocate dbnames

-----3��仰Ҫ����������ݵ��ڴ���

dbcc dropcleanbuffers

declare @name nvarchar(100)
declare @cmd nvarchar(1000)
declare dbnames cursor for
select name from master.dbo.sysdatabases

open dbnames
fetch next from dbnames into @name
while @@FETCH_STATUS =0
begin 
	set @cmd = 'select b.database_id,db=db_name(b.database_id),p.object_id,p.index_id,buffer_count=count(*) from '+
	@name +'.sys.allocation_units a, '
	+@name+'.sys.dm_os_buffer_descriptors b,'+@name+'.sys.partitions p
	where a.allocation_unit_id = b.allocation_unit_id
	and a.container_id = p.hobt_id
	and b.database_id = db_id('''+@name+''')
	group by b.database_id,p.object_id,p.index_id
	order by b.database_id,buffer_count desc'
	print @cmd
	exec(@cmd)
fetch next from dbnames into @name
end
close dbnames
deallocate dbnames

11	AdventureWorks2012	60	1	30
11	AdventureWorks2012	69	3	2
11	AdventureWorks2012	3	1	1
11	AdventureWorks2012	93	1	1

11	AdventureWorks2012	373576369	1	345
11	AdventureWorks2012	60	1	31
11	AdventureWorks2012	1589580701	1	7
11	AdventureWorks2012	7	2	5
11	AdventureWorks2012	245575913	0	5
11	AdventureWorks2012	74	2	4
11	AdventureWorks2012	55	2	3
11	AdventureWorks2012	5	1	3

select * from person.Address


---sys.dm_exec_cached_plans :�˽�ִ�мƻ���������Щʲô����ЩЩ�Ƚ�ռ�ڴ�
select objtype,sum(size_in_bytes) as sum_size_in_bytes,
count(bucketid) as cache_counts
from sys.dm_exec_cached_plans
group by objtype

--�鿴����洢����Щ����
select usecounts,refcounts,size_in_bytes,cacheobjtype,objtype,text
from sys.dm_exec_cached_plans cp
cross apply sys.dm_exec_sql_text(plan_handle)
order by objtype DESC

/*
�ҳ���ȡ����ҳ������������

1,ʹ��DMV����sqlserver�����Ը�����read�������
sys.dm_exec_query_stats :���ػ����ѯ�ƻ��ľۺ�����ͳ����Ϣ��
����ƻ��е�ÿ����ѯ����ڸ���ͼ�ж�һ�С�sqlserver��ͳ��ʹ�����ִ�мƻ��������ϴ�sqlserver������������Ϣ

*/
--�����������ҳ��������
SELECT TOP 50 
qs.total_physical_reads,qs.execution_count,
qs.total_physical_reads/qs.execution_count as [avg IO],
substring(qt.text,qs.statement_start_offset/2,(
case when qs.statement_end_offset = -1 then len(convert(nvarchar(max),qt.text))*2
else qs.statement_end_offset end -qs.statement_start_offset)/2) as query_text,
qt.dbid,dbname=DB_NAME(qt.dbid),
qt.objectid,
qs.sql_handle,
qs.plan_handle
 FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
order by qs.total_physical_reads DESC

--�����߼�����ҳ��������
SELECT TOP 50 
qs.total_logical_reads,qs.execution_count,
qs.total_logical_reads/qs.execution_count as [avg IO],
substring(qt.text,qs.statement_start_offset/2,(
case when qs.statement_end_offset = -1 then len(convert(nvarchar(max),qt.text))*2
else qs.statement_end_offset end -qs.statement_start_offset)/2) as query_text,
qt.dbid,dbname=DB_NAME(qt.dbid),
qt.objectid,
qs.sql_handle,
qs.plan_handle
 FROM sys.dm_exec_query_stats qs
CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) as qt
order by qs.total_logical_reads DESC

/*
DMV������ȱ�㣺
a����ͼ��ÿһ������¼����������ִ�мƻ���������������sqlserver���ڴ�ѹ������һ����ִ�мƻ��ӻ�����ɾ��ʱ����
Щ��¼Ҳ��Ӹ���ͼ��ɾ�������Բ�ѯ�õ��Ľ�����ܱ�֤��ɿ��ԡ�

b����ͼ�������ʷ��Ϣ����sqlserver�����Ϳ�ʼ�ռ��ˣ����Ǻܶ�ʱ����������ÿ��ĳ���ض�ʱ����﷢���ġ�


2,ʹ��sql Trace�ļ�������ĳһ��ʱ������read�������
*/
SELECT * INTO SAMPLE
FROM fn_trace_gettable('c:\sample\a.trc',default)
WHERE eventclass IN(10,12)
--10,RPC:Completed �������Զ�̹��̵���(RPC)ʱ������һ����һЩ�洢���̵���
--12��sql:batchcompleted �������transact-sql������ʱ������

--�ҵ�����̨�ͻ��˷������ϵ��Ǹ�Ӧ�÷��������������������ڷ�ݿ��������reads���
SELECT databaseid,hostname,applicationname,SUM(reads) FROM SAMPLE 
GROUP BY databaseid,hostname,applicationname
ORDER BY SUM(reads) DESC 

--����reads�Ӵ�С�������ĵ����
SELECT TOP 1000 
textdata,databaseid,hostname,applicationname,loginname,spid
 FROM SAMPLE
ORDER BY reads DESC 


---����ͼ�۲�sqlserver io
SELECT 
wait_type,
waiting_tasks_count,
wait_time_ms
FROM sys.dm_os_wait_stats
/*
������������Ӵ��ڵȴ�����io��һ����������������io���ǱȽ�æ�ģ������ַ�æ�Ѿ�Ӱ�쵽��������Ӧ�ٶȡ�
��sqlserverҪȥ��дһ��ҳ���ʱ�������Ȼ���buffer pool��Ѱ�ң������buffer pool���ҵ��ˣ���ô����д������
�������У�û���κεȴ������û���ҵ�����ôsqlserver�ͻ��������ӵĵȴ�״̬Ϊ
Pageiolatch_ex��д����PageIolatch_sh(��)��Ȼ����һ���첽io��������ҳ�����buffer pool�У���ioû����֮ǰ����
�Ӷ��ᱣ�����״̬��io���ĵ�ʱ��Խ�����ȴ���ʱ��Ҳ��Խ����

Writelog ��־�ļ��ĵȴ�״̬����sqlserverҪд��־�ļ����������������ʱ��sqlserver�᲻�ò�����ȴ�״̬��ֱ����־
��¼��д�룬�Ż��ύ��ǰ���������sqlserver����Ҫ��writelog,ͨ��˵�������ϵ�ƿ�����ǱȽ����صġ�
*/

--�˽����Ǹ����ݿ⣬�Ǹ��ļ�����io
SELECT 
db.name AS database_name,f.fileid AS FILE_ID,
f.filename AS FILE_NAME,
i.num_of_reads,i.num_of_bytes_read,i.io_stall_read_ms,
i.num_of_writes,i.num_of_bytes_written,i.io_stall_write_ms,
i.io_stall,i.size_on_disk_bytes
 FROM sys.databases db 
INNER JOIN sys.sysaltfiles f ON db.database_id = f.dbid
INNER JOIN sys.dm_io_virtual_file_stats(NULL,null) i ON i.database_id = f.dbid AND i.file_id = f.fileid

--��鵱ǰsqlserver��ÿ���������״̬��io����
SELECT 
database_id,file_id,io_stall,io_pending_ms_ticks,scheduler_address
FROM sys.dm_io_virtual_file_stats(NULL,NULL) t1, sys.dm_io_pending_io_requests AS t2
WHERE t1.file_handle = t2.io_handle