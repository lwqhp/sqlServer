

/*
sql�������� sqlserver�����ṩ�Ĺ��ܺͲ��������ݿ����� ���ݿ����е�״̬��������ʽ���Զ�ѡ�������ѡ�����Ŀ��ո���ѡ�

Sql Server ����

��window�У�ͨ����פ����Ϊ�û��ṩ���ֹ��ܣ�sqlserverҲ�����⣬һ��sqlserver���̻��������һ����Ӧwindow����

��window��������У������趨�����������ֹͣ����ͣ������״̬�����÷���ĵ�¼��ݡ�

���� ����ĵ�½��ݣ�һ�㲻�Ƽ���

����ĵ�¼��ݾ����˷�����ʲ���ϵͳ������Դʱ��ӵ�е�Ȩ�ޡ����Ҷ�ĳЩ��Դ�ķ���Ȩ���Ǳ���ģ������¼�����ж�
ĳЩ��Դ�ķ���Ȩ�ޣ���ᵼ�·����޷�������������������

ע:�ڷ���������sqlserver�������ĵ�¼���ʱ�����ô�����򲻻�Ϊ�����õĵ��������κ�Ȩ�ޣ����Ҫ��������ǰ����
�õ� ¼Ӧ�þ��е�Ȩ�ޣ�����ᵼ�·����޷�������

ע����¼�����Ȩ�޲�����������

ʹ��sqlserver���ù����� �����˰�������Ļ��������⣬�������Զ���ɵ�¼������������Ҫ�ĸ���Ȩ�޷��䣬SMO��WMI��
������������������������������Ч��

�ɲ鿴�������ID��������·���ȣ�������������
ͨ�������������Կ���sqlservere���������ķ�ʽ ��������С�������������û�ģʽ����

��½���3+1

Local System :����ϵͳ�ʻ�������һ������ϵͳ�����ʻ������ڷ���������ϵͳ���б���һ��Ȩ�ޣ������ʻ������з�������
��Ȩ�ޡ����Ҫ�ڷ����з���������Դ������Ҫ������ĵ�¼�������Ϊָ�����û���


sql server�����ṩ��sqlserver���ù��������Է���Ļ������ã����ṩһ���洢���̶����з��������ܵķ������趨����
*/

sp_configure 


/*
���ݿ�����ѡ��

���ݿ�������趨�����˿��������ݿ��Ҽ���������Ķ����ݿ�����ã�������ʹ��ʹ�� Alter DataBase ��������ݿ���в���

*/
Alter DATABASE 


--��ȫȨ��

/*
1,���Ӱ�ȫ����ֻ֤����ɵĿͻ����ܹ���ָ���ķ�ʽ����Ҫ������ʹ����������Э�飩���ӵ�Sqlserver.

2,��½��֤����¼��֤��֤����ɿͻ��˷����ĵ�¼�����ǺϷ��ġ�

3��Ȩ�����ã�Ȩ�����ÿ��ƺϷ���¼���ܴ��µľ��������
*/

--���Ӱ�ȫ
/*
���ӵİ�ȫͨ�����ڷ���ǽ�ϣ������ӽ��й��ˣ����磺ֻ������ָ����IP��ַ����1433��ͨѶ��
����ֻ�Ǵ�sqlServer����Ƕ��˽�ͻ��˺ͷ�������ʵ�����ӵĹ��̣�
��������Ų��ṩ���ݡ�

SqlServer��ͨ������Э���TDS�˵���client-Server֮��ͨ�ŵġ�
Ĭ��sqlServer����4��ͨ��Э�� ��TCP/IP,VIA,Named Pipe ,Shared Memory

Э�����sqlserver���ù�������鿴������
shared memoryЭ��������ӵ�������ʵ�����ڱ����Ͻ�ʹ�ô�Э�����ӣ��ɼ�������sqlserver�Ƿ�����.
Named Pipes :Ϊ��������������Э�顣
TCP/IP : internetͨ��Э�飬�ʺ����г��ϣ�Ĭ�϶˿���1433
VIA : ��VIAӲ��һͬʹ�õ�Э�飬Ĭ�Ϲرա�

ע����sqlserver�������á����������÷��������Э��
	��sql native Client��:���ڿͻ���Э������
	
DTS�ǹ���������Э���е�һ�����ݰ���ʽ������ʽ����������DTS�˵��Ƕ�DTS��ʵ���������������á�
��������Բ鿴������ ����˵�DTS�˵�״̬
*/
SELECT * FROM sys.endpoints 
ALTER ENDPOINT  [TSQL Default VIA] STATE=STARTED
ALTER ENDPOINT [TSQL Default VIA] STATE=STOPPED


