
--sqlserver ����ô��ʹ��һ̨�������ϵ�ϵͳ��Դ��

/*
��Ϊһ��window����ϵͳ�ϵ�Ӧ�ó���sql server���Ƚ���window�Ĺ�������window���ų��ĸ���API
������͵��ȸ�����Դ��ʹ�á�����Ϊһ����������ϵͳ��sqlserver�����Լ�һ�׵�ϵͳ��Դ�������
�����Ƕ��ڹ˺�cpu��Դ��

Ҳ����˵����Դ�����ϣ�һ����window�����ϣ���window�������ȶ���ϵͳ��Դ��sqlserver,�ڶ�����sqlserver
�ڲ�����sqlserver�����Լ��ƿص���Դ������ô�á�

�ڴ����
��Ϊһ����Ҫ�����������ݵ�Ӧ�ã�sqlserver�������ڴ��л���ܶ���Ϣ�����ܾ������õ����ܡ�

1��sqlServer��ռ�õ��ڴ������������Ժ󣬾Ͳ�ͣ��������
Ҫ�������������Ҫ�˽�sqlserver��window���Լ���������window֮�ϵ����������Ӧ������ô�໥�����
����������ϵ��ڴ�ģ�����Ҳ��Ҫ�˽���ô���ܱȽ�׼ȷ�ط���һ̨��������window�Ͱ���sqlserver����
������Ӧ�ý��̵��ڴ�ʹ�á�

2����window2003���ϰ汾�����е�slqserver,�ڴ�ʹ����ͻȻ�����½���

3���û���������ʱ�������ڴ�����ʧ�ܡ�

4���ڴ�ѹ�����µ������½�

�Ӳ���ϵͳ���濴sql server�ڴ����
 sqlserver������Ӧ�ó����������ڴ���û��ʲô���𣬶���ͨ��virtualalloc֮���API��windows�����ڴ档
 windowҪЭ���������������Ӧ�õ����󣬻�Ҫ��֤��Щ���󲻻�Σ��window����İ�ȫ��
 
 Virtual Address Space �����ַ�ռ�
 �����ڴ�Ѱַ�ռ䣬ÿһ���ڴ浥Ԫ����һ����Ӧ�ķ��ʵ�ַ��Ѱַ�ռ�Ĵ�С������Ӧ�ó����ܹ�������ʵ�
 ������ַ�ռ䣬32λ�ķ������ϣ����ڵ�ַ��Ԫ�ĳ�����32λ��Ѱַ�ռ����2^32,��4GB���ٴ�Ŀռ�Ҳ�޷�
 ��Ӧ�ó���ʹ�õ���
 ע�������ַ�ռ����ŵ�������Ϣ��һ�����������ڴ��window�������ʹ���������������ʲôʱ��������
 �ڴ��ʲôʱ������ڴ��ļ���(paging file)

 Page Hard Fault(Ӳ����)
 ������һ�������������ַ�ռ䣬���������������ڴ��ҳ�棬�ͻᷢ��һ��page Fault.windows�ڴ��������ᴦ��
 ÿһ��ҳ����ʴ���������Ҫ�ж��ǲ��Ƿ���Խ�磬������ǣ����Ŀ��ҳ�������Ӳ����(����,��page file��)��
 ���ַ��ʻ����һ��Ӳ�̶�д�����ǳ���ΪHard Fault.��һ��ҳ������ɣ�������ڴ��У����ǻ�û��ֱ�ӷ����������
 ��working Set �£���Ҫwindows���¶���һ�Σ����ַ��ʲ������Ӳ�̲��������ǳ�֮ΪSoft Fault.

 Reserved Memory�������ڴ棩
 Ӧ�ó������ڴ��б���һ��һ���ڴ�Ѱַ�ռ䣬�Թ�����ʹ��,������ʵ��ȥ�����ڴ�ռ䡣

 Committed Memory(�ύ�ڴ�)
 ��Ԥ�ȱ������ڴ�Ѱַ��ʽ�ύʹ�ã��������ݡ�Ҳ����˵����ʽ�������ڴ�������һ�οռ䣬��ҳ���д������ݡ�

 Working Set(������)
 ĳ�����̵ĵ�ַ�ռ��У�����������ڴ����һ���ݡ�
 
 shared Memory(�ɹ���)
 windows�ṩ���ڽ��̺Ͳ���ϵͳ�乲���ڴ�Ļ��ơ������ڴ���Զ���Ϊ��һ�����ϵĽ��̶��ǿɼ����ڴ棬���
 ���ڶ�����̵������ַ�ռ䡣
 
 private bytes(ר��)
 ĳ�������ύ�ĵ�ַ�ռ�(Committed Memory)�У��ǹ���Ĳ��֡�
 

 Memory Leak(�ڴ�й©)
 ��Ӧ�ó����г���ĳ��ѭ����һֱ���ϵر���(Reserve)���ύ(Commit)�ڴ���Դ���������ǲ��ٱ�ʹ�ã�Ҳ���ͷŸ������û����á�
 �ͻ�����ڴ�й©��sqlServer���ڴ�й©�����֣�һ����SqlServer ��Ϊһ�����̣����ϵ���windows�����ڴ���Դ��ֱ������window�ڴ�ľ���
 ��һ������sqlServr�ڲ���ĳ��sql Server ������ϵ������ڴ棬ֱ����sqlServer�����뵽�������ڴ涼�ľ���ʹ������sqlServer�Ĺ���
 �����������ʹ���ڴ档

 �ر��˽���32λ�µ�Ѱַ��Χ
 32λwindow ���û� ���̻���4G��Ѱַ�ռ䣬����2GB�Ǹ�����̬(Kernel Mode)���µģ�ʣ��2GB�Ǹ��û�̬(user Mode)���µģ�window������
 Ϊ����ĳһ���ڴ��ַ�ռ��þ���������һ��Ŀռ��ó���

 /3GB����
 ��boot.ini�ļ���ʹ��/3GB�������԰Ѻ���̬��Ѱַ�ռ併��1G,�û�̬Ѱַ�ռ�����3G.

 AWE(Address Windowsing Extensions ��ַ�ռ���չ)
 ����һ������ 32λӦ�ó������64GB�����ڴ棬������ͼ�򴰿�ӳ��2GB�����ַ�ռ�Ļ��ơ�

 ע��sqlserver��ͨ��һЩ���⺯�����ã�ȥ����2G�����ڴ��ַ����Reserve��Ȼ��ͨ��Commit���ڴ���ã�������ʹ����չ���ڴ棬��
 һ��ķ�ʽ������ڴ棬����ֻ��ʹ��2GB��.

 ����AWE
 1)��Ҫsqlserver�����ʻ���window����lock pages in memoryȨ�ޡ�
 2)��½�û��з�����Ȩ��
 3) sp_configure 'awe enabled',1
 4)ȷ�� sql��־����
	server Address Windowing Extensions enabled.
	ʧ�ܣ�Cannot use Address Windowing Extensions Because lock memory Privilege was not granted.
 

 --------windows �ڴ���------------------------------------------------
 windows����û�����Ե��ڴ�ѹ������sqlServer�������е�ǰ�ᡣ
 ��飺
 1)windowsϵͳ�����ڴ�ʹ���������ڴ�ֲ���
 2����������ÿһ�����̵��ڴ�ʹ������� �˽���Щ�����ڴ�ʹ�õ���࣬��Щ�����������ڴ�ѹ����

 ����windows ϵͳʹ�����
 
 ��Դ������
1������������п������ڴ������ǽ��̵�ר���ڴ��С
2��������=�ɹ���+ר��
3���ύ~=ר���ڴ�+ҳ�ļ���С,����ϵͳԤ����һ���������ڴ���Լ�ʹ��

a) ΪӲ���������ڴ棺�����Դ����⣬����û�����߸���û���ڴ���ӳ�似�����壬��Ӳ��ռ�õ�һ���ֵͶ˵�ַ�ռ䡣
b) ����ʹ�ã�	�����̡�������������ϵͳʹ�õ��ڴ�
c) ���޸ģ������ݱ����ڽ�����̺������������Ŀ�ĵ��ڴ档ָ�����Ѿ�����˲������ȴ�д������ǲ����ڴ档
d) ���ã�	����δ��Ծʹ�õĻ������ݺʹ�����ڴ棬Ҳ�����Ѵ���������õ������ݵ��ڴ�ռ䣬����������ʹ�á�
e) ���ã��������ڴ棬�������κ��м�ֵ���ݣ��Լ������̡�������������ϵͳ��Ҫ�����ڴ�ʱ������ʹ�õ��ڴ档

 1,����ʹ�÷���
Committed Bytes
����windowsϵͳ������windows���������û�����ʹ�õ��ڴ����������������ڴ�������ݺ��ļ������е����ݡ�

���������ڴ�����-��Դ�������е�����ʹ���ڴ�-ΪӲ���������ڴ�=ʹ�õ�ҳ���ļ�����

2,Commit Limit
����windowsϵͳ�ܹ����������ڴ�������ֵ���������ڴ�����ļ�����Ĵ�С��

���Committed Bytes�Ѿ��ӽ������Commit Limit,˵��ϵͳ���ڴ�ʹ���Ѿ��ӽ����ޣ������
���ļ������Զ�������ϵͳ�������ṩ������ڴ�ռ䡣

3,Available Mbytes
����ϵͳ���е������ڴ��������ָ���ܹ�ֱ�ӷ�ӳ��windows��������û���ڴ�ѹ����
�Ƚϣ������ֵ������Դ����������Ŀ��������ǶԵ��ϵġ����������ܷ�ӳ��ĳ��ʱ�������С��ƽ��ֵ��

4��Page File:%Usage ��Page File:%Peak Usage
�������ǰٷֱ�������Ӧ�����ļ�ʹ�����Ķ��٣��������ļ������д��Խ�࣬˵�������ڴ�������ʵ������
���Ĳ��Խ������ҲԽ�

5��pages/sec
Hard Page Fault ÿ������Ҫ�Ӵ����϶�ȡ��д���ҳ����Ŀ���������windowsϵͳ������Ӧ�ý��̵����д�
��paging��������Memory:pages input/sec ��memory:pages output/sec �ĺ͡�

����һ���������ã����㹻�ڴ���Դ��ϵͳ����������Ҫ���������Ӧ�ñȽϳ��ڵر����������ڴ�����Ƶ��
�ر���������(page in/page/out)���Ʊػ�����Ӱ�����ܣ��������һ��ϵͳ��ȱ�ڴ棬pages/sec���ܳ�ʱ��ر�
����һ���Ƚϸߵ�ֵ��

�ܽ᣺�˽������ڴ��ַ�ռ��ʹ�ô�С���Լ��ж���������ʵ������Ӳ���ϵĻ����ļ��
�ж��ٿ��е������ڴ滹�ܱ�ʹ�á�����һ̨sqlserver���������������С��10MB��һ�����������ڴ��ǲ�̫���ġ�
ȷ��ϵͳ�Ƿ���Ϊ�����ڴ治�㣬��Ƶ����ҳ�滻����������������ǣ�Ҳ˵�������ڴ治��ԣ��


----Windowsϵͳ�����ڴ�ʹ�����------------------------------------
һ��32λ��windows ϵͳ��windows�������ڴ�ʹ���ڼ���Mb,64λ�����ϣ����ܻ�ﵽ1-2GB,�������windows����һЩ
����Ĳ�������������windows��������ڴ�й©��һ������һЩӲ��������ɵģ���windows���ܻ��õ�����G����ʮ��GB��
��������ѹ��Ӧ�ó���������ڴ�ʹ�á�

Memory:Cache Bytes
ϵͳ��working Set ,Ҳ����ϵͳʹ�õ������ڴ���Ŀ���������ٻ��棬ҳ���������ɵ�ҳ��ntoskrnl.exe ������������룬�Լ�
ϵͳӳ����ͼ�ȡ�
�������¼��������ܺ�
Memory:Ststem cache Resident bytes(system cache)
ϵͳ���ٻ������ĵ������ڴ档

Memory:Pool paged resident bytes
ҳ���������ĵ������ڴ�

Memory:System Driver Resident Bytes
�ɵ�ҳ���豸��������������ĵ������ڴ档

Memory:System Code Resident Bytes
Ntoskrnl.exe �пɵ�ҳ�������ĵ��ڴ档

----System Pool------------------------------------
windows������������Ҫ�Ľ�����(pool),����������ڴ����й©�����߿ռ��þ���windows�����һЩ���
�Ĳ�������Ϊ������Ӱ��sqlServer���ȶ����У������������ڴ��ʹ�����ҲҪ���һ�¡�
memory:pool Nonpaged bytes(��ҳ������) 
Memory:Pool paged resident Bytes(ҳ������)

--����proecss ���̵�ʹ�����
��Available MBytes�������������ڴ�����þ������Ǵ�Memory:Cache Bytes ��ֵ����window�Լ�û��ʹ�ö��٣����ھ�Ҫ����
��������Щ��Ӧ�ý��̰������ڴ涼ռ���ˡ�

Process:%processor Time ָ����Ŀ��������ĵ�cpu��Դ���������û�̬�ͺ���̬��ʱ��,Ҳ���Ǵ���������ִ�з������߳�ʱ��
�İٷֱȡ�

Process:Page Faults/sec ָ����Ŀ������Ϸ�����Page Faults����Ŀ��

Process:Handle Count ָ����Ŀ�����Handle(ָ��object��ָ��)��Ŀ����������ڲ��ж������Ǵ���������ʱ���գ��ͻᷢ��Handle Leak.

Process:Thread Count ָ����Ŀ����̵��߳���Ŀ������������Ǵ������̣߳����ͷ����̣߳��ͻᷢ��Thread Leak.

Process:Pool Paged Bytes ָ����Ŀ�������ʹ�õ�Paged Pool ��С.

Process:Pool Nonpaged Bytes ָ����Ŀ�������ʹ�õ�Non-Paged Pool ��С.


Process:Working Set :ĳ�����̵ĵ�ַ�ռ��У�����������ڴ����һ���ݡ�
Process: Virtual Bytes:ĳ������������������ַ�ռ��С������reserved  Memory��Committed Memory.
Process:Private Bytes:ĳ�����̵��ύ�˵ĵ�ַ�ռ�(committed Memory)�У��ǹ���Ĳ��ݡ�

Ŀ�꣺
ʹ���ڴ����Ľ���
�ڴ�ʹ�����ڲ��������Ľ���
����������Ǹ�ʱ�����ڴ�ʹ������������ͻ��Ľ���.


SqlServer�ڴ�ʹ������

Ĭ�������û�̬��ַ�ռ���2GB,���ʹ����/3GB���������� AWE����������64λ�Ļ����ϣ�sqlserver����
ʹ�ø�����ڴ棬sqlserver�Ǹ���ϲ���ڴ���Դ�ĳ�����������״̬�����ǰ����п��ܻ��õ������ݺͽṹ
�������������ڴ���Դﵽ���ŵ����ܡ�

Ĭ������£�����sqlServer ��̬ʹ���ڴ棬���ᶨ�ڲ�ѯϵͳ��ȷ�����������ڴ���


�ͷ��ڴ����
Total Server Memory :SqlServer �Լ������Buffer Pool �ڴ��ܺ�
Target Server Memory : sqlServer���������ܹ�ʹ�õ������ڴ���Ŀ��

��sqlserver������ʱ��������һ���Լ��������ַ�ռ䣬�Ƿ�����AWE,sp_configure���"max Server Memory"ֵ���Լ���
ǰ�������Ŀ��������ڴ���������ȡһ����Сֵ����Ϊ�Լ���Target server memoryֵ��

��sqlServer���еĹ����У��������֪��windows������ڴ�ѹ�����ͻή��Target ServerMemory�Ĵ�С����sql Server�ֻᶨ��
�Ƚ�TotalServerMemory��TargetServerMemory����ֵ.

��Total Server MemoryС��TargetServerMemoryʱ��sqlserver֪��ϵͳ�����㹻���ڴ棬��������Ҫ�����κ��µ�����ʱ���ͻ������
���ڴ��ַ�ռ䡣�Ӽ������Ͽ���totalServerMemory��ֵ�᲻�ϱ��.

��Total Server Memory����TargetServerMemoryʱ��sqlServer ֪���Լ��Ѿ�������ϵͳ�ܹ�������ڴ�ռ䣬�����Ҫ�����κ��µ���
�ݣ���������ȥ�����µ��ڴ�ռ䣬���������������Լ����ڵ��ڴ�ռ������������ڳ��ռ������µ�����ʹ�á�

��sqlServer�յ�windows�ڴ�ѹ���źţ���Сtarget ServerMemoryֵ��ʹ��Total Server Memory����target Server Memoryʱ��sqlserver
��ʼ�ڴ�����������С�Լ��ĵ�ַ�ռ��С���ͷ��ڴ档

-----------�ڴ����---------------------------------------


---�ڴ���ض�̬��ͼDMV
sqlServer2005�Ժ�sqlserverʹ��Memory Clerk�ķ�ʽͳһ����sqlServer�ڴ�ķ���ͻ��ա�����sqlserver ����Ҫ������ͷ��ڴ棬����
Ҫͨ�����ǵ�Clerk.ͨ�����ֻ��ƣ�sqlserver ����֪��ÿ��clerk ʹ���˶����ڴ棬�Ӷ�Ҳ�ܹ�֪���Լ��ܹ����˶����ڴ档��Щ��Ϣ��̬��
�������ڴ涯̬������ͼ��.

��ʼ
sys.dm_os_memory_clerks:����sqlServerʵ���е�ǰ���ڻ״̬��ȫ���ڴ�clerk�ļ���,Ҳ����˵���������ͼ����Կ����ڴ�����ô��
sqlServerʹ�õ���

�ڴ��е�����ҳ������Щ�����ɣ���ռ���٣�
sys.dm_os_buffer_descriptors : ��¼��sqlserver ����й�е�ǰ��������ҳ����Ϣ������ʹ�ø���ͼ��������������ݿ⣬�����������ȷ������
�������ݿ�ҳ�ķֲ���

�����ͼ���Իش�
1,һ��Ӧ�þ���Ҫ���ʵ����ݵ�������Щ���ж��
2������Լ���̵ܶ�ʱ����������Ľű���ǰ�󷵻صĽ���кܴ���죬˵��sqlServer�ո�Ϊ�µ���������paging,sql�Ļ�������ѹ�������ں����Ǵ�
���г��ֵ������ݣ����Ǹո�page in���������ݡ�
3,��һ������һ��ִ��ǰ�������һ������Ľű������ܹ�֪����仰Ҫ����������ݵ��ڴ���

sys.dm_exec_cached_plans :�˽�ִ�мƻ���������Щʲô����ЩЩ�Ƚ�ռ�ڴ�
*/
select type,
sum(virtual_memory_reserved_kb) as vm_reserved,
sum(virtual_memory_committed_kb) as vm_committed,
sum(awe_allocated_kb) as awe_allocated,
sum(shared_memory_reserved_kb) as sm_reserved,
sum(shared_memory_committed_kb) as sm_committed,
sum(pages_kb) as mu_page_allocator
from sys.dm_os_memory_clerks 
group by type



