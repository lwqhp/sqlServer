


--SqlServer��ȫ����
/*
һ������������������ݿ��ܹ���Դ��ʵ���Ϊ��ȫ���壬��ΪSqlServer�Ѱ�ȫ����ֳ���������
window����
sqlServer����
���ݿ⼶��

��ͬ�İ�ȫ��������˰�ȫ�����Ӱ�췶Χ��ͨ����window��sqlserver����İ�ȫ�������ʵ�����ķ�Χ�������ݿ⼶���������
Ӱ�췶Χ���ض������ݿ⡣

ʹ��window�����֤������SQLServerʵ�����ʻ�����һ��window��������,���window��¼��������һ�����û�,�����û�.����һ���û���
ֻ�н�window�ʻ���ӵ�sqlserverʵ���У������������ݿ�����Ȩ�ޡ�
*/
--����window��½��
create login [hengkangit\li.weiqiang]
from windows
with default_database=HK_BI_ETL

--����һ��window�û����window��¼��
create login [hengkangit\public]
from windows
with default_database=HK_BI_ETL
/*
��sql Server��¼��������windows�û��飬��ʹ�����window�û�������г�Ա�̳���window��¼���ķ���Ȩ�ޣ����ԣ�����û���
�����г�Ա����Ҫ�ֱ���ʽ���ÿ��window�ʺŵ�sqlserverʵ������ӵ���˷���slqserverʵ����Ȩ�ޡ�
*/

--�鿴ʵ�����Ѿ���ӵ�window��¼�����û���
select * from sys.server_principals
where type_desc in('WINDOWS_LOGIN','WINDOWS_GROUP')

--�޸�window��¼����һЩ����
alter login [HENGKANGIT\li.weiqiang]
with default_database=HK_BI_ETL --Ĭ�����ݿ�

alter login [HENGKANGIT\li.weiqiang] disable --����
alter login [HENGKANGIT\li.weiqiang] enable --����

--ɾ����¼��
drop login [HENGKANGIT\li.weiqiang]
--�����¼��ӵ���κεİ�ȫ����drop����ʧ�ܡ�

use master
go
--�ܾ�����
deny connect sql to [HENGKANGIT\li.weiqiang]
--�������
grant connect sql to [HENGKANGIT\li.weiqiang]
/*��¼������һ�ε�¼ʱ��Ч*/

/* sqlServer���������(sqlserver�ĵ�½�ʻ�)-------------------------------------------------------------------------------

window�����֤�����ڵײ�Ĳ���ϵͳ����������֤��������ζ��slqserverҪ��ɱ�Ҫ����Ȩ(������������֤���û�����ִ
��ʲô����),sqlServer�����sqlserver �����֤һ����ʱ��sqlServer�Լ���������֤����Ȩ��

��window��¼��һ����sqlServer��¼��Ҳֻ�����ڷ��������𣬲����Ը�������Ȩ�޵��ض������ݿ�����ϣ������㱻���ڹ̶���
������ɫ(����sysadmin)�ĳ�Ա��������ʹ�����ݿ������֮ǰ�����봴����������¼�Ӱ����ݿ��û��ϡ�
*/
--����sqlServer��¼��
create login text2
with password='A,12345678',
default_database=HK_BI_ETL

--�鿴
select * from sys.server_principals where type_desc in('sql_login')

--�޸�
alter login text2
with name=text21,password='A/123456'
--��Ҫӵ�й̶���������ɫsysadmin

drop login text21

--�鿴��½������
select loginproperty('text2','islocked') islocked,
	loginproperty('text2','isexpired') isexpired,
	loginproperty('text2','ismustchange') isMustChange,
	loginproperty('text2','badPasswordcount') badPasswordcount,
	loginproperty('text2','historylength') historylength,
	loginproperty('text2','lockouttime') lockouttime,
	loginproperty('text2','passwordlastsettime') passwordlastsettime,
	loginproperty('text2','passwordhash' ) passwordhash


