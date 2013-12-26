select * from sys.login_token

exec sp_helplogins 'sa'


-- 安全对象和权限
/*
安全对象，它是权限和主体的中间对象，把权限的范围分成3个嵌套分级。

层次最高的是服务器范围，它包含登录名，数据库和端点。--这里安全主体和安全对象的区分
数据库范围包含在服务器范围中，控制着数据库用户，角色，安全凭证，架构等安全对象。
最里层的是架构范围，它控制安全对象架构及架构中的对象，比如表，视图，函数存储过程等。

数据库默认的用户
dbo用户(指定数据库的用户)
guest用户(功能受限的指定数据库的用户)
information_schema用户和sys用户

dbo用户
数据库所有者或称dbo是一个特殊类型的数据库用户，并且它被授于特殊的权限。一般来说，创建数据库的用户是数据库的所有者。
dbo被隐式授于对数据库的所有权限，并且能将这些权限授于其他用户，因为sysadmin服务器角色的成员被自动映射为特殊用户dbo,
以sysadmin角色登录能执行dbo能执行的任何任务

*/

--查看所有可用的权限
SELECT * FROM sys.fn_builtin_permissions(DEFAULT) 

--仅显示架构安全对象范围中的权限
SELECT * FROM sys.fn_builtin_permissions('schema')

/*服务器范围的安全对象和权限
服务器安全对象的权限只能授于服务器级别主体，而不能授于数据库级别的主体。
也就是说，这类权限是针对服务器主体的，比如创建数据库，登录名，链接服务器等。

一种理解：
固定角色是一种特珠的安全对象，不能往上加权限，权限可以往上加到自定义角色，加到安全主体(只有服务器类的权限可以加到安全主体上)

*/
SELECT * FROM sys.fn_builtin_permissions('SERVER') ORDER BY permission_name

--授于跟踪权限
GRANT ALTER trace TO login_name
WITH GRANT OPTION-- 被授于者拥有将权限授于其他被授于者的权限
AS grantor_principal -- 指定授于者派生它的权力，将权限授于被授于者

GRANT CREATE ANY DATABASE,VIEW ANY DATABASE TO [li.weiqiang]

--拒绝
DENY SHUTDOWN TO [li.weiqiang]
CASCADE --如果被授于者主体授于所有这些权限给其他主体，那么那些被授于者的权限也将被拒绝。
AS grantor_principal

--取消,既没有授于也没有拒绝这个权限--取消操作删除以前授于或拒绝了的权限。
REVOKE ALTER trace FROM [li.weiqiang]
CASCADE

--查看服务器范围权限
SELECT * FROM sys.server_permissions a
INNER JOIN sys.server_principals b ON a.grantee_principal_id = b.principal_id
WHERE name = 'lwqhp'

/*数据库范围的安全对象和权限------------------------------------------------------------------------
数据库级别的安全对象对于提定的数据库是唯一的，包括
角色，程序集，密码系统对象，broker对象，全文目录，数据库用户，架构，等等。

*/
SELECT * FROM sys.fn_builtin_permissions('DATABASE') ORDER BY permission_name

GRANT ALTER ANY ASSEMBLY TO USER_NAME

DENY ALTER ANY DATABASE DDL TRIGGER TO USER_NAME

REVOKE CONNECT FROM USER_NAME

--查看数据库权限
SELECT name,principal_id FROM sys.database_principals --确定主体标识符 

SELECT 
a.class_desc,a.permission_name,a.state_desc,b.type_desc,
CASE a.class_desc WHEN 'schema' THEN SCHEMA_NAME(major_id)
	 WHEN 'object_or_column' THEN CASE WHEN minor_id=0 THEN OBJECT_NAME(major_id)	
										ELSE (SELECT OBJECT_NAME(object_id)+'.'+name FROM sys.columns 
										WHERE object_id = a.major_id AND column_id = a.minor_id) END
							ELSE '' END  AS object_name 
 FROM sys.database_permissions a
LEFT JOIN sys.objects b ON a.major_id = b.object_id
WHERE grantee_principal_id = 5


/*架构范围的安全对象和权限---------------------------------------------------------------------------------

对象包含在架构中，用户不在直接拥有对象，而是转而拥有架构，这样实际了对象和用户的分离。
这意味着多个用户可以拥有架构，架构里的所有对象可以作为一个整体进行管理，而不是以单个对象级别进行管理。
*/

CREATE SCHEMA SCHEMA_NAME [authorization owner_name]

DROP SCHEMA SCHEMA_NAME


ALTER SCHEMA dbo TRANSFER lwq.TB

--查看数据库架构列表
SELECT * FROM sys.schemas a
INNER JOIN sys.database_principals b ON a.principal_id = b.principal_id
ORDER BY a.name

--用户test被授于take ownership权限到架构person中
GRANT TAKE OWNERSHIP ON shema ::person TO test

/*对象的权限
对象是嵌套在架构范围中的，它们包括表，视图，存储过程，函数和聚合，在架构范围，比如select ,exec 定义权限可以
给被 授于者定义架构中所有对象的权限，也可以在对象级别定义权限。
对象权限是在架构权限中嵌套，数据库范围的权限中的架构权限以及服务器级别权限中的数据库范围权限。

*/

--授于用户权限
GRANT DELETE,INSERT,SELECT,UPDATE
ON dbo.tb
TO test


--检测当前连接的安全对象的权限

SELECT HAS_PERMS_BY_NAME('dbname','datatabae','alter')
/*
1,希望验证权限的安全对象的名称
2，要检查的安全对象类的名称。类名
3，要检查的权限的名称
*/

--返回当前连接的主体分配的权限

--检查当前连接的服务器范围权限
EXECUTE AS LOGIN='text'
go

SELECT * FROM fn_my_permissions(NULL,N'Server')

/*
1,要验证的安全对象的名称，如果在服务器或数据库范围检查权限就使用null
2,你要对基列出权限的安全对对象类
*/

--改变对象的拥有者
/*
当需要删除登陆名或数据库用户时，可能希望改变所有权
*/

--将架构的拥有者改变为数据库用户 textuser
ALTER AUTHORIZATION ON SCHEMA::humanresources TO testuser

--查看
SELECT * FROM sys.endpoints a
INNER JOIN sys.server_principals b ON a.principal_id = b.principal_id
WHERE a.name = 'product'

--缺审核对象的了解