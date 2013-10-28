
--����cpu��ʹ����
/*
sqlServer��ʹ��cpu�ĵط�
1��������ر���

2������;ۺϼ���

3���������join����

��cpu��ص����ã�sp_configure��
1,priority boost
sqlserver������window�ϵ����ȼ���������1,sqlserver ���̻��Խϸߵ����ȼ��������Ӷ�ʹ֮��windows���̵����ﱻ�������С�

2��affinity mask
���� sqlserver�̶�ʹ��ĳ����cpu

3,lightweight pooling 
����sqlserver�Ƿ�Ҫʹ���˳̼���

4��max degree of parallelism
����sqlserver����ö��ٸ��߳�������ִ��һ��ָ��

5��cost threshold of parallelism
������ֵ���������ĸ��Ӷ�

6��max worker threads
����sqlserver��������߳�����


�������������cpuʹ�����
processor : processor time
			privileged tme
			user time
system : processor queue length
context switches/sec

���ÿ�����̵�cpuʹ�����
process : processor time
			privileged time
			user time

2,ȷ����ʱsqlserver�Ƿ�������������û��17883/17884֮������ⷢ������û�з���Խ��(access violation)֮����������ⷢ��


3���ҳ�cpu100%��ʱ��sqlserver ���������е����cpu��Դ����䣬�����ǽ����Ż���			
*/
--������trace���ٻ�����dmv����ѯ
SELECT 
highest_cpu_queries.*,q.dbid,q.objectid,q.number,q.encrypted,q.text
 FROM (SELECT TOP 50 qs.* FROM sys.dm_exec_query_stats qs ORDER BY qs.total_worker_time DESC ) AS highest_cpu_queries
CROSS APPLY sys.dm_exec_sql_text(plan_handle) AS q
ORDER BY highest_cpu_queries.total_worker_time DESC 

--�ҳ�����ر���Ĵ洢����
SELECT 
TOP 25 sql_text.text,sql_handle,plan_generation_num,execution_count,dbid,objectid
 FROM sys.dm_exec_query_stats a
CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS sql_text
WHERE plan_generation_num>1
ORDER BY plan_generation_num DESC 

/*
4,����ϵͳ���أ���������Ӳ��
*/