SELECT  * ,
        1 AS SAMPLE ,
        GETDATE() AS sample_time
INTO    #waiting_tasks
FROM    sys.dm_os_waiting_tasks

WAITFOR DELAY '00:00:10'

INSERT  #waiting_tasks
        SELECT  * ,
                2 ,
                GETDATE()
        FROM    sys.dm_os_waiting_tasks

--figure out the deltas
SELECT  w1.session_id ,
        w1.exec_context_id ,
        w2.wait_duration_ms - w1.wait_duration_ms AS d_wait_duration ,
        w1.wait_type ,
        w2.wait_type ,
        DATEDIFF(ms, w1.SAMPLe_time, w2.sample_time) AS interval_ms
FROM    #waiting_tasks AS w1
        INNER JOIN #waiting_tasks AS w2 ON w1.session_id = w2.session_id
                                           AND w1.exec_context_id = w2.exec_context_id
WHERE   w1.SAMPLE = 1
        AND w2.SAMPLE = 2
ORDER BY 3 DESC 

--select * from #waiting_tasks

DROP TABLE #waiting_tasks