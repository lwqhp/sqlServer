


--SqlServer��ȫȨ��
/*
�ְ�ȫ����Ͱ�ȫ����

һ������������������ݿ��ܹ���Դ��ʵ���Ϊ��ȫ���壬��ΪSqlServer�Ѱ�ȫ����ֳ���������
window����
sqlServer����
���ݿ⼶��

��ͬ�İ�ȫ��������˰�ȫ�����Ӱ�췶Χ��ͨ����window��sqlserver����İ�ȫ�������ʵ�����ķ�Χ�������ݿ⼶���������
Ӱ�췶Χ���ض������ݿ⡣

ͬ����sqlServerҲ�԰�ȫ����ķ�Χ�����˻���
������
���ݿ�
�ܹ�

���ݿ��е����ж�����λ�ڼܹ��ڵģ�ÿһ�ܹ����������ǽ�ɫ�������Ƕ������û����������û��������ݿ����

Ȩ�ޣ�
���Ƕ԰�ȫ�������ܽ��еĲ���
*/

SELECT * FROM sys.fn_builtin_permissions('login')
WHERE class_desc =''

SELECT HAS_PERMS_BY_NAME(DB_NAME(),'Database','any')

SELECT DB_NAME()

SELECT HAS_PERMS_BY_NAME(name,'object','insert') ,* FROM sys.tables

EXECUTE AS USER='lwqhp'
SELECT HAS_PERMS_BY_NAME(name,'object','insert') ,* FROM sys.tables
