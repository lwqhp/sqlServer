


--SqlServer��ȫ����
/*
һ������������������ݿ��ܹ���Դ��ʵ���Ϊ��ȫ���壬SqlServer�Ѱ�ȫ����ֳ���������
window����
sqlServer����
���ݿ⼶��

��ͬ�İ�ȫ��������˰�ȫ�����Ӱ�췶Χ��ͨ����window��sqlserver����İ�ȫ�������ʵ�����ķ�Χ�������ݿ⼶���������
Ӱ�췶Χ���ض������ݿ⡣


{�������Ϊ�����㼶��������������ݿ��,�������㼶������window����������SqlServer����}
>>��һ����
ʹ��window�����֤������SQLServerʵ�����ʻ�����һ��window��������,���window��¼��������һ�����û�,�����û�.����һ���û���
ֻ�н�window�ʻ���ӵ�sqlserverʵ���У������������ݿ�����Ȩ�ޡ�

*/
--2.1)window����--------------------------------------------------------------------------------

--��������������޸ļ��鿴
create login [PC-LIWEIQIANG\lwq] --�����û�
from windows
with default_database=HK_ERP_PT

create login [HENGKANGIT\�㿵�ͷ���] --�û���
from windows
with default_database=HK_ERP_PT

alter login [HENGKANGIT\�㿵�ͷ���] --��Ĭ�����ݿ�
with default_database=HK_BI_ETL

--alter login [HENGKANGIT\�㿵�ͷ���] disable --���ܶ�����alter
alter login [PC-LIWEIQIANG\lwq] disable  --����
alter login [PC-LIWEIQIANG\lwq] enable  ----����

----�����¼��ӵ���κεİ�ȫ����drop����ʧ�ܡ�
drop login [PC-LIWEIQIANG\lwq] --ɾ��

use master
go
--ֻ���ڵ�ǰ���ݿ��� master ʱ�����������������Χ��Ȩ��,��¼������һ�ε�¼ʱ��Ч
deny connect sql to [HENGKANGIT\li.weiqiang]  --�ܾ�����(GUI��״̬�����Ӿܾ�,ʹ����ʾ���޷����ӣ���½ʧ��)

grant connect sql to [HENGKANGIT\li.weiqiang] --�������

--�鿴ʵ�����Ѿ���ӵ�window��¼�����û���
select * from sys.server_principals
where type_desc in('WINDOWS_LOGIN','WINDOWS_GROUP')

/*
��sql Server��¼��������windows�û��飬��ʹ�����window�û�������г�Ա�̳���window��¼���ķ���Ȩ�ޣ����ԣ�����û���
�����г�Ա����Ҫ�ֱ���ʽ���ÿ��window�ʺŵ�sqlserverʵ������ӵ���˷���slqserverʵ����Ȩ�ޡ�

>>>{GUI��ʵ���µİ�ȫ��-��½�������Ƿ���������ȫ����}
*/



/* 2.2)sqlServer���������(sqlserver�ĵ�½�ʻ�)-------------------------------------------------------------------------------

window�����֤�����ڵײ�Ĳ���ϵͳ����������֤��������ζ��slqserverҪ��ɱ�Ҫ����Ȩ(������������֤���û�����ִ
��ʲô����),sqlServer�����sqlserver �����֤һ����ʱ��sqlServer�Լ���������֤����Ȩ��

��window��¼��һ����sqlServer��¼��Ҳֻ�����ڷ��������𣬲����Ը�������Ȩ�޵��ض������ݿ�����ϣ������㱻���ڹ̶���
������ɫ(����sysadmin)�ĳ�Ա��������ʹ�����ݿ������֮ǰ�����봴��������¼�����ݿ��û��ϡ�
����
sysadmin��ɫ�ĳ�Ա��sqlserver������߼����Ȩ�ޣ�������ִ���κ����͵�����
*/

create login lwq1 --����sqlServer��¼��
with password='A,12345678',
default_database=HK_BI_ETL

alter login lwq1
with name=lwq1a,password='A/123456' --����������

alter login lwq1
with default_database=master

--��Ҫӵ�й̶���������ɫsysadmin
drop login lwq1a		--ɾ��

--�鿴
select * from sys.server_principals where type_desc in('sql_login')

--�鿴��½������
declare @LoginName varchar(30)='lwq1'
select loginproperty(@LoginName,'islocked') islocked,
	loginproperty(@LoginName,'isexpired') isexpired,
	loginproperty(@LoginName,'ismustchange') isMustChange,
	loginproperty(@LoginName,'badPasswordcount') badPasswordcount,
	loginproperty(@LoginName,'historylength') historylength,
	loginproperty(@LoginName,'lockouttime') lockouttime,
	loginproperty(@LoginName,'passwordlastsettime') passwordlastsettime,
	loginproperty(@LoginName,'passwordhash' ) passwordhash


/*
>>>>>>>>>>>>>>>�����������������������Ȩ��------------------------------------------------------------

--�̶���������ɫ

����Ԥ�����sql�û��飬���Ǳ������ض���sqlServer��Χ(�����ݿ��ܹ���Χ���)��Ȩ�ޣ�Ĭ����public��ɫ
ʹ�÷�������ɫ���ڹ�������������������ʹ��¼��Ϊ��ɫ��Ա���û��ô˵�½�Ϳ�ִ�н�ɫ��ɵ��κ�����.

*/

--�鿴�̶���������ɫ
select * from sys.server_principals where type_desc = 'SERVER_ROLE' --�������ôʲô���Ű�
--�鿴�̶���������ɫ�б�
exec sp_helpsrvrole

