

SELECT * FROM FIGL_Bas_Account WHERE accountname LIKE '[Ƥ��]'

SELECT * FROM FIGL_Bas_Account WHERE PATINDEX('%[^Ƥ��]%',AccountName)>0


--ͨ���
/*
������ͨ���
1)% ��ʾ������������ַ��������ַ���
2)_ ��ʾ�κε����ַ�
3)[] ָ��ĳ����Χ���б��е�һ���ַ�
4)[^] ָ�������ض���Χ�е�һ���ַ�

ͨ���ת�� ��escape '/'

ʹ��ͨ��������������� like patindex
*/

--like �ؼ���
SELECT * FROM dbo.FIGL_Bas_Account WHERE AccountName LIKE '%[���д��]%'
SELECT * FROM dbo.FIGL_Bas_Account WHERE AccountName LIKE '����__'
SELECT * FROM dbo.FIGL_Bas_Account WHERE AccountName LIKE '[���д��]'

SELECT * FROM dbo.FIGL_Bas_Account WHERE PATINDEX('%[����]%',AccountName)>0

SELECT * FROM figl_bas_account WHERE AccountName LIKE '%��%/%%' ESCAPE '/'
/*
˵����
[]��ʾһ��ȡֵ��Χ������ÿһ���ַ�����й���'��'��ϵ��^����'�ǻ�'��ϵ��������ĸ�������м����'-'��ʾ
ת����ڹؼ��ֺ���escape ������

*/

