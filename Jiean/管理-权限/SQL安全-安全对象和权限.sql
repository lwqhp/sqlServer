select * from sys.login_token

exec sp_helplogins 'sa'


-- ��ȫ�����Ȩ��
/*
��ȫ��������Ȩ�޺�������м���󣬰�Ȩ�޵ķ�Χ�ֳ�3��Ƕ�׷ּ���

�����ߵ��Ƿ�������Χ����������¼�������ݿ�Ͷ˵㡣--���ﰲȫ����Ͱ�ȫ���������
���ݿⷶΧ�����ڷ�������Χ�У����������ݿ��û�����ɫ����ȫƾ֤���ܹ��Ȱ�ȫ����
�������Ǽܹ���Χ�������ư�ȫ����ܹ����ܹ��еĶ��󣬱������ͼ�������洢���̵ȡ�

���ݿ�Ĭ�ϵ��û�
dbo�û�(ָ�����ݿ���û�)
guest�û�(�������޵�ָ�����ݿ���û�)
information_schema�û���sys�û�

dbo�û�
���ݿ������߻��dbo��һ���������͵����ݿ��û��������������������Ȩ�ޡ�һ����˵���������ݿ���û������ݿ�������ߡ�
dbo����ʽ���ڶ����ݿ������Ȩ�ޣ������ܽ���ЩȨ�����������û�����Ϊsysadmin��������ɫ�ĳ�Ա���Զ�ӳ��Ϊ�����û�dbo,
��sysadmin��ɫ��¼��ִ��dbo��ִ�е��κ�����

*/

--�鿴���п��õ�Ȩ��
SELECT * FROM sys.fn_builtin_permissions(DEFAULT) 

--����ʾ�ܹ���ȫ����Χ�е�Ȩ��
SELECT * FROM sys.fn_builtin_permissions('schema')

/*��������Χ�İ�ȫ�����Ȩ��
��������ȫ�����Ȩ��ֻ�����ڷ������������壬�������������ݿ⼶������塣
Ҳ����˵������Ȩ������Է���������ģ����紴�����ݿ⣬��¼�������ӷ������ȡ�

һ����⣺
�̶���ɫ��һ������İ�ȫ���󣬲������ϼ�Ȩ�ޣ�Ȩ�޿������ϼӵ��Զ����ɫ���ӵ���ȫ����(ֻ�з��������Ȩ�޿��Լӵ���ȫ������)

*/
SELECT * FROM sys.fn_builtin_permissions('SERVER') ORDER BY permission_name

--���ڸ���Ȩ��
GRANT ALTER trace TO login_name
WITH GRANT OPTION-- ��������ӵ�н�Ȩ�����������������ߵ�Ȩ��
AS grantor_principal -- ָ����������������Ȩ������Ȩ�����ڱ�������

GRANT CREATE ANY DATABASE,VIEW ANY DATABASE TO [li.weiqiang]

--�ܾ�
DENY SHUTDOWN TO [li.weiqiang]
CASCADE --�������������������������ЩȨ�޸��������壬��ô��Щ�������ߵ�Ȩ��Ҳ�����ܾ���
AS grantor_principal

--ȡ��,��û������Ҳû�оܾ����Ȩ��--ȡ������ɾ����ǰ���ڻ�ܾ��˵�Ȩ�ޡ�
REVOKE ALTER trace FROM [li.weiqiang]
CASCADE

--�鿴��������ΧȨ��
SELECT * FROM sys.server_permissions a
INNER JOIN sys.server_principals b ON a.grantee_principal_id = b.principal_id
WHERE name = 'lwqhp'

/*���ݿⷶΧ�İ�ȫ�����Ȩ��------------------------------------------------------------------------
���ݿ⼶��İ�ȫ��������ᶨ�����ݿ���Ψһ�ģ�����
��ɫ�����򼯣�����ϵͳ����broker����ȫ��Ŀ¼�����ݿ��û����ܹ����ȵȡ�

*/
SELECT * FROM sys.fn_builtin_permissions('DATABASE') ORDER BY permission_name

