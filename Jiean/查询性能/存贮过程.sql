
1,����
CREATE PROCEDURE dbo.proName(
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

ѭ�����
WHILE @var IS NOT NULL 
BEGIN
	--�ؼ��㣺��ʼǰ���ȸ�@var��һ��ֵ�����ж��Ƿ�Ҫ����ѭ��
		
	--ִ���������ȡֵ��@var���������ѭ��
	SET @var=''
END 
	
--���ڿ���������֧��ѡ��ķ���

@@ERROR
--������ת�����������У�û����ͼ�������ִ�У��д������ת�������ж���䣬�ع����ύ
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

--�洢���̵��ô洢����
/*
�Ӵ洢���̷���ִ��״̬
@RetVal int Output ����

����
Set @RetVal=-1
RETURN @RetVal


���洢������
exec procName
IF @RetVal<>1
return
*/	


�˳���Ϣ
Declare @MsgLangID Int
Select @MsgLangID = msglangid From sys.syslanguages  Where name = @@LANGUAGE  
Begin
	Set @RetVal = 0
	--���ݲ�����
	Select [text] From sys.messages Where message_id = 50001 And language_id = @MsgLangID
	Set Language @Lang 
	Return 
END

���ݿ�����ѡ��
Set NoCount On 
Declare @Lang Varchar(30) --�ݴ�ԭ����
Set @Lang = @@Language
--����Ϊ�ͻ���ѡ������
If Upper(@FormLang) = 'CN' 
	Set Language 'Simplified Chinese'  --���� 
Else If Upper(@FormLang) = 'TW' 
	Set Language 'Traditional Chinese' --����
Else If Upper(@FormLang) = 'KR' 
	Set Language 'Lorean'              --����
Else If Upper(@FormLang) = 'JP' 
	Set Language 'Japanese'            --����
Else If Upper(@FormLang) = 'EN' 
	Set Language 'English'             --Ӣ��  
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

