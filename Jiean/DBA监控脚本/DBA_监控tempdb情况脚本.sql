DBCC showfilestats
--query 1
--返回所有做过空间申请的会话信息
SELECT 'Tempdb' AS DB,GETDATE() AS TIME,SUM(user_object_reserved_page_count)*8 AS user_objects_kb,SUM(internal_object_reserved_page_count)*8 AS internal_objects_kb,
SUM(version_store_reserved_page_count)*8 AS version_store_kb,SUM(unallocated_extent_page_count)*8 AS freespace_kb
FROM sys.dm_db_file_space_usage WHERE database_id=2

--query 2
--这个管理视图能够反映当时tempdb 空间的总体分配
SELECT t1.session_id,t1.internal_objects_alloc_page_count,
t1.user_objects_alloc_page_count,t1.internal_objects_dealloc_page_count,t1.user_objects_dealloc_page_count,
t3.*
FROM sys.dm_db_session_space_usage t1,
--反映每个会话累计空间申请
sys.dm_exec_sessions AS t3
--每个会话的信息
WHERE t1.session_id=t3.session_id
AND (t1.internal_objects_alloc_page_count>0 OR
t1.user_objects_alloc_page_count>0 OR 
t1.internal_objects_dealloc_page_count>0 OR
t1.user_objects_dealloc_page_count>0)

--query 3
--返回正在运行并做过空间申请的会话正在运行的语句
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