-------
select b.database_id,db=db_name(b.database_id),p.object_id,p.index_id,buffer_count=count(*) 
from master.sys.allocation_units a, master.sys.dm_os_buffer_descriptors b,master.sys.partitions p
	where a.allocation_unit_id = b.allocation_unit_id
	and a.container_id = p.hobt_id
	and b.database_id = db_id('master')
	group by b.database_id,p.object_id,p.index_id
	order by b.database_id,buffer_count desc


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


---
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

����ҳ������ѹ������
���sqlserver����Ҫ���ڴ��Ӳ�̼䵹���ݣ�����ɲ�ͬ�û��Բ�ͬ����ҳ�ķ���������ôsqlserver���������ܻ��ܵ������Ӱ�죬
����˵���������������ǳ����������⣬sqlserver �������������ԭ��һ�����Ա��һ��sqlServer���ܣ�DataBase Page �Ƿ���
ƿ����Ҫ���ȼ���.

���һ��sqlServer û���㹻���ڴ��ž���Ҫ���ʵ�����ҳ�棬sqlServer �ͻᷢ��������Ϊ
1,sqlServer��Ҫ��������Lazy Writes,�����ʵ�Ƶ�ȣ������û�з��ʵ�����ҳ���д��Ӳ���ϵ������ļ�������û��ʹ�õ�
ִ�мƻ����ڴ��������
2,SqlServer��Ҫ�����������ļ��������ҳ�棬���Ի��кܶ�Ӳ�̶���
3������Ӳ�̶�ȡ����ڴ���������Ǽ��������£������û������ᾭ���ȴ�Ӳ�̶�д��ɡ�
4������ִ�мƻ��ᱻ�������������Page Life Expectancy����ܸߣ����һᾭ���½���

