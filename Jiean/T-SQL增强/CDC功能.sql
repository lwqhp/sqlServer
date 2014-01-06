/*
ʹ�á�������ݲ��񡱣�CDC������
SQL Server 2008�ṩ���ڽ��ķ���������ݲ���Change Data Capture ��CDC����ʵ���첽�����û���������޸ģ�
������һ����ӵ����С�����ܿ���������������������Դ�ĳ������£����罫OLTP���ݿ��е����ݱ��Ǩ�Ƶ����ݲֿ����ݿ⡣
*/
use master 
GO 
IF EXISTS (SELECT [name] FROM sys.databases WHERE name = 'TestDb2') 
    drop DATABASE TestDb2 
Go 
CREATE DATABASE TestDb2 
GO 
--�鿴�Ƿ�����CDC 
SELECT is_cdc_enabled FROM sys.databases WHERE name = 'TestDb2' 
USE TestDb2 
GO 
----���õ�ǰ���ݿ��CDC���� 
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
��Ҫ����SQL Server Agent���񣬷���ᱨ������ע SQLServerAgent is not currently running so it cannot be notified of this action.
***********************************/
/****** �������е��б����ֻ�����еľ����������Ĭ�� *******/
EXEC sys.sp_cdc_enable_table
@source_schema = 'dbo',
@source_name = 'DepartDemo',
@role_name = NULL,
@capture_instance = NULL,
@supports_net_changes = 1,
@index_name = NULL,
@captured_column_list = NULL,
@filegroup_name = default
/*ע���ʱ��SQL Server ������������job,һ������һ�������ע�������Ĭ���賿���㣬
���72Сʱ���ϵ����ݡ����ͬһ���ݿ�ı���CDC�Ѿ����ã������ؽ�job��*/

--ȷ�ϱ��Ѿ������� 
SELECT is_tracked_by_cdc FROM sys.tables 
WHERE name = 'DepartDemo' and schema_id = SCHEMA_ID('dbo')
/* is_tracked_by_cdc 1 */
--ȷ��
EXEC sys.sp_cdc_help_change_data_capture 'dbo', 'DepartDemo'
/*
���Կ�����SQL Server ������һ����[cdc].[dbo_DepartDemo_CT] 
���Դ����˸��ֶΣ� 
[__$start_lsn] 
,[__$end_lsn] 
,[__$seqval] 
,[__$operation] 
,[__$update_mask] 
*/
--������ֱ�Ӳ�ѯ�ñ���Ӧ��ʹ������ļ��ɣ�
INSERT [dbo].[DepartDemo] ([DName], [DCode], [Manager], [ParentID],
[AddUser], [AddTime], [ModUser], [ModTime], [CurState], [Remark], [F1], [F2])
VALUES (N'�����', N'0', N'���к�', 0, N'DemoUser1',
CAST(0x00009DF7017B6F96 AS DateTime), N'', CAST(0x0000000000000000 AS DateTime),
1, N'��ܻ���', 0, N'')

INSERT [dbo].[DepartDemo] ([DName], [DCode], [Manager], [ParentID],
[AddUser], [AddTime], [ModUser], [ModTime], [CurState], [Remark], [F1], [F2])
VALUES (N'ͳ�ƾ�', N'0', N'������', 0, N'DemoUser2',
CAST(0x00009DF7017B6F96 AS DateTime), N'', CAST(0x0000000000000000 AS DateTime),
1, N'ͳ������', 0, N'')
GO

UPDATE [dbo].[DepartDemo]
SET Manager='������'
WHERE DID =101

DELETE [dbo].[DepartDemo]
WHERE DID = 102

--select * from [cdc].[dbo_DepartDemo_CT]
/*
Ҫ��ѯ�����������Ҫ����������������־���кţ�Log Sequence Numbers����LSN
��http://msdn.microsoft.com/zh-cn/library/ms190411%28v=sql.100%29.aspx����ʵ��LSN����ĸ������ݱ���� 
����ʾ����sys.fn_cdc_map_time_to_lsn��http://msdn.microsoft.com/zh-cn/library/bb500137%28v=sql.100%29.aspx��
����LSNת��Ϊʱ�䡣
*/



