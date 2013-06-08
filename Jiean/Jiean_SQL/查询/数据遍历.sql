--return  --确认删除，则注释该行

/*
 A.查、删当前数据库中所有表 指定字段、值的记录
*/
USE pattySocure01
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
SET @findField = 'MaterialID'
SET @whereValue = ' and MaterialID like ''%（%'''

DECLARE objectid_Cursor CURSOR FOR select object_id from sys.columns where name=@findField
open objectid_Cursor
FETCH NEXT FROM objectid_Cursor Into @objectid
WHILE @@FETCH_STATUS = 0
BEGIN

   select @name=name from sys.objects where object_id=@objectid and type='U' 
   IF @name >''
   BEGIN 
	   set @sql=' Select  * from  '+@name+' where 1=1 '+@whereValue+ 'collate Chinese_PRC_CI_AS_WS'
	   --set @sql=' DELETE from  '+@name+' where 1=1 '+@whereValue
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
SET @whereValue = ' and companycode in (''CL'',''FR'')'

DECLARE objectid_Cursor CURSOR FOR select object_id from sys.columns where name=@findField
open objectid_Cursor
FETCH NEXT FROM objectid_Cursor Into @objectid
WHILE @@FETCH_STATUS = 0
BEGIN
   select @name=name from sys.objects where object_id=@objectid and type='U' and name like 'FIRP_%'
   IF @name >''
   BEGIN
		set @sql=' Select top 1 * from  '+@name+' where 1=1 '+@whereValue
	   --set @sql=' DELETE from  '+@name+' where companycode in (''CL'',''FR'')'
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


--另动态拼接语句
declare @sql nvarchar(2000)
set @sql=''
select @sql=@sql+ ' delete from '+ name from sys.sysobjects where name like 'temp%'
print @sql
--exec (@sql)
