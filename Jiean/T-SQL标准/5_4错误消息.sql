

--ϵͳ��Ϣ

select * from sys.messages

--����Զ�����Ϣ
Exec sp_AddMessage 50001, 16, N'Not Bill', N'us_english',False,Replace
Exec sp_AddMessage 50001, 16, N'��ǰ���ݲ����ڣ�', N'Simplified Chinese',False,Replace
Exec sp_AddMessage 50001, 16, N'��ǰ�Γ������ڣ�', N'Traditional Chinese',False,Replace

/*
�û��Զ��������ϢID�������50000
16 ������Ϣ�����ؼ���
������Ϣ���ı�
������Ϣ��ʹ�õ�����
ָ���Ƿ��¼������Ϣ
ָ��ʹ���µ���Ϣ���ĺ����ؼ��𸲸����еĴ�����Ϣ
*/

--ɾ���Զ�����Ϣ

exec sp_dropmessage 50001,'all'


--�޸��Զ�����Ϣ
exec sp_altermessage 50001,'with_log','true'

--�׳�������Ϣ
raiserror(50001,16,1)