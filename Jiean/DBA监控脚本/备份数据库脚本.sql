/*
注意：由于用GUI备份会导致备份链中断，而作业无法实现“仅复制备份”，所以使用脚本备份
create by huangzj 20120510
EXEC Backup_By_DBA 'AuditDB_DBA','e:\新建文件夹\'
*/

ALTER PROC Backup_By_DBA
(
@dbname NVARCHAR(128),
@bakpath NVARCHAR(128)='E:\'
)
AS
--不备份系统表
IF @dbname IN ( 'master', 'msdb', 'model', 'tempdb' ) 
    BEGIN
        RETURN
    END 
ELSE 
    BEGIN
--定义备份时间，精确到秒
        DECLARE @date NVARCHAR(64)
        SELECT  @date = SUBSTRING(CONVERT(VARCHAR(20), GETDATE(), 121), 1, 4)
                + '_' + SUBSTRING(CONVERT(VARCHAR(20), GETDATE(), 121), 6, 2)
                + '_' + SUBSTRING(CONVERT(VARCHAR(20), GETDATE(), 121), 9, 2)
                + '_' + CONVERT(CHAR(2), DATEPART(hh, GETDATE()))
                + CONVERT(CHAR(2), DATEPART(mi, GETDATE()))
                + CONVERT(CHAR(2), DATEPART(ss, GETDATE()))
--定义要备份的数据库名
        DECLARE @db NVARCHAR(20)
        SET @db = '' + '' + DB_NAME() + '' + ''
--定义备份文件的全名
        DECLARE @bakname NVARCHAR(128)
        SELECT  @bakname = @db + '_' + @date
--定义备份存放路径
        DECLARE @disk NVARCHAR(256)
        SELECT  @disk = @bakpath + @bakname + '.bak'
--定义备份描述
        DECLARE @name NVARCHAR(128)
        SELECT  @name = @db + '-完整 数据库 备份'
--定义错误信息
        DECLARE @error NVARCHAR(128)
        SELECT  @error = '验证失败。找不到数据库“' + @db + '”的备份信息。'

        BACKUP DATABASE @db TO  DISK = @disk WITH  COPY_ONLY, NOFORMAT, NOINIT,  
NAME =@name, SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CHECKSUM ;
        DECLARE @backupSetId AS INT
        SELECT  @backupSetId = position
        FROM    msdb..backupset
        WHERE   database_name = @db
                AND backup_set_id = ( SELECT    MAX(backup_set_id)
                                      FROM      msdb..backupset
                                      WHERE     database_name = @db
                                    )
        IF @backupSetId IS NULL 
            BEGIN
                RAISERROR(@error, 16, 1)
            END
        RESTORE VERIFYONLY FROM  DISK = @disk WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
        
        INSERT INTO AuditDB_DBA.dbo.BackupHistory(DatabaseName,CreateDate,Compatibilitylevel,RecoveryModel,BackupStartData,BackupEndData,BackupSpace,Operator,Servername,[FILENAME])
        SELECT a.[name] ,create_date,a.[compatibility_level] ,recovery_model_desc,S.backup_start_date,S.backup_finish_date,CONVERT(VARCHAR(20),CONVERT(DECIMAL(10,2),S.compressed_backup_size/(1024*1024)))+'MB',
        S.[user_name],S.[server_name],physical_device_name
        FROM sys.databases a INNER JOIN msdb.dbo.backupset S ON a.name=S.database_name Inner Join
            msdb.dbo.backupmediafamily M ON S.media_set_id =M.media_set_id
        WHERE a.name=db_name() AND physical_device_name=@disk
    END