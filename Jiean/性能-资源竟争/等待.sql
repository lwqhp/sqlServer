

--系统等待
/*
去掉一些类型的等待:
睡眠等待:当线程被挂起,未执行任何操作时发生
队列等待:当工作线程空闲,等待分配任务时发生
还有一些不代表出表现问题的等待:clr_auto_event,request_for_deadlock_search

与io有关的等待
ioLatch

与网络有关的等待：
async_network_io

一些跟编译和重编译有关的等待
cmemthread 当某任务正在等待线程安全的内存对象时出现


cxpacket等待:太多线程的并行查询，因等待其他线程完成它们的工作而出现 


临时数据库tempdb出现性能问题出现的等待page_latch_up 表示在内部结构（如iam,gam,sgam和pfs页面）上出现角用，
原因可能是为临时表频繁地分配页面，向堆空间插入大量数据等。

pageiolatch_sh 等待代表读取操作的i/o闩锁等待时间

*/

SELECT 
wait_type,waiting_tasks_count,wait_time_ms,max_wait_time_ms,
signal_wait_time_ms/*表示从线程收到资源可用的信号开始，到线程得到CPU时间，开始使用资源为止经历的时间，如果
这个属性的值很高，通常表示cpu存在问题*/
 FROM sys.dm_os_wait_stats
ORDER BY wait_type

--对于各等待的累积总和占系统总等待时间的百分比，达到某个临界值的那些等待
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

--收集等待信息
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

--AS中分析

--查看数据库文件相关的io信息
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