GRANT ALTER ANY ASSEMBLY TO USER_NAME

DENY ALTER ANY DATABASE DDL TRIGGER TO USER_NAME

REVOKE CONNECT FROM USER_NAME

--�鿴���ݿ�Ȩ��
SELECT name,principal_id FROM sys.database_principals --ȷ�������ʶ�� 

SELECT 
a.class_desc,a.permission_name,a.state_desc,b.type_desc,
CASE a.class_desc WHEN 'schema' THEN SCHEMA_NAME(major_id)
	 WHEN 'object_or_column' THEN CASE WHEN minor_id=0 THEN OBJECT_NAME(major_id)	
										ELSE (SELECT OBJECT_NAME(object_id)+'.'+name FROM sys.columns 
										WHERE object_id = a.major_id AND column_id = a.minor_id) END
							ELSE '' END  AS object_name 
 FROM sys.database_permissions a
LEFT JOIN sys.objects b ON a.major_id = b.object_id
WHERE grantee_principal_id = 5


/*�ܹ���Χ�İ�ȫ�����Ȩ��---------------------------------------------------------------------------------

��������ڼܹ��У��û�����ֱ��ӵ�ж��󣬶���ת��ӵ�мܹ�������ʵ���˶�����û��ķ��롣
����ζ�Ŷ���û�����ӵ�мܹ����ܹ�������ж��������Ϊһ��������й����������Ե������󼶱���й���
*/

CREATE SCHEMA SCHEMA_NAME [authorization owner_name]

DROP SCHEMA SCHEMA_NAME


ALTER SCHEMA dbo TRANSFER lwq.TB

--�鿴���ݿ�ܹ��б�
SELECT * FROM sys.schemas a
INNER JOIN sys.database_principals b ON a.principal_id = b.principal_id
ORDER BY a.name

--�û�test������take ownershipȨ�޵��ܹ�person��
GRANT TAKE OWNERSHIP ON shema ::person TO test

/*�����Ȩ��
������Ƕ���ڼܹ���Χ�еģ����ǰ�������ͼ���洢���̣������;ۺϣ��ڼܹ���Χ������select ,exec ����Ȩ�޿���
���� �����߶���ܹ������ж����Ȩ�ޣ�Ҳ�����ڶ��󼶱���Ȩ�ޡ�
����Ȩ�����ڼܹ�Ȩ����Ƕ�ף����ݿⷶΧ��Ȩ���еļܹ�Ȩ���Լ�����������Ȩ���е����ݿⷶΧȨ�ޡ�

*/

--�����û�Ȩ��
GRANT DELETE,INSERT,SELECT,UPDATE
ON dbo.tb
TO test


--��⵱ǰ���ӵİ�ȫ�����Ȩ��

SELECT HAS_PERMS_BY_NAME('dbname','datatabae','alter')
/*
1,ϣ����֤Ȩ�޵İ�ȫ���������
2��Ҫ���İ�ȫ����������ơ�����
3��Ҫ����Ȩ�޵�����
*/

--���ص�ǰ���ӵ���������Ȩ��

--��鵱ǰ���ӵķ�������ΧȨ��
EXECUTE AS LOGIN='text'
go

SELECT * FROM fn_my_permissions(NULL,N'Server')

/*
1,Ҫ��֤�İ�ȫ��������ƣ�����ڷ����������ݿⷶΧ���Ȩ�޾�ʹ��null
2,��Ҫ�Ի��г�Ȩ�޵İ�ȫ�Զ�����
*/

--�ı�����ӵ����
/*
����Ҫɾ����½�������ݿ��û�ʱ������ϣ���ı�����Ȩ
*/

--���ܹ���ӵ���߸ı�Ϊ���ݿ��û� textuser
ALTER AUTHORIZATION ON SCHEMA::humanresources TO testuser

--�鿴
SELECT * FROM sys.endpoints a
INNER JOIN sys.server_principals b ON a.principal_id = b.principal_id
WHERE a.name = 'product'

--ȱ��˶�����˽