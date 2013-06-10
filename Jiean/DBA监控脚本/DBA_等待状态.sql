SELECT  * ,
        1 AS SAMPLE ,
        GETDATE() AS sample_time
INTO    #wait_stats
FROM    sys.dm_os_wait_stats

WAITFOR DELAY '00:00:30'

INSERT  #wait_stats
        SELECT  * ,
                2 ,
                GETDATE()
        FROM    sys.dm_os_wait_stats

--figure out the deltas

SELECT  w2.wait_type ,
        w2.waiting_tasks_count - w1.waiting_tasks_count AS d_wtc ,
        w2.wait_time_ms - w1.wait_time_ms AS d_wtm ,
        CAST(( w2.wait_time_ms - w1.wait_time_ms ) AS FLOAT)
        / CAST(( w2.waiting_tasks_count - w2.waiting_tasks_count ) AS FLOAT) AS avg_wtm ,
        DATEDIFF(ms, w1.sample_time, w2.sample_time) AS interval
FROM    #wait_stats AS w1
        INNER JOIN #wait_stats AS w2 ON w1.wait_type = w2.wait_type
WHERE   w1.SAMPLE = 1
        AND w2.SAMPLE = 2
        AND w2.wait_time_ms - w1.wait_time_ms > 0
ORDER BY 3 DESC 

DROP TABLE #wait_stats