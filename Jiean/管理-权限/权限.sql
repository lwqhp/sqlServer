������ɫ���û���Ȩ�� 
/*--ʾ��˵�� ʾ�������ݿ�pubs�д���һ��ӵ�б�jobs������Ȩ�ޡ�
ӵ�б�titles��SELECTȨ�޵Ľ�ɫr_test ��󴴽���һ����¼l_test��
Ȼ�������ݿ�pubs��Ϊ��¼l_test�������û��˻�u_test ͬʱ���û��˻�u_test��ӵ���ɫr_test�У�
ʹ��ͨ��Ȩ�޼̳л�ȡ�����ɫr_testһ����Ȩ�� ���ʹ��DENY���ܾ����û��˻�u_test�Ա�titles��SELECTȨ�ޡ� 
���������Ĵ���ʹ��l_test��¼SQL Serverʵ������ֻ���б�jobs������Ȩ�ޡ� --*/ 
USE pubs 
--������ɫ 
r_test EXEC sp_addrole 'r_test' 
--���� r_test �� jobs �������Ȩ�� 
GRANT ALL ON jobs TO r_test 
--�����ɫ r_test �� titles ��� SELECT Ȩ�� 
GRANT SELECT ON titles TO r_test 
--��ӵ�¼ l_test,��������Ϊpwd,Ĭ�����ݿ�Ϊpubs 
EXEC sp_addlogin 'l_test','pwd','pubs' 
--Ϊ��¼ l_test �����ݿ� pubs ����Ӱ�ȫ�˻� u_test 
EXEC sp_grantdbaccess 'l_test','u_test' 
--��� u_test Ϊ��ɫ r_test �ĳ�Ա 
EXEC sp_addrolemember 'r_test','u_test' 
--�ܾ���ȫ�˻� u_test �� titles ��� SELECT Ȩ�� 
DENY SELECT ON titles TO u_test 
/*--������������,�� l_test ��¼,���Զ�jobs��������в���,���޷���titles���ѯ,
��Ȼ��ɫ r_test ��titles���selectȨ��,���Ѿ��ڰ�ȫ�˻�����ȷ�ܾ��˶�titles��selectȨ��,
����l_test��titles���selectȨ��--*/
 --�����ݿ� pubs ��ɾ����ȫ�˻� 
 EXEC sp_revokedbaccess 'u_test' 
 --ɾ����¼ 
 l_test EXEC sp_droplogin 'l_test' 
 --ɾ����ɫ 
 r_test EXEC sp_droprole 'r_test'