/******* ʹ��LSN �鿴CDC��¼ *********/

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

/**************�鿴����CDC��¼*************/
/************* 3w@live.cn ����***************/

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

/************�鿴���и���*************************

__$operation __$update_mask DID DName Manager
2 0x1FFF 105 ����� ���к�
2 0x1FFF 106 ͳ�ƾ� ������
1 0x1FFF 101 ����� ������
1 0x1FFF 103 ����� ���к�
1 0x1FFF 104 ͳ�ƾ� ������
1 0x1FFF 105 ����� ���к�
1 0x1FFF 106 ͳ�ƾ� ������
2 0x1FFF 107 ����� ���к�
2 0x1FFF 108 ͳ�ƾ� ������
4 0x0008 107 ����� ������
1 0x1FFF 108 ͳ�ƾ� ������
*/

/**************�鿴����CDC��¼*************/
/************* 3w@live.cn ����***************/
DECLARE @FromLSN varbinary(10) =
sys.fn_cdc_map_time_to_lsn
( 'smallest greater than or equal' , '2012-04-09 16:09:30')

DECLARE @ToLSN varbinary(10) =
sys.fn_cdc_map_time_to_lsn
( 'largest less than or equal' , '2012-04-09 23:59:59')

--����һ��Operation�ľ��庬��
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



/**************�鿴�����ģ�Net changes��CDC��¼*************/

INSERT [dbo].[DepartDemo] ([DName], [DCode], [Manager], [ParentID],
[AddUser], [AddTime], [ModUser], [ModTime], [CurState], [Remark], [F1], [F2])
VALUES (N'ҩ���', N'0', N'����ҽ��', 0, N'DemoUser3',
CAST(0x00009DF7017B6F96 AS DateTime), N'', CAST(0x0000000000000000 AS DateTime),
1, N'�ƶ�ҩ��', 0, N'')
GO

UPDATE [dbo].[DepartDemo]
SET Manager='����ţ'
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
�����ǻ�����ͨ��ת��CDC���������ø�Ϊֱ�۵Ľ����������Ҫ������������������sys.fn_cdc_is_bit_set
��http://msdn.microsoft.com/zh-cn/library/bb500241%28v=SQL.110%29.aspx����
sys.fn_cdc_get_column_ordinal��http://msdn.microsoft.com/zh-cn/library/bb522549%28v=SQL.100%29.aspx��
*/



/************** ת��CDC�������� *************/

UPDATE dbo.[DepartDemo]
SET [Manager] = '��������'
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
����ǰ����ܵ�ָ��LSN�߽�ķ�����SQL Server���ṩ��һϵ�еĻ�ȡ�߽�ķ�����

sys.fn_cdc_get_max_lsn��http://msdn.microsoft.com/zh-cn/library/bb500304%28v=sql.100%29.aspx��

sys.fn_cdc_get_min_lsn��http://msdn.microsoft.com/zh-cn/library/bb510621%28v=sql.100%29.aspx��

sys.fn_cdc_increment_lsn��http://msdn.microsoft.com/zh-cn/library/bb510745%28v=sql.100%29.aspx��

sys.fn_cdc_decrement_lsn��http://msdn.microsoft.com/zh-cn/library/bb500246%28v=sql.100%29.aspx��
*/


/************** ��ȡLSN�߽���������� *************/ 

--��ȡ��С�߽�
SELECT sys.fn_cdc_get_min_lsn ('dbo_DepartDemo') Min_LSN
--��ȡ���õ����߽�
SELECT sys.fn_cdc_get_max_lsn () Max_LSN
--��ȡ���߽����һ�����
SELECT sys.fn_cdc_increment_lsn (sys.fn_cdc_get_max_lsn())
New_Lower_Bound_LSN
--��ȡ���߽��ǰһ�����
SELECT sys.fn_cdc_decrement_lsn (sys.fn_cdc_get_max_lsn())
New_Lower_Bound_Minus_one_LSN
ͨ�����´洢���������ݿ�ͱ�����CDC

