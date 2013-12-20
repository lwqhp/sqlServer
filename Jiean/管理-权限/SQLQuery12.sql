


--SqlServer安全权限
/*
分安全主体和安全对象

一个能请求服务器，数据库或架构资源的实体称为安全主体，因为SqlServer把安全级别分成三个级别
window级别
sqlServer级别
数据库级别

不同的安全级别决定了安全主体的影响范围，通常，window和sqlserver级别的安全主体具有实例级的范围，而数据库级别的主体其
影响范围是特定的数据库。

同样的sqlServer也对安全对象的范围进行了划分
服务器
数据库
架构

数据库中的所有对象是位于架构内的，每一架构的所有者是角色，而不是独立的用户，允许多个用户管理数据库对象。

权限：
则是对安全对象所能进行的操作
*/

SELECT * FROM sys.fn_builtin_permissions('login')
WHERE class_desc =''

SELECT HAS_PERMS_BY_NAME(DB_NAME(),'Database','any')

SELECT DB_NAME()

SELECT HAS_PERMS_BY_NAME(name,'object','insert') ,* FROM sys.tables

EXECUTE AS USER='lwqhp'
SELECT HAS_PERMS_BY_NAME(name,'object','insert') ,* FROM sys.tables
