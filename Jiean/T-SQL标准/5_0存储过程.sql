/*
�洢���̵ĺô�
1,���������ݲ�ۼ�t-sql����
2,������ļ�ϯ��ѯ������������
3,�ٽ�����Ŀɸ����ԡ�
4���������ݻ�ȡ�ķ���
5������ͼ��ͬ���洢���̿������������ƣ���ʱ���������
6,�Բ�ѯ��Ӧʱ���Ӱ��Ƚ��ȶ�
*/

--�洢����
/*
��������
1)����		:��@��ͷ��������Ƕ�ո񣬷�����������
2)��������	:sqlserver���û��û��Զ������Ч��������
3)Ĭ��ֵ	��������ʼֵ
4)����		��output��ʾ�����ⲿ������ַ����Ҳ�����Ϊ���������

return ����ֵ������Ϊ������Ĭ�Ϸ���0,��ʾ�洢����ִ�гɹ���return������
����ֵ������ʵ�ʵط������ݣ������ʶֵ���Ǵ洢����Ӱ���������һ����Ҫ����ȷ���洢���̵�ִ��״̬��
*/

--����ֵ�����----------------------------------------
DECLARE @RetVal INT
EXEC @RetVal = Sp_TestReturns;
SELECT @RetVal

/*
�洢���̵ı��룺��һ�����У��Ż�������
�����ǵ�һ�����У������ڻ����У����±���
�����ǵ�һ�����У����ڻ����У�ֱ�����С�

�����ֶ��ظ�Ԥ(with recompile),����ֻ���ڵ�һ�����д洢����ʱ�����ߵ���ѯ���漰�ı������ͳ����Ϣʱ���ŶԴ�
�����̽����Ż���
*/

--1,����
CREATE PROCEDURE proName(
@sqlParam nvarchar(100)
,@param2 int
)
AS

--�������
DECLARE @varName int
DECLARE @varName2 nvarchar(1000)
DECLARE @sql nvarchar(4000)

--��ӡ�����ִ�����,�˳�
PRINT @varName
EXECUTE(@sql)
RETURN 

--��������ֵ
SET @varName = 'a'
SELECT @varName = filed FROM tableName



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


--�˳���Ϣ
Declare @MsgLangID Int
Select @MsgLangID = msglangid From sys.syslanguages  Where name = @@LANGUAGE  
Begin
	Set @RetVal = 0
	--���ݲ�����
	Select [text] From sys.messages Where message_id = 50001 And language_id = @MsgLangID
	Set Language @Lang 
	Return 
END

--���ݿ�����ѡ��
Set NoCount On 
Declare @Lang nVarchar(30) --�ݴ�ԭ����
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
		

--sqlServer ����ʱ�Զ�ִ�д洢����

--�л���master,ֻ��������ط����ܷ����Զ�ִ�еĴ洢����
USE master
go 

--����һ��Ҫsqlserver�������Զ�ִ�еĴ洢����
CREATE PROCEDURE sqlStartupLog(
	@startupDateTime datetime NOT null
)
AS
INSERT INTO sqlStartupLog(startupDateTime)VALUES(GETDATE()
go

--��ִ������
EXEC sys.sp_procoption  @ProcName = N'sqlStartupLog', -- nvarchar(776) Ҫִ�еĴ洢��������
    @OptionName = 'startup', -- varchar(35) �
    @OptionValue = 'true' -- varchar(12) ��ʾ���û����


--�鿴�洢����Ԫ����
SELECT * FROM sys.sql_modules

 

	
--���ڿ���������֧��ѡ��ķ���
SELECT @@ERROR
--������ת�����������У�û����ͼ�������ִ�У��д������ת�������ж���䣬�ع����ύ
	DECLARE @error	int
	SET @ERROR = 0
	--ִ��һ�����
	SET @ERROR = @@ERROR
		IF(@ERROR <> 0)
		GOTO ERROR
		
		--��ת��
	ERROR:
		IF(@ERROR <> 0)
		BEGIN
			ROLLBACK TRANSACTION
			--д��־
		END
		ELSE
		BEGIN
			COMMIT TRANSACTION
			--ִ�к������
		END	

-------------------------------------------------------------------------------------------
----�洢���̵�������ʽ��-------------------------------------------------------------------

--1���жϴ洢���̲���������ʼ��--------------------------------------------------

IF @objectId IS NULL -- �ж϶����Ƿ����
    BEGIN
        PRINT 'The object not exists'
        RETURN
    END	
    
IF ISNULL(@var,'') =''
	SET @var = '��ʼֵ'   
	
--2����ȡ��׼���ݣ�����ת�����ݸ�ʽ--------------------------------------------------

	--�ָ��ַ����γ���ʱ��
	 Create Table #CardTypeList (CardTypeID varchar(20) )	
		if IsNull(@CardTypeID,'') <> ''
		begin
			insert into #CardTypeList(CardTypeID) Select * From dbo.fnSys_SplitString(@CardTypeID,',')
		end
		else
			set @CardTypeID =Null;  
			
	--��ȡС���ݲ�����������ݴ���ʱ��		  	
	 Select StateFixFlag, StateId, StateType,
	  Into #TmpVIPOperState
		From Sys_State 
		Where StateFixFlag = 'VIPOperState'	

--3������ҵ���߼�--------------------------------------------------------------------------
/*
���ݻ�׼���ݣ���ҵ��Ҫ������ݽ��мӹ�������������,������ʵ��
����ѭ������֧���������õ�
*/

--4�����ݺϲ�----------------------------------------------------------------------
/*
�Դ������ҵ�����ݸ���������ʾҪ��������ݺϲ�,����ά�ȱ��벢��ʵ�����
*/

--5�������ʱ��----------------------------------------------------------------------

If OBJECT_ID('tempdb.dbo.#StateList') Is Not Null 
	Drop Table #StateList	