
CREATE TRIGGER [DDLTriggertTrace] ON DATABASE
--捕获存储过程、视图、表的创建、修改、删除动作
    FOR DDL_DATABASE_LEVEL_EVENTS
AS
    BEGIN
        SET NOCOUNT ON ;
        DECLARE @EventData XML = EVENTDATA() ;--返回有关服务器或数据库事件的信息，以XML格式保存。
        DECLARE @ip VARCHAR(32) = ( SELECT  client_net_address
                                    FROM    sys.dm_exec_connections
                                    WHERE   session_id = @@SPID 
                                  ) ;
		--记录所有操作到表中
        INSERT  AuditDB_DBA.dbo.DDLEvents
                ( EventType ,
                  EventDDL ,
                  EventXML ,
                  DatabaseName ,
                  SchemaName ,
                  ObjectName ,
                  HostName ,
                  IPAddress ,
                  ProgramName ,
                  LoginName
                )
                SELECT  @EventData.value('(/EVENT_INSTANCE/EventType)[1]',
                                         'NVARCHAR(100)') ,
                        @EventData.value('(/EVENT_INSTANCE/TSQLCommand)[1]',
                                         'NVARCHAR(MAX)') ,
                        @EventData ,
                        DB_NAME() ,
                        @EventData.value('(/EVENT_INSTANCE/SchemaName)[1]',
                                         'NVARCHAR(255)') ,
                        @EventData.value('(/EVENT_INSTANCE/ObjectName)[1]',
                                         'NVARCHAR(255)') ,
                        HOST_NAME() ,
                        @ip ,
                        PROGRAM_NAME() ,
                        SUSER_SNAME() ;
                        
		--由于存在作业，DBA操作，导致devuser帐号记录过多，所以删除devuser的数据
		DELETE FROM AuditDB_DBA.dbo.DDLEvents WHERE LoginName in ('erpuser','sqlagent');
    END


