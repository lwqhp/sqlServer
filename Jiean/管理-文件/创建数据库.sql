

--�������ݿ�

/*
����ϵͳ���ݿ�model��Ĭ�����ã����ݿ�model����sqlserverһ��װ��ϵͳ���ݿ⣬��Ϊ������sqlserverʵ���е���
���������ݿⶨ����ģ�飬����������ݿ�ʱ�������ݿ�������û��ָ���κ�ѡ�ѡ���ֵ������ϵͳ���ݿ�model��
*/
CREATE DATABASE test2

--�鿴
EXEC sp_helpdb 'test2'

--�޸ļ��ݼ���
ALTER DATABASE test2
SET COMPATIBILITY_LEVEL=100


--�������ݿ�

CREATE DATABASE test3
ON PRIMARY ( --�������ļ�
	NAME  = 'test301',  --�߼���
	FILENAME = 'e:\test301.mdf', --�ļ���
	SIZE=3Mb, --��ʼ��С
	MAXSIZE=UNLIMITED, --�ļ����ֵ
	FILEGROWTH=10MB --������
),( --���ŷָ������ļ�
	NAME = 'test302',
	FILENAME='e:\test3012.ndf',
	size=1MB,
	MAXSIZE=30,
	FILEGROWTH=5%
)
LOG ON( --��־�ļ�����һ��
	NAME = 'test03_log',
	FILENAME='e:\test03_log.ldf',
	size=504KB,
	MAXSIZE=100MB,
	FILEGROWTH=10%
)
DROP DATABASE test3
/*
�ļ���
Ĭ����������������ݿ⣬�����ļ��������ļ��飬������������ļ����Լ�����û����ʽ���䵽��ͬ�ļ���������ļ���

�û�Ҳ�����Զ����ļ���

*/

CREATE DATABASE test4
ON PRIMARY(
	NAME = 'test04',
	FILENAME ='e:\test0401.mdf',
	SIZE=3MB,
	MAXSIZE=UNLIMITED,
	FILEGROWTH=5MB
),
FILEGROUP fg2 DEFAULT( --����һ���µ��ļ���fg2,default��ʾ�κδ����µ����ݿ���󶼽������������
	NAME='test0402',
	FILENAME='e:\test0402.ndf',
	SIZE=1MB,
	MAXSIZE=UNLIMITED,
	FILEGROWTH=1mb
)
LOG ON(
	NAME = 'test02_log',
	FILENAME='e:\test02_log.ldf',
	SIZE=504KB,
	MAXSIZE=100MB,
	FILEGROWTH=10%
)

DROP DATABASE test4

----------------------------------------------------------------------------------------------
--�������ݿ��û�����

SELECT user_access_desc,* FROM  sys.databases WHERE name = 'test'

ALTER DATABASE test
SET SINGLE_USER | RESTRICTED_USER | MULTI_USER
WITH ROLLBACK  AFTER  INTEGER [seconds] | ROLLBACK IMMEDIATE | NO_WAIT 

/*
single_user,���û�ģʽ��ֻ����һ���û�����,����ʹ����ֹѡ����������޸ģ�ֱ�����������û������ݿ��жϿ�
����
resticted_user : ֻ��sysadmin,dbcreator��dbowner��ɫ�ĳ�Ա���Է������ݿ�
multi_user : �����ݿ���Ȩ�� �û����������

rollback after integer ָ���򿪵����ݿ�������ָһ��������ع�
rollback immediate �����ع��򿪵�����
no_wait �������������ɽ��������ִ��ʧ�ܣ�Ϊ�˿��Գɹ�ִ�У�ʹ�����ѡ����Ҫ���ݿ���û�д򿪵�����

����Ӧ�ó�����δ��ɵĽ��̵ķ����������ַ�ʽȡ���򿪵�������ܻ���Ӧ�ó������������⣬Ҫ��ס�����Ҫ������
Ҫ�������ڲ����û���������ڼ䳢�Ըı��û�����ģʽ��
*/

--���ݿ����
--��Ҫ�����ݿ��е�master�£��õ�ģʽҲ����
ALTER DATABASE test4
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE

ALTER DATABASE test4
MODIFY NAME = new_test4

ALTER DATABASE new_test4
SET MULTI_USER

--ɾ�����ݿ�

ALTER DATABASE new_test4
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE

DROP DATABASE new_test4

--�������ݿ�(ɾ�������������ݿ��ļ�)

ALTER DATABASE new_test4
SET SINGLE_USER	
WITH ROLLBACK IMMEDIATE

EXEC sp_detach_db 'new_test4','false' --true ��ʾ�������ݿ�֮ǰ�������ͳ����Ϣ

--�������ݿ�

--����ԭ�������ݿ⣬�����µ����ݿ�����
CREATE DATABASE new_test5
ON(FILENAME='e:\test4.mdf')--�ļ�·��
FOR ATTACH /*attach ָ��ʹ���ڷ�������ݿ���ʹ�õ�����ԭʼ�ļ����������ݿ⣬��ָ��attach_rebuild_log,������
����־�ļ�������ʱ��sqlserver���ؽ�������־�ļ�*/
