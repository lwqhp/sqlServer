SELECT  r.session_id ,
        status ,
        SUBSTRING(qt.text, r.statement_start_offset / 2,
                  ( CASE WHEN r.statement_end_offset = -1
                         THEN LEN(CONVERT(NVARCHAR(MAX), qt.text)) * 2
                         ELSE r.statement_end_offset
                    END - r.statement_start_offset ) / 2) AS query_text ,
        qt.dbid ,
        qt.objectid ,
        r.cpu_time ,
        r.total_elapsed_time ,
        r.reads ,
        r.writes ,
        r.logical_reads ,
        r.scheduler_id
FROM    sys.dm_exec_requests r
        CROSS APPLY sys.dm_exec_sql_text(sql_handle) AS qt
WHERE   r.session_id > 50
ORDER BY r.cpu_time DESC 