--return  --ȷ��ɾ������ע�͸���

/*
 A.�顢ɾ��ǰ���ݿ������б� ָ���ֶΡ�ֵ�ļ�¼
*/
USE hk_ERP
go


DECLARE @findField VARCHAR(50)	--�����ֶ�
DECLARE @whereValue VARCHAR(100)--��������

declare @objectid varchar(20)	--�����ID
declare @name varchar(50)		--����
declare @sql varchar(500)		--ִ�����
declare @NO INT					--��¼��

set nocount on
SET @name = ''

--���ֶ�Ϊcompanyid
SET @findField = 'CompanyID'
SET @whereValue = ' and CompanyID like ''YBL%'''

DECLARE objectid_Cursor CURSOR FOR select object_id from sys.columns where name=@findField
open objectid_Cursor
FETCH NEXT FROM objectid_Cursor Into @objectid
WHILE @@FETCH_STATUS = 0
BEGIN

   select @name=name from sys.objects where object_id=@objectid and type='U' 
   IF @name >''
   BEGIN 
	   --set @sql=' Select  * from  '+@name+' where 1=1 '+@whereValue+ 'collate Chinese_PRC_CI_AS_WS'
	   set @sql=' DELETE from  '+@name+' where 1=1 '+@whereValue
	   EXEC (@sql)
	   set @NO=@@ROWCOUNT
	   if @NO>0
	   print @name
   END
   SET @name = ''
   FETCH NEXT FROM objectid_Cursor Into @objectid
END
CLOSE objectid_Cursor
DEALLOCATE objectid_Cursor	

--���ֶ�Ϊcompanycode

SET @findField = 'companycode'
SET @whereValue = ' and companycode like ''YBL%'''

DECLARE objectid_Cursor CURSOR FOR select object_id from sys.columns where name=@findField
open objectid_Cursor
FETCH NEXT FROM objectid_Cursor Into @objectid
WHILE @@FETCH_STATUS = 0
BEGIN
   select @name=name from sys.objects where object_id=@objectid and type='U' 
   IF @name >''
   BEGIN
		--set @sql=' Select top 1 * from  '+@name+' where 1=1 '+@whereValue
	   set @sql=' DELETE from  '+@name+' where 1=1 '+@whereValue
	   exec (@sql)
	   set @NO=@@ROWCOUNT
	   if @NO>0
	   print @name
   END 
   SET @name = ''
   FETCH NEXT FROM objectid_Cursor Into @objectid
END
CLOSE objectid_Cursor
DEALLOCATE objectid_Cursor	





/*
MSSQL�������SQL������б�����ݣ����������������ͣ� 
��һ��ֻҪ���ݿ��б��ǿյģ� 
�ڶ������ǿյģ������������п��Դӣ���ʼ������ 
���������ǿյģ������������п��Դӣ���ʼ���������Ҵ��ڱ���Լ���� 
������΢�������£����������������Ҫ�����Ѳ��ġ� 
��ʵ���ⲻ��ʲô����ֻҪ�����ݿ�����ɽű��������Ӽ�������һ���ɾ��ı�ṹ���洢���̡���ͼ��Լ���ȡ������ṩ����һ����SQL�������ķ�����Ȩ�������ĵ�ѧϰ�������ӡ��ɡ��Ǻǡ� 
���ȣ���һЩ���裺����database��ΪTestDB_2000_2005_2008 
Ԥ��׼��һЩ�ű� 

*/
--Sql���� 
use master      
go      
IF OBJECT_ID('TestDB_2000_2005_2008') IS NOT NULL      
-- print 'Exist databse!'    
-- else print 'OK!'    
DROP Database TestDB_2000_2005_2008      
GO      
Create database TestDB_2000_2005_2008      
go      
use TestDB_2000_2005_2008      
go      
IF OBJECT_ID('b') IS NOT NULL      
drop table b      
go      
create table b(id int identity(1,1),ba int,bb int)      
--truncate table b      
insert into b      
select  1,1 union all      
select 2,2 union all      
select 1,1      
IF OBJECT_ID('c') IS NOT NULL      
drop table c      
go      
create table c(id int identity(1,1),ca int,cb int)      
insert into c      
select  1,2 union all      
select 1,3    


