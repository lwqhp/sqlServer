SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SELECT TOP 30
        ROUND(s.avg_total_user_cost * s.avg_user_impact * ( s.user_seeks
                                                            + s.user_scans ),
              0) AS [Total Cost] ,
        s.avg_total_user_cost * ( s.avg_user_impact / 100.0 ) * ( s.user_seeks
                                                              + s.user_scans ) AS Improvement_Measure ,
        DB_NAME() AS DatabaseName ,
        d.[statement] AS [Table Name] ,
        equality_columns ,
        inequality_columns ,
        included_columns
FROM    sys.dm_db_missing_index_groups g
        INNER JOIN sys.dm_db_missing_index_group_stats s ON s.group_handle = g.index_group_handle
        INNER JOIN sys.dm_db_missing_index_details d ON d.index_handle = g.index_handle
WHERE   s.avg_total_user_cost * ( s.avg_user_impact / 100.0 ) * ( s.user_seeks
                                                              + s.user_scans ) > 10
ORDER BY [Total Cost] DESC ,
        s.avg_total_user_cost * s.avg_user_impact * ( s.user_seeks
                                                      + s.user_scans ) DESC

--可减少的成本*可下降成本百分比*使用的次数=总的可以减少的成本