

    SELECT   spid,
             blocked,
             DB_NAME(sp.dbid) AS DBName,
             program_name,
             waitresource,
             lastwaittype,
             sp.loginame,
             sp.hostname,
             a.[Text] AS [TextData],
             SUBSTRING(A.text, sp.stmt_start / 2, 
             (CASE WHEN sp.stmt_end = -1 THEN DATALENGTH(A.text) ELSE sp.stmt_end 
             END - sp.stmt_start) / 2) AS [current_cmd]
    FROM     sys.sysprocesses AS sp OUTER APPLY sys.dm_exec_sql_text (sp.sql_handle) AS A
    WHERE    spid > 50
    ORDER BY blocked DESC, DB_NAME(sp.dbid) ASC, a.[text];


KILL 51
