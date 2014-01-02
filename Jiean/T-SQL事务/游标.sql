

--游标

--声明一个游标cur_obj
DECLARE cur_obj CURSOR
FORWARD_ONLY READ_ONLY	/*游标参数:forward_only-只允许从游标第一行开始向前移动，scroll则可以在结果集中前后移
动，read_only:只读，不能通过游标进行更新*/
FOR		--for定义游标对象
	SELECT session_id FROM sys.dm_exec_requests WHERE status IN('runnable','sleeping','runing')
	
--打开游标
OPEN cur_obj

--从游标中一次检索一行
FETCH NEXT 
FROM cur_obj INTO @session_id

--当存在游标就持续检索行
WHILE @@FETCH_STATUS=0
BEGIN 
	EXEC('dbcc outputbuffer('+@session_id+')')
	
	--提取下一行
	FETCH NEXT
	FROM cur_obj INTO @session_id
END

--关闭游标
CLOSE cur_obj

--释放游标
DEALLOCATE cur_obj


	/*删除模板表*/
declare @template_name varchar(50)
 
declare cur_missive_delete  cursor for 
 select [name] from sysobjects where xtype='U' and [name] like 'office_missive_template_%'
   OPEN cur_missive_delete  
   FETCH NEXT FROM cur_missive_delete  INTO @template_name 

 
   WHILE @@FETCH_STATUS = 0
   BEGIN      
     exec('delete from '+@template_name +' from #A where '+@template_name +'.sys_work_id=#A.office_missive_id')
    --print ('delete from '+@template_name +' from #A where '+@template_name +'.sys_work_id=#A.office_missive_id')
    FETCH NEXT FROM cur_missive_delete  INTO  @template_name 
   
   END

   CLOSE cur_missive_delete  
   DEALLOCATE cur_missive_delete
drop table #A
