

--���е�ֵ��
/*
���е�ֵ����ָ�Ծ���˳������ĵ�ֵ���ݵĶ��������������ݿ��������֣����ڵȣ�

���б�������Ӧ�÷�ʽ��
1�����������ѿ�������������ֵ��Ϊѭ���Ĵ�������Ŀ̶ȡ�

2�����������ӳԴ������������ԡ�
*/

--�������е�ֵ��

--1
SELECT number FROM master..spt_values WHERE type = 'P'

--2
SELECT TOP 1000 IDENTITY(INT,1,1) number 
INTO #
FROM sys.objects a,sys.objects b

SELECT * FROM #