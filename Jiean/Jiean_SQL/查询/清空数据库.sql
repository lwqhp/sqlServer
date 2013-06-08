--return  --确认删除，则注释该行

/*
 A.查、删当前数据库中所有表 指定字段、值的记录
*/
USE hk_ERP
go


DECLARE @findField VARCHAR(50)	--查找字段
DECLARE @whereValue VARCHAR(100)--查找条件

declare @objectid varchar(20)	--表对象ID
declare @name varchar(50)		--表名
declare @sql varchar(500)		--执行语句
declare @NO INT					--记录数

set nocount on
SET @name = ''

--表字段为companyid
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

--表字段为companycode

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
MSSQL中如何用SQL清除所有表的数据？这个需求分三种类型： 
第一：只要数据库中表是空的； 
第二：表是空的，并且自增长列可以从１开始增长。 
第三：表是空的，并且自增长列可以从１开始增长，而且存在表间的约束。 
邀月稍微整理了下，放在这里，便于有需要的朋友参阅。 
其实，这不算什么需求。只要用数据库的生成脚本，几分钟即可生成一个干净的表结构及存储过程、视图、约束等。这里提供了另一种用SQL解决问题的方案。权当是无聊的学习，加深点印象吧。呵呵。 
首先，作一些假设：假设database名为TestDB_2000_2005_2008 
预先准备一些脚本 

*/
--Sql代码 
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
先来看看第一种需求： 只要数据库中表是空的。 
这个其实并不难，用一个游标循环得出所有表名，再清除所有表，delete或truncate table 
提供几个语句：以下语句均在SQL2000/SQL2005/SQL2008下使用通过。 
*/
--方法甲： 
--Sql代码 
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

--方法乙： 
--Sql代码 
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

--方法丙： 
--Sql代码 
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
再来看看第二种需求： 表是空的，并且自增长列可以从１开始增长 。 
这种需求其实和第一种差不多。 因为我们在以上语句中使用的是 truncate　table 语句，所以，表的自增长 列是默认从头重新的。 

关键是第三种需求： 表是空的，并且自增长列可以从１开始增长 ，而且存在表间的约束 。 
这是个比较头痛的问题。因为外键约束，不能使用truncate table语句，但是，如果使用delete，又不能使自增长列从１开始重排。 
*/
--我们不妨先来增加一些约束条件： 
--Sql代码 
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
此时再来执行甲乙丙语句时会提示：“无法截断表 'd'，因为该表正由 FOREIGN KEY 约束引用。” 
我们可以这样设想： 
1、先找出没有外键约束的表，truncate 
２、有外键的表，先delete,再复位identity列 
于是得出， 
*/
--语句丁（注意没有使用游标 ） 
--Sql代码 
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

--小结：除了以上方法，还可以临时禁用外键约束。语句为： 
--Sql代码 
-- --禁用所有约束   
--exec sp_msforeachtable 'alter table ? nocheck CONSTRAINT all'   
-- --再启用所有外键约束   
--exec sp_msforeachtable 'alter table ? check constraint all' 

--如果没有上面的这些约束 还可以这样

declare @sql  varchar(5000)
set @sql = ''
select @sql = @sql +'truncate table '+[name]+';'  from sysobjects where xtype='u'
print  @sql
exec(@sql) 