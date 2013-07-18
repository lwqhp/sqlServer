


数据库对象

--对象
select * from sys.databases

/*数据库备份相关对象*/
--每当对数据库做备份时，sqlserver往msdb.dbo.backupset表中插入一行记录
select * from msdb.dbo.backupset

--数据库备份文件信息
select * from  msdb.dbo.backupfile

--媒体集
select * from  msdb.dbo.backupmediaset

--里面的记录表明某个媒体集编号包含多少个物理文件，每一行又称为媒体簇
select * from  msdb.dbo.backupmediafamily
/*
backup_set_id：对数据库的每次备份都有唯一的一个编号，即为备份集编号

media_set_id：为备份媒体集编号，此为一个逻辑名称，对三个物理文件的抽象的称谓，如果是把多次的备份同时放入一个物理文件中，那备份媒体集编号是不变的

last_family_number：备份放入多少个物理文件中的
*/

select * from msdb..backupset

select * from msdb..backupfile