/*
����������һ������ ֻҪ���ݿ��б��ǿյġ� 
�����ʵ�����ѣ���һ���α�ѭ���ó����б�������������б�delete��truncate table 
�ṩ������䣺����������SQL2000/SQL2005/SQL2008��ʹ��ͨ���� 
*/
--�����ף� 
--Sql���� 
use TestDB_2000_2005_2008      
go      
select * from b      
select * from c      
Declare @t varchar (1024)      
Declare @SQL varchar(2048)      
Declare tbl_cur cursor for  select TABLE_NAME from INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'    
OPEN tbl_cur FETCH NEXT  from tbl_cur INTO @t    
WHILE @@FETCH_STATUS = 0      
BEGIN    
SET @SQL='TRUNCATE TABLE '+ @t    
--print (@SQL)      
EXEC (@SQL)      
FETCH NEXT  from tbl_cur INTO @t    
END    
CLOSE tbl_cur      
DEALLOCATE tbl_Cur      
select * from b      
select * from c    

use TestDB_2000_2005_2008  
go  
select * from b    
select * from c    
Declare @t varchar (1024)  
Declare @SQL varchar(2048)  
Declare tbl_cur cursor for  select TABLE_NAME from INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'  
OPEN tbl_cur FETCH NEXT  from tbl_cur INTO @t  
WHILE @@FETCH_STATUS = 0  
BEGIN  
SET @SQL='TRUNCATE TABLE '+ @t  
--print (@SQL)  
EXEC (@SQL)  
FETCH NEXT  from tbl_cur INTO @t  
END  
CLOSE tbl_cur  
DEALLOCATE tbl_Cur  
select * from b    
select * from c  

--�����ң� 
--Sql���� 
use TestDB_2000_2005_2008      
go      
select * from b      
select * from c      
select * from d      
select * from e      
DECLARE @TableName VARCHAR(256)      
DECLARE @varSQL VARCHAR(512)      
DECLARE @getTBName CURSOR SET @getTBName = CURSOR FOR SELECT name FROM sys.Tables WHERE NAME NOT LIKE 'Category'    
OPEN @getTBName FETCH NEXT FROM @getTBName INTO @TableName      
WHILE @@FETCH_STATUS = 0      
BEGIN      
SET @varSQL = 'Truncate table '+ @TableName      
--PRINT (@varSQL)      
EXEC (@varSQL)      
FETCH NEXT FROM @getTBName INTO @TableName      
END      
CLOSE @getTBName      
DEALLOCATE @getTBName      
----select * from b      
----select * from c  

use TestDB_2000_2005_2008  
go  
select * from b    
select * from c    
select * from d    
select * from e    
DECLARE @TableName VARCHAR(256)  
DECLARE @varSQL VARCHAR(512)  
DECLARE @getTBName CURSOR SET @getTBName = CURSOR FOR SELECT name FROM sys.Tables WHERE NAME NOT LIKE 'Category'  
OPEN @getTBName FETCH NEXT FROM @getTBName INTO @TableName  
WHILE @@FETCH_STATUS = 0  
BEGIN  
SET @varSQL = 'Truncate table '+ @TableName    
--PRINT (@varSQL)  
EXEC (@varSQL)  
FETCH NEXT FROM @getTBName INTO @TableName  
END  
CLOSE @getTBName  
DEALLOCATE @getTBName  
----select * from b    
----select * from c 

--�������� 
--Sql���� 
Declare @t table(query varchar(2000),tables varchar(100))      
Insert into @t    
    select 'Truncate table ['+T.table_name+']', T.Table_Name from INFORMATION_SCHEMA.TABLES T      
    left outer join INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC      
    on T.table_name=TC.table_name      
    where (TC.constraint_Type ='Foreign Key' or TC.constraint_Type is NULL) and    
    T.table_name not in ('dtproperties','sysconstraints','syssegments') and    
    Table_type='BASE TABLE'    
Insert into @t    
    select 'delete from ['+T.table_name+']', T.Table_Name from INFORMATION_SCHEMA.TABLES T      
        left outer join INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC      
      on T.table_name=TC.table_name where TC.constraint_Type ='Primary Key' and T.table_name <>'dtproperties'and Table_type='BASE TABLE'    
Declare @sql varchar(8000)      
Select @sql=IsNull(@sql+' ','')+ query from @t    
print(@sql)      
Exec(@sql)    

Declare @t table(query varchar(2000),tables varchar(100))  
Insert into @t  
    select 'Truncate table ['+T.table_name+']', T.Table_Name from INFORMATION_SCHEMA.TABLES T  
    left outer join INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC  
    on T.table_name=TC.table_name  
    where (TC.constraint_Type ='Foreign Key' or TC.constraint_Type is NULL) and  
    T.table_name not in ('dtproperties','sysconstraints','syssegments') and  
    Table_type='BASE TABLE'  
Insert into @t  
    select 'delete from ['+T.table_name+']', T.Table_Name from INFORMATION_SCHEMA.TABLES T  
        left outer join INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC  
      on T.table_name=TC.table_name where TC.constraint_Type ='Primary Key' and T.table_name <>'dtproperties'and Table_type='BASE TABLE'  
