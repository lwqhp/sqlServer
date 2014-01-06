/*
使用“变更数据捕获”（CDC）功能
SQL Server 2008提供了内建的方法变更数据捕获（Change Data Capture 即CDC）以实现异步跟踪用户表的数据修改，
而且这一功能拥有最小的性能开销。可以用于其他数据源的持续更新，例如将OLTP数据库中的数据变更迁移到数据仓库数据库。
*/
use master 
GO 
IF EXISTS (SELECT [name] FROM sys.databases WHERE name = 'TestDb2') 
    drop DATABASE TestDb2 
Go 
CREATE DATABASE TestDb2 
GO 
--查看是否启用CDC 
SELECT is_cdc_enabled FROM sys.databases WHERE name = 'TestDb2' 
USE TestDb2 
GO 
----启用当前数据库的CDC功能 
EXEC sys.sp_cdc_enable_db 
GO

SELECT is_cdc_enabled FROM sys.databases WHERE name = 'TestDb2' 
/* is_cdc_enabled 1 */ 
USE testDb2 
GO 
CREATE TABLE [dbo].[DepartDemo]( 
[DID] [int] IDENTITY(101,1) NOT NULL PRIMARY KEY, 
[DName] [nvarchar](200) NULL, 
[DCode] [nvarchar](500) NULL, 
[Manager] [nvarchar](50) NULL, 
[ParentID] [int] NOT NULL DEFAULT ((0)), 
[AddUser] [nvarchar](50) NULL, 
[AddTime] [datetime] NULL, 
[ModUser] [nvarchar](50) NULL, 
[ModTime] [datetime] NULL, 
[CurState] [smallint] NOT NULL DEFAULT ((0)),
[Remark] [nvarchar](500) NULL,
[F1] [int] NOT NULL DEFAULT ((0)),
[F2] [nvarchar](300) NULL
)
GO
/**********************************
需要启用SQL Server Agent服务，否则会报错，邀月注 SQLServerAgent is not currently running so it cannot be notified of this action.
***********************************/
/****** 捕获所有的行变更，只返回行的净变更，其他默认 *******/
EXEC sys.sp_cdc_enable_table
@source_schema = 'dbo',
@source_name = 'DepartDemo',
@role_name = NULL,
@capture_instance = NULL,
@supports_net_changes = 1,
@index_name = NULL,
@captured_column_list = NULL,
@filegroup_name = default
/*注意此时，SQL Server 自启动了两个job,一个捕获，一个清除，注意清除是默认凌晨２点，
清除72小时以上的数据。如果同一数据库的表中CDC已经启用，不会重建job。*/

--确认表已经被跟踪 
SELECT is_tracked_by_cdc FROM sys.tables 
WHERE name = 'DepartDemo' and schema_id = SCHEMA_ID('dbo')
/* is_tracked_by_cdc 1 */
--确认
EXEC sys.sp_cdc_help_change_data_capture 'dbo', 'DepartDemo'
/*
可以看到，SQL Server 增加了一个表[cdc].[dbo_DepartDemo_CT] 
相比源表多了个字段： 
[__$start_lsn] 
,[__$end_lsn] 
,[__$seqval] 
,[__$operation] 
,[__$update_mask] 
*/
--不建议直接查询该表，而应该使用下面的技巧：
INSERT [dbo].[DepartDemo] ([DName], [DCode], [Manager], [ParentID],
[AddUser], [AddTime], [ModUser], [ModTime], [CurState], [Remark], [F1], [F2])
VALUES (N'银监会', N'0', N'云中鹤', 0, N'DemoUser1',
CAST(0x00009DF7017B6F96 AS DateTime), N'', CAST(0x0000000000000000 AS DateTime),
1, N'监管汇率', 0, N'')

