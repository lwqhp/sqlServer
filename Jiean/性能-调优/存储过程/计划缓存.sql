

--�ƻ�����
/*
�����ǳ���declare ,ÿһ����䶼������һ���ƻ����档

�洢������ִ�е���ÿһ����������һ�������ļƻ����棬���������е�ʱ�򣬾ͻ����á�

������֧��Ӱ��ƻ����á����Ƕ����ġ�
*/


--��ƻ�����
SELECT  TOP 100
         qs.execution_count,
         DatabaseName = DB_NAME(qp.dbid),
         ObjectName = OBJECT_NAME(qp.objectid,qp.dbid),
         StatementDefinition =
                SUBSTRING (
                        st.text,
                        (
                                qs.statement_start_offset / 2
                        ) + 1,
                 (
                                       (
                                               CASE qs.statement_end_offset
                         WHEN -1 THEN DATALENGTH(st.text)
                         ELSE qs.statement_end_offset
                                               END - qs.statement_start_offset
                                       ) / 2
                                ) + 1
                ),
         query_plan,
         st.text, total_elapsed_time
 FROM    sys.dm_exec_query_stats AS qs
         CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS st
         CROSS APPLY sys.dm_exec_query_plan (qs.plan_handle) qp
 WHERE
     st.encrypted = 0
 ORDER BY qs.execution_count DESC