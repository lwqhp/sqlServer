


--SqlServer安全主体
/*
一个能请求服务器，数据库或架构资源的实体称为安全主体，SqlServer把安全级别分成三个级别
window级别
sqlServer级别
数据库级别

不同的安全级别决定了安全主体的影响范围，通常，window和sqlserver级别的安全主体具有实例级的范围，而数据库级别的主体其
影响范围是特定的数据库。


{可以理解为两个层级，服务器层和数据库层,服务器层级包括了window级别的主体和SqlServer主体}
>>进一步：
使用window身份验证来访问SQLServer实例的帐户就是一个window级别主体,这个window登录名可以是一个域用户,本地用户.或是一个用户组
只有将window帐户添加到sqlserver实例中，才能授于数据库对象的权限。

*/
--2.1)window主体--------------------------------------------------------------------------------

--服务器主体的增修改及查看
create login [PC-LIWEIQIANG\lwq] --本地用户
from windows
with default_database=HK_ERP_PT

create login [HENGKANGIT\恒康客服部] --用户组
from windows
with default_database=HK_ERP_PT

alter login [HENGKANGIT\恒康客服部] --改默认数据库
with default_database=HK_BI_ETL

--alter login [HENGKANGIT\恒康客服部] disable --不能对组用alter
alter login [PC-LIWEIQIANG\lwq] disable  --禁用
alter login [PC-LIWEIQIANG\lwq] enable  ----启用

----如果登录名拥有任何的安全对象，drop将会失败。
drop login [PC-LIWEIQIANG\lwq] --删除

use master
go
--只有在当前数据库是 master 时，才能授予服务器范围的权限,登录名在下一次登录时起效
deny connect sql to [HENGKANGIT\li.weiqiang]  --拒绝访问(GUI中状态是连接拒绝,使用提示：无法连接，登陆失败)

grant connect sql to [HENGKANGIT\li.weiqiang] --允许访问

--查看实例中已经添加的window登录名和用户组
select * from sys.server_principals
where type_desc in('WINDOWS_LOGIN','WINDOWS_GROUP')

/*
当sql Server登录名关联到windows用户组，它使得这个window用户组的所有成员继承了window登录名的访问权限，所以，这个用户组
的所有成员不需要分别显式添加每个window帐号到sqlserver实例，就拥有了访问slqserver实例的权限。

>>>{GUI：实例下的安全性-登陆名：就是服务器级安全主体}
*/



/* 2.2)sqlServer级别的主体(sqlserver的登陆帐户)-------------------------------------------------------------------------------

window身份验证依赖于底层的操作系统来完成身份验证，并且意味着slqserver要完成必要的授权(决定完成身份验证的用户可以执
行什么动作),sqlServer主体和sqlserver 身份验证一起工作时，sqlServer自己完成身份验证和授权。

与window登录名一样，sqlServer登录名也只能用在服务器级别，不可以给它授于权限到特定的数据库对象上，除非你被授于固定服
务器角色(比如sysadmin)的成员，否则在使用数据库对象工作之前，必须创建关联登录到数据库用户上。
比如
sysadmin角色的成员在sqlserver上有最高级别的权限，并且能执行任何类型的任务。
*/

create login lwq1 --创建sqlServer登录名
with password='A,12345678',
default_database=HK_BI_ETL

alter login lwq1
with name=lwq1a,password='A/123456' --改名改密码

alter login lwq1
with default_database=master

--需要拥有固定服务器角色sysadmin
drop login lwq1a		--删除

--查看
select * from sys.server_principals where type_desc in('sql_login')

--查看登陆名属性
declare @LoginName varchar(30)='lwq1'
select loginproperty(@LoginName,'islocked') islocked,
	loginproperty(@LoginName,'isexpired') isexpired,
	loginproperty(@LoginName,'ismustchange') isMustChange,
	loginproperty(@LoginName,'badPasswordcount') badPasswordcount,
	loginproperty(@LoginName,'historylength') historylength,
	loginproperty(@LoginName,'lockouttime') lockouttime,
	loginproperty(@LoginName,'passwordlastsettime') passwordlastsettime,
	loginproperty(@LoginName,'passwordhash' ) passwordhash


/*
>>>>>>>>>>>>>>>服务器级别的主体可以授予的权限------------------------------------------------------------

--固定服务器角色

这是预定义的sql用户组，它们被赋于特定的sqlServer范围(与数据库或架构范围相对)的权限，默认是public角色
使用服务器角色授于管理服务器的能力，如果使登录成为角色成员，用户用此登陆就可执行角色许可的任何任务.

*/