sqlServer:buffer Manager -lazy writes/sec
һ��������sqlServer ��ż����һЩlazy writes,�������ڴ�Խ���ʱ�򣬻���������lazy writes.

sqlServer:buffer Manager - page life expectancy
����һ��������SqlServer,��������û�����û�л������ڴ�������ݣ�����page life expectancy ʱ��ʱ������Ҳ������ġ�
�������ڴ�ʼ�ղ��������£�����ᱻ�����ػ���������page life expectancy��ʼ��������ȥ��

3,sqlServer:buffer Manager - page reads/sec
sqlServer �������ļ���ȡ�������������Ա������������������sqlserver,�����������ֵӦ��ʼ�սӽ���0,ż����ֵ��ҲӦ��
�ܿ콵��0.һֱ��Ϊ0��״̬���ǻ�����Ӱ�����ܵġ�

4,sqlServer:Buffer Manager - Stolen Pages
���������ҳ�棬sqlServer ��Ƚ����ȵ�����ڴ����ִ�мƻ������Ե�Buffer Pool�����ڴ�ѹ����ʱ��Ҳ�ῴ��Stolen pages
���͡������������Stolen pages ����Ŀûʲô�仯��һ������������ζ��sqlServer �����㹻���ڴ���database  pages(������ע
�⣬����һ����ζ��buffer pool���stolen �ڴ��multi-page �ڴ�û������)

