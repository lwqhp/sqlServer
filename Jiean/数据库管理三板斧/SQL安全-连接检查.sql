

--���Ӽ��
/*
���ô�ͳ�Ĳ��跽���������ò������ļ��

��ʼ:
�������ӣ���λ�п���ԭ��ķ�Χ
1���������ӣ��жϴ�����Ϣ�Ƿ�����������
2��ָ��Э�����ӣ��ж�Э���Ƿ�����ͨ��

��ԭ��
---------------��һ��-----------------------------------------
����Χwindow�¼����鿴�¼���־�Ƿ�ɾ�������ʲô����.

---------------�ڶ���--�������������õ�����----------------------------------------------
���û��ֹ��ص�����Э�飺
SqlServer���ù�����-->SqlServer�������ã��˿�����

ע���HKEY_LOCAL_MACHINE\SHOTWARE\Microsoft\Microsoft SqlServer\MSSQL.X\SMSQLServer
\SuperSocketNetLib�µĸ�����Ŀ�

---------------������--���������������Ƿ���Ч----------------------------------------------

a)ipconfig /all //�鿴����IP
b)netstart -an  //�鿴�˿��Ƿ�����
c)telnet ip��ַ �˿ں�  //ʹ��Զ�����Ӷ˿ڣ��鿴ip,�˿��Ƿ��������

d)���������Э�������Ϸ�������Ҳ���Բ鿴��־���鿴�����Ƿ�����Э��

�鿴sql��־��Դ��������
1,Shared Memory����������Ϣ��
Server local connection provider is ready to accept connection on [ \\.\pipe\SQLLocal\SQL2008 ].

2��Named Pipe����������Ϣ��
Server named pipe provider is ready to accept connection on [ \\.\pipe\MSSQL$SQL2008\sql\query ].

3��TCP/IP����������Ϣ�����Կ���SqlServerʵ�� ��������IP��ַ�Ͷ˿ںţ�
Server is listening on [ 'any' <ipv4> 52604]. //��������IP��ַ��52604�˿�
Server is listening on [ 127.0.0.1 <ipv4> 52605]. //����������52604�˿�

SqlServer Bowroer����
*/