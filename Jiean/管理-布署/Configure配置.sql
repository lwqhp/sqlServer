

--Configure����


--�鿴SQLServerѡ��
SELECT 
name,
value,
maximum,
value_in_use,
is_dynamic,--��̬ѡ���ִ��reconfigure��������øı�ͻ���Ч
is_advanced --�߼�ѡ������Ҫ�����߼�ѡ����ܿ�����Щ����
 FROM sys.configurations
 
 --��ʾ����ѡ��
 EXEC sys.sp_configure 
 
 --��ʾ�߼�ѡ��
 EXEC sp_configure 'show advanced option',1
 RECONFIGURE