sys.sp_cdc_disable_table ��http://msdn.microsoft.com/zh-cn/library/bb510702(v=sql.100).aspx��

sys.sp_cdc_disable_db��http://msdn.microsoft.com/zh-cn/library/bb522508(v=sql.100).aspx��ע�⣬������ͬʱҲɾ����CDC�ܹ�����ص�SQL������ҵ��
/************** �����ݿ�ͱ�����CDC *************/
/************* 3w@live.cn ���� **************/
EXEC sys.sp_cdc_disable_table 'dbo', 'DepartDemo', 'all'
SELECT is_tracked_by_cdc FROM sys.tables
WHERE name = 'DepartDemo' and schema_id = SCHEMA_ID('dbo')
--��ǰ���ݿ��Ͻ���CDC
EXEC sys.sp_cdc_disable_db

 

�ġ�ʹ�á����ĸ��١�����С�Ĵ��̿������پ����ݸ���

����CDC�������������ݿ�����ݲֿ�ĳ������ݱ�������첽���ݸ��٣���SQL Server 2008�������ġ����ĸ��١�ȴ��һ��ͬ�����̣���DML��������I/D/U�������һ���֣������������������С�Ĵ��̿�������⾻�б�����������޸ĵ�����������һ�µ���ʽ���֣����ṩ�˼�����ݳ�ͻ�����������������Ը����ⲿ�����Ӧ�ó��������ģ�����ɸ�ϸ�����ȵĸ��Ĵ����ο�WITH CHANGE_TRACKING_CONTEXT ��http://msdn.microsoft.com/zh-cn/library/bb895330%28v=sql.100%29.aspx��
/***ʹ�á����ĸ��١�����С�Ĵ��̿������پ����ݸ���****/
/************* 3w@live.cn ���� **************/
IF EXISTS (SELECT [name] FROM sys.databases WHERE name = 'TestDb4')
  drop DATABASE TestDb4
Go CREATE DATABASE TestDb4
GO
--���ø��¸��٣�36Сʱ����һ��
ALTER DATABASE TestDb4 SET CHANGE_TRACKING = ON (CHANGE_RETENTION = 36 HOURS, AUTO_CLEANUP = ON)

����ע�⣬��һ����������ո��룬����΢������ġ����ʵ���������������а汾�����ɻ����Ӷ���Ŀռ�ʹ�ã��Ӷ��������ܵ�I/O����,����ʹ�ÿ��ջ���������һ�µı����Ϣ��

    ALTER DATABASE TestDb4
    SET ALLOW_SNAPSHOT_ISOLATION ON
    GO

    SELECT DB_NAME(database_id) ���ݿ�����,is_auto_cleanup_on,
    retention_period,retention_period_units_desc
    FROM sys.change_tracking_databases
    /*
    ���ݿ����� is_auto_cleanup_on retention_period retention_period_units_desc
    TestDb4 1 36 HOURS
    */

    USE TestDb4
    GO
    --�������Ա�
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

    --���ñ���и��¸���
    ALTER TABLE dbo.DepartDemo
    ENABLE CHANGE_TRACKING
    WITH (TRACK_COLUMNS_UPDATED = ON)

    --ȷ���Ƿ���¸��ٿ���
    SELECT OBJECT_NAME(object_id) ObjNM,is_track_columns_updated_on
    FROM sys.change_tracking_tables

    /*
    ObjNM is_track_columns_updated_on
    DepartDemo 1
    */

    --���Ӳ�������
    INSERT dbo.DepartDemo
    (DName,ParentID)
    VALUES
    ('����', 0),
    ('���м�', 101),
    ('������',0)

    SELECT * FROM dbo.DepartDemo

    --��ǰ�汾
    SELECT CHANGE_TRACKING_CURRENT_VERSION ()
    as ��ǰ�汾
    /*
    ��ǰ�汾
    1
    */
    SELECT CHANGE_TRACKING_MIN_VALID_VERSION
    ( OBJECT_ID('dbo.DepartDemo') )as ��С���ð汾

    /*
    ��С���ð汾
    0
    */

