

--ҵ���֧--------------------------------------------
/*
��ҵ���߼������У�ͨ���ֿ�ʵ��ҵ���ܣ��鼶֮��ķ�֧���ж���IF��������ж�
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
������֮��ĳн�
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
WHILE @var IS NOT NULL 
BEGIN
	��ֵ����SELECT �� set �����û�м�¼��SELECT �еı�����ֵ����ǲ�ִ�У�����ԭ����ֵ��SET����᷵��nullֵ������
	
	�ؼ��㣺��ʼǰ���ȸ�@var��һ��ֵ�����ж��Ƿ�Ҫ����ѭ��
		
	ִ���������ȡֵ��@var���������ѭ��
END 