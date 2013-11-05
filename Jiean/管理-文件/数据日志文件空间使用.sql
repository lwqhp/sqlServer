

--������־�ļ��ռ�ʹ��
/*

ֻ�Ǵ��Ե��˽������ļ�����־�ļ���ʹ�ÿռ�
*/
--��Ҫ�����ͨ���ݿ⣬���ܱ�֤ʵʱ���¿ռ�ʹ��ͳ����Ϣ����tempdb���ݿ���洢��һЩϵͳ��ʱ���ݶ����޷�ͳ��
sp_spaceused 

/*
unallocated space��δ����ʹ�ÿռ�
reserved:���ù��������ͷŵĿռ�
data:���������ļ������Ǳ��������ռ�õĿռ�
unused : û���ù��Ŀռ�

�ؽ��ۼ������������ͷ�reserved�ռ�
*/

--sqlServer�Դ�����


--��ϸͳ�ƿռ�ʹ�����

--����ͳ��
DBCC showfilestats
/*
���������ֱ�Ӵ�GAM��SGAM������ϵͳ����ҳ�������ȡ��������Ϣ��ֱ��������ݿ��ļ����ж������ѱ����䡣
�ܹ�����׼ȷ�ؼ����һ�����ݿ������ļ�������������ʹ�ù���������Ŀ��
*/

--��ҳͳ��
SELECT 
o.name,
SUM(p.reserved_page_count) AS reserved_page_count,
SUM(p.used_page_count) AS used_page_count,
SUM(CASE WHEN p.index_id<2 THEN p.in_row_data_page_count+p.lob_used_page_count+p.row_overflow_used_page_count
	ELSE p.lob_used_page_count+p.row_overflow_used_page_count END )AS Datpages,
SUM(CASE WHEN p.index_id<2 THEN row_count ELSE 0 end) AS RowCounts 
 FROM sys.dm_db_partition_stats p 
INNER JOIN sys.objects o ON p.object_id = o.object_id
GROUP BY o.name

--�˽�ÿ��ҳ������ʹ���������Ƭ�̶�
DBCC SHOWCONTIG
SELECT * FROM sys.dm_db_index_physical_stats()


--��־�ļ���ʹ����� 
DBCC SQLPERF(LOGSPACE)

--TempDB�Ŀռ�ʹ��---------------------------
/*
temdb����Ķ���
1���û�����
���û���ʽ���������û��Ự�д��������������û�����(�洢���̣����������û����庯��)�д�������Щ������� ��
	�û�����ı������
	ϵͳ�������
	ȫ����ʱ�������
	�ֲ���ʱ�������
	table����
	��ֵ�����з��صı�

2���ڲ�����
 sqlserver���ڴ���sqlserver���������Ķ��󣬰�����
	�����α����ѻ������Լ���ʱ���Ͷ���(LOB)�洢�Ĺ�����
	���ڹ�ϣ���ӻ��ϣ�ۺϲ����Ĺ����ļ�
	���ڴ������������������Ȳ���(���ָ����sort_in_tempdb)���м�������������ĳЩgroup by ,order by ��union ��ѯ���м���������
	
ÿ���ڲ���������ʹ��9ҳ��һ��IAMҳ��8��ҳ������

3���汾�洢��
�汾�洢��������ҳ�ļ��ϣ�������֧��ʹ���а汾���ƵĹ�������������У���Ҫ����֧�ֿ���������뼶���Լ�һЩ
����������ݿⲢ���ȵ��¹��ܡ�
*/

--�������������ռ�����ĻỰ��Ϣ
SELECT * FROM sys.dm_db_file_space_usage

--tempdb�ռ���������
SELECT * FROM sys.dm_db_session_space_usage t1,sys.dm_exec_sessions t3
WHERE t1.session_id = t3.session_id


--�����������в��������ռ�����ĻỰ�������е����
SELECT * FROM sys.dm_db_session_space_usage t1,
sys.dm_exec_requests t4
CROSS APPLY sys.dm_exec_sql_text(t4.sql_handle) st
WHERE t1.session_id = t4.session_id
AND t1.session_id>50

/*
������־ʹ��
1������tempdb���Զ�����
2��ģ����������Ĳ�ѯ��������ͬʱ����tempdb �ռ�ʹ��
3��ģ��ִ��һЩϵͳά��������������������������ͬʱ����tempdb�ռ�
4��ʹ��2,3��tempdb�ռ�ʹ��ֵ ��Ԥ���ܵĹ��������£���ʹ�ö��ٿռ䣬����Լƻ��Ĳ����ȵ��� ��ֵ�����磬���һ��
�����ʹ��10GB��tempdb�ռ䣬�������������������ܻ���4������������ͬʱ���У���Ҫ����Ԥ��40GB�Ŀռ䡣
5������4�õ���ֵ������tempdb�����������µĳ�ʼ��С��ͬʱҲ�����Զ�������
*/

/*
������ݿ��ļ����������Ƿ��ڲ�ͬ��Ӳ���ϣ��Դﵽ��ɢi/0���ص�Ŀ�ģ���Ҫ�������ļ����뱣֤ͬһ���ļ��������������
�ļ����л���һ����С�Ŀ��пռ䣨��������Щ�ļ�һ����Ϳ��Եģ������ĳ��Ӳ���ϵ������ļ��Ѿ���д���ˣ�sqlserver��
�����������Ӳ����д�ˣ�������пռ���ԱȽ��٣�sqlserverд����ĿҲ����Լ��١�
*/