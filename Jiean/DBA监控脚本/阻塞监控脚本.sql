
 
USE AuditDB_DBA
GO
 
CREATE TABLE Blocking_sysprocesses
    (
      [spid] SMALLINT ,
      [kpid] SMALLINT ,
      [blocked] SMALLINT ,
      [waitType] BINARY(2) ,
      [waitTime] BIGINT ,
      [lastWaitType] NCHAR(32) ,
      [waitResource] NCHAR(256) ,
      [dbID] SMALLINT ,
      [uid] SMALLINT ,
      [cpu] INT ,
      [physical_IO] INT ,
      [memusage] INT ,
      [login_Time] DATETIME ,
      [last_Batch] DATETIME ,
      [open_Tran] SMALLINT ,
      [status] NCHAR(30) ,
      [sid] BINARY(86) ,
      [hostName] NCHAR(128) ,
      [program_Name] NCHAR(128) ,
      [hostProcess] NCHAR(10) ,
      [cmd] NCHAR(16) ,
      [nt_Domain] NCHAR(128) ,
      [nt_UserName] NCHAR(128) ,
      [net_Library] NCHAR(12) ,
      [loginName] NCHAR(128) ,
      [context_Info] BINARY(128) ,
      [sqlHandle] BINARY(20) ,
      [CapturedTimeStamp] DATETIME
    )
GO
CREATE TABLE [dbo].[Blocking_SqlText]
    (
      [spid] [smallint] ,
      [sql_text] [nvarchar](2000) ,
      [Capture_Timestamp] [datetime]
    )
GO
 
CREATE PROCEDURE [dbo].[checkBlocking]
AS 
    BEGIN
 
        SET NOCOUNT ON ;
        SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
 
        DECLARE @Duration INT -- in milliseconds, 1000 = 1 sec
        DECLARE @now DATETIME
        DECLARE @Processes INT
 
        SELECT  @Duration = 100  -- in milliseconds, 1000 = 1 sec
        SELECT  @Processes = 0
 
        SELECT  @now = GETDATE()
 
        CREATE TABLE #Blocks_rg
            (
              [spid] SMALLINT ,
              [kpid] SMALLINT ,
              [blocked] SMALLINT ,
              [waitType] BINARY(2) ,
              [waitTime] BIGINT ,
              [lastWaitType] NCHAR(32) ,
              [waitResource] NCHAR(256) ,
              [dbID] SMALLINT ,
              [uid] SMALLINT ,
              [cpu] INT ,
              [physical_IO] INT ,
              [memusage] INT ,
              [login_Time] DATETIME ,
              [last_Batch] DATETIME ,
              [open_Tran] SMALLINT ,
              [status] NCHAR(30) ,
              [sid] BINARY(86) ,
              [hostName] NCHAR(128) ,
              [program_Name] NCHAR(128) ,
              [hostProcess] NCHAR(10) ,
              [cmd] NCHAR(16) ,
              [nt_Domain] NCHAR(128) ,
              [nt_UserName] NCHAR(128) ,
              [net_Library] NCHAR(12) ,
              [loginName] NCHAR(128) ,
              [context_Info] BINARY(128) ,
              [sqlHandle] BINARY(20) ,
              [CapturedTimeStamp] DATETIME
            )    
     
        INSERT  INTO #Blocks_rg
                SELECT  [spid] ,
                        [kpid] ,
                        [blocked] ,
                        [waitType] ,
                        [waitTime] ,
                        [lastWaitType] ,
                        [waitResource] ,
                        [dbID] ,
                        [uid] ,
                        [cpu] ,
                        [physical_IO] ,
                        [memusage] ,
                        [login_Time] ,
                        [last_Batch] ,
                        [open_Tran] ,
                        [status] ,
                        [sid] ,
                        [hostName] ,
                        [program_name] ,
                        [hostProcess] ,
                        [cmd] ,
                        [nt_Domain] ,
                        [nt_UserName] ,
                        [net_Library] ,
                        [loginame] ,
                        [context_Info] ,
                        [sql_Handle] ,
                        @now AS [Capture_Timestamp]
                FROM    master..sysprocesses
                WHERE   blocked <> 0
                        AND waitTime > @Duration     
     
        SET @Processes = @@rowcount
 
        INSERT  INTO #Blocks_rg
                SELECT  src.[spid] ,
                        src.[kpid] ,
                        src.[blocked] ,
                        src.[waitType] ,
                        src.[waitTime] ,
                        src.[lastWaitType] ,
                        src.[waitResource] ,
                        src.[dbID] ,
                        src.[uid] ,
                        src.[cpu] ,
                        src.[physical_IO] ,
                        src.[memusage] ,
                        src.[login_Time] ,
                        src.[last_Batch] ,
                        src.[open_Tran] ,
                        src.[status] ,
                        src.[sid] ,
                        src.[hostName] ,
                        src.[program_name] ,
                        src.[hostProcess] ,
                        src.[cmd] ,
                        src.[nt_Domain] ,
                        src.[nt_UserName] ,
                        src.[net_Library] ,
                        src.[loginame] ,
                        src.[context_Info] ,
                        src.[sql_Handle] ,
                        @now AS [Capture_Timestamp]
                FROM    master..sysprocesses src
                        INNER JOIN #Blocks_rg trgt ON trgt.blocked = src.[spid]
 
        IF @Processes > 0 
            BEGIN
                INSERT  [dbo].[Blocking_sysprocesses]
                        SELECT  *
                        FROM    #Blocks_rg
     
                DECLARE @SQL_Handle BINARY(20) ,
                    @SPID SMALLINT ;
                DECLARE cur_handle CURSOR
                FOR
                    SELECT  sqlHandle ,
                            spid
                    FROM    #Blocks_rg ;
                OPEN cur_Handle
                FETCH NEXT FROM cur_handle INTO @SQL_Handle, @SPID
                WHILE ( @@FETCH_STATUS = 0 ) 
                    BEGIN
 
                        INSERT  [dbo].[Blocking_SqlText]
                                SELECT  @SPID ,
                                        CONVERT(NVARCHAR(4000), [text]) ,
                                        @now AS [Capture_Timestamp]
                                FROM    ::
                                        fn_get_sql(@SQL_Handle)
 
                        FETCH NEXT FROM cur_handle INTO @SQL_Handle, @SPID
                    END
                CLOSE cur_Handle
                DEALLOCATE cur_Handle
 
            END
 
        DROP TABLE #Blocks_rg
 
    END
 
GO
 
 
 
 
USE msdb ;
GO
 
EXEC dbo.sp_add_job @job_name = N'AuditDB_DBA' ;
GO
 
EXEC sp_add_jobstep @job_name = N'AuditDB_DBA',
    @step_name = N'execute blocking script', @subsystem = N'TSQL',
    @command = N'exec checkBlocking', @database_name = N'AuditDB_DBA' ;
GO   
 
EXEC sp_add_jobSchedule @name = N'ScheduleBlockingCheck',
    @job_name = N'AuditDB_DBA', @freq_type = 4, -- daily
    @freq_interval = 1, @freq_subday_type = 4, @freq_subday_interval = 1
 
EXEC sp_add_jobserver @job_name = N'AuditDB_DBA',
    @server_name = N'(local)'