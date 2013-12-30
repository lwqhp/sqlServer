

--查看数据库配置信息
SELECT * FROM sys.configurations

--数据库配置存储过程
EXEC sys.sp_configure
	@configname = '', -- varchar(35)
    @configvalue = 0 -- int
RECONFIGURE --强制更新当前的配置值
WITH oerrie --对于不合法的值，会提示警告，甚至拒绝更新，此参数会强制修改这个选项值


--查看数据库选项
SELECT name,is_read_only,is_auto_close_on,is_auto_shrink_on,* FROM sys.databases
WHERE name='test'

--配置ANSI SQL选项
/*
ansi这是美国的一个国家标准学会定制的sql相容性默认值
*/

--数据库的状态
/*
online 联机：数据库是打开的并且是可用的
offline 离线：数据库是关闭的，并且不可以修改或被任何用户查询
emergency 紧急：允许服务器角色sysadmin登陆到数据库的只读访问，允许查询所有仍可以访问的数据库对象。
*/

ALTER DATABASE Test
SET ONLINE | OFFLINE | EMERGENCY


--修改数据库拥有者

EXEC sp_changedbowner 'lwqhp'