5��sys.sysprocesses ��̬������ͼ�г���һЩ���ӵȴ�i/0��ɵ�����
��sqlserver����database page�ڹ�ƿ����ʱ������������ŷ���Ӳ��ƿ�����⡣������Ϊ
1��sqlserver����ҳpaging ���������������Ӳ�̶�д��ʹ��Ӳ�̸���æµ������
2�����һ������Ҫ��sqlserer��Ӳ���϶����ݣ�����ȴ���ȴ��ڴ����Ҫ���ö࣬ʱ�仨�Ѳ���һ���������ϡ�����Ӳ����
�죬Ҳ�Ȳ����ڴ档���Դ����ӵĵȴ�״̬���֣����ǻᾭ����Ӳ�̡�

---ȷ��ѹ����Դ�ͽ���취

1,�ⲿѹ��
��window��������ڴ治����ʱ��sqlserver��ѹ���Լ����ڷ�ʹ�ã���ʱ��database pages ���׵���壬��ѹ���������Լ�
Ȼ�ᷢ���ڴ�ƿ������ʱ��ѹ������ sqlServer���ⲿ

a,sqlserverMemory Manager  - Total Server Memory ��û�б�ѹ��
b,memory:available mbytes ��û���½�һһ���Ƚϵ͵�ֵ
c,���sqlServerû��ʹ��AWE��lock page in memory������process �ϵ��ڴ����������׼�ģ����Կ���process:private bytes-sqlserver
��process:working Set -sqlservr��ֵ�ǲ���Ҳ���˼�����½���

