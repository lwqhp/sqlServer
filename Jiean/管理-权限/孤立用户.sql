

--孤立用户
/*
复习下：
sqlserver的用户安全管理有两层，一层是服务器，一层是数据库，在两个层面上分配不同的权限。
服务器层帐号：叫登陆帐号:可以设置它管理整 个sqlserver 服务器，开启跟踪，修改sqlserver安全配置，备份所有数据库。
数据库层帐号：叫数据库用户：可以设置它对这个特定的数据库有读写，修改表格结构，存储过程定义等权限。

服务器层面的安全是设置在服务器的登陆帐号上的，所有登陆帐号的信息存放在master数据库中，可以通过视图sys.server_principats查看
服务器层面登陆帐号有两种，sqlserver帐号和window帐号，sqlserver的帐号SID是随机的，window帐号sid则跟域里SID一样。

数据库层面的帐号则是存放在数据库中的，可以通过视图sys.database_principale查看，数据库用户的SiD必须和服务器中的SID
一样才能建立起关联。

也就是说，当你把数据库移到一个新的服务器上时，如果同在一个域中，window帐号只需再添加一下就可以了。但sqlserver帐号
则是随机生成的SID,就没有办法和原来的数据库用户关联上的。
*/

--检测孤立用户
sp_change_users_login @Action='Report';
go
--更新SID关联
sp_change_users_login @Action='Update_on',@userNamePattern='database_user',@loginName='login_Name';