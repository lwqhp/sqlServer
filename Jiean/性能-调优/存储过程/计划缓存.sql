

--计划缓存
/*
本质是除了declare ,每一条语句都会生成一个计划缓存。

存储过程里执行到的每一步都会生成一个单独的计划缓存，当缓存中有的时候，就会重用。

条件分支不影响计划重用。都是独立的。
*/


--查计划缓存
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