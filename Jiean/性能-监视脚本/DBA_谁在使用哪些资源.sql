--who is using all the resources?
SELECT spid,kpid,cpu,physical_io,memusage,sql_handle,1 AS SAMPLE,GETDATE() AS sampleTime,hostname,program_name,nt_username INTO #Resources
FROM master..sysprocesses 

WAITFOR DELAY '00:00:10'

INSERT #Resources 
SELECT spid,kpid,cpu,physical_io,memusage,sql_handle,2 AS SAMPLE,GETDATE() AS sampleTime,hostname,program_name,nt_username 
FROM master..sysprocesses 

--Find the deltas
SELECT r1.spid,r1.kpid,r2.cpu-r1.cpu AS d_cpu_total,r2.physical_io-r1.physical_io AS d_physical_io_total,
r2.memusage-r1.memusage AS d_memusage_total,r1.hostname,r2.program_name,r1.nt_username,r1.sql_handle,r2.sql_handle
FROM #Resources AS r1 INNER JOIN #Resources AS r2 ON r1.spid=r2.spid AND r1.kpid=r2.kpid
WHERE r1.SAMPLE=1 AND r2.SAMPLE=2 AND (r2.cpu-r1.cpu)>0
ORDER BY (r2.cpu-r1.cpu) DESC 

SELECT r1.spid,r1.kpid,r2.cpu-r1.cpu AS d_cpu_total,r2.physical_io-r1.physical_io AS d_physical_io_total,r2.memusage-r1.memusage AS d_memusage_total,r1.hostname,
r1.program_name,r1.nt_username INTO #Usage
FROM #Resources AS r1 INNER JOIN #Resources AS r2 ON r1.spid=r2.spid AND r1.kpid=r2.kpid 
WHERE r1.SAMPLE=1 AND r2.SAMPLE=2 AND (r2.cpu-r1.cpu) >0
ORDER BY (r2.cpu-r1.cpu) DESC 

SELECT spid,hostname,program_name,nt_username,SUM(d_cpu_total) AS sum_cpu,SUM(d_physical_io_total) AS sum_io
FROM #Usage
GROUP BY spid,hostname,program_name,nt_username
ORDER BY 6 DESC 


DROP TABLE #Resources
DROP TABLE #Usage