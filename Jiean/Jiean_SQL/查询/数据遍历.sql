--return  --ȷ��ɾ������ע�͸���

/*
 A.�顢ɾ��ǰ���ݿ������б� ָ���ֶΡ�ֵ�ļ�¼
*/
USE pattySocure01
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
SET @findField = 'MaterialID'
SET @whereValue = ' and MaterialID like ''%��%'''

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

--���ֶ�Ϊcompanycode

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


--��̬ƴ�����
declare @sql nvarchar(2000)
set @sql=''
select @sql=@sql+ ' delete from '+ name from sys.sysobjects where name like 'temp%'
print @sql
--exec (@sql)
