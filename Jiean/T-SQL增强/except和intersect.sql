

--���ݼ��ȶ�except ��intersect
/*
�Ա��������ݼ��ļ�¼�Ƿ���ͬ���Ҳ���ͬ�ļ�¼����Ҫ����û�������Ķѱ�Ƚϡ�

Ҫ���ѯ��������ͬ������Ū����������Ҫ���ݣ����������Բ���Ҫһ��
*/

SELECT * 
INTO FIGL_Bas_AccountA
FROM dbo.FIGL_Bas_Account WHERE Accountcode NOT IN( '1001','1002')

SELECT * 
INTO FIGL_Bas_AccountB
FROM dbo.FIGL_Bas_Account WHERE Accountcode NOT IN( '100101','100201')


--except : ��ѯ����д��ڶ������ұ��д��ڵ��У�����A,B��Ƚϣ�A���ж�����ļ�¼��

SELECT * FROM FIGL_Bas_AccountA
EXCEPT 
SELECT * FROM FIGL_Bas_AccountB


--intersect : ͬʱ�����������������еĲ��ظ���(A,B���ж��еļ�¼)
SELECT * FROM FIGL_Bas_AccountA
INTERSECT  
SELECT * FROM FIGL_Bas_AccountB

SELECT * FROM FIGL_Bas_AccountB