INSERT [dbo].[DepartDemo] ([DName], [DCode], [Manager], [ParentID],
[AddUser], [AddTime], [ModUser], [ModTime], [CurState], [Remark], [F1], [F2])
VALUES (N'统计局', N'0', N'神算子', 0, N'DemoUser2',
CAST(0x00009DF7017B6F96 AS DateTime), N'', CAST(0x0000000000000000 AS DateTime),
1, N'统计数据', 0, N'')
GO

UPDATE [dbo].[DepartDemo]
SET Manager='段正淳'
WHERE DID =101

DELETE [dbo].[DepartDemo]
WHERE DID = 102

--select * from [cdc].[dbo_DepartDemo_CT]
/*
要查询变更，我们需要借助大名鼎鼎的日志序列号（Log Sequence Numbers）即LSN
（http://msdn.microsoft.com/zh-cn/library/ms190411%28v=sql.100%29.aspx）来实现LSN级别的跟踪数据变更。 
下面示例中sys.fn_cdc_map_time_to_lsn（http://msdn.microsoft.com/zh-cn/library/bb500137%28v=sql.100%29.aspx）
用于LSN转换为时间。
*/



/******* 使用LSN 查看CDC记录 *********/

--http://msdn.microsoft.com/zh-cn/library/bb500137%28v=sql.100%29.aspx
SELECT sys.fn_cdc_map_time_to_lsn
( 'smallest greater than or equal' , '2012-04-09 16:09:30') as BeginLSN

/*
BeginLSN
0x0000002C000000AA0003
*/

SELECT sys.fn_cdc_map_time_to_lsn
( 'largest less than or equal' , '2012-04-09 23:59:59') as EndLSN

/*
EndLSN
0x0000002C000001C20005
*/

/**************查看所有CDC记录*************/
/************* 3w@live.cn 邀月***************/

DECLARE @FromLSN varbinary(10) =
sys.fn_cdc_map_time_to_lsn
( 'smallest greater than or equal' , '2012-04-09 16:09:30')

DECLARE @ToLSN varbinary(10) =
sys.fn_cdc_map_time_to_lsn
( 'largest less than or equal' , '2012-04-09 23:59:59')

SELECT
__$operation,
__$update_mask,
DID,
DName,
Manager
FROM [cdc].[fn_cdc_get_all_changes_dbo_DepartDemo]
(@FromLSN, @ToLSN, 'all')

/************查看所有更新*************************

__$operation __$update_mask DID DName Manager
2 0x1FFF 105 银监会 云中鹤
2 0x1FFF 106 统计局 神算子
1 0x1FFF 101 银监会 段正淳
1 0x1FFF 103 银监会 云中鹤
1 0x1FFF 104 统计局 神算子
1 0x1FFF 105 银监会 云中鹤
1 0x1FFF 106 统计局 神算子
2 0x1FFF 107 银监会 云中鹤
2 0x1FFF 108 统计局 神算子
4 0x0008 107 银监会 段正淳
1 0x1FFF 108 统计局 神算子
*/

/**************查看所有CDC记录*************/
/************* 3w@live.cn 邀月***************/
DECLARE @FromLSN varbinary(10) =
sys.fn_cdc_map_time_to_lsn
( 'smallest greater than or equal' , '2012-04-09 16:09:30')

DECLARE @ToLSN varbinary(10) =
sys.fn_cdc_map_time_to_lsn
( 'largest less than or equal' , '2012-04-09 23:59:59')

--解释一下Operation的具体含义
SELECT
CASE __$operation
WHEN 1 THEN 'DELETE'
WHEN 2 THEN 'INSERT'
WHEN 3 THEN 'Before UPDATE'
WHEN 4 THEN 'After UPDATE'
END Operation,
__$update_mask,
DID,
DName,
Manager
FROM [cdc].[fn_cdc_get_all_changes_dbo_DepartDemo]
(@FromLSN, @ToLSN, 'all update old')



/**************查看净更改（Net changes）CDC记录*************/