/*
Ĭ��ÿ��Э�鶼��һ����Ӧ��DTS�˵�

�û�Ҳ���Զ����Լ���DTS�˵㣬��Щ�ܿ�

*/
--�ڡ�SQL Server ���ù��������ġ�SQL Server 2005���������С�����ֹ��TCP/IP֮�������Э�飻

-- ʹ�����µ�T-SQL��ֹĬ�ϵ�TCP�˵�
ALTER ENDPOINT [TSQL Default TCP] STATE = STOPPED

--ʹ�����µ�T-SQL�����µ�TCP�˵����Ȩ
USE master
GO
-- ����һ���µĶ˵�
CREATE ENDPOINT [TSQL User TCP] --�˵�����
STATE = STARTED
AS TCP(
   LISTENER_PORT = '1433',
   LISTENER_IP = ('192.168.1.1')  -- �����������ַ
)
FOR TSQL()
GO

-- �������е�¼(����ָ����¼)ʹ�ô˶˵������Ȩ��
GRANT CONNECT ON ENDPOINT::[TSQL User TCP]
TO [public]

--ֻ��ͨ�������ַ����Ϊ192.168.1.1����������Ŀͻ��˲��ܷ���SQL Server
/*
��ȫ������SQL Server ���ݿ�������Ȩϵͳ���ƶ�����з��ʵ���Դ��ͨ�׵�˵��������SQL ServerȨ����ϵ�¿��ƵĶ�����Ϊ���еĶ���(�ӷ���������������ͼ��������)����SQL Server��Ȩ����ϵ����֮�£�������SQL Server�е��κζ��󶼿��Ա���Ϊ��ȫ����

    ������һ������ȫ����֮��Ҳ���в㼶���Ը��㼶�ϵİ�ȫ����Ӧ�õ�Ȩ�޻ᱻ���Ӳ㼶�İ�ȫ�������̳С�SQL Server�н���ȫ�����Ϊ�������,�ֱ�Ϊ:

        �������㼶
        ���ݿ�㼶
        ���ܲ㼶
*/
-------------------------

--��½��֤
/*
��½�ĵ�һ�����ʺ���֤��������������֤�ķ�ʽ���ʺ���Ч�ԣ��û�����������ȷ��

��������������֤ģʽ��window�����֤�ͻ��ģʽ

�ڻ��ģʽ�£�sqlServer�ʺű����Ǹ���Ч�ʺš�
��window�����֤�ͻ��ģʽ�£�window�ʺű����sqlServer����ӳ�䵽sql�û�������windowϵͳ����Ч�û������Ʊ�����
������\�û���������������������ȫ�޶����ơ�

��½��֤�Ƿ�ͨ�������������йأ�
1��sql��������֤ģʽ�Ƿ�ƥ�䣺
	��Ҫ��window�����֤ģʽ�£�ʹ����sqlServer��½����
	--��ʵ���ķ��������Եġ���ȫ�ԡ�����������֤�ķ�ʽ��
	
2����½�ʺ��Ƿ�Ϊ��Ч�ʺţ�
	window�ʺ��� "��windowϵͳ����Ч�û�",���ʺű���ӳ�䵽sql�û�����½��������������������\�û���������������������ȫ�޶����ơ�,"������ȷ"
	sqlServer�ʺ��� ��sqlServer���Ѵ�����½������"������ȷ"

1,Ҫ֪����Щ���õ�½����ʲô�õ�

��"##"��ͷ�ͽ�β���û���sqlserver�ڲ�ʹ�õ��ʻ�����֤�鴴������Ӧ�ñ�ɾ����
sa :���ܱ�ɾ�������Ȩ���ߡ�
NT Authority\networkServer �����������ʻ�����sqlserver����ʹ�õĵ�½����
NT Authority\System ������ϵͳ�ʺŵ�½ʹ�õĵ�½�������sqlserver�������ԡ�����ϵͳ�ʻ�����½������ɾ��

2����½�ʺ��ܷ�����ЩȨ��

���ڷ�������������Щ����
1)sql������ʵ������Ȩ�ޣ��������������̶���ɫ����

�ܶԵ������ݿ���ʲô����
2)���ʺ�ӳ�䵽��Щ���ݿ��û�������Ĭ�ϻ��ھ������ݿ��д���ָ���û�����

��ȫ����
���������������õİ�ȫ���󣺶˵㣬��½����������


��������ɫ(7)+2
bulkadmin : administer bulk operations
dbcreator : create database
diskadmin : alter resources
processadmin : alter any connection,alter server state
securityadmin: alter any login
serveradmin : alter any endpoint ,alter resources,alter server state,alter settings,shutdown,view server state
setupadmin : alter any linked server
sysadmin : control server

public��ɫ��������Ĭ�Ͻ�ɫ�����е�½���������������ɫ��publicֻ�� view any database��Ȩ��
(������ڷ�������ɫ��û�п���public����ô�ܿ�������Ϊ��û�а�װsql server�����²�������sql server 2005 sp2)������)

*/



