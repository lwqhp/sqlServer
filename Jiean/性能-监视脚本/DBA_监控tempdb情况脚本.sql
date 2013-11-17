DBCC showfilestats
--query 1
--�������������ռ�����ĻỰ��Ϣ
SELECT 'Tempdb' AS DB,GETDATE() AS TIME,SUM(user_object_reserved_page_count)*8 AS user_objects_kb,SUM(internal_object_reserved_page_count)*8 AS internal_objects_kb,
SUM(version_store_reserved_page_count)*8 AS version_store_kb,SUM(unallocated_extent_page_count)*8 AS freespace_kb
FROM sys.dm_db_file_space_usage WHERE database_id=2

--query 2
--���������ͼ�ܹ���ӳ��ʱtempdb �ռ���������
SELECT t1.session_id,t1.internal_objects_alloc_page_count,
t1.user_objects_alloc_page_count,t1.internal_objects_dealloc_page_count,t1.user_objects_dealloc_page_count,
t3.*
FROM sys.dm_db_session_space_usage t1,
--��ӳÿ���Ự�ۼƿռ�����
sys.dm_exec_sessions AS t3
--ÿ���Ự����Ϣ
WHERE t1.session_id=t3.session_id
AND (t1.internal_objects_alloc_page_count>0 OR
t1.user_objects_alloc_page_count>0 OR 
t1.internal_objects_dealloc_page_count>0 OR
t1.user_objects_dealloc_page_count>0)

--query 3
--�����������в������ռ�����ĻỰ�������е����
SELECT t1.session_id,st.text
FROM sys.dm_db_session_space_usage AS t1,
sys.dm_exec_requests AS t4
CROSS APPLY sys.dm_exec_sql_text(t4.sql_handle) AS st
WHERE t1.session_id=t4.session_id
AND t1.session_id>50
AND (t1.internal_objects_alloc_page_count>0 OR
t1.user_objects_alloc_page_count>0 OR
t1.internal_objects_dealloc_page_count>0 OR
t1.user_objects_dealloc_page_count>0)
