

--����Ĵ���׽�ͻع�

/*
���ݿ�������ݴ�������ؼ�������ط�Ϊ4������
	�ȼ�[severity] 0`10 ʱ��Ϊ����Ϣ����Ϣ��,���ݿ����治���������ؼ���Ϊ0`9��ϵͳ����
	�ȼ�[severity] 11`16ʱ, Ϊ���û����Ծ��������ݿ�������󡱡������Ϊ0,���û������try/catch�飬��ô��Щ����
							����ֹ����ִ�в��ڿͻ�����������״̬��ʾΪ���õ��κ�ֵ�����������try�飬��ô��
							���ô�������򣬶������ڿͻ�����������
	�ȼ�[severity] 17ʱ		��ͨ��ֻ��sqlserver��ʹ��������������Լ��𣬻����ϣ�����ʱsqlserver��������Դ������tempdb������
							���Ҳ����������				
	�ȼ�[severity] 18`19ʱ��Ϊ����ҪDBAע��Ĵ���.���ڴ治�㣬���ݿ������ѵ����޵ȡ����Ұ�ʾϵͳ����ԱҪע��ײ�ԭ��
							���ڴ��������Լ���19��˵����Ҫʹ��with logѡ��¼�����windows event log����ʾ��
	�ȼ�[severity] 20`25ʱ, Ϊ�����������ϵͳ���⡱.��Ӳ��������𻵣������������������ݿ�������ֹ�Ĵ���
*/
--Exec spCRM_AddMessage
--Exec spEM_AddMessage
--Exec spSD_AddMessage
--Exec spBC_AddMessage

--������Ϣ����
/*
RaisError�������Է���1`25����Ĵ�����Ϣ
try..catch �ɲ�׽�������ؼ������10������ֹ���ݿ����ӵĴ���.���ؼ���0`10�Ĵ�������Ϣ����Ϣ����������ִ�д�try��������
����ֹ���ݿ����ӵĴ���ͨ�����ؼ���Ϊ20`25������catch�鴦����Ϊ������ֹ��ִ��Ҳ��ֹ�ˡ�

*/
--1)RaisError�����׳��û�ָ����ŵĴ�����Ϣ��̬�Ĺ���������Ϣ���ͻ��ˡ�
RaisError(N'û���û�ID�����ȵ�ϵͳ��������,����ʹ���Զ��ϲ�����', --�Զ��������Ϣ��������ϢID
	16, --���ؼ���
	1,	--�����з�������λ�õı�ʶ��
	N'����' --�������Ķ�̬����(%1,%2) 
	)

declare @CheckBillNo varchar(30)
set @CheckBillNo='222'
RaisError(100016, 16, 1,@CheckBillNo)  	

begin try
	raiserror('xxx',12,3)
	with log --���浽window��־
	 ,nowait --�����͵��ͻ���
	 ,seterror --��@@errorֵ��error_numberֵ����Ϊ<��ϢID>��50000
end try
begin catch
	select ERROR_MESSAGE(),error_state(),ERROR_SEVERITY()
	throw; --�����׳�����
end catch


--2)��begin try ��׽������ʱ,��ת��begin catchģ�飬�������������ع����׳����󣬴���д��־
begin catch
	ROLLBACK
	--ҵ����
	PRINT '����ع�' --����һ��������Ϣ��¼

	--���ش�����Ϣ
	SELECT ERROR_NUMBER() AS �����,
	ERROR_SEVERITY() AS ����ȼ�,
	ERROR_STATE() as ����״̬,
	DB_ID() as ���ݿ�ID,
	DB_NAME() as ���ݿ�����,
	ERROR_LINE() as �����к�,
	ERROR_PROCEDURE() as  ���س��ִ���Ĵ洢���̻򴥷���������,
	ERROR_MESSAGE() as ���ش�����Ϣ�������ı������ı��ɰ����κο��滻�������ṩ��ֵ���糤�ȡ���������ʱ�䡣

	--д��־
	insert into ErrorLog(sMessage)
	select ERROR_MESSAGE() as ������Ϣ
end catch

--3)@@error ��һ������ִ�д�����Ϣ��ͨ�����@@error�ŵ������У����ͳһ����
if @@error<>0 print '������'

--4)@@trancount �����ڵ�ǰ������ִ�е� BEGIN TRANSACTION ������Ŀ
/*begin  tran ��佫 @@Trancount�� 1��
Rollback  tran�� @@Trancount�ݼ��� 0��
�� Rollback tran savepoint_name ���⣬����Ӱ�� @@Trancount��Commit  tran �� Commit  work �� @@Trancount �ݼ� 1��*/
BEGIN TRY
    BEGIN TRANSACTION
    -- You code here.
     COMMIT TRANSACTION --��try�����ύ����
END TRY
BEGIN CATCH
    IF (@@TRANCOUNT > 0)
        -- Adds store procedure
        -- Writes the error into ErrorLog table.
        ROLLBACK TRANSACTION
