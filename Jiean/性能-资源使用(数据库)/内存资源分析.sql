

--Sql Server�ڴ����

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