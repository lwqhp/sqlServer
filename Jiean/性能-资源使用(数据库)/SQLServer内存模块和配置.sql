

--�ڴ�ģ�������
/*
һ���ڴ����ģʽ
sqlserver ���ݲ�ͬ�������ֳ���ͬ��ģ�飬��Բ�ͬ���ڴ�ģ����ò�ͬ�Ĵ���ʽ��

a)Database Cache:�������ҳ�Ļ�����������һ����Reserve ��Commit �Ĵ洢��������databaseCahce�У�Ҳ����Щϸ�֣�
����С��8Kb�����ݣ�ͳ�Ʒ���һ��8KB��ҳ�棬���з���Buffer Pool�飬�����ڴ���8KB�����ݣ�������multi-page���У�

���û��޸���ĳ��ҳ���ϵ�����ʱ��sqlserver�����ڴ��н����ҳ���޸ģ����ǲ������̽����ҳ��д��Ӳ�̣����ǵȵ���
���checkpoint��lazy write��ʱ���д���

b)Consumer�����������sqlserver����������������񣬱���:
	connection���ӻ�������generalԪ���ݴ�������Query Plan:���ʹ洢���̵�ִ�мƻ�����

c)�߳�����sqlserver��Ϊ�����ڵ�ÿ���̷߳���0.5MB���ڴ棬�Դ���̵߳����ݽṹ�������Ϣ��

d)����һ�����ǵ�������������ڴ棬��Щ�ڴ�sqlserv�ǹܲ����ģ�������Ϊһ�����̣�windows�ܹ�֪��sqlserver�����
�����ڴ棬����Ҳ�ܼ�����һ���ݵ��ڴ�ʹ�á�


------------------------------------------------------------------------------------------------------
����SqlServer �ṩ���ڴ���ڽӿ�

1,Min Server Memory(MB) sp_configure����
����sqlserver ����С�ڴ�ֵ������һ���߼������������sqlserver total server memory�Ĵ�С�����������Ƿ��������ڴ�
���ǻ����ļ�ʱ�ڣ�����window�����ģ��������ֵ���ܱ�֤sqlserverʹ�õ���С�����ڴ�����

��sqlserver�ĵ�ַ�ռ����������ֵ�Ժ󣬾Ͳ�����С�����ֵ��������sqlserver�����������С�ڴ�ֵ��

exec sp_configure 'show advanced option','1'--ʹ��sp_configure�洢������Ӱ��/��Ŷ��ʾ�߼�ѡ��
exec sp_configure 'min server memory(MB)'��100
ReConfigure with override --����sp_configure�����ã�Ĭ���ǲ�ʵʱ���°����ڴ�����ֵ��ϵͳĿ¼������ovverideǿ�Ƹ���

2��Max Server Memory(MB) sp_configure ����
����sqlserver ������ڴ�ֵ��ͬ������Ҳ��һ���߼��������sqlserver total server memory�Ĵ�С�����������Ƿ��������ڴ�
���ǻ����ļ�ʱ�ڣ�����window�����ġ�

����趨ֻ�ܿ���һ����sqlserver���ڴ�ʹ������

exec sp_configure 'max server memory(MB)'

3��Set working Set Size (sp_configure ����)
sqlServer��ִ�д���ͨ������һ��windows��������ͼ��sqlserver�������ڴ���ʹ�õ��ڴ����̶��������������ڵ�windows�汾
�Ѿ�������������������и����á�

4��AWE enabled (sp_configure ����)
��sqlserver������AWE���������ڴ棬��ͻ��32λwindows��2GB�û�Ѱַ�ռ䡣����slqserver2012�汾�У�32λ��sqlserver��
ȡ��������ܡ�

5��Lock pages in memory(��ҵ����Զ�����)
������ص�������һ��������ȷ��sqlserver�������ڴ���������Ҳ��ʮ�ֿɿ���

6����Ե����õ�32λ���������Ż�
1)����3GB���̿ռ�
�ڱ�׼��32λ��ַ����ӳ�����4GB�ڴ�Ѱַ�ռ䣬��Ĭ�ϸ�λ2GB������ϵͳ��������λ��2GB������Ӧ�ó���
��32λϵͳ��boot.ini�ļ���ָ��/3GB���أ�����ϵͳֻ����1GB�ĵ�ַ�ռ䣬Ӧ�ó�����Է��ʵ�3GB.
[boot loader]
timeout=30
default=multi(0)disk(0)rdisk(0)partition(1)\WINNT
[operation systems]
multi(0)disk(0)rdisk(0)partition(1)\WINNT="Microsoft windows server 2008 Advanced Server"/fastdetect /3GB

3)��32λsqlserver��ʹ��4GB���ϵ��ڴ�
[boot loader]
timeout=30
default=multi(0)disk(0)rdisk(0)partition(1)\WINNT
[operation systems]
multi(0)disk(0)rdisk(0)partition(1)\WINNT="Microsoft windows server 2008 Advanced Server"/fastdetect /PAE

���ݿ�������5GB�ķ���
sp_configure 'show advanced options',1
reconfigure
go
sp_configure 'awe enabled',1
reconfigure
go
sp_configure 'max server memory',5120
reconfigure
go

sqlserver 2008��AWE�ڴ汻����ʱ����̬�����ڴ�ռ��С�����ԣ�ʹ��AWE�ڴ�ʱ��������sqlserver�ķ���������ڴ�
���ò�������ר�õ�sqlserver�����Ϸ���������ڴ��������Ϊ�������ڴ�-200MB,��Ϊ����ϵͳ��������Ҫ�Ĺ���/Ӧ
�ó������㹻�������ڴ�
������ͬ���������ж��slqserver2008ʵ��ʱ������ȷ��
1��ÿ��ʹ��awe�ڴ��ʵ���������˷���������ڴ�
2�����÷���������ڴ�ʱ�����뿼��sqlserver��������Ҫ�ķǻ�����ڴ�
3������ʵ�� �ķ���������ڴ���ܺ�Ӧ��С�ڼ���������ڴ��������

���ʹ��/3GB���Ժ�AEW,��ôһ��sqlserverʵ���������������16GB����չ�ڴ棬������Ϊwindowserver����ϵͳ��
�ڲ���ƣ�ʹ��/3GB���ؽ����̿ռ��е�ϵͳ�ռ�����Ϊ1GB,����window Server�������16GB�������ڴ档

*/