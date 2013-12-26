


--SqlServer安全主体
/*
一个能请求服务器，数据库或架构资源的实体称为安全主体，因为SqlServer把安全级别分成三个级别
window级别
sqlServer级别
数据库级别

不同的安全级别决定了安全主体的影响范围，通常，window和sqlserver级别的安全主体具有实例级的范围，而数据库级别的主体其
影响范围是特定的数据库。

使用window身份验证来访问SQLServer实例的帐户就是一个window级别主体,这个window登录名可以是一个域用户,本地用户.或是一个用户组
只有将window帐户添加到sqlserver实例中，才能授于数据库对象的权限。
*/
--创建window登陆名
create login [hengkangit\li.weiqiang]
from windows
with default_database=HK_BI_ETL

--创建一个window用户组的window登录名
create login [hengkangit\public]
from windows
with default_database=HK_BI_ETL
/*
当sql Server登录名关联到windows用户组，它使得这个window用户组的所有成员继承了window登录名的访问权限，所以，这个用户组
的所有成员不需要分别显式添加每个window帐号到sqlserver实例，就拥有了访问slqserver实例的权限。
*/

--查看实例中已经添加的window登录名和用户组
select * from sys.server_principals
where type_desc in('WINDOWS_LOGIN','WINDOWS_GROUP')

--修改window登录名的一些属性
alter login [HENGKANGIT\li.weiqiang]
with default_database=HK_BI_ETL --默认数据库

alter login [HENGKANGIT\li.weiqiang] disable --禁用
alter login [HENGKANGIT\li.weiqiang] enable --启用

--删除登录名
drop login [HENGKANGIT\li.weiqiang]
--如果登录名拥有任何的安全对象，drop将会失败。

use master
go
--拒绝访问
deny connect sql to [HENGKANGIT\li.weiqiang]
--允许访问
grant connect sql to [HENGKANGIT\li.weiqiang]
/*登录名在下一次登录时起效*/

/* sqlServer级别的主体(sqlserver的登陆帐户)-------------------------------------------------------------------------------

window身份验证依赖于底层的操作系统来完成身份验证，并且意味着slqserver要完成必要的授权(决定完成身份验证的用户可以执
行什么动作),sqlServer主体和sqlserver 身份验证一起工作时，sqlServer自己完成身份验证和授权。

与window登录名一样，sqlServer登录名也只能用在服务器级别，不可以给它授于权限到特定的数据库对象上，除非你被授于固定服
务器角色(比如sysadmin)的成员，否则在使用数据库对象工作之前，必须创建关联到登录钟摆数据库用户上。
*/
--创建sqlServer登录名
create login text2
with password='A,12345678',
default_database=HK_BI_ETL

--查看
select * from sys.server_principals where type_desc in('sql_login')

--修改
alter login text2
with name=text21,password='A/123456'
--需要拥有固定服务器角色sysadmin

drop login text21

--查看登陆名属性
select loginproperty('text2','islocked') islocked,
	loginproperty('text2','isexpired') isexpired,
	loginproperty('text2','ismustchange') isMustChange,
	loginproperty('text2','badPasswordcount') badPasswordcount,
	loginproperty('text2','historylength') historylength,
	loginproperty('text2','lockouttime') lockouttime,
	loginproperty('text2','passwordlastsettime') passwordlastsettime,
	loginproperty('text2','passwordhash' ) passwordhash


--固定服务器角色
/*
这是预定义的sql用户组，它们被赋于特定的sqlServer范围(与数据库或架构范围相对)的权限。
*/

--创建一个登陆名，并把登陆名添加到固定服务器角色中
create login text3
with password='A.38409587'

select * from sys.server_principals where type_desc in('sql_login')

exec sp_addsrvrolemember 'text3','sysadmin'

exec sp_dropsrvrolemember 'text3','sysadmin'

--查看固定服务器角色
select * from sys.server_principals where type_desc = 'server_role'

--查看固定服务器角色列表
exec sp_helpsrvrole

--查看某个固定服务器角色的成员
exec sp_helpsrvrolemember 'sysadmin'


/*数据库级别的主体-------------------------------------------------
数据库级别的主体是可以分配访问数据库或数据库中的特殊对象的权限给用户的对象。

数据库用户：是执行数据库内的请求的数据库级别的安全上下文，并且与sqlserver或windows登录名关联。
数据库角色：
应用程序角色

一旦创建了登录名，就可以把它映射到数据库用户，一个登录名可以映射到一个sqlserver实例 的多个数据库上。
*/

--创建用户
CREATE LOGIN text3
with password='A,12345678'

CREATE USER text3
FOR LOGIN [text3]	--默认是名称相同的登陆名上
WITH default_schema=dbo --默认是dbo


