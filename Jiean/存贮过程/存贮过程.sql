
1,����
CREATE PROCEDURE proName(
@sqlParam nvarchar(100)
,@param2 int
)
AS

�������
DECLARE @varName int
DECLARE @varName2 nvarchar(1000)
DECLARE @sql nvarchar(4000)

��ӡ�����ִ�����,�˳�
PRINT @varName
EXECUTE(@sql)
RETURN 

��������ֵ
SET @varName = 'a'
SELECT @varName = filed FROM tableName


�������
IF @a >0 
BEGIN 

END
ELSE
	BEGIN
	
	end	
IF @a>0
BEGIN ...END
ELSE IF @a<0 
BEGIN ...END
ELSE
begin ...END 	

ѭ�����
WHILE @var IS NOT NULL 
BEGIN
	��ֵ����SELECT �� set �����û�м�¼��SELECT �еı�����ֵ����ǲ�ִ�У�����ԭ����ֵ��SET����᷵��nullֵ������
	
	�ؼ��㣺��ʼǰ���ȸ�@var��һ��ֵ�����ж��Ƿ�Ҫ����ѭ��
		
	ִ���������ȡֵ��@var���������ѭ��
END 

/*
������֮��ĳн�
*/
--�����ִ�п���������ѡ��
DECLARE @id INT=@@ROWCOUNT;
IF @id >0 

--�м���ô洢���̣�����ֵ
	--���ر�
	INSERT INTO #tb
	EXEC spBC_MergeOrder 'A','B'
	
	--����ֵ��ִ��״̬������������ѡ��
	DECLARE @RetVal TINYINT  --����ֵ   
	DECLARE @billno VARCHAR(20) --����ֵ  ����
	declare @FormLang Varchar(2) = 'CN'
	
	EXEC spBC_MergeOrder @RetVal   Output,   @FormLang , @RetBillNo   Output  
	
	IF @RetVal=0 
	BEGIN ...END
	ELSE IF @RetVal=-1 
	BEGIN ...END
 













--�׳�����
 RaisError(N'û���û�ID�����ȵ�ϵͳ��������,����ʹ���Զ��ϲ�����', 16, 1,N'����')
 
 BEGIN TRY
 --�������
 END TRY
 begin CATCH
	--ִ�г���
		Set @RetBillNo = ''	--A)������Ϊ��
 	    Set  @RetVal = -1	--B)��������Ϊ-1
 	     Select @Msg = ERROR_MESSAGE() ;	--C)��ȡ������Ϣ
 	    INSERT INTO  [BC_Bas_MargeOrderLog]	--D)д��
 END CATCH 
 
 --ʹ��ϵͳ����
 RaisError(100016, 16, 1,@CheckBillNo)  	  
 Set Language @Lang --E)��ԭ���� 
 Set @RetVal = -1 	  
 return --F)�˳�
 

 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
	
���ڿ���������֧��ѡ��ķ���

@@ERROR
������ת�����������У�û����ͼ�������ִ�У��д������ת�������ж���䣬�ع����ύ
	SET @ERROR = 0
	ִ��һ�����
	SET @ERROR = @@ERROR
		IF(@ERROR <> 0)
		GOTO ERROR
		
		--��ת��
	ERROR:
		IF(@ERROR <> 0)
		BEGIN
			ROLLBACK TRANSACTION
			INSERT INTO nn_sys_returnerp_log([office_missive_id]
		  ,[type]
		  ,[log_datetime]
		  ,[desc])
			VALUES(@office_missive_id,2,getdate(),Convert(varchar(30),@ERROR)+'��ת���������!');
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION
			/*ֻ�а��ĵ����Զ���ǩ������ֹ�ĵ���Ӧ�������Զ�ǩ��?*/	
			IF EXISTS(SELECT 0 FROM office_missive_search WHERE office_missive_id =	@office_missive_id 
AND m_isback = 0 AND m_status=2)	
			--�Զ���ǩ�����
			EXECUTE sp_auto_addsign_tosearch @office_missive_id
		END	
		
	--================================	
		
		*ɾ��ģ���*/
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