Declare @sql varchar(8000)  
Select @sql=IsNull(@sql+' ','')+ query from @t  
print(@sql)  
Exec(@sql) 

/*
���������ڶ������� ���ǿյģ������������п��Դӣ���ʼ���� �� 
����������ʵ�͵�һ�ֲ�ࡣ ��Ϊ���������������ʹ�õ��� truncate��table ��䣬���ԣ���������� ����Ĭ�ϴ�ͷ���µġ� 

�ؼ��ǵ��������� ���ǿյģ������������п��Դӣ���ʼ���� �����Ҵ��ڱ���Լ�� �� 
���Ǹ��Ƚ�ͷʹ�����⡣��Ϊ���Լ��������ʹ��truncate table��䣬���ǣ����ʹ��delete���ֲ���ʹ�������дӣ���ʼ���š� 
*/
--���ǲ�����������һЩԼ�������� 
--Sql���� 
CREATE TABLE [d] (  
    [id] [int] IDENTITY (1, 1) NOT NULL ,  
    [da] [int] NULL ,  
    [db] [int] NULL ,  
    CONSTRAINT [PK_d] PRIMARY KEY  CLUSTERED    
    (  
        [id]  
    )  ON [PRIMARY]    
) ON [PRIMARY]  
CREATE TABLE [e] (  
    [id] [int] IDENTITY (1, 1) NOT NULL ,  
    [da] [int] NULL ,  
    [db] [int] NULL ,  
    [did] [int] NULL ,  
    CONSTRAINT [FK_e_d] FOREIGN KEY    
    (  
        [did]  
    ) REFERENCES [d] (  
        [id]  
    )  
) ON [PRIMARY]  
insert into d  
select 5,6 union all  
select 7,8 union all  
select 9,9  
insert into e  
select 8,6,1 union all  
select 8,8,2 union all  
select 8,9,2  

CREATE TABLE [d] ( 
    [id] [int] IDENTITY (1, 1) NOT NULL , 
    [da] [int] NULL , 
    [db] [int] NULL , 
    CONSTRAINT [PK_d] PRIMARY KEY  CLUSTERED 
    ( 
        [id] 
    )  ON [PRIMARY] 
) ON [PRIMARY] 
CREATE TABLE [e] ( 
    [id] [int] IDENTITY (1, 1) NOT NULL , 
    [da] [int] NULL , 
    [db] [int] NULL , 
    [did] [int] NULL , 
    CONSTRAINT [FK_e_d] FOREIGN KEY 
    ( 
        [did] 
    ) REFERENCES [d] ( 
        [id] 
    ) 
) ON [PRIMARY] 
insert into d 
select 5,6 union all 
select 7,8 union all 
select 9,9 
insert into e 
select 8,6,1 union all 
select 8,8,2 union all 
select 8,9,2 

/*
��ʱ����ִ�м��ұ����ʱ����ʾ�����޷��ضϱ� 'd'����Ϊ�ñ����� FOREIGN KEY Լ�����á��� 
���ǿ����������룺 
1�����ҳ�û�����Լ���ı�truncate 
����������ı���delete,�ٸ�λidentity�� 
���ǵó��� 
*/
--��䶡��ע��û��ʹ���α� �� 
--Sql���� 
SET NoCount ON  
   DECLARE @tableName varchar(512)   
   Declare @SQL varchar(2048)   
   SET @tableName=''  
   WHILE EXISTS   
   (      
   --Find all child tables and those which have no relations   
   SELECT T.table_name   FROM INFORMATION_SCHEMA.TABLES T   
          LEFT OUTER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC    ON T.table_name = TC.table_name   
     WHERE ( TC.constraint_Type = 'Foreign Key' OR TC.constraint_Type IS NULL )   
         AND T.table_name NOT IN ( 'dtproperties', 'sysconstraints', 'syssegments' )   
         AND Table_type = 'BASE TABLE'  
         AND T.table_name > @TableName   
         )   
    Begin  
        SELECT @tableName = min(T.table_name)    FROM INFORMATION_SCHEMA.TABLES T   
        LEFT OUTER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC    ON T.table_name=TC.table_name   
           WHERE ( TC.constraint_Type = 'Foreign Key' OR TC.constraint_Type IS NULL )   
         AND T.table_name NOT IN ( 'dtproperties', 'sysconstraints', 'syssegments' )   
         AND Table_type = 'BASE TABLE'  
         AND T.table_name > @TableName   
         --Truncate the table   
         SET @SQL = 'Truncate table '+ @TableName    
         print (@SQL)   
         Exec(@SQL)   
     End  
     
   SET @TableName=''  
   WHILE EXISTS   
   (    
   --Find all Parent tables   
     SELECT T.table_name     FROM INFORMATION_SCHEMA.TABLES T   
     LEFT OUTER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC     ON T.table_name = TC.table_name   
     WHERE TC.constraint_Type = 'Primary Key'  
     AND T.table_name <> 'dtproperties'  
     AND Table_type='BASE TABLE'  
     AND T.table_name > @TableName   
     )   
   Begin  
     SELECT @tableName = min(T.table_name)   FROM INFORMATION_SCHEMA.TABLES T   
          LEFT OUTER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC   ON T.table_name=TC.table_name   
     WHERE TC.constraint_Type = 'Primary Key'  
     AND T.table_name <> 'dtproperties'  
     AND Table_type = 'BASE TABLE'  
     AND T.table_name > @TableName   
     --Delete the table   
       
        SET @SQL = ' delete from '+ @TableName    
         print (@SQL)   
         Exec(@SQL)   
     --Reset identity column   
         IF EXISTS ( SELECT *   FROM INFORMATION_SCHEMA.COLUMNS   
             WHERE COLUMNPROPERTY(   
             OBJECT_ID( QUOTENAME(table_schema)+ '.' + QUOTENAME(@tableName) ),   
             column_name,'IsIdentity'  
             ) = 1   
           )   
     DBCC CHECKIDENT(@tableName,RESEED,0)   
   End  
   SET NoCount OFF  