--�̶���������ɫ
/*
����Ԥ�����sql�û��飬���Ǳ������ض���sqlServer��Χ(�����ݿ��ܹ���Χ���)��Ȩ�ޡ�
*/

--����һ����½�������ѵ�½����ӵ��̶���������ɫ��
create login text3
with password='A.38409587'

select * from sys.server_principals where type_desc in('sql_login')

exec sp_addsrvrolemember 'text3','sysadmin'

exec sp_dropsrvrolemember 'text3','sysadmin'

--�鿴�̶���������ɫ
select * from sys.server_principals where type_desc = 'server_role'

--�鿴�̶���������ɫ�б�
exec sp_helpsrvrole

--�鿴ĳ���̶���������ɫ�ĳ�Ա
exec sp_helpsrvrolemember 'sysadmin'


/*���ݿ⼶�������-------------------------------------------------
���ݿ⼶��������ǿ��Է���������ݿ�����ݿ��е���������Ȩ�޸��û��Ķ���

���ݿ��û�����ִ�����ݿ��ڵ���������ݿ⼶��İ�ȫ�����ģ�������sqlserver��windows��¼��������
���ݿ��ɫ��
Ӧ�ó����ɫ

һ�������˵�¼�����Ϳ��԰���ӳ�䵽���ݿ��û���һ����¼������ӳ�䵽һ��sqlserverʵ�� �Ķ�����ݿ��ϡ�
*/

--�����û�
CREATE LOGIN text3
with password='A,12345678'

CREATE USER text3
FOR LOGIN [text3]	--Ĭ����������ͬ�ĵ�½����
WITH default_schema=dbo --Ĭ����dbo


--�鿴���ݿ��û���Ϣ
EXEC sys.sp_helpuser @name_in_db = text3 -- sysname

--�޸�
ALTER USER text3
WITH NAME =text4

ALTER USER text4
WITH DEFAULT_SCHEMA=dbo

DROP USER text4

--�޸����������ݿ��û�
SELECT * FROM sys.database_principals a
LEFT JOIN sys.server_principals b ON a.sid = b.sid
WHERE b.sid IS NULL AND a.type_desc ='sql_user' AND a.principal_id>4

--����ָ��
ALTER USER text4
WITH LOGIN li.weiqiang

--�鿴�̶����ݿ��ɫ
EXEC sys.sp_helpdbfixedrole @rolename = NULL -- sysname

--�鿴�й̶����ݿ��ɫ���û�
EXEC sys.sp_helprolemember @rolename = NULL -- sysname
/*
һ���̶����ݿ��ɫ����Ҫ�����ݿ�Ȩ�޻㼯��һ����ЩȨ�޲������޸Ļ�ɾ����
��̶���������ɫһ�����������ݿ��û�����ò�Ҫ��û��ȷ������Ȩ�޶��Ǿ��Ա�Ҫ������£��������ڵ��̶����ݿ�
��ɫ�ĳ�Ա�У����磬��Ҫ���û�ֻ��Ҫһ�����select Ȩ��ʱ������db_owner��Ա��ϵ��
*/

--�����û������ݿ��ɫ
EXEC sp_addrolemember 'db_datawriter','text4'
EXEC sp_droprolemember 'db_datawriter','text4'

--�����û��Զ������ݿ��ɫ

--�鿴
EXEC sys.sp_helprole @rolename = NULL -- sysname

CREATE ROLE role_lwq AUTHORIZATION db_owner

--����һ�����selectȨ�޸��µĽ�ɫ
GRANT SELECT ON TB TO role_lwq

--����û�
EXEC sp_addrolemember 'role_lwq','text3'

--�޸�
ALTER ROLE role_lwq WITH NAME = role_lwq2

--ɾ����ɫ�е��û�
EXEC sp_droprolemember 'role_lwq2','text3'
--ɾ����ɫ
DROP ROLE role_lwq2

