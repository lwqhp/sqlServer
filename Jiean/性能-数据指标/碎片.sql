

--��Ƭ
/*
��Ƭ�ڱ��е����ݱ��޸�ʱ��������������߸��±��е�����ʱ����Ķ�Ӧ�������޸ģ�������������޸Ĳ���������ͬ
һ��ҳ���У����ܵ�������Ҷ��ҳ��ָһ���µ�Ҷ��ҳ�潫������԰���ԭ��ҳ��Ĳ��ݣ�����ά�����������е���
��˳����Ȼ��Ҷ��ҳ��ά��ԭʼҳ�����е��߼�˳�򣬵�������µ�ҳ��ͨ���ڴ����ϲ���ԭ��ҳ�����ڡ�
*/

SELECT * FROM sys.dm_db_index_physical_stats

SELECT * FROM sys.dm_db_index_usage_stats

--�������ݿ���ƽ����Ƭ����30�����ж���
SELECT * FROM sys.dm_db_index_physical_stats(db_id('test'),NULL,NULL,NULL,'Limited')
WHERE avg_fragmentation_in_percent>30
ORDER BY OBJECT_NAME(OBJECT_ID)
/*
avg_fragmentation_in_percent  ��ʾ �ۼ�������Ǿۼ��������߼���Ƭ������������Ҷ������ҳ�İٷֱȣ����ڶ���
˵����ʾ������������Ƭ
*/

--����ָ�����ݿ⣬����������Ƭ
SELECT * FROM sys.dm_db_index_physical_stats(DB_ID('test'),OBJECT_ID('tb'),2,NULL,'Limited')

--������ʹ�����
/*
���ݿ��д������õ�������Ҫ�������ݿ��д���ܣ��ڼ���select ��ѯ��ͬʱ���������������ݵ��޸ģ�����ƽ���ȡ
���������ؾ����������������Ĵ��ۺ�����

����ͨ����ͼsys.dm_db_index_usage_state ȷ��δʹ�õ����������᷵���й��������ң����裬���»���ҵĴ���
��ͳ����Ϣ��Ҳ�����������������ʱ��
*/