
CREATE TRIGGER [DDLTriggertTrace] ON DATABASE
--����洢���̡���ͼ����Ĵ������޸ġ�ɾ������
    FOR DDL_DATABASE_LEVEL_EVENTS
AS
    BEGIN
        SET NOCOUNT ON ;
        DECLARE @EventData XML = EVENTDATA() ;--�����йط����������ݿ��¼�����Ϣ����XML��ʽ���档
        DECLARE @ip VARCHAR(32) = ( SELECT  client_net_address
                                    FROM    sys.dm_exec_connections
                                    WHERE   session_id = @@SPID 
                                  ) ;
		--��¼���в���������
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
                        
		--���ڴ�����ҵ��DBA����������devuser�ʺż�¼���࣬����ɾ��devuser������
		DELETE FROM AuditDB_DBA.dbo.DDLEvents WHERE LoginName in ('erpuser','sqlagent');
    END