INSERT [dbo].[DepartDemo] ([DName], [DCode], [Manager], [ParentID],
[AddUser], [AddTime], [ModUser], [ModTime], [CurState], [Remark], [F1], [F2])
VALUES (N'药监局', N'0', N'蝶谷医仙', 0, N'DemoUser3',
CAST(0x00009DF7017B6F96 AS DateTime), N'', CAST(0x0000000000000000 AS DateTime),
1, N'制定药价', 0, N'')
GO

UPDATE [dbo].[DepartDemo]
SET Manager='胡青牛'
WHERE DID =109

DECLARE @FromLSN varbinary(10) =
sys.fn_cdc_map_time_to_lsn
( 'smallest greater than or equal' , '2012-04-09 16:09:30')

DECLARE @ToLSN varbinary(10) =
sys.fn_cdc_map_time_to_lsn
( 'largest less than or equal' , '2012-04-09 23:59:59')

SELECT
CASE __$operation
WHEN 1 THEN 'DELETE'
WHEN 2 THEN 'INSERT'
WHEN 3 THEN 'Before UPDATE'
WHEN 4 THEN 'After UPDATE'
WHEN 5 THEN 'MERGE'
END Operation,
__$update_mask,
DID,
DName,
Manager
FROM [cdc].[fn_cdc_get_net_changes_dbo_DepartDemo]
(@FromLSN, @ToLSN, 'all with mask')

/*
　我们还可以通过转换CDC更新掩码获得更为直观的结果，这里需要借助于另外两个函数sys.fn_cdc_is_bit_set
（http://msdn.microsoft.com/zh-cn/library/bb500241%28v=SQL.110%29.aspx）和
sys.fn_cdc_get_column_ordinal（http://msdn.microsoft.com/zh-cn/library/bb522549%28v=SQL.100%29.aspx）
*/



/************** 转换CDC更新掩码 *************/

UPDATE dbo.[DepartDemo]
SET [Manager] = '东方不败'
WHERE DID =107

UPDATE dbo.[DepartDemo]
SET ParentID = 109
WHERE DID =107

DECLARE @FromLSN varbinary(10) =
sys.fn_cdc_map_time_to_lsn
( 'smallest greater than or equal' , '2012-04-09 16:09:30')

DECLARE @ToLSN varbinary(10) =
sys.fn_cdc_map_time_to_lsn
( 'largest less than or equal' , '2012-04-09 23:59:59')

SELECT
sys.fn_cdc_is_bit_set (
sys.fn_cdc_get_column_ordinal (
'dbo_DepartDemo' , 'Manager' ),
__$update_mask) Manager_Updated,
sys.fn_cdc_is_bit_set (
sys.fn_cdc_get_column_ordinal (
'dbo_DepartDemo' , 'ParentID' ),
__$update_mask) ParentID_Updated,
DID,
Manager,
ParentID
FROM cdc.fn_cdc_get_all_changes_dbo_DepartDemo
(@FromLSN, @ToLSN, 'all')
WHERE __$operation = 4

/*
除了前面介绍的指定LSN边界的方法，SQL Server还提供了一系列的获取边界的方法：

sys.fn_cdc_get_max_lsn（http://msdn.microsoft.com/zh-cn/library/bb500304%28v=sql.100%29.aspx）

sys.fn_cdc_get_min_lsn（http://msdn.microsoft.com/zh-cn/library/bb510621%28v=sql.100%29.aspx）

sys.fn_cdc_increment_lsn（http://msdn.microsoft.com/zh-cn/library/bb510745%28v=sql.100%29.aspx）

sys.fn_cdc_decrement_lsn（http://msdn.microsoft.com/zh-cn/library/bb500246%28v=sql.100%29.aspx）
*/


/************** 获取LSN边界的其他方法 *************/ 

--获取最小边界
SELECT sys.fn_cdc_get_min_lsn ('dbo_DepartDemo') Min_LSN
--获取可用的最大边界
SELECT sys.fn_cdc_get_max_lsn () Max_LSN
--获取最大边界的下一个序号
SELECT sys.fn_cdc_increment_lsn (sys.fn_cdc_get_max_lsn())
New_Lower_Bound_LSN
--获取最大边界的前一个序号
SELECT sys.fn_cdc_decrement_lsn (sys.fn_cdc_get_max_lsn())
New_Lower_Bound_Minus_one_LSN
通过以下存储过程在数据库和表级禁用CDC

