SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
select 
db_name(),quotename(SCHEMA_NAME(c.schema_id))+'.'+quotename(OBJECT_NAME(a.object_id)),
b.name,b.type,a.user_updates,a.system_seeks+a.system_scans+a.system_lookups AS [System_usage]
 from sys.dm_db_index_usage_stats a
inner join sys.indexes b on a.object_id = b.object_id and a.index_id = b.index_id
inner join sys.objects c on b.object_id = c.object_id
where a.database_id = db_id()
	and b.index_id>=1
	and a.user_seeks =0
	and a.user_scans = 0
	and a.user_lookups = 0
ORDER BY a.user_updates DESC