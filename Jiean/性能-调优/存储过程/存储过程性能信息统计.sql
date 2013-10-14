

--�洢����������Ϣͳ��

/*
sys.dm_exec_procedure_stats : ���ػ���洢���̵ľۺ�����ͳ����Ϣ��
����ͼΪÿ������Ĵ洢���̼ƻ�������һ�У��е���������洢���̱��ֻ���״̬��ʱ��һ�������ӻ�����ɾ���洢����ʱ
Ҳ���Ӹ�ͼ��ɾ����Ӧ�С�
*/

--��ش洢���̵�ִ��
SELECT 
p.NAME AS spName
,qs.last_elapsed_time/1000 AS [lastExecTime(ms)]
,(total_elapsed_time/execution_count)/1000 AS [agexectim(ms)]
,min_elapsed_time/1000 AS [minexectime(ms)]
,max_elapsed_time/1000 AS [maxexectime(ms)]
,(total_worker_time/execution_count)/1000 AS [avgcputime(ms)]
,qs.execution_count AS exccount
,qs.cached_time AS lastcachedtime
,(total_logical_writes+total_logical_reads)/execution_count AS avglogicalios
,min_logical_reads AS minlogicalreads
,max_logical_reads AS maxlogicalreads
,min_logical_writes AS minlogicalwrites
,max_logical_writes AS maxlogicalwrites
FROM sys.dm_exec_procedure_stats qs,sys.procedures p
WHERE p.object_id = qs.object_id
ORDER BY [lastexectime(ms)] DESC 

/*
1,ÿ��һ��ʱ���ռ�һ��
2���ȶ����ִ��ʱ������ִ��ʱ�䣨��ƽ��ִ��ʱ�䣩
*/