END CATCH


--�Զ��������Ϣ
--����ʹ��sp_addmessage�����ؼ���Ϊ1`25���û����������Ϣ��ӵ� "sys.messages"Ŀ¼��ͼ�С���Щ�û�����Ĵ�����Ϣ�ɹ�RaisErrorʹ��.

/*
���壺
�û��Զ��������Ϣ��ID�������50000
����Ҫ���һ��Ӣ�İ汾�Ĵ�����Ϣ��Ȼ���������������Եİ汾�����û��ָ�����ԣ���ʹ��Ĭ�ϵ�����
*/
exec sp_addmessage 500001,--������ϢID
	15,	--ָ�����ؼ���
	N'XXX',--������Ϣ
	us_english --����

--�޸�
exec sp_altermessage 500001, --ID
	'WITH_LOG', --д��window��־
	'true'	--�Ƿ�д��

exec sp_dropmessage 500001,--id
	'all' --ȫ��

--Ȩ��Ҫ����� sysadmin �� serveradmin �̶���������ɫ�ĳ�Ա���
Exec sp_AddMessage 80002, 16, N'The bill', N'us_english',False,Replace
Exec sp_AddMessage 80002, 16, N'�˵����ѱ����ã��������ϣ�', N'Simplified Chinese',False,Replace
Exec sp_AddMessage 80002, 16, N'�ˆΓ��ѱ����ã��������U��', N'Traditional Chinese',False,Replace

select * from sys.messages


--------����ع�----------------------------------------------------------------------------------
/*
Ĭ�ϲ���XACT_ABORT ΪOFF,��������ʽ����ʽ�������ύʱ��������ֻ��ع��������䣬�������ǰ�����䶼��ִ�С�
��ʱ XACT_ABORT ΪONʱ�������У���ʽ����ʽ���������ִ���ʱ�����ع���������

ע�������Ҫ�ع��������񣬽��鲶׽������ֶ��ع�����
*/
set  xact_abort on

--Ƕ������


/*�����ʾ���У���ϵ�˵ĵ����ʼ���ַ��һ��Ƕ�������б����£���ᱻ�����ύ��Ȼ��ROLLBACK TRAN��ִ�С�
ROLLBACK TRAN��@@TRANCOUNT��Ϊ0���ع�������������Ƕ�׵��������������Ƿ��Ѿ����ύ��
��ˣ�Ƕ�������������ĸ��±��ع�������û���κθı䡣
*/
use AdventureWorks2012
go

BEGIN TRAN
    PRINT 'After 1st BEGIN TRAN: ' + CAST(@@trancount as char(1))
    BEGIN TRAN
        PRINT 'After 2nd BEGIN TRAN: ' + CAST(@@trancount as char(1))
            BEGIN TRAN
            PRINT 'After 3rd BEGIN TRAN: ' + CAST(@@trancount as char(1))
            UPDATE Person.EmailAddress
            SET EmailAddress = 'test@test.at'
            WHERE EmailAddressID = 20
            COMMIT TRAN
        PRINT 'After first COMMIT TRAN: ' + CAST(@@trancount as char(1))
ROLLBACK TRAN

PRINT 'After ROLLBACK TRAN: ' + CAST(@@trancount as char(1))
SELECT * FROM Person.EmailAddress
WHERE EmailAddressID = 20;

/*
ʼ���μ�:
��Ƕ�׵������У�ֻ������������������Ƿ��ύ�ڲ�����
ÿһ��COMMIT TRAN�������Ӧ�������һ��ִ�е�BEGIN TRAN����ˣ�����ÿһ��BEGIN TRAN���������һ��COMMIT TRAN���ύ����
ROLLBACK TRAN��������������������񣬲���������ǻع�����������������д��˶���Ƕ������
����Ϊ�ˣ�����Ƕ������ܸ��ӡ����ÿһ��Ƕ�״洢���̶��������п�ʼһ��������ôǶ������󲿷ֻᷢ����Ƕ�״洢�����С�
Ҫ����Ƕ�����񣬿����ڹ��̿�ʼ�����@@TRANCOUNT��ֵ���Դ���ȷ���Ƿ���Ҫ��ʼһ���������@@TRANCOUNT����0��
��Ϊ�����Ѿ�����һ�������в��ҵ���ʵ�������ڴ�����ʱ�ع�����

*/

BEGIN TRAN t1
SELECT @@trancount --1
	BEGIN TRAN t2
	SELECT @@trancount --2
		BEGIN TRAN t3
		SELECT @@TRANCOUNT --3
		COMMIT TRAN 
		SELECT @@TRANCOUNT -2
	ROLLBACK TRAN 
	SELECT @@trancount --0

---���ڴ���
 Set Language @Lang --E)��ԭ���� 
 Set @RetVal = -1 	  
 return --F)�˳