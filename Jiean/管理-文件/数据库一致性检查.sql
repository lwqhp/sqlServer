

--���ݿ�����һ���Լ��

--�������ҳ�ͷ������
/*
������filestream����֮����������ݿ�ҳ���ڲ��ṹ�ķ��������������Ϣ���ݣ����а����ڲ�ҳ����Ϣ����������
�Լ�ҳ�档��������󣬱��������з����һ���Դ���
*/
DBCC CHECKALLOC('test')

--���ṹ������
DBCC CHECKDB('test')

--����ļ����б�Ľṹ������
DBCC CHECKFILEGROUP('fg2')

--�����������ͼ������������
DBCC CHECKTABLE('tb')
WITH all_errormsgs

--�����������Ҫ��tempdb�ռ�
DBCC CHECKTABLE('tb')
WITH estimateonly

--������������Լ��

--�鿴����id
SELECT index_id,* FROM sys.indexes WHERE object_id=object_id('tb')
AND name = 'IX_tb'

DBCC CHECKTABLE('tb',index_id)
WITH physical_only


--�����������
/*
������ָ�����Լ���з��ֵ�����checka�����Լ����Υ��������������������Υ��Լ�������ݣ��Ӷ���������Υ��
��Լ�����������ʹ����nocheck������Լ������ô�������Ҳ���Ჶ׽Լ��Υ�������
*/
DBCC CHECKCONSTRAINTS('tb')

--���ϵͳ���һ����
DBCC CHECKCATALOG('test')