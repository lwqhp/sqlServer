

--ҵ���֧--------------------------------------------
/*
��ҵ���߼������У�ͨ���ֿ�ʵ��ҵ���ܣ��鼶֮��ķ�֧���ж���IF��������ж�

�������
 ���õ���5�֣�
 1��return: ������������������˳������򲢽�����Ȩ���ظ�������Ҳ�����ڰ�����ֵ���ظ������ߡ�
 �򵥵������������ж�ִ�У�ǿ���˳������Է���ָ��������ֵ���ڴ洢������Ĭ�Ϸ���0,��ʾִ����ɡ�
 
 2��while : ������Ϊtrueʱ��ִ�е�ѭ����䣬�����������������ѭ��
	break-�˳�ѭ������������ִ��
	continue - �˳�����ѭ����������һ��ѭ����
 
 3��goto: ������t-sql������������һ����ǩ����ͨ�������ڷ��������ʱ����ת��ĳ��������������������ĳ��
 ��������������Ĵ��룬����д���ǡ�����ʽ�����룬��Ϊ����ȫ�����δ�������ʵ������ʲô�����ò��ڴ���
 ��������ȥ��
 
 4��waitfor : �����ӳ�������ĺ���t-sql���������һ���̶���ʱ��λ��ǵ�ĳ��ʱ�䡣
 
 5���α꣺ �б��ǰ���Ĳ�ѯ��д��ͨ����ϰ����ʹ���α꣬�����ǻ��ڼ��ϵķ�������ȡ������У����α��ľ�sql
 serverʵ�����ڴ棬���ٲ����ԣ������������������Դ�����Ҿ�������Ҫ�Ȼ��ڼ��ϵķ�������Ĵ���

*/

declare @a int 

IF @a >0 
BEGIN 
	print '�ű�1'
END
ELSE
	BEGIN
		print '�ű�2'
	end	

IF @a>0
BEGIN 
	print '�ű�1' 
END
ELSE IF @a<0 
BEGIN 
	print '�ű�2'
END
ELSE
begin 
	print '�ű�3'
END 	

/*
case����-------------------------------------------------------------------------------
��������ڲ�ѯ�ֶ����������ж���
*/

/*
������֮��ĳн�---------------------------------------
*/
--�����ִ�п���������ѡ��
DECLARE @id INT=@@ROWCOUNT;
IF @id >0 print '��һ������'



--�м���ô洢���̣�����ֵ
	--���ر�
	INSERT INTO #tb
	EXEC spBC_MergeOrder 'A','B'
	
	--����ֵ��ִ��״̬������������ѡ��
	DECLARE @RetVal TINYINT =0 --����ֵ   
	DECLARE @billno VARCHAR(20) --����ֵ  ����
	declare @FormLang Varchar(2) = 'CN'
	
	EXEC spBC_MergeOrder @RetVal   Output,   @FormLang , @RetBillNo   Output  
	--�ж�
	IF @RetVal=0 
	BEGIN 
		print '�ű�1'
	END
	ELSE IF @RetVal=-1 
	BEGIN 
		print '�ű�2'
	END


--ѭ�����
WHILE @@ROWCOUNT>0
WHILE @var IS NOT NULL 
BEGIN
	��ֵ����SELECT �� set �����û�м�¼��SELECT �еı�����ֵ����ǲ�ִ�У�����ԭ����ֵ��SET����᷵��nullֵ������
	
	�ؼ��㣺��ʼǰ���ȸ�@var��һ��ֵ�����ж��Ƿ�Ҫ����ѭ��
		
	ִ���������ȡֵ��@var���������ѭ��
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