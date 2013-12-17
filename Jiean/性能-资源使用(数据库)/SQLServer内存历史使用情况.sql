

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
order by objtype desc