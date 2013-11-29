

/*
	查询数据库表使用现状
	sp_spaceUsed [[ @objname = ] 'objname' ][,[ @updateusage = ] 'updateusage' ]
	显示行数、保留的磁盘空间以及当前数据库中的表、索引视图或 SQL Server 2005 Service Broker 队列所使用的磁盘空间，或显示由整个数据库保留和使用的磁盘空间。

	exec sp_tablesInfo
*/

IF NOT EXISTS(SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[dbo].[sp_tablesInfo]') AND xtype = 'P')
 Create Procedure	[dbo].[sp_tablesinfo]
AS

Declare	@id	Integer,@maxid	Integer,@tname	Varchar(50)

Create Table #tabName(
id	Int IDENTITY(1,1) Not Null,
tname	Varchar(50) Null)

Create Table #tabmInfo(
tname	 	Varchar(50) Not Null Primary Key,
trows	 	Varchar(11) Null,
reserved 	Varchar(18) Null,
data		Varchar(18) Null,
index_size 	Varchar(18) Null,
unused		Varchar(18) Null)

Create Table #tablInfo(
name		Varchar(50) Not Null Primary Key,
rows		BigInt ,
reserved	BigInt ,
data		BigInt ,
index_size	BigInt ,
unused		BigInt ,
unit		Varchar(4) Default 'KB')


Insert Into #tabName(tname) 
Select U.name + '.' + T.name 
From sysobjects T, sysusers U
Where T.uid = U.uid And T.type = 'U'

Select @id = 1,@maxid = Max(id) From #tabName

While @id <= @maxid
Begin
    Select @tname = tname From #tabName Where id =@id

    Insert Into #tabmInfo Exec sp_spaceused @tname

    Set @id = @id + 1
End

Insert Into #tablInfo(name,rows,reserved,data,index_size,unused)
Select M.tname,Convert(BigInt,M.trows),Convert(BigInt,Left(M.reserved,Len(M.reserved) - 3)),Convert(BigInt,Left(M.data,Len(M.data) - 3)),Convert(BigInt,Left(M.index_size,Len(M.index_size) - 3)),Convert(BigInt,Left(M.unused,Len(M.unused) - 3))
From   #tabmInfo M

Select * From #tablInfo Order By reserved DESC

SELECT
	schema_name = SCH.name,
	table_name = TB.name,
	column_name = C.name,
	type_name = T.name,
	column_length_byte = C.max_length,
	column_precision = C.precision,
	column_scale = C.scale,
	column_is_nullable = C.is_nullable,
	column_is_identity = C.is_identity,
	column_is_computed = C.is_computed
FROM sys.tables TB
	INNER JOIN sys.schemas SCH
		ON TB.schema_id = SCH.schema_id
	INNER JOIN sys.columns C
		ON TB.object_id = C.object_id
	INNER JOIN sys.types T
		ON C.user_type_id = T.user_type_id
WHERE TB.is_ms_shipped = 0       -- 此条件表示仅查询不是由内部 SQL Server 组件创建对象
ORDER BY schema_name, table_name, column_name


SELECT
	schema_name = SCH.name,
	view_name = V.name,
	column_name = C.name,
	type_name = T.name,
	column_length_byte = C.max_length,
	column_precision = C.precision,
	column_scale = C.scale,
	column_is_nullable = C.is_nullable,
	column_is_identity = C.is_identity,
	column_is_computed = C.is_computed
FROM sys.views V
	INNER JOIN sys.schemas SCH
		ON V.schema_id = SCH.schema_id
	INNER JOIN sys.columns C
		ON V.object_id = C.object_id
	INNER JOIN sys.types T
		ON C.user_type_id = T.user_type_id
WHERE V.is_ms_shipped = 0       -- 此条件表示仅查询不是由内部 SQL Server 组件创建对象
ORDER BY schema_name, view_name, column_name