sys.sp_cdc_disable_table （http://msdn.microsoft.com/zh-cn/library/bb510702(v=sql.100).aspx）

sys.sp_cdc_disable_db（http://msdn.microsoft.com/zh-cn/library/bb522508(v=sql.100).aspx）注意，该命令同时也删除了CDC架构和相关的SQL代理作业。
/************** 在数据库和表级禁用CDC *************/
/************* 3w@live.cn 邀月 **************/
EXEC sys.sp_cdc_disable_table 'dbo', 'DepartDemo', 'all'
SELECT is_tracked_by_cdc FROM sys.tables
WHERE name = 'DepartDemo' and schema_id = SCHEMA_ID('dbo')
--当前数据库上禁用CDC
EXEC sys.sp_cdc_disable_db

 

四、使用“更改跟踪”以最小的磁盘开销跟踪净数据更改

　　CDC可以用来对数据库和数据仓库的持续数据变更进行异步数据跟踪，而SQL Server 2008中新增的“更改跟踪”却是一个同步进程，是DML操作本身（I/D/U）事务的一部分，它的最大优势是以最小的磁盘开销来侦测净行变更，它允许修改的数据以事务一致的形式表现，并提供了检测数据冲突的能力。它甚至可以根据外部传入的应用程序上下文，来完成更细颗粒度的更改处理，参看WITH CHANGE_TRACKING_CONTEXT （http://msdn.microsoft.com/zh-cn/library/bb895330%28v=sql.100%29.aspx）
/***使用“更改跟踪”以最小的磁盘开销跟踪净数据更改****/
/************* 3w@live.cn 邀月 **************/
IF EXISTS (SELECT [name] FROM sys.databases WHERE name = 'TestDb4')
  drop DATABASE TestDb4
Go CREATE DATABASE TestDb4
GO
--启用更新跟踪，36小时清理一次
ALTER DATABASE TestDb4 SET CHANGE_TRACKING = ON (CHANGE_RETENTION = 36 HOURS, AUTO_CLEANUP = ON)

　　注意，下一步是允许快照隔离，这是微软推祟的“最佳实践”，尽管这样行版本的生成会增加额外的空间使用，从而会增加总的I/O数量,但不使用快照会引发事务不一致的变更信息。

    ALTER DATABASE TestDb4
    SET ALLOW_SNAPSHOT_ISOLATION ON
    GO

    SELECT DB_NAME(database_id) 数据库名称,is_auto_cleanup_on,
    retention_period,retention_period_units_desc
    FROM sys.change_tracking_databases
    /*
    数据库名称 is_auto_cleanup_on retention_period retention_period_units_desc
    TestDb4 1 36 HOURS
    */

    USE TestDb4
    GO
    --创建测试表
    CREATE TABLE dbo.DepartDemo
    ([DID] [int] IDENTITY(101,1) NOT NULL PRIMARY KEY,
    [DName] [nvarchar](200) NULL,
    [Manager] [nvarchar](50) NULL,
    [ParentID] [int] NOT NULL DEFAULT ((0)),
    [CurState] [smallint] NOT NULL DEFAULT ((0)),
    )
    GO

    ----TRUNCATE table dbo.DepartDemo
    ----GO

    --启用表的列更新跟踪
    ALTER TABLE dbo.DepartDemo
    ENABLE CHANGE_TRACKING
    WITH (TRACK_COLUMNS_UPDATED = ON)

    --确认是否更新跟踪开启
    SELECT OBJECT_NAME(object_id) ObjNM,is_track_columns_updated_on
    FROM sys.change_tracking_tables

    /*
    ObjNM is_track_columns_updated_on
    DepartDemo 1
    */

    --增加测试数据
    INSERT dbo.DepartDemo
    (DName,ParentID)
    VALUES
    ('明教', 0),
    ('五行集', 101),
    ('少林派',0)

    SELECT * FROM dbo.DepartDemo

    --当前版本
    SELECT CHANGE_TRACKING_CURRENT_VERSION ()
    as 当前版本
    /*
    当前版本
    1
    */
    SELECT CHANGE_TRACKING_MIN_VALID_VERSION
    ( OBJECT_ID('dbo.DepartDemo') )as 最小可用版本

    /*
    最小可用版本
    0
    */