����ChangeTable�������÷���������:
һ��ʹ��Changes�ؼ���
����ʹ��Version�ؼ���
/* һ��ʹ��Changes�ؼ��� */
SELECT DID,SYS_CHANGE_OPERATION, SYS_CHANGE_VERSION
FROM CHANGETABLE (CHANGES dbo.DepartDemo, 0) AS CT

���¹�����
UPDATE dbo.DepartDemo SET Manager='���޼�' WHERE DID = 101
UPDATE dbo.DepartDemo SET [DName] = '������' WHERE DID = 102
DELETE dbo.DepartDemo WHERE DID = 103
SELECT CHANGE_TRACKING_CURRENT_VERSION () as ��ǰ�汾 /* ��ǰ�汾 4 */
--�汾1֮��ĸ���
SELECT DID, SYS_CHANGE_VERSION, SYS_CHANGE_OPERATION, SYS_CHANGE_COLUMNS FROM CHANGETABLE (CHANGES dbo.DepartDemo, 1) AS CT

���¹�����
--������Щ�б��޸ģ�1Ϊ��,0Ϊ��
SELECT DID,
CHANGE_TRACKING_IS_COLUMN_IN_MASK(
COLUMNPROPERTY(
OBJECT_ID('dbo.DepartDemo'),'DName', 'ColumnId') ,
SYS_CHANGE_COLUMNS) �Ƿ�ı�DName,
CHANGE_TRACKING_IS_COLUMN_IN_MASK(
COLUMNPROPERTY(
OBJECT_ID('dbo.DepartDemo'), 'Manager', 'ColumnId') ,
SYS_CHANGE_COLUMNS) �Ƿ�ı�Manager
FROM CHANGETABLE (CHANGES dbo.DepartDemo, 1) AS CT
WHERE SYS_CHANGE_OPERATION = 'U'
/* DID �Ƿ�ı�DName �Ƿ�ı�Manager 101 0 1 102 1 0 */

 
/* ����ʹ��Version�ؼ��� */
SELECT d.DID, d.DName, d.Manager, ct.SYS_CHANGE_VERSION
FROM dbo.DepartDemo d
CROSS APPLY CHANGETABLE (VERSION dbo.DepartDemo , (DID), (d.DID)) as ct


���¹�����
UPDATE dbo.DepartDemo SET DName = '��ԭ����', CurState = 0
WHERE DID = 101
SELECT d.DID, d.DName, d.Manager, ct.SYS_CHANGE_VERSION
FROM dbo.DepartDemo d
CROSS APPLY CHANGETABLE (VERSION dbo.DepartDemo , (DID), (d.DID)) as ct

���¹�����
SELECT CHANGE_TRACKING_CURRENT_VERSION () as ��ǰ�汾 /* ��ǰ�汾 5 */
--�����ⲿ������һ��������ĸ��ģ��������ҳ�Դͷ
DECLARE @context varbinary(128) = CAST('������ڧ�������' as varbinary(128));
WITH CHANGE_TRACKING_CONTEXT (@context)
INSERT dbo.DepartDemo (DName, Manager) VALUES ('��ӥ��', '������')
--��ѯContext����
SELECT DID, SYS_CHANGE_OPERATION, SYS_CHANGE_VERSION, CAST(SYS_CHANGE_CONTEXT as varchar) ApplicationContext
FROM CHANGETABLE (CHANGES dbo.DepartDemo, 5) AS CT
/* DID SYS_CHANGE_OPERATION SYS_CHANGE_VERSION ApplicationContext 104 I 6 ������ڧ������� */

 