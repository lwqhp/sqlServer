

--����ֵ
/*
����ֵ����ĳ���ͽ�������������������
*/

--�����������з�����

--1��
SELECT IDENTITY(INT,1,1) id INTO # FROM TB

--2)��������
SELECT ROW_NUMBER() OVER(ORDER BY column) ,DENSE_RANK() OVER(PARTITION BY column) FROM TB
