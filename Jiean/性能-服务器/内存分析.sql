

--Sql Server�ڴ����

/*
һ��SqlServer �ṩ���ڴ���ڽӿ�

1,Min Server Memory(MB) sp_configure����
����sqlserver ����С�ڴ�ֵ������һ���߼������������sqlserver total server memory�Ĵ�С�����������Ƿ��������ڴ�
���ǻ����ļ�ʱ�ڣ�����window�����ģ��������ֵ���ܱ�֤sqlserverʹ�õ���С�����ڴ�����

��sqlserver�ĵ�ַ�ռ����������ֵ�Ժ󣬾Ͳ�����С�����ֵ��������sqlserver�����������С�ڴ�ֵ��

2��Max Server Memory(MB) sp_configure ����
����sqlserver ������ڴ�ֵ��ͬ������Ҳ��һ���߼��������sqlserver total server memory�Ĵ�С�����������Ƿ��������ڴ�
���ǻ����ļ�ʱ�ڣ�����window�����ġ�

����趨ֻ�ܿ���һ����sqlserver���ڴ�ʹ������

3��Set working Set Size (sp_configure ����)
sqlServer��ִ�д���ͨ������һ��windows��������ͼ��sqlserver�������ڴ���ʹ�õ��ڴ����̶��������������ڵ�windows�汾
�Ѿ�������������������и����á�

4��AWE enabled (sp_configure ����)
��sqlserver������AWE���������ڴ棬��ͻ��32λwindows��2GB�û�Ѱַ�ռ䡣����slqserver2012�汾�У�32λ��sqlserver��
ȡ��������ܡ�

5��Lock pages in memory(��ҵ����Զ�����)
������ص�������һ��������ȷ��sqlserver�������ڴ���������Ҳ��ʮ�ֿɿ���

�����ڴ����ģʽ
sqlserver ���ݲ�ͬ�������ֳ���ͬ��ģ�飬��Բ�ͬ���ڴ�ģ����ò�ͬ�Ĵ���ʽ��

a)Database Cache:�������ҳ�Ļ�����������һ����Reserve ��Commit �Ĵ洢��������databaseCahce�У�Ҳ����Щϸ�֣�
����С��8Kb�����ݣ�ͳ�Ʒ���һ��8KB��ҳ�棬���з���Buffer Pool�飬�����ڴ���8KB�����ݣ�������multi-page���У�

���û��޸���ĳ��ҳ���ϵ�����ʱ��sqlserver�����ڴ��н����ҳ���޸ģ����ǲ������̽����ҳ��д��Ӳ�̣����ǵȵ���
���checkpoint��lazy write��ʱ���д���

b)Consumer�����������sqlserver����������������񣬱���:
	connection���ӻ�������generalԪ���ݴ�������Query Plan:���ʹ洢���̵�ִ�мƻ�����

c)�߳�����sqlserver��Ϊ�����ڵ�ÿ���̷߳���0.5MB���ڴ棬�Դ���̵߳����ݽṹ�������Ϣ��

d)����һ�����ǵ�������������ڴ棬��Щ�ڴ�sqlserv�ǹܲ����ģ�������Ϊһ�����̣�windows�ܹ�֪��sqlserver�����
�����ڴ棬����Ҳ�ܼ�����һ���ݵ��ڴ�ʹ�á�


>>>>>>>>>>>>>-----------------------------------------------------------------------------------------------

windows �ṩ��SQL���ܼ�����

��ʵ������ͷ:Memory manager:���ӷ������ڴ���������ļ�����
	1,Total Server Memory : �ӻ�����ύ���ڴ棬�ⲻ��sqlserverʹ�õ����ڴ棬����buffer pool�Ĵ�С
	2��target Server Memory:�������ܹ�ʹ�õ��ڴ�������
	
���ߵĹ۲죺��total С��target,˵��sqlserver��û������ϵͳ�ܹ���sqlserver�������ڴ档sqlserverw�᲻�ϵػ����µ�
����ҳ���ִ�мƻ�����������������ݻ�������������sqlserver���ڴ�ʹ�������������ӡ�
��target��Ϊϵͳ�ڴ�ѹ������Сʱ�������ܻ�С�� total��ֻҪ���������鷢����sqlserver���Ŭ���������棬�����ڴ�
ʹ������ֱ��total ��targetһ����Ϊֹ.

	��ӳ�ڴ�ķֲ����
	1��Optimizer memory : �������������ڲ�ѯ�Ż��Ķ�̬�ڴ�������
	2��sql Cache Memory �������������ڶ�̬sqlserver���ٻ���Ķ�̬�ڴ�����
	3,lock Memory:�������������Ķ�̬�ڴ�������
	4��connection memory����������������ά�����ӵĶ�̬�ڴ�������
	5��Granted workspace memory : ��ǰ��Ԥִ�й�ϣ�����򣬴��������ƺ��������������Ƚ��̵��ڴ�����
	6��memory grants pending : �ȴ������ռ��ڴ���Ȩ�Ľ���������

�۲죺	���memory grants pending���ֵ������0����˵����ǰ��һ���û����ڴ����������ڴ�ѹ�������ӳ٣�
һ�������������ζ���бȽ����ص��ڴ�ƿ����ͨ���ڴ������ķֲ����˽�sqlserver�ڴ��ǲ��ݲ���ռ�ıȽ϶ࡣ��
����¼һЩָ�ꡣ

-----------------
��ʵ������ͷ:Buffer manager:�ṩ�˼����������ڼ���sqlserver���ʹ���ڴ�洢����ҳ���ڲ����ݽṹ�͹��̻��档
	1��Buffer Cache Hit Ratio:�ڻ��������ٻ������ҵ�������Ҫ�Ӵ����ж�ȡ��ҳ�İٷֱȡ�
�۲죺�ñ����ǻ��������ܴ������ȥ��ǧ��ҳ����ʵĻ�������ܴ���֮�ȣ�������99%%���ϣ����С��95%,ͨ��������
�ڴ治������⣬����ͨ������sqlserver�Ŀ����ڴ�������߻��������ٻ��������ʡ�
	
	2��Checkpoint pages/sec:��Ҫ��ˢ��������ҳ�ļ������������ÿ��ˢ�µ����̵�ҳ����
�۲죺����û��Ĳ�����Ҫ�Ƕ����Ͳ����кܶ����ݸĶ�����ҳ��checkpoint��ֵ�ͱȽ�С���෴������û����˺ܶ�insert/
update/delete,��ô�ڴ����޸Ĺ���������ҳ�ͻ�Ƚ϶࣬ÿ��checkpoint����Ҳ��Ƚϴ�
���ֵ�ڷ���disk io�����ʱ�򷴶��õñȽ϶ࡣ

	3��Database pages : ����������ݿ����ݵ�ҳ����Ҳ������ν��database cache�Ĵ�С��
	
	4��Free Pages : ���п��п��õ���ҳ����(2012ȡ��)
�۲죺�����ֵ����ʱ����˵��sqlserver���ڷ����ڴ��һЩ�û��������ֵ�½����Ƚϵ͵�ֵʱ��slqserver�ͻῪʼ��lazywrites,
��һЩ�ڴ��ڳ���������һ�����ֵ����Ϊ0.����������������ͣ���˵��sqlserver�����ڴ�ƿ����һ��û���ڴ�ƿ����sqlserver
��FREE Pages��ά����һ���ȶ���ֵ��

	5��lazy writes/sec:ÿ�뱻�������������Ķ��Ա�д��д��Ļ���������
�۲죺��sqlserver�е��ڴ�ѹ����ʱ�򣬾ͻὫ���û�б����õ�������ҳ��ִ�мƻ�������ڴ棬ʹ���ǿ��������û����̡�
���sqlserver�ڴ�ѹ������lazy writer�Ͳ��ᱻ���������������������������ôӦ�������ڴ��ƿ����
һ��������sqlServer ��ż����һЩlazy writes,�������ڴ�Խ���ʱ�򣬻���������lazy writes.

	6��Page Life expectancy : ҳ���������ã����ڻ������ͣ����������
�۲죺 ���sqlserverû���µ��ڴ����󣬻����п���Ŀռ�������µ��ڴ�������ôlazy writer�Ͳ��ᱻ������ҳ���һֱ
���ڻ�������ôpagelife expectancy�ͻ�ά����һ���Ƚϸߵ�ˮƽ�����sqlserver�������ڴ�ѹ����lazy writer�ͻᱻ����
page life expectancyҲ��ͻȻ�½������ԣ����һ��sqlserver ��page life expectancy���Ǹ߸ߵ͵ͣ������ȶ���ˮƽ�ϣ���ô
���sqlserverӦ�������ڴ�ѹ���ġ�
����һ��������SqlServer,��������û�����û�л������ڴ�������ݣ�����page life expectancy ʱ��ʱ������Ҳ������ġ�
�������ڴ�ʼ�ղ��������£�����ᱻ�����ػ���������page life expectancy��ʼ��������ȥ��

	7��page reads/sec:ÿ�뷢�����������ݼ�ҳ��ȡ������ͳ����Ϣ��ʾ�����������ݿ�������ҳ��ȡ������
�۲죺�������ȫ���������ڴ������Ҫ�����κ�page read����������sqlserv��Ҫ����Щҳ�溵������ҪΪ�����ڳ��ڴ�ռ�����
���ڵ�pagereads/sec�Ƚϸ�ʱ��һ��page life expectancy���½���lazy writes���������⼸���������������ġ�
sqlServer �������ļ���ȡ�������������Ա������������������sqlserver,�����������ֵӦ��ʼ�սӽ���0,ż����ֵ��ҲӦ��
�ܿ콵��0.һֱ��Ϊ0��״̬���ǻ�����Ӱ�����ܵġ�

��������io������page reads ����һ����Ӱ��sqlserver�����ܣ�����ͨ��ʹ�ø�������ݻ��棬��������������Ч�Ĳ�ѯ��
�������ݿ���Ƶȷ�������page reads���͡�

	8��page writes/sec:ÿ��ִ�е��������ݿ�ҳд������
	
	9��Stolen pages :(2012ȡ��) ���ڷ�database pages(����ִ�мƻ�����)��ҳ�����������stole memory��buffer pool��Ĵ�С
���������ҳ�棬sqlServer ��Ƚ����ȵ�����ڴ����ִ�мƻ������Ե�Buffer Pool�����ڴ�ѹ����ʱ��Ҳ�ῴ��Stolen pages
���͡������������Stolen pages ����Ŀûʲô�仯��һ������������ζ��sqlServer �����㹻���ڴ���database  pages(������ע
�⣬����һ����ζ��buffer pool���stolen �ڴ��multi-page �ڴ�û������)
	
	10,target pages:������������ҳ��������8kb,��Ӧ����target server memory��ֵ��
	
	11��total pages:��2012ȡ����������е�ҳ��(�������ݿ�ҳ������ҳ��stolenҳ) ����8kb,��Ӧ����total server memory ��ֵ��


---�ڴ���ض�̬��ͼDMV-------------------------------
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
sum(multi_pages_kb) as mu_page_allocator,--ͨ��stolen ����ĵ�ҳ����,Ҳ����buffer pool ��stolen memory�Ĵ�С
SUM(single_pages_kb) AS sinlgepage_all,--����Ķ�ҳ�ڴ��������ڴ��ڻ��������䣬Ҳ�������Ǵ�˵��sqlserver�Լ��Ĵ���ʹ�õ�memtoleave�Ĵ�С��
[Reserved/COMMIT]=sum(virtual_memory_reserved_kb)/NULLIF(sum(virtual_memory_committed_kb),0),
[Stolen]=SUM(single_pages_kb)+sum(multi_pages_kb),
[Buffer Pool(single page)]=sum(virtual_memory_committed_kb) +SUM(single_pages_kb),
[Memtoleave(Multi-page)]=sum(multi_pages_kb)
from sys.dm_os_memory_clerks 
group by type
ORDER BY type



/*
�ڴ��е�����ҳ������Щ�����ɣ���ռ���٣�
sys.dm_os_buffer_descriptors : ��¼��sqlserver ����й�е�ǰ��������ҳ����Ϣ������ʹ�ø���ͼ��������������ݿ⣬�����������ȷ������
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

	
	
/*
sqlServer���ڴ水�����С�����뷽ʽ����Ҫ������
����ҳ�� database page
buffer pool ���stolen����
multi-page

Stolen�ڴ���������������ʹ��������ϣ���� ����ѯ�������ڴ棩��
��Ϊ��Щ�����������ͨ���ڴ�洢�����洢�ڲ����ݽṹ �������� ���������ĺ�������Ϣ�Ļ�������
����д���������в�����ˢ��Stolen�ӻ�����еĻ�������

<�������ҳ���������ڴ����>

���sqlserver����Ҫ���ڴ��Ӳ�̼䵹���ݣ�����ɲ�ͬ�û��Բ�ͬ����ҳ�ķ���������ôsqlserver���������ܻ��ܵ������Ӱ�죬
����˵���������������ǳ����������⣬sqlserver �������������ԭ��һ�����Ա��һ��sqlServer���ܣ�DataBase Page �Ƿ���
ƿ����Ҫ���ȼ���.

���һ��sqlServer û���㹻���ڴ��ž���Ҫ���ʵ�����ҳ�棬sqlServer �ͻᷢ��������Ϊ
1,sqlServer��Ҫ��������Lazy Writes,�����ʵ�Ƶ�ȣ������û�з��ʵ�����ҳ���д��Ӳ���ϵ������ļ�������û��ʹ�õ�
ִ�мƻ����ڴ��������
2,SqlServer��Ҫ�����������ļ��������ҳ�棬���Ի��кܶ�Ӳ�̶���
3������Ӳ�̶�ȡ����ڴ���������Ǽ��������£������û������ᾭ���ȴ�Ӳ�̶�д��ɡ�
4������ִ�мƻ��ᱻ�������������buffer pool���stolen�ڴ沿��Ӧ�ò���ܶࡣ
5����������ҳ�ᱻ�������������Page Life Expectancy����ܸߣ����һᾭ���½���

sys.sysprocesses ��̬������ͼ�г���һЩ���ӵȴ�i/0��ɵ�����
��sqlserver����database page�ڴ�ƿ����ʱ������������ŷ���Ӳ��ƿ�����⡣������Ϊ
1��sqlserver����ҳpaging ���������������Ӳ�̶�д��ʹ��Ӳ�̸���æµ������
2�����һ������Ҫ��sqlserer��Ӳ���϶����ݣ�����ȴ���ȴ��ڴ����Ҫ���ö࣬ʱ�仨�Ѳ���һ���������ϡ�����Ӳ����
�죬Ҳ�Ȳ����ڴ档���Դ����ӵĵȴ�״̬���֣����ǻᾭ����Ӳ�̡�

��ȷ��������ҳ�滺�������ڴ�ѹ���󣬷���ѹ����Դ�ͽ������

1,�ⲿѹ��
��window��������ڴ治����ʱ��sqlserver��ѹ���Լ����ڴ�ʹ�ã���ʱ��database pages ���׵���壬��ѹ���������Լ�
Ȼ�ᷢ���ڴ�ƿ������ʱ��ѹ������ sqlServer���ⲿ

a,sqlserverMemory Manager  - Total Server Memory ��û�б�ѹ��
b,memory:available mbytes ��û���½�һһ���Ƚϵ͵�ֵ
c,���sqlServerû��ʹ��AWE��lock page in memory������process �ϵ��ڴ����������׼�ģ����Կ���process:private bytes-sqlserver
��process:working Set -sqlservr��ֵ�ǲ���Ҳ���˼�����½���

����취
��Ȼѹ������sqlserer ֮�⣬�ǹ���Ա��Ҫ����ѡ�����Ǹ�sqlserver��һ���ڴ���Դ�أ�������sqlserver�Լ�������ʳ������һЩ�ڴ��ϵͳ,
�����������ͨ������sqlserver��max server memoryֵ������

Ϊ�����̶���Ԥ���ⲿѹ���� sqlserver�������������Ӱ�죬���ǽ�����Ҫ��sqlserver������ð�װ��ר�ŵķ������ϣ���Ҫ�������������һ��

2������sqlserver����database pageʹ�������ѹ��
sqlserver��totalserver memory�Ѿ��������û��趨��max servermemory���ޣ�����sqlserver�Ѿ�û�а취��windows���������뵽���ڴ棬��
�û��������ʵ���������Զ���������ڴ������������ҳ��Ĵ�С����ʹsqlserver���ϵؽ��ڴ��������page out ��page in,�������ǰ�û�����

��Ҫ������
1)sqlServer:memory manager-Total Server Memory һֱά����һ���Ƚϸߵ�ֵ����sqlserver memory manager-target server memory��ȡ�����
��total server memory ����target server memory������
��һ���������ڲ�ѹ�����ⲿѹ���������Բ��.

2,������ͬ����
sqlserver:buffer manager - lazy writes/sec : �������ֲ�Ϊ0.
....page Life expectancy:�����������½�
....page reads/sec : ������Ϊ0
....Stolen pages :ά����һ���Ƚϵ͵�ˮƽ��Ӧ�ñ�database page ҪС�ܶࡣ
sys.sysprocesses ��̬������ͼ�г���һЩ���ӵȴ�i/o��ɵ�����

����취
��Ȼsqlserver�Լ�û����ߵ��ڴ�ռ��database pages,�ǽ�������˼·��������������취��sqlserver������ڴ棬
�����취��sqlserver����һ���ڴ档
a,��32λ�������Ͽ���awe���ܣ���չʹ��4G�����ڴ档
b,���sql�Ѿ����ʹ���˷��������ڴ棬�㲻�ǲ����������ڴ档
c,���scale up�����ף����Կ���scale out,�����ݿ⵽�����������ϡ�
d,����sqlserver�����У��ҵ���ȡ����ҳ���������������������Щ���������Ҫ���ܶ����ݣ��Ǿ�Ҫ��Ӧ�ÿ�����Ա������
Ϊʲôÿ��Ҫ��sqlserver�϶�ȡ��ô�����ݣ��Ƿ��������Ҫ��������ֻ��Ҫ���ز������ݣ�������Ϊ�����û�к��ʵ�������
ʹ��sqlѡ����һ����ɨ���ִ�мƻ�����ʵ�Ϻܶ�������û��Ҫ���ģ��Ǿ�Ҫ�Ż����ݿ���������ƣ��Թ�������ִ�У�����
�ڴ�ʹ�á�


3������buffer pool���stolen memory��ѹ��
��������£�buffer pool���stolen memory �ǲ�Ӧ�ø�database pages ���̫���ѹ���ģ���Ϊ���database pages ��ѹ����
�ͻᴥ��lazy writes,ͬʱsqlҲ�����stolen �ڴ��ִ�мƻ����沿�ݡ�������һ��buffer pool���ڴ�ѹ����sqlserver�ϣ��ǲ�
��̫���stolen memory�ģ���������Щsqlserver�ϣ��û����ܿ�����һЩsqlserver�����û�м�ʱ�رգ����磬�����˺ܶ��ε���
�������Ժ󲻹أ�����prepare �˺ܶ�ִ�мƻ����ǲ�un-prepare,��Щ������󲿷��Ƿ���buffer pool��ģ�����û�ʼ�ղ��ͷ�
���ǣ�Ҳ���ǳ�sqlserver,���ⲿ���ڴ�������Ų��������ⲿ���ڴ��ǵ��㹻��ʱ���ᷴ����ѹ��database page ��ʹ�á�

���stolen memoryʹ����Ҳ�Ƚϼ򵥣�����ֱ�Ӳ�ѯ sys.dm_os_memory_clerks ���ϵͳ������ͼ��single_pages_kb�ֶΣ�����
�ĸ�clerk�õ��˱Ƚ϶��stolen�ڴ淽��Ƚ������

4������multi-page��memtoleave����ѹ��
���� multi-page��buffer pool����sqlserve�������ַ�ռ䣬���multi-pageʹ�õ�̫�࣬buffer pool�ĵ�ַ�ռ��С�ˣ���Ҳ��
ѹ��database page�Ĵ�С������sqlserverʹ��multi-page����һ�㲻��������������Ƚ��ٷ�����

64λ��sqlserver�ϣ���multi-pageʹ���Ѿ�û�����ޡ�sqlserver��Ҫʹ�ö��٣����ܹ����뵽���١����sqlserver ������һЩ
�ڴ�й©�������ĵ��������룬64λ�ϵ��ڴ���Ȼ�Ƚϳ�ԣ����Ҳ�б�©��Ŀ��ܡ�

��ѯsys.dm_os_memory_clerks.multi-page��������clerk�õ����ڴ档


5���������ڴ�ʹ�����̶�����û���ⲿѹ����sqlserver���ڴ�ѹ����Ҫ����database pages ʱ������ԱҪ���ľ���Ҫ�ҳ�sqlserver
ΪʲôҪ����ô��databse page���棬���ڴ���ѹ��������£�sqlserver�ǲ����޴��޹ʵػ��˴�����ҳ��ġ�һ�������û�������Щ
���ݡ�

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


--Stolen Memory����ѹ������------------------------------
/*
��sqlServer �����dataBase Pages,�������ڴ������������������reserve,��commit�ķ���������ֱ�Ӵӵ�ַ�ռ�������
������Щ�ڴ��������Stolen Memory.��һ���SqlServer,Stolen �ڴ�Ҳ��Ҫ��8KBΪ��λ���䣬�ֲ���BUffer Pool ��

Stolen �ڴ���Ȼ����������ҳ�棬���Ƕ�sqlserver����������Ҳ�Ǳز���ȱ�ģ��κ�һ������ִ�У�����Ҫstolen�ڴ�������
��ķ������Ż���ִ�мƻ��Ļ��棬Ҳ������Ҫ�ڴ��������򣬼��㡣�κ�һ�����ӵĽ�����Ҳ�Ϸ�Ҫ����stolen�ڴ����������
�ݽṹ�����롢������������������stolen�ڴ����벻����sqlServer���κβ������п����������⡣

���һ��sqlServer�ܹ�������ô�಻ͬ��ִ�мƻ���˵�����ڲ����еĴ�����Ƕ�̬t-sql��䣬���������á�

���֣�
��stolen�ڴ���ѹ����ʱ�򣬻�����������⡣һ�����û��ύ��������Ϊȱ���ڴ��������ɣ�sqlserver���ش�����Ϣ��
���������sqlserver��Ӱ���Ƚ����أ�����֢״Ҳ�Ƚ����ԡ�
��һ���� sqlserver�ڴ�ռ����������ƿ��������sqlserver����ͨ��ѹ��ĳЩclerk������ڴ����������������һЩ������
�õ�������ڴ棬�������û��ȴ�һ�ᣬ����������û��ύ������

��sqlserver�����ⷽ���ƿ��ʱ������ͨ��sys.sysprocesses.waittype�ֶβ�����0x0000���۲�

1��CMEMthREAD(0x00B9)�ȴ� 
�߲���sqlserer,ͬʱ�������̫�࣬����Щ���������ӣ��ڴ�����ʹ����Ҫÿ�ζ�������Ķ�̬t-sql��䡣����������������ڴ棬
�����޸Ŀͻ���������Ϊ�������ܸ����ʹ�ô洢���̣�����ʹ�ò�������t-sql�����ã�������������������ִ�мƻ������á�
�����������ͬʱ�����ڴ��������������

2��SOS_RESERVEDMEMBLOCKLIST(0X007B)
���û�������������ں��д����Ĳ�����������һ���ܳ���in�Ӿ�ʱ������ִ�мƻ���8kb ��single pages ���ܻ�Ų��£���Ҫ��
multi-page���洢������sqlserver��Ҫ��mumtoleave������ռ䣬��ɵĺ�����������Ż����ִ�мƻ�Խ��Խ�࣬����buffer pool
���stolen�ڴ��ڲ���������memtoleav�������洢ִ�мƻ���stolen�ڴ�Ҳ�ڲ������������û�Ҫ��������ڴ����ʱ���ܵõ�����
ʱ�ĵȴ�״̬��

���������
a,����ʹ�����ִ��������������߳�in�Ӿ�����
b,ʹ��64λ��sqlserver
c,��������dbcc freeproccache


3,RESOURCE_SEMAPHORE_QUERY_COMPILE(0X011a)
��һ��batch��洢���̷ǳ��߳����ӵ�ʱ��sqlserver��Ҫ�ܶ���ڴ��ڽ��б��룬Ϊ�˷�ֹ̫���ڴ汻���������룬sql
serverΪ�����ڴ�����һ�����ޡ�����̫�ิ�ӵ����ͬʱ��������ʱ�����ܱ����ڴ�ʹ�û�ﵽ������ޣ�����������
�����ò�����ȴ�״̬��

���������
a,�޸Ŀͻ����ӵ���Ϊ�������ܸ����ʹ�ô洢���̻�����ʹ�ò�������t-sql�����ã�������������������ִ�мƻ������á�
�����������ͬʱ�����ڴ��������������
b,��ÿ����Ҫ��������ĸ��Ӷȣ����ͱ�����Ҫ���ڴ�����
c,��������dbcc freeproccache


--Multi-Page ������ѹ������------------------------------------

��multi-page�ڴ������
a,С�ڵ���8Kb���ݷ���buffer pool�ڴ������8KB,�����Ǽ�����sqlserver�����ڵĵ�����������������ڴ棬����mulit-page�ڴ���
b,��32λϵͳ�multi-page����Ŀ�������Ƶģ�������64λϵͳ���Ѳ��������ƣ���sqlserver��max server memory���� ����
buffer pool�����á�
c,multi-page��Ҫ����ÿ��sql����threadҪ��0.5MB,sqlserver�Լ�����ĳ���8kb��stolen�ڴ棬�Լ�sql��������صĵ�����������
������ڴ档

������ԭ��
1���ͻ��������򳬹�8bk��������ʹ������Щ�ڴ棬���� ���������������߳�in����䣬�����ӵ�network packet size���8kb����ߡ�
2,�ͻ���Ӧ�õ�����һЩ���ӻ������޴��xml���ܡ�
3������ʹ����clr�ȹ��ܡ�

*/