/*Ӧ�ó����ɫ
Ӧ�ó����ɫ���ɵ�¼�������ݿ��ɫ��϶��ɵģ��ܹ����������û������ɫȨ����ͬ�ķ�ʽ������Ȩ�޸�Ӧ�ó���
��ɫ����ͬ����Ӧ�ó����ɫ�в�����ӵ�г�Ա��ȡ����֮���ǣ�Ӧ�ó����ɫ��ʹ�����������ϵͳ�洢���̼����
ʹ��Ӧ�ó����ɫʱ���������ǵ�¼������ӵ�е������������ޡ�

*/

--����
CREATE APPLICATION ROLE app
WITH PASSWORD ='123',
DEFAULT_SCHEMA = 'dbo'

--����Ȩ��
GRANT SELECT ON TB TO app

--������ǰ�û��Ự��Ӧ�ó����ɫȨ��
EXEC sp_setapprole 'app','123'

SELECT * FROM TB

--ʹ��sp_setaprole ���뵽Ӧ�ó���Ȩ��Ҳ����ˮ ��ֻӦ�������ɫ��Ȩ��
ALTER APPLICATION ROLE app WITH NAME = new_app,PASSWORD='1234',DEFAULT_SCHEMA='dbo'

DROP APPLICATION ROLE new_app



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

--�����ݿ�Ƕȣ����û����ɫ���������ݿ�Ȩ��
/*
���ݿ�����-Ȩ��

������־
�������ݿ�
����
�鿴����
������
��������,����,�ܹ������ӵ�

*/

--�����ݿ��û��Ƕȣ����õ�ǰ���ݿ�İ�ȫ�����Ȩ��
/*
��ͬ�İ�ȫ����������ڵ�Ȩ�޲�ͬ
�����

����
�鿴����
���ģ����£�ɾ�����ӹ�������Ȩ��
*/

--�Ӱ�ȫ����Ƕȣ�������û��ͽ�ɫ����Ȩ��
/*
���ݿ�-��������-Ȩ��

�԰�ȫ��������ڵ�Ȩ����ͬ
*/


-----��ɫ
/*
��Ԥ����ϵͳ��ɫ�ĳ�Ա�����ݿ�/���ݿ������������������Ȩ�ޡ�
��ɫ������Ȩ�޲��ܱ����ġ�

��������ɫ
ʹ�÷�������ɫ���ڹ�������������������ʹ��¼��Ϊ��ɫ��Ա���û��ô˵�½�Ϳ�ִ�н�ɫ��ɵ��κ�����.

����
sysadmin��ɫ�ĳ�Ա��sqlserver������߼����Ȩ�ޣ�������ִ���κ����͵�����


���ݿ��ɫ
�����ݿ⼶�����Ȩ�ޣ����ÿһ�����ݿ��������ݿ��ɫ

�û�����ı�׼��ɫ
�û������Ӧ�ó����ɫ
Ԥ�����̶������ݿ��ɫ

��׼��ɫ���������е�һȨ�޵Ľ�ɫ�����û������߼����飬Ȼ��Ϊ��ɫ���䵥һ��Ȩ�ޣ������ǵ���Ϊÿһ���û�����Ȩ�ޡ�

Ԥ��������ݿ��ɫ�����в��ܸ��ĵ�Ȩ�ޡ�
*/

select * from sys.login_token

exec sp_helplogins 'sa'

/*
���ݿ�Ĭ�ϵ��û�
dbo�û�(ָ�����ݿ���û�)
guest�û�(�������޵�ָ�����ݿ���û�)
information_schema�û���sys�û�

dbo�û�
���ݿ������߻��dbo��һ���������͵����ݿ��û��������������������Ȩ�ޡ�һ����˵���������ݿ���û������ݿ�������ߡ�
dbo����ʽ���ڶ����ݿ������Ȩ�ޣ������ܽ���ЩȨ�����������û�����Ϊsysadmin��������ɫ�ĳ�Ա���Զ�ӳ��Ϊ�����û�dbo,
��sysadmin��ɫ��¼��ִ��dbo��ִ�е��κ�����
*/