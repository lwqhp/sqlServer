

--�ڴ�ģ�������
/*
һ��SqlServer �ṩ���ڴ���ڽӿ�

1,Min Server Memory(MB) sp_configure����
����sqlserver ����С�ڴ�ֵ������һ���߼������������sqlserver total server memory�Ĵ�С�����������Ƿ��������ڴ�
���ǻ����ļ�ʱ�ڣ�����window�����ģ��������ֵ���ܱ�֤sqlserverʹ�õ���С�����ڴ�����

��sqlserver�ĵ�ַ�ռ����������ֵ�Ժ󣬾Ͳ�����С�����ֵ��������sqlserver�����������С�ڴ�ֵ��

2��Max Server Memory(MB) sp_configure ����
����sqlserver ������ڴ�ֵ��ͬ������Ҳ��һ���߼��������sqlserver total server memory�Ĵ�С�����������Ƿ��������ڴ�
���ǻ����ļ�ʱ�ڣ�����window�����ġ�

����趨ֻ�ܿ���һ����sqlserver���ڴ�ʹ������

3��Set working Set Size (sp_configure ����)
sqlServer��ִ�д���ͨ������һ��windows��������ͼ��sqlserver�������ڴ���ʹ�õ��ڴ����̶��������������ڵ�windows�汾
�Ѿ�������������������и����á�

4��AWE enabled (sp_configure ����)
��sqlserver������AWE���������ڴ棬��ͻ��32λwindows��2GB�û�Ѱַ�ռ䡣����slqserver2012�汾�У�32λ��sqlserver��
ȡ��������ܡ�

5��Lock pages in memory(��ҵ����Զ�����)
������ص�������һ��������ȷ��sqlserver�������ڴ���������Ҳ��ʮ�ֿɿ���

�����ڴ����ģʽ
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
*/