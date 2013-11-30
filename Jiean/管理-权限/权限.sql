创建角色，用户，权限 
/*--示例说明 示例在数据库pubs中创建一个拥有表jobs的所有权限、
拥有表titles的SELECT权限的角色r_test 随后创建了一个登录l_test，
然后在数据库pubs中为登录l_test创建了用户账户u_test 同时将用户账户u_test添加到角色r_test中，
使其通过权限继承获取了与角色r_test一样的权限 最后使用DENY语句拒绝了用户账户u_test对表titles的SELECT权限。 
经过这样的处理，使用l_test登录SQL Server实例后，它只具有表jobs的所有权限。 --*/ 
USE pubs 
--创建角色 
r_test EXEC sp_addrole 'r_test' 
--授予 r_test 对 jobs 表的所有权限 
GRANT ALL ON jobs TO r_test 
--授予角色 r_test 对 titles 表的 SELECT 权限 
GRANT SELECT ON titles TO r_test 
--添加登录 l_test,设置密码为pwd,默认数据库为pubs 
EXEC sp_addlogin 'l_test','pwd','pubs' 
--为登录 l_test 在数据库 pubs 中添加安全账户 u_test 
EXEC sp_grantdbaccess 'l_test','u_test' 
--添加 u_test 为角色 r_test 的成员 
EXEC sp_addrolemember 'r_test','u_test' 
--拒绝安全账户 u_test 对 titles 表的 SELECT 权限 
DENY SELECT ON titles TO u_test 
/*--完成上述步骤后,用 l_test 登录,可以对jobs表进行所有操作,但无法对titles表查询,
虽然角色 r_test 有titles表的select权限,但已经在安全账户中明确拒绝了对titles的select权限,
所以l_test无titles表的select权限--*/
 --从数据库 pubs 中删除安全账户 
 EXEC sp_revokedbaccess 'u_test' 
 --删除登录 
 l_test EXEC sp_droplogin 'l_test' 
 --删除角色 
 r_test EXEC sp_droprole 'r_test'