函数ChangeTable有两种用法来检测更改:
一、使用Changes关键字
二、使用Version关键字
/* 一、使用Changes关键字 */
SELECT DID,SYS_CHANGE_OPERATION, SYS_CHANGE_VERSION
FROM CHANGETABLE (CHANGES dbo.DepartDemo, 0) AS CT

邀月工作室
UPDATE dbo.DepartDemo SET Manager='张无忌' WHERE DID = 101
UPDATE dbo.DepartDemo SET [DName] = '五行旗' WHERE DID = 102
DELETE dbo.DepartDemo WHERE DID = 103
SELECT CHANGE_TRACKING_CURRENT_VERSION () as 当前版本 /* 当前版本 4 */
--版本1之后的更改
SELECT DID, SYS_CHANGE_VERSION, SYS_CHANGE_OPERATION, SYS_CHANGE_COLUMNS FROM CHANGETABLE (CHANGES dbo.DepartDemo, 1) AS CT

邀月工作室
--返回哪些列被修改，1为真,0为假
SELECT DID,
CHANGE_TRACKING_IS_COLUMN_IN_MASK(
COLUMNPROPERTY(
OBJECT_ID('dbo.DepartDemo'),'DName', 'ColumnId') ,
SYS_CHANGE_COLUMNS) 是否改变DName,
CHANGE_TRACKING_IS_COLUMN_IN_MASK(
COLUMNPROPERTY(
OBJECT_ID('dbo.DepartDemo'), 'Manager', 'ColumnId') ,
SYS_CHANGE_COLUMNS) 是否改变Manager
FROM CHANGETABLE (CHANGES dbo.DepartDemo, 1) AS CT
WHERE SYS_CHANGE_OPERATION = 'U'
/* DID 是否改变DName 是否改变Manager 101 0 1 102 1 0 */

 
/* 二、使用Version关键字 */
SELECT d.DID, d.DName, d.Manager, ct.SYS_CHANGE_VERSION
FROM dbo.DepartDemo d
CROSS APPLY CHANGETABLE (VERSION dbo.DepartDemo , (DID), (d.DID)) as ct


邀月工作室
UPDATE dbo.DepartDemo SET DName = '中原明教', CurState = 0
WHERE DID = 101
SELECT d.DID, d.DName, d.Manager, ct.SYS_CHANGE_VERSION
FROM dbo.DepartDemo d
CROSS APPLY CHANGETABLE (VERSION dbo.DepartDemo , (DID), (d.DID)) as ct

邀月工作室
SELECT CHANGE_TRACKING_CURRENT_VERSION () as 当前版本 /* 当前版本 5 */
--跟踪外部程序哪一部分引起的更改，这样好找出源头
DECLARE @context varbinary(128) = CAST('明教内讧引起分裂' as varbinary(128));
WITH CHANGE_TRACKING_CONTEXT (@context)
INSERT dbo.DepartDemo (DName, Manager) VALUES ('天鹰教', '殷天正')
--查询Context更改
SELECT DID, SYS_CHANGE_OPERATION, SYS_CHANGE_VERSION, CAST(SYS_CHANGE_CONTEXT as varchar) ApplicationContext
FROM CHANGETABLE (CHANGES dbo.DepartDemo, 5) AS CT
/* DID SYS_CHANGE_OPERATION SYS_CHANGE_VERSION ApplicationContext 104 I 6 明教内讧引起分裂 */

 