--查看固定服务器角色
select * from sys.server_principals where type_desc = 'SERVER_ROLE' --这个表怎么什么都放啊
--查看固定服务器角色列表
exec sp_helpsrvrole

exec sp_addsrvrolemember 'lwq1','sysadmin' --加到sysadmin角色

exec sp_dropsrvrolemember 'text3','sysadmin' --删除服务器角色

--查看固定服务器角色包含的成员
exec sp_helpsrvrolemember 'sysadmin'


---==========================================================================================================
----------------------------------------分割线---------------------------------------------------------------
--===========================================================================================================

/*数据库级别的主体-------------------------------------------------

数据库级别的主体是可以分配访问数据库或数据库中的特殊对象的权限给用户的对象。

1,数据库用户：是执行数据库内的请求的数据库级别的安全上下文，并且与sqlserver或windows登录名关联。
2,数据库角色：
3,应用程序角色



一旦创建了登录名，就可以把它映射到数据库用户，一个登录名可以映射到一个sqlserver实例 的多个数据库上。
*/

--3.1数据库用户--------------------------------------
CREATE USER lwq1
FOR LOGIN [lwq1]	--默认是名称相同的登陆名上
WITH default_schema=dbo --默认是dbo


--查看数据库用户信息
EXEC sys.sp_helpuser @name_in_db = lwq1a -- sysname


ALTER USER lwq1 --修改
WITH NAME =lwq1a

ALTER USER lwq1a
WITH DEFAULT_SCHEMA=dbo

DROP USER lwq1a --删除
ALTER AUTHORIZATION ON SCHEMA::db_owner TO dbo; --然后手动删除就可以了。 



--3.2查看固定数据库角色--------------------------------------------------------
/*
数据库角色
在数据库级别分配权限，针对每一个数据库设置数据库角色

用户定义的标准角色
用户定义的应用程序角色
预定义或固定的数据库角色

标准角色允许创建具有单一权限的角色，对用户进行逻辑分组，然后为角色分配单一的权限，而不是单独为每一个用户分配权限。

预定义的数据库角色，具有不能更改的权限。
*/
EXEC sys.sp_helpdbfixedrole @rolename = NULL -- sysname

--查看有固定数据库角色的用户
EXEC sys.sp_helprolemember @rolename = NULL -- sysname
/*
一个固定数据库角色将重要的数据库权限汇集到一起，这些权限不可以修改或删除。
像固定服务器角色一样，对于数据库用户，最好不要在没有确认所有权限都是绝对必要的情况下，将它授于到固定数据库
角色的成员中，例如，不要在用户只需要一个表的select 权限时授于它db_owner成员关系。
*/

--关联用户和数据库角色
EXEC sp_addrolemember 'db_datawriter','lwq1'
EXEC sp_droprolemember 'db_datawriter','lwq1'

-->>>>>管理用户自定义数据库角色---------------
EXEC sys.sp_helprole @rolename = NULL -- sysname--查看

CREATE ROLE role_lwq AUTHORIZATION db_owner


--给角色添加权限
GRANT SELECT ON TB TO role_lwq --授于一个表的select权限给新的角色

--给角色添加用户
EXEC sp_addrolemember 'role_lwq','text3'

--修改
ALTER ROLE role_lwq WITH NAME = role_lwq2

--删除角色中的用户
EXEC sp_droprolemember 'role_lwq2','text3'
--删除角色
DROP ROLE role_lwq2


/*3.3应用程序角色-------------------------------------------------------------------------
应用程序角色是由登录名和数据库角色混合而成的，能够以与分配给用户定义角色权限相同的方式，分配权限给应用程序
角色，不同的是应用程序角色中不允许拥有成员，取而代之的是，应用程序角色被使用启用密码的系统存储过程激活，当
使用应用程序角色时，它将覆盖登录名可能拥有的所有其他以限。

*/
CREATE APPLICATION ROLE app --创建
WITH PASSWORD ='123',
DEFAULT_SCHEMA = 'dbo'

--授于权限
GRANT SELECT ON TB TO app

--激法当前用户会话的应用程序角色权限
EXEC sp_setapprole 'app','123'

--使用sp_setaprole 进入到应用程序权限也意喷水 着只应用这个角色的权限
ALTER APPLICATION ROLE app WITH NAME = new_app,PASSWORD='1234',DEFAULT_SCHEMA='dbo'

DROP APPLICATION ROLE new_app













