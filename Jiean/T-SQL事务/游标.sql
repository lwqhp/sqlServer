

--�α�

--����һ���α�cur_obj
DECLARE cur_obj CURSOR
FORWARD_ONLY READ_ONLY	/*�α����:forward_only-ֻ������α��һ�п�ʼ��ǰ�ƶ���scroll������ڽ������ǰ����
����read_only:ֻ��������ͨ���α���и���*/
FOR		--for�����α����
	SELECT session_id FROM sys.dm_exec_requests WHERE status IN('runnable','sleeping','runing')
	
--���α�
OPEN cur_obj

--���α���һ�μ���һ��
FETCH NEXT 
FROM cur_obj INTO @session_id

--�������α�ͳ���������
WHILE @@FETCH_STATUS=0
BEGIN 
	EXEC('dbcc outputbuffer('+@session_id+')')
	
	--��ȡ��һ��
	FETCH NEXT
	FROM cur_obj INTO @session_id
END

--�ر��α�
CLOSE cur_obj

--�ͷ��α�
DEALLOCATE cur_obj


	/*ɾ��ģ���*/
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
