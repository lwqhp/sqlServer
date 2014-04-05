SELECT TOP 20
        DB_NAME() AS DatabaseName ,
        '[' + SCHEMA_NAME(o.Schema_ID) + ']' + '.' + '['
        + OBJECT_NAME(s.[object_id]) + ']' AS TableName ,
        i.name AS IndexName ,
        i.type AS IndexType ,
        ( s.user_updates ) AS update_usage ,
        ( s.user_seeks + s.user_scans + s.user_lookups ) AS retrieval_usage ,
        ( s.user_updates ) - ( s.user_seeks + user_scans + s.user_lookups ) AS maintenance_cost ,
        s.system_seeks + s.system_scans + s.system_lookups AS system_usage ,
        s.last_user_seek ,
        s.last_user_scan ,
        s.last_user_lookup
FROM    sys.dm_db_index_usage_stats s
        INNER JOIN sys.indexes i ON s.[object_id] = i.[object_id]
                                    AND s.index_id = i.index_id
        INNER JOIN sys.objects o ON i.object_id = O.object_id
WHERE   s.database_id = DB_ID('{0}')
        AND i.name IS NOT NULL
        AND OBJECTPROPERTY(s.[object_id], 'IsMsShipped') = 0
        AND ( s.user_seeks + s.user_scans + s.user_lookups ) > 0
ORDER BY maintenance_cost DESC