����취
��Ȼѹ������sqlserer ֮�⣬�ǹ���Ա��Ҫ����ѡ�����Ǹ�sqlserver��һ���ڴ���Դ�أ�������sqlserver�Լ�������ʳ������һЩ�ڴ��ϵͳ,
�����������ͨ������sqlserver��max server memoryֵ������

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
��Ȼsqlserver�Լ�û����ߵ��ڴ�ռ��database pages,�ǽ�������˼·��������������취��sqlserverg������ڴ棬
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

4������multi-page��memtoleave����ѹ��
���� multi-page��buffer pool����sqlserve�������ַ�ռ䣬���multi-pageʹ�õ�̫�࣬buffer pool�ĵ�ַ�ռ��С�ˣ���Ҳ��
ѹ��database page�Ĵ�С������sqlserverʹ��multi-page����һ�㲻��������������Ƚ��ٷ�����

��η����ڴ�ʹ�ñȽ϶�����

1,ʹ��DMV����sqlserver�����Ի�����read�������
sys.dm_exec_query_stats :���ػ����ѯ�ƻ��ľۺ�����ͳ����Ϣ��
*/
SELECT * FROM sys.dm_exec_query_stats

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
����������ѯ�����Դ���֪��sqlserver��ϲ�������ݵ��������Щ��.

