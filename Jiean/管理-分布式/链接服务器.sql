

--���ӷ�����
/*
��ƽ̨���ݷ�����ͨ��OLEDB ���ʽӿ�����Զ�̵�����Դ��oledb ��΢�������������ṩ�����ֲ�ͬ������Դ��һ��
�Է��� ��һ���������ģ��COM�ӡ�Ϊ�˽�����sqlServerʵ������һ����Դ�ķ��ʣ���Ҫѡ���ʵ���oledb���ʽӿڡ�

������˵�����ӷ������ǽ�����Զ������Դ�����ӵ�һ��;�������������������ӷ�������oleDB��������ִ�зֲ�ʽ
��ѯ���������ݣ�����Զ������Դ��ִ�в�����
*/

--��������

EXEC sp_addlinkedserver @server='Joerod\node2',@srvproduct='SQL Server'

--�޸����ӷ���������
EXEC sys.sp_serveroption @server = 'Joerod\node2', -- sysname
    @optname = 'query timeout', -- varchar(35)
    @optvalue = N'60' -- nvarchar(128)

--�鿴���ӷ�������Ϣ
SELECT * FROM sys.servers WHERE is_linked=1

--ɾ��
EXEC sp_dropserver @server='Joerod\node2',
@droplogins='droplogins' --ɾ�����ӷ�����ǰҪɾ����¼��ӳ��

--�������ӷ�������¼��
/*
�������ӷ�������ִ�зֲ�ʽ��ѯʱ��sqlserver�Ὣ���ص�¼��ƾ��ӳ�䵽���ӷ�����������Զ������Դ�İ�ȫ�ԣ�ƾ
�ݿ��ܻᱻ���ܻ��Ǿܾ���
*/

--��ʾ������½��ӳ��
EXEC sp_addlinkedsrvlogin @rmtsrvname='joeprod\node2',
@useself='false',--ʹ��Զ�̷���������
@locallogin=NULL,--���б���sqlserver���ӵĵ����������䵽test��¼����
@rmtuser = 'test',--������û�ִ��Զ�̷������ϵĲ�ѯ
@rmtpassword='test1'

--�鿴���ӵ�¼��
SELECT * FROM sys.linked_logins	a
INNER JOIN sys.servers b ON a.server_id = b.servier_id
LEFT JOIN sys.server_principals c ON c.principal_id = a.local_principal_id
WHERE b.is_lined=1

--ɾ�����ӷ�����������
EXEC sp_droplinkedsrvlogin @rmtsrvname='joeprod\node2',@locallogin=NULL

--�����ֲ�ʽ��ѯ------------------------------------------------------------------------------
/*
OpenQuery ����ͨ�������Դ��ݲ�ѯ��ʽ������ѯ���ӷ����������ݲ�ѯ��Զ�̷�������������ִ�У����ҽ��������
�����õĲ�ѯ��
*/
SELECT * FROM OPENQUERY([joeprod],'select * from master.sys.dm_os_erformance_counters')

--openrowset����һ��������Դ����ʱ�����ӣ�û��ʹ�ü��е����ӷ��������Ӳ�ѯԶ������Դ
SELECT * FROM OPENROWSET('oledb�ӿڱ�ʶ��','serverName','username','pwd','t-sql')

--���ļ��ж�ȡ����
SELECT * FROM OPENROWSET(BULK 'c:\a.txt' --�����ļ�
,FORMATFILE='c:\b.txt' --���ݸ�ʽ�ļ�
,FIRSTROW=1 --��ʼ������к�
,MAXERRORS=5 --�������������
,ERRORFILE='c:\c.txt'--���汻�ܾ��еĴ����ļ�
,SINGLE_CLOB --��ascii�ı��ĸ�ʽ��������
) AS contacttype