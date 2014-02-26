

--ϵͳ�ȴ�
/*
ȥ��һЩ���͵ĵȴ�:
˯�ߵȴ�:���̱߳�����,δִ���κβ���ʱ����
���еȴ�:�������߳̿���,�ȴ���������ʱ����
����һЩ���������������ĵȴ�:clr_auto_event,request_for_deadlock_search

��io�йصĵȴ�
ioLatch

�������йصĵȴ���
async_network_io

һЩ��������ر����йصĵȴ�
cmemthread ��ĳ�������ڵȴ��̰߳�ȫ���ڴ����ʱ����


cxpacket�ȴ�:̫���̵߳Ĳ��в�ѯ����ȴ������߳�������ǵĹ��������� 


��ʱ���ݿ�tempdb��������������ֵĵȴ�page_latch_up ��ʾ���ڲ��ṹ����iam,gam,sgam��pfsҳ�棩�ϳ��ֽ��ã�
ԭ�������Ϊ��ʱ��Ƶ���ط���ҳ�棬��ѿռ����������ݵȡ�

pageiolatch_sh �ȴ������ȡ������i/o�����ȴ�ʱ��

*/

SELECT 
wait_type,waiting_tasks_count,wait_time_ms,max_wait_time_ms,
signal_wait_time_ms/*��ʾ���߳��յ���Դ���õ��źſ�ʼ�����̵߳õ�CPUʱ�䣬��ʼʹ����ԴΪֹ������ʱ�䣬���
������Ե�ֵ�ܸߣ�ͨ����ʾcpu��������*/
 FROM sys.dm_os_wait_stats
ORDER BY wait_type

--���ڸ��ȴ����ۻ��ܺ�ռϵͳ�ܵȴ�ʱ��İٷֱȣ��ﵽĳ���ٽ�ֵ����Щ�ȴ�
WITH Waits AS
(
  SELECT
    wait_type,
    wait_time_ms / 1000. AS wait_time_s,
    100. * wait_time_ms / SUM(wait_time_ms) OVER() AS pct,
    ROW_NUMBER() OVER(ORDER BY wait_time_ms DESC) AS rn,
    100. * signal_wait_time_ms / wait_time_ms as signal_pct
  FROM sys.dm_os_wait_stats
  WHERE wait_time_ms > 0
    AND wait_type NOT LIKE N'%SLEEP%'
    AND wait_type NOT LIKE N'%IDLE%'
    AND wait_type NOT LIKE N'%QUEUE%'    
    AND wait_type NOT IN(  N'CLR_AUTO_EVENT'
                         , N'REQUEST_FOR_DEADLOCK_SEARCH'
                         , N'SQLTRACE_BUFFER_FLUSH'
                         /* filter out additional irrelevant waits */ )
)
SELECT
  W1.wait_type, 
  CAST(W1.wait_time_s AS NUMERIC(12, 2)) AS wait_time_s,
  CAST(W1.pct AS NUMERIC(5, 2)) AS pct,
  CAST(SUM(W2.pct) AS NUMERIC(5, 2)) AS running_pct,
  CAST(W1.signal_pct AS NUMERIC(5, 2)) AS signal_pct
FROM Waits AS W1
  JOIN Waits AS W2
    ON W2.rn <= W1.rn
GROUP BY W1.rn, W1.wait_type, W1.wait_time_s, W1.pct, W1.signal_pct
HAVING SUM(W2.pct) - W1.pct < 80 -- percentage threshold
    OR W1.rn <= 5
ORDER BY W1.rn;
GO

--�ռ��ȴ���Ϣ
USE Performance;
IF OBJECT_ID('dbo.WaitStats', 'U') IS NOT NULL DROP TABLE dbo.WaitStats;

CREATE TABLE dbo.WaitStats
(
  dt                  DATETIME     NOT NULL DEFAULT (CURRENT_TIMESTAMP),
  wait_type           NVARCHAR(60) NOT NULL,
  waiting_tasks_count BIGINT       NOT NULL,
  wait_time_ms        BIGINT       NOT NULL,
  max_wait_time_ms    BIGINT       NOT NULL,
  signal_wait_time_ms BIGINT       NOT NULL
);

CREATE UNIQUE CLUSTERED INDEX idx_dt_type ON dbo.WaitStats(dt, wait_type);
CREATE INDEX idx_type_dt ON dbo.WaitStats(wait_type, dt);

-- Load waitstats data on regular intervals
INSERT INTO Performance.dbo.WaitStats
    (wait_type, waiting_tasks_count, wait_time_ms,
     max_wait_time_ms, signal_wait_time_ms)
  SELECT
    wait_type, waiting_tasks_count, wait_time_ms,
    max_wait_time_ms, signal_wait_time_ms
  FROM sys.dm_os_wait_stats
  WHERE wait_type NOT IN (N'MISCELLANEOUS');

-- Creation script for IntervalWaits function
IF OBJECT_ID('dbo.IntervalWaits', 'IF') IS NOT NULL
  DROP FUNCTION dbo.IntervalWaits;
GO

CREATE FUNCTION dbo.IntervalWaits
  (@fromdt AS DATETIME, @todt AS DATETIME)
RETURNS TABLE
AS

RETURN
  WITH Waits AS
  (
    SELECT dt, wait_type, wait_time_ms,
      ROW_NUMBER() OVER(PARTITION BY wait_type
                        ORDER BY dt) AS rn
    FROM dbo.WaitStats
  )
  SELECT Prv.wait_type, Prv.dt AS start_time,
    CAST((Cur.wait_time_ms - Prv.wait_time_ms)
           / 1000. AS NUMERIC(12, 2)) AS interval_wait_s
  FROM Waits AS Cur
    JOIN Waits AS Prv
      ON Cur.wait_type = Prv.wait_type
      AND Cur.rn = Prv.rn + 1
      AND Prv.dt >= @fromdt
      AND Prv.dt < DATEADD(day, 1, @todt)
GO

-- Return interval waits
SELECT wait_type, start_time, interval_wait_s
FROM dbo.IntervalWaits('20090212', '20090213') AS F
ORDER BY SUM(interval_wait_s) OVER(PARTITION BY wait_type) DESC,
  wait_type, start_time;
GO

--AS�з���

--�鿴���ݿ��ļ���ص�io��Ϣ
WITH DBIO AS
(
  SELECT
    DB_NAME(IVFS.database_id) AS db,
    MF.type_desc,
    SUM(IVFS.num_of_bytes_read + IVFS.num_of_bytes_written) AS io_bytes,
    SUM(IVFS.io_stall) AS io_stall_ms
  FROM sys.dm_io_virtual_file_stats(NULL, NULL) AS IVFS
    JOIN sys.master_files AS MF
      ON IVFS.database_id = MF.database_id
      AND IVFS.file_id = MF.file_id
  GROUP BY DB_NAME(IVFS.database_id), MF.type_desc
)
SELECT db, type_desc, 
  CAST(1. * io_bytes / (1024 * 1024) AS NUMERIC(12, 2)) AS io_mb,
  CAST(io_stall_ms / 1000. AS NUMERIC(12, 2)) AS io_stall_s,
  CAST(100. * io_stall_ms / SUM(io_stall_ms) OVER()
       AS NUMERIC(10, 2)) AS io_stall_pct,
  ROW_NUMBER() OVER(ORDER BY io_stall_ms DESC) AS rn
FROM DBIO
ORDER BY io_stall_ms DESC;