�����ͼ��ÿһ������¼����������ִ�мƻ���������������sqlserver���ڴ�ѹ������һ����ִ�мƻ��Ӽ�����ɾ��ʱ����Щ
��¼Ҳ��Ӹ���ͼ��ɾ����

��ͼ�������ʷ��Ϣ����ӳ������ĳ��ʱ��ε��õñȽ�Ƶ��������Բ��Ǻ�ǿ��

���Ҫ׼ȷ֪����ĳ��ʱ������Щ���ȽϺ��ڴ���Դ��sqlserver��־�ļ��ϳ���


----Stolen Memory����ѹ������
��sqlServer �����dataBase Pages,�������ڴ������������������reserve,��commit�ķ���������ֱ�Ӵӵ�ַ�ռ�������
������Щ�ڴ��������Stolen Memory.��һ���SqlServer,Stolen �ڴ�Ҳ��Ҫ��8KBΪ��λ���䣬�ֲ���BUffer Pool ��

���һ��sqlServer�ܹ�������ô�಻ͬ��ִ�мƻ���˵�����ڲ����еĴ�����Ƕ�̬t-sql��䣬���������á�


CMEMthREAD(0x00B9)�ȴ� sys.sysprocesses.waittype
�߲���sqlserer,ͬʱ�������̫�࣬����Щ���������ӣ��ڴ�����ʹ����Ҫÿ�ζ�������Ķ�̬t-sql��䡣����������������ڴ棬
�����޸Ŀͻ���������Ϊ�������ܸ����ʹ�ô洢���̣�����ʹ�ò�������t-sql�����ã�������������������ִ�мƻ������á�
�����������ͬʱ�����ڴ��������������
*/