exec sp_addsrvrolemember 'lwq1','sysadmin' --�ӵ�sysadmin��ɫ

exec sp_dropsrvrolemember 'text3','sysadmin' --ɾ����������ɫ

--�鿴�̶���������ɫ�����ĳ�Ա
exec sp_helpsrvrolemember 'sysadmin'


---==========================================================================================================
----------------------------------------�ָ���---------------------------------------------------------------
--===========================================================================================================

/*���ݿ⼶�������-------------------------------------------------

���ݿ⼶��������ǿ��Է���������ݿ�����ݿ��е���������Ȩ�޸��û��Ķ���

1,���ݿ��û�����ִ�����ݿ��ڵ���������ݿ⼶��İ�ȫ�����ģ�������sqlserver��windows��¼��������
2,���ݿ��ɫ��
3,Ӧ�ó����ɫ



һ�������˵�¼�����Ϳ��԰���ӳ�䵽���ݿ��û���һ����¼������ӳ�䵽һ��sqlserverʵ�� �Ķ�����ݿ��ϡ�
*/

--3.1���ݿ��û�--------------------------------------
CREATE USER lwq1
FOR LOGIN [lwq1]	--Ĭ����������ͬ�ĵ�½����
WITH default_schema=dbo --Ĭ����dbo


--�鿴���ݿ��û���Ϣ
EXEC sys.sp_helpuser @name_in_db = lwq1a -- sysname


ALTER USER lwq1 --�޸�
WITH NAME =lwq1a

ALTER USER lwq1a
WITH DEFAULT_SCHEMA=dbo

DROP USER lwq1a --ɾ��
ALTER AUTHORIZATION ON SCHEMA::db_owner TO dbo; --Ȼ���ֶ�ɾ���Ϳ����ˡ� 



--3.2�鿴�̶����ݿ��ɫ--------------------------------------------------------
/*
���ݿ��ɫ
�����ݿ⼶�����Ȩ�ޣ����ÿһ�����ݿ��������ݿ��ɫ

�û�����ı�׼��ɫ
�û������Ӧ�ó����ɫ
Ԥ�����̶������ݿ��ɫ

��׼��ɫ���������е�һȨ�޵Ľ�ɫ�����û������߼����飬Ȼ��Ϊ��ɫ���䵥һ��Ȩ�ޣ������ǵ���Ϊÿһ���û�����Ȩ�ޡ�

Ԥ��������ݿ��ɫ�����в��ܸ��ĵ�Ȩ�ޡ�
*/
EXEC sys.sp_helpdbfixedrole @rolename = NULL -- sysname

--�鿴�й̶����ݿ��ɫ���û�
EXEC sys.sp_helprolemember @rolename = NULL -- sysname
/*
һ���̶����ݿ��ɫ����Ҫ�����ݿ�Ȩ�޻㼯��һ����ЩȨ�޲������޸Ļ�ɾ����
��̶���������ɫһ�����������ݿ��û�����ò�Ҫ��û��ȷ������Ȩ�޶��Ǿ��Ա�Ҫ������£��������ڵ��̶����ݿ�
��ɫ�ĳ�Ա�У����磬��Ҫ���û�ֻ��Ҫһ�����select Ȩ��ʱ������db_owner��Ա��ϵ��
*/

--�����û������ݿ��ɫ
EXEC sp_addrolemember 'db_datawriter','lwq1'
EXEC sp_droprolemember 'db_datawriter','lwq1'

-->>>>>�����û��Զ������ݿ��ɫ---------------
EXEC sys.sp_helprole @rolename = NULL -- sysname--�鿴

CREATE ROLE role_lwq AUTHORIZATION db_owner


--����ɫ���Ȩ��
GRANT SELECT ON TB TO role_lwq --����һ�����selectȨ�޸��µĽ�ɫ

--����ɫ����û�
EXEC sp_addrolemember 'role_lwq','text3'

--�޸�
ALTER ROLE role_lwq WITH NAME = role_lwq2

--ɾ����ɫ�е��û�
EXEC sp_droprolemember 'role_lwq2','text3'
--ɾ����ɫ
DROP ROLE role_lwq2


/*3.3Ӧ�ó����ɫ-------------------------------------------------------------------------
Ӧ�ó����ɫ���ɵ�¼�������ݿ��ɫ��϶��ɵģ��ܹ����������û������ɫȨ����ͬ�ķ�ʽ������Ȩ�޸�Ӧ�ó���
��ɫ����ͬ����Ӧ�ó����ɫ�в�����ӵ�г�Ա��ȡ����֮���ǣ�Ӧ�ó����ɫ��ʹ�����������ϵͳ�洢���̼����
ʹ��Ӧ�ó����ɫʱ���������ǵ�¼������ӵ�е������������ޡ�

*/
CREATE APPLICATION ROLE app --����
WITH PASSWORD ='123',
DEFAULT_SCHEMA = 'dbo'

--����Ȩ��
GRANT SELECT ON TB TO app

--������ǰ�û��Ự��Ӧ�ó����ɫȨ��
EXEC sp_setapprole 'app','123'

--ʹ��sp_setaprole ���뵽Ӧ�ó���Ȩ��Ҳ����ˮ ��ֻӦ�������ɫ��Ȩ��
ALTER APPLICATION ROLE app WITH NAME = new_app,PASSWORD='1234',DEFAULT_SCHEMA='dbo'

DROP APPLICATION ROLE new_app













