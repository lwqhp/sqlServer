
/*
EXEC [HKERP_CREATE_INSERT] sys_user
    @pTableName = '', --表名
    @pWhere = '',  --按条件生成
    @pCreateDel = '' --是否生产删除语句
*/  
CREATE PROC [HKERP_CREATE_INSERT]
    @pTableName SYSNAME ,
    @pWhere VARCHAR(500) = '' ,
    @pCreateDel BIT = 0    --是否生成删除语句 
AS 
    DECLARE @lColumn VARCHAR(MAX) 
    DECLARE @lColumnData VARCHAR(MAX) 
    DECLARE @lColumnData1 VARCHAR(MAX) 
    DECLARE @lSql VARCHAR(MAX) 
    DECLARE @lSql1 VARCHAR(MAX) 
    DECLARE @lXtype TINYINT 
    DECLARE @lName SYSNAME 
    DECLARE @lObjectId INT 
    DECLARE @lObjectName SYSNAME 
    DECLARE @lIdent INT 

    SET nocount ON 

    SET @lObjectId = OBJECT_ID(@pTableName) 

    IF @lObjectId IS NULL -- 對象是否存在 
        BEGIN   
            PRINT 'The object not exists'   
            RETURN   
        END   

    IF OBJECTPROPERTY(@lObjectId, 'IsTable') <> 1 -- 對象是否是table   
        BEGIN   
            PRINT 'The object is not table'   
            RETURN   
        END   

    SET @lObjectName = RTRIM(OBJECT_NAME(@lObjectId)) 

    IF @lObjectName IS NULL
        OR CHARINDEX(@lObjectName, @pTableName) = 0 --此判断不严密 
        BEGIN 
            PRINT 'object not in current database' 
            RETURN 
        END 

--是否有自增列
    SELECT  @lIdent = status & 0x80
    FROM    syscolumns
    WHERE   id = @lObjectId
            AND status & 0x80 = 0x80 

    IF @lIdent IS NOT NULL 
        PRINT 'SET IDENTITY_INSERT ' + @pTableName + ' ON' 


    DECLARE syscolumns_cursor CURSOR
    FOR
        SELECT  c.name ,
                c.xtype
        FROM    syscolumns c
        WHERE   c.id = @lObjectId
        ORDER BY c.colid 
    OPEN syscolumns_cursor 
    SET @lColumn = '' 
    SET @lColumnData = '' 
    SET @lColumnData1 = ''

    FETCH NEXT FROM syscolumns_cursor INTO @lName, @lXtype 
    WHILE @@fetch_status <> -1 
        BEGIN 
            IF @@fetch_status <> -2 
                BEGIN 
                    IF @lXtype NOT IN ( 189, 34, 35, 99, 98 ) --image,text,ntext,sql_variant不处理 
                        BEGIN 
                            SET @lColumn = @lColumn
                                + CASE WHEN LEN(@lColumn) = 0 THEN ''
                                       ELSE ','
                                  END + @lName 
                            IF LEN(@lColumnData) < 3500 
                                SET @lColumnData = @lColumnData
                                    + CASE WHEN LEN(@lColumnData) = 0 THEN ''
                                           ELSE ','','','
                                      END
                                    + CASE WHEN @lXtype IN ( 167, 175 )
                                           THEN '''''''''+' + 'replace(rtrim('
                                                + @lName
                                                + '),'''''''','''''''''''')'
                                                + '+''''''''' --varchar,char 
                                           WHEN @lXtype IN ( 231, 239 )
                                           THEN '''N''''''+'
                                                + 'replace(rtrim(' + @lName
                                                + '),'''''''','''''''''''')'
                                                + '+''''''''' --nvarchar,nchar 
                                           WHEN @lXtype = 61
                                           THEN '''''''''+convert(char(23),'
                                                + @lName + ',121)+''''''''' --datetime 
                                           WHEN @lXtype = 58
                                           THEN '''''''''+convert(char(16),'
                                                + @lName + ',120)+''''''''' --smalldatetime 
                                           WHEN @lXtype = 36
                                           THEN '''''''''+convert(char(36),'
                                                + @lName + ')+''''''''' --uniqueidentifier 
                                           ELSE @lName
                                      END 
                            ELSE 
                                SET @lColumnData1 = @lColumnData1
                                    + CASE WHEN LEN(@lColumnData) = 0 THEN ''
                                           ELSE ','','','
                                      END
                                    + CASE WHEN @lXtype IN ( 167, 175 )
                                           THEN '''''''''+' + 'replace(rtrim('
                                                + @lName
                                                + '),'''''''','''''''''''')'
                                                + '+''''''''' --varchar,char 
                                           WHEN @lXtype IN ( 231, 239 )
                                           THEN '''N''''''+'
                                                + 'replace(rtrim(' + @lName
                                                + '),'''''''','''''''''''')'
                                                + '+''''''''' --nvarchar,nchar 
                                           WHEN @lXtype = 61
                                           THEN '''''''''+convert(char(23),'
                                                + @lName + ',121)+''''''''' --datetime 
                                           WHEN @lXtype = 58
                                           THEN '''''''''+convert(char(16),'
                                                + @lName + ',120)+''''''''' --smalldatetime 
                                           WHEN @lXtype = 36
                                           THEN '''''''''+convert(char(36),'
                                                + @lName + ')+''''''''' --uniqueidentifier 
                                           ELSE @lName
                                      END 

                        END 
                END   

            FETCH NEXT FROM syscolumns_cursor INTO @lName, @lXtype

        END 

    CLOSE syscolumns_cursor 
    DEALLOCATE syscolumns_cursor 

    IF ( @pCreateDel = 1 ) /*需要产生对应的删除语句*/ 
        SELECT  'Delete From ' + @pTableName + ' ' + @pWhere + CHAR(13) + 'GO'

--set @lSql='set nocount on select ''insert '+@pTableName+'('+@lColumn+') values(''as ''--'','+@lColumnData+','')'' from '+@pTableName+' '+@pWhere 
    SET @lSql = 'set nocount on select ''INSERT ' + @pTableName + '('
        + @lColumn + ') VALUES(''as ''--'',' + @lColumnData
    SET @lSql1 = @lColumnData1 + ','')'' from ' + @pTableName + ' ' + @pWhere 
    PRINT '--' + @lSql + @lSql1
    EXEC(@lSql+@lSql1) 

    IF @lIdent IS NOT NULL 
        PRINT 'SET IDENTITY_INSERT ' + @pTableName + ' OFF'