

--����Ĵ���׽�ͻع�

/*
���ݿ�������ݴ�������ؼ�������ط�Ϊ4������
	�ȼ�[severity] 0`10 ʱ��Ϊ����Ϣ����Ϣ��,���ݿ����治���������ؼ���Ϊ0`9��ϵͳ����
	�ȼ�[severity] 11`16ʱ, Ϊ���û����Ծ��������ݿ�������󡱡������Ϊ0
	�ȼ�[severity] 17`19ʱ��Ϊ����ҪDBAע��Ĵ���.���ڴ治�㣬���ݿ������ѵ����޵ȡ�
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
--1)RaisError�����׳�ָ����ŵĴ�����Ϣ��̬�Ĺ���������Ϣ
RaisError(N'û���û�ID�����ȵ�ϵͳ��������,����ʹ���Զ��ϲ�����', 16, 1,N'����')
RaisError(100016, 16, 1,@CheckBillNo)  	

--2)��begin try ��׽������ʱ,��ת��begin catchģ�飬�������������ع����׳����󣬴���д��־
begin catch
	ROLLBACK
	PRINT '����ع�' --����һ��������Ϣ��¼

	SELECT ERROR_NUMBER() AS �����,
	ERROR_SEVERITY() AS ����ȼ�,
	ERROR_STATE() as ����״̬,
	DB_ID() as ���ݿ�ID,
	DB_NAME() as ���ݿ�����,
	ERROR_MESSAGE() as ������Ϣ;

	insert into ErrorLog(sMessage)
	select ERROR_MESSAGE() as ������Ϣ
end catch

--3)@@error ��һ������ִ�д�����Ϣ
if @@error<>0 print '������'

--�Զ��������Ϣ
--����ʹ��sp_addmessage�����ؼ���Ϊ1`25���û����������Ϣ��ӵ� "sys.messages"Ŀ¼��ͼ�С���Щ�û�����Ĵ�����Ϣ�ɹ�RaisErrorʹ��.

--Ȩ��Ҫ����� sysadmin �� serveradmin �̶���������ɫ�ĳ�Ա���
Exec sp_AddMessage 80002, 16, N'The bill', N'us_english',False,Replace
Exec sp_AddMessage 80002, 16, N'�˵����ѱ����ã��������ϣ�', N'Simplified Chinese',False,Replace
Exec sp_AddMessage 80002, 16, N'�ˆΓ��ѱ����ã��������U��', N'Traditional Chinese',False,Replace

select * from sys.messages


--------����ع�----------------------------------------------------------------------------------
����


---���ڴ���
 Set Language @Lang --E)��ԭ���� 
 Set @RetVal = -1 	  
 return --F)�˳