--Ȩ�޿���----------------------------------------------------------------------------------------
/*
��ɫ���������̶���ɫ�����ݿ�̶���ɫ
�̶���ɫ�ǲ����Զ���ģ���ɫ�����˶԰�ȫ��������ķ�Χ���û����������Ľ�ɫ

 Ĭ�Ϲ̶���ɫ�����ڷ��������������ݿ�

�����ݿ����ܽ�����Щ�����������ݿ���û�Ȩ������(�����ݿ⼶���������û��ͽ�ɫ)

1������Щ�����û�
Dbo : ���ݿ��Ĭ���û�������ɾ��
Guest :�����˻�,�����¼��û��ӳ�䵽���ݿ��û�������·������ݿ⡣Ĭ�������guest�û��ǲ����õ�
INFORMATION_SCHEMA�û���sys�û�ӵ��ϵͳ��ͼ�����������ݿ��û����ܱ�ɾ��

2,������Щ��ɫ
Public��ɫ: ӵ�е�Ȩ���Զ����κ�����̳У����Զ���Public��ɫ��Ȩ���޸�Ҫ����С��

���ݿ�̶���ɫ(8)+2
db_owner :����ִ�����ݿ���������ú�ά���


db_accessadmin alter any user,create schema ������Ȩ����Ա
db_accessadmin :connect
db_backupoperator : backup datebase,backuplog ,checkpoint
db_datereader : select
db_datawrite : delete,insert,update
db_ddladmin �� ����ddl����
db_securityadmin : alter any application role,alter any role,create schema,view deinition
dB_denydatareader : �ܾ� select 
db_denydatawrite :  �ܾ� delete ,insert,update

*/
--ÿһ����½����������д��һ����¼
select * from sys.sql_logins


/*
�ܹ�

���Ϊ�����ռ䣬


--��Ȩ

���ڸ���ȫ���������õ�Ȩ�ޣ��ᱻ�Զ��̳е��Ӱ�ȫ�����ϡ�
 ���磬�Ҹ�������CareySon(��¼��)���ڰ�ȫ����CareySon-PC(������)��Select(Ȩ��),
 ��ôCareySon��������Զ�ӵ��CareySon-PC�����������е����ݿ��б����ͼ���Ӱ�ȫ�����SELECTȨ��
 
��Ȩԭ��
�Զ����£��ɹ㵽խ�� ��С��Ȩ

������-���ݿ�
��ɫ-�û���
=����Ȩ
*/

--�﷨
GRANT { ALL [ PRIVILEGES ] }
      | permission [ ( column [ ,...n ] ) ] [ ,...n ]
      [ ON [ class :: ] securable ] TO principal [ ,...n ] 
      [ WITH GRANT OPTION ] [ AS principal ]
DENY { ALL [ PRIVILEGES ] }
      | permission [ ( column [ ,...n ] ) ] [ ,...n ]
      [ ON [ class :: ] securable ] TO principal [ ,...n ] 
      [ CASCADE] [ AS principal ]
REVOKE [ GRANT OPTION FOR ]
      { 
        [ ALL [ PRIVILEGES ] ]
        |
                permission [ ( column [ ,...n ] ) ] [ ,...n ]
      }
      [ ON [ class :: ] securable ] 
      { TO | FROM } principal [ ,...n ] 
      [ CASCADE] [ AS principal ]            

grant select--Ȩ��
 ON Schema::SalesLT--����::��ȫ����
  to careyson--����

deny select--Ȩ��
 ON Schema::SalesLT--����::��ȫ����
  to careyson--����

revoke select--Ȩ��
 ON Schema::SalesLT--����::��ȫ����
  to careyson--����


/*
��ҵ
1,����̶���ɫ�����úͷ�Χ
*/
---С��

--
DENY VIEW any DATABASE to PUBLIC;

--Ȼ���Best���Best�û�ִ�У�
ALTER AUTHORIZATION ON DATABASE::Best TO Best