SET NoCount ON
   DECLARE @tableName varchar(512)
   Declare @SQL varchar(2048)
   SET @tableName=''
   WHILE EXISTS
   (   
   --Find all child tables and those which have no relations
   SELECT T.table_name   FROM INFORMATION_SCHEMA.TABLES T
          LEFT OUTER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC    ON T.table_name = TC.table_name
     WHERE ( TC.constraint_Type = 'Foreign Key' OR TC.constraint_Type IS NULL )
         AND T.table_name NOT IN ( 'dtproperties', 'sysconstraints', 'syssegments' )
         AND Table_type = 'BASE TABLE'
         AND T.table_name > @TableName
         )
    Begin
        SELECT @tableName = min(T.table_name)    FROM INFORMATION_SCHEMA.TABLES T
        LEFT OUTER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC    ON T.table_name=TC.table_name
           WHERE ( TC.constraint_Type = 'Foreign Key' OR TC.constraint_Type IS NULL )
         AND T.table_name NOT IN ( 'dtproperties', 'sysconstraints', 'syssegments' )
         AND Table_type = 'BASE TABLE'
         AND T.table_name > @TableName
         --Truncate the table
         SET @SQL = 'Truncate table '+ @TableName 
         print (@SQL)
         Exec(@SQL)
     End
  
   SET @TableName=''
   WHILE EXISTS
   ( 
   --Find all Parent tables
     SELECT T.table_name     FROM INFORMATION_SCHEMA.TABLES T
     LEFT OUTER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC     ON T.table_name = TC.table_name
     WHERE TC.constraint_Type = 'Primary Key'
     AND T.table_name <> 'dtproperties'
     AND Table_type='BASE TABLE'
     AND T.table_name > @TableName
     )
   Begin
     SELECT @tableName = min(T.table_name)   FROM INFORMATION_SCHEMA.TABLES T
          LEFT OUTER JOIN INFORMATION_SCHEMA.TABLE_CONSTRAINTS TC   ON T.table_name=TC.table_name
     WHERE TC.constraint_Type = 'Primary Key'
     AND T.table_name <> 'dtproperties'
     AND Table_type = 'BASE TABLE'
     AND T.table_name > @TableName
     --Delete the table
    
        SET @SQL = ' delete from '+ @TableName 
         print (@SQL)
         Exec(@SQL)
     --Reset identity column
         IF EXISTS ( SELECT *   FROM INFORMATION_SCHEMA.COLUMNS
             WHERE COLUMNPROPERTY(
             OBJECT_ID( QUOTENAME(table_schema)+ '.' + QUOTENAME(@tableName) ),
             column_name,'IsIdentity'
             ) = 1
           )
     DBCC CHECKIDENT(@tableName,RESEED,0)
   End
   SET NoCount OFF

--С�᣺�������Ϸ�������������ʱ�������Լ�������Ϊ�� 
--Sql���� 
-- --��������Լ��   
--exec sp_msforeachtable 'alter table ? nocheck CONSTRAINT all'   
-- --�������������Լ��   
--exec sp_msforeachtable 'alter table ? check constraint all' 

--���û���������ЩԼ�� ����������

declare @sql  varchar(5000)
set @sql = ''
select @sql = @sql +'truncate table '+[name]+';'  from sysobjects where xtype='u'
print  @sql
exec(@sql) 