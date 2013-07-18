

if object_id('ColWaitInfo') is not null drop table ColWaitInfo
CREATE TABLE ColWaitInfo
([wait_type] [nvarchar](60) NOT NULL,
 [waiting_tasks_count] [bigint] NOT NULL,
 [wait_time_ms] [bigint] NOT NULL,
 [max_wait_time_ms] [bigint] NOT NULL,
 [signal_wait_time_ms] [bigint] NOT NULL,
 [capture_time] [datetime] NOT NULL,
 [increment_id] [int] NOT NULL
);

ALTER TABLE ColWaitInfo ADD DEFAULT (GETDATE()) FOR [capture_time]; 


--���ö�̬��ͼ sys.dm_os_wait_stats �鿴ϵCPU,�ڴ����IO�ĵȴ�״��
-------------------------------
--����Wait�ȴ���ռ��
with waits as(
	select wait_type,waiting_tasks_count,
	wait_time_ms/1000 as wait_time_s,
	100.*wait_time_ms/sum(wait_time_ms) over() as Pct, --�����ȴ�����ռȫ���ȴ�ʱ��İٷֱ�%
	ROW_NUMBER() over(order by wait_time_ms desc ) as rn
	from sys.dm_os_wait_stats
	where wait_type not in(
		'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE',
   'SLEEP_TASK', 'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR',
   'CLR_AUTO_EVENT', 'CLR_MANUAL_EVENT','BROKER_TASK_STOP'
	)
)
select a.wait_type,cast(a.wait_time_s as decimal(12,2)) as wait_time_s,
cast(a.Pct as decimal(12,2)) as Pct,cast(sum(b.pct) as decimal(12,2)) as running_pct --���Լ�ռ��С�ĵȴ�����
from waits a
inner join waits b on b.rn <=a.rn --ÿһ�������������Ӽ�
group by a.rn,a.wait_type,a.wait_time_s,a.Pct
having sum(b.Pct)-a.Pct <95 --ȥ������ȴ��������¼���Χ��ռ�ع�С��

--drop table  #
--create table #(v int, id int)
--insert into #
--select '1',5 union all
--select '2',4 union all
--select '3',3

--select a.v,a.id,sum(b.v) from # a
--inner join # b on a.id>=b.id
--group by a.v,a.id



--Insert waitstats info in a datestamped format for later querying:
DECLARE @DT DATETIME ;
SET @DT = GETDATE() ;
DECLARE @increment_id INT;

select @increment_id = MAX(increment_id) + 1 FROM ColWaitInfo
set  @increment_id = ISNULL(@increment_id, 1)

INSERT INTO ColWaitInfo([wait_type], [waiting_tasks_count],[wait_time_ms], [max_wait_time_ms],[signal_wait_time_ms],[capture_time], [increment_id])
SELECT[wait_type], [waiting_tasks_count], [wait_time_ms],[max_wait_time_ms],[signal_wait_time_ms],@DT, @increment_id
FROM sys.dm_os_wait_stats;

 

 --select * from ColWaitInfo

--��ѯ����ڵ��ۻ���Ϣ
/*
http://technet.microsoft.com/zh-cn/library/ms179984%28v=sql.90%29.aspx
*/

DECLARE @max_increment_id INT
SELECT @max_increment_id = MAX(increment_id)
FROM  ColWaitInfo

SELECT a.wait_type, 
 (a.waiting_tasks_count -b.waiting_tasks_count) AS '�ȴ�������',
 (a.wait_time_ms - b.wait_time_ms)/1000 AS '�ȴ�ʱ�����',
 (a.wait_time_ms - b.wait_time_ms)/60000 AS '�ȴ�ʱ������',
 a.max_wait_time_ms, 
 (a.signal_wait_time_ms -b.signal_wait_time_ms) AS[signal_wait_time_ms],
 DATEDIFF(ms, b.capture_time, a.capture_time) AS [elapsed_time_ms],
 a.capture_time AS [last_time_stamp],b.capture_time AS[previous_time_stamp]
FROM
(
	SELECT wait_type,waiting_tasks_count, wait_time_ms, max_wait_time_ms,signal_wait_time_ms, capture_time,increment_id
	FROM ColWaitInfo
	WHERE increment_id = @max_increment_id
 )AS a 
 INNER JOIN 
 (
 SELECT  wait_type,waiting_tasks_count, wait_time_ms, max_wait_time_ms,signal_wait_time_ms, capture_time,increment_id
 FROM ColWaitInfo
 WHERE increment_id =(@max_increment_id -1)--��һ��
 )AS b ON a.wait_type = b.wait_type
WHERE (a.wait_time_ms - b.wait_time_ms) > 0 --�ȴ�ʱ�������ӵ�
  AND a.wait_type    NOT IN(
	'CLR_SEMAPHORE', 'LAZYWRITER_SLEEP', 'RESOURCE_QUEUE','SLEEP_TASK', 'SLEEP_SYSTEMTASK', 'SQLTRACE_BUFFER_FLUSH', 'WAITFOR','CLR_AUTO_EVENT', 'CLR_MANUAL_EVENT','BROKER_TASK_STOP')  
--and a.wait_type like 'PAGEIOLATCH%' --����I/O
ORDER BY (a.wait_time_ms - b.wait_time_ms) DESC;