--查看数据库用户信息
EXEC sys.sp_helpuser @name_in_db = text3 -- sysname

--修改
ALTER USER text3
WITH NAME =text4

ALTER USER text4
WITH DEFAULT_SCHEMA=dbo

DROP USER text4

--修复孤立的数据库用户
SELECT * FROM sys.database_principals a
LEFT JOIN sys.server_principals b ON a.sid = b.sid
WHERE b.sid IS NULL AND a.type_desc ='sql_user' AND a.principal_id>4

--重新指定
ALTER USER text4
WITH LOGIN li.weiqiang

--查看固定数据库角色
EXEC sys.sp_helpdbfixedrole @rolename = NULL -- sysname

--查看有固定数据库角色的用户
EXEC sys.sp_helprolemember @rolename = NULL -- sysname
/*
一个固定数据库角色将重要的数据库权限汇集到一起，这些权限不可以修改或删除。
像固定服务器角色一样，对于数据库用户，最好不要在没有确认所有权限都是绝对必要的情况下，将它授于到固定数据库
角色的成员中，例如，不要在用户只需要一个表的select 权限时授于它db_owner成员关系。
*/

--关联用户和数据库角色
EXEC sp_addrolemember 'db_datawriter','text4'
EXEC sp_droprolemember 'db_datawriter','text4'

--管理用户自定义数据库角色

--查看
EXEC sys.sp_helprole @rolename = NULL -- sysname

CREATE ROLE role_lwq AUTHORIZATION db_owner

--授于一个表的select权限给新的角色
GRANT SELECT ON TB TO role_lwq

--添加用户
EXEC sp_addrolemember 'role_lwq','text3'

--修改
ALTER ROLE role_lwq WITH NAME = role_lwq2

--删除角色中的用户
EXEC sp_droprolemember 'role_lwq2','text3'
--删除角色
DROP ROLE role_lwq2

/*应用程序角色
应用程序角色是由登录名和数据库角色混合而成的，能够以与分配给用户定义角色权限相同的方式，分配权限给应用程序
角色，不同的是应用程序角色中不允许拥有成员，取而代之的是，应用程序角色被使用启用密码的系统存储过程激活，当
使用应用程序角色时，它将覆盖登录名可能拥有的所有其他以限。

*/

--创建
CREATE APPLICATION ROLE app
WITH PASSWORD ='123',
DEFAULT_SCHEMA = 'dbo'

--授于权限
GRANT SELECT ON TB TO app

--激法当前用户会话的应用程序角色权限
EXEC sp_setapprole 'app','123'

SELECT * FROM TB

--使用sp_setaprole 进入到应用程序权限也意喷水 着只应用这个角色的权限
ALTER APPLICATION ROLE app WITH NAME = new_app,PASSWORD='1234',DEFAULT_SCHEMA='dbo'

DROP APPLICATION ROLE new_app



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

--从数据库角度，对用户或角色，设置数据库权限
/*
数据库属性-权限

备份日志
备份数据库
插入
查看定义
创建表
创建过程,函数,架构，连接等

*/

--从数据库用户角度，设置当前数据库的安全对象的权限
/*
不同的安全对象可以授于的权限不同
比如表

插入
查看定义
更改，更新，删除，接管理所有权等
*/

--从安全对象角度，给多个用户和角色设置权限
/*
数据库-对象属性-权限

对安全对象可授于的权限相同
*/


-----角色
/*
仅预定义系统角色的成员或数据库/数据库对象所有者有隐含的权限。
角色的隐含权限不能被更改。

服务器角色
使用服务器角色授于管理服务器的能力，如果使登录成为角色成员，用户用此登陆就可执行角色许可的任何任务.

比如
sysadmin角色的成员在sqlserver上有最高级别的权限，并且能执行任何类型的任务。


数据库角色
在数据库级别分配权限，针对每一个数据库设置数据库角色

用户定义的标准角色
用户定义的应用程序角色
预定义或固定的数据库角色

标准角色允许创建具有单一权限的角色，对用户进行逻辑分组，然后为角色分配单一的权限，而不是单独为每一个用户分配权限。

预定义的数据库角色，具有不能更改的权限。
*/

select * from sys.login_token

exec sp_helplogins 'sa'

/*
数据库默认的用户
dbo用户(指定数据库的用户)
guest用户(功能受限的指定数据库的用户)
information_schema用户和sys用户

dbo用户
数据库所有者或称dbo是一个特殊类型的数据库用户，并且它被授于特殊的权限。一般来说，创建数据库的用户是数据库的所有者。
dbo被隐式授于对数据库的所有权限，并且能将这些权限授于其他用户，因为sysadmin服务器角色的成员被自动映射为特殊用户dbo,
以sysadmin角色登录能执行dbo能执行的任何任务
*/