

--Select Into��¼����
/*
�±��л�̳в�ѯ��������е����ƣ��������ͣ��Ƿ�����Ϊnull,�Լ�identity���ԡ�
����̳�Լ������������������

select into ��һ��������(bulk)���������Ŀ�����ݿⲻ������ģʽ��select into ����С��־��¼��������������
��־��¼����Ҫ��ܶࡣ

1����into�����ձ�ͷ
��where 1=2�У�sqlserver���������ȥ�������Դ���ݣ����Ǹ��ݱ�ļܹ�������Ŀ���

2��ȥ��indetity���Լ̳�
select id+0 as new id into # from tb

3)�Ѵ洢���̲嵽����
select * into target_table
from openquery(��������'exec sql') as a
*/