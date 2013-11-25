

/*
sql服务配置 sqlserver所能提供的功能和操作。数据库配置 数据库运行的状态，工作方式（自动选项，可用性选项，事务的快照隔离选项）

Sql Server 服务

在window中，通过常驻服务为用户提供各种功能，sqlserver也不例外，一个sqlserver进程或组件都有一个对应window服务

在window服务面板中，可以设定服务的启动，停止，暂停，启动状态，设置服务的登录身份。

设置 服务的登陆身份（一般不推荐）

服务的登录身份决定了服务访问操作系统各项资源时所拥有的权限。并且对某些资源的访问权限是必需的，如果登录不具有对
某些资源的访问权限，则会导致服务无法启动（正常工作）。

注:在服务中配置sqlserver各项服务的登录身份时，配置处理程序不会为所配置的登妹授予任何权限，因此要求在配置前设置
好登 录应该具有的权限，否则会导致服务无法启动。

注：登录身份有权限才能启动服务。

使用sqlserver配置管理器 ，除了包括服务的基本配置外，还可以自动完成登录启动服务所需要的各项权限分配，SMO或WMI更
改密码无需重新启动服务便可立即生效。

可查看服务进程ID，二进制路径等，配置启动参数
通过启动参数可以控制sqlservere服务启动的方式 ，比如最小配置启动，单用户模式启动

登陆身份3+1

Local System :本地系统帐户，这是一个操作系统内置帐户，对于服务器操作系统具有本地一切权限，但此帐户不具有访问网络
的权限。如果要在服务中访问网络资源，则需要将服务的登录身份设置为指定的用户。


sql server除了提供【sqlserver配置管理器】以服务的基本配置，还提供一个存储过程对所有服务器功能的服务项设定配置
*/

sp_configure 


/*
数据库配置选项

数据库的配置设定，除了可以在数据库右键，属性里的对数据库的设置，还可以使用使用 Alter DataBase 命令对数据库进行操作

*/
Alter DATABASE 


--安全权限

/*
1,连接安全：保证只有许可的客户端能够以指定的方式（主要体现在使用哪种网络协议）连接到Sqlserver.

2,登陆验证：登录验证保证从许可客户端发出的登录请求是合法的。

3，权限配置：权限配置控制合法登录所能从事的具体操作。
*/

--连接安全
/*
连接的安全通常放在防火墙上，对连接进行过滤，比如：只允许与指定的IP地址建立1433的通讯。
这里只是从sqlServer引擎角度了解客户端和服务器端实例连接的过程，
以问题的排查提供依据。

SqlServer是通过网络协议和TDS端点在client-Server之间通信的。
默认sqlServer配置4种通信协议 ：TCP/IP,VIA,Named Pipe ,Shared Memory

协议可在sqlserver配置管理器里查看和设置
shared memory协议仅能连接到本机的实例，在本机上仅使用此协议连接，可检查服务器sqlserver是否正常.
Named Pipes :为局域网而开发的协议。
TCP/IP : internet通信协议，适合所有场合，默认端口是1433
VIA : 和VIA硬件一同使用的协议，默认关闭。

注：【sqlserver网络配置】：用于配置服务端网络协议
	【sql native Client】:用于客户端协议配置
	
DTS是工作在网络协议中的一种数据包格式（表格格式数据流），DTS端点是对DTS的实例化对象，用于配置。
在这里，可以查看，设置 服务端的DTS端点状态
*/
SELECT * FROM sys.endpoints 
ALTER ENDPOINT  [TSQL Default VIA] STATE=STARTED
ALTER ENDPOINT [TSQL Default VIA] STATE=STOPPED


/*
默认每种协议都有一个对应的DTS端点

用户也可以定义自己的DTS端点，作些管控

*/
--在“SQL Server 配置管理器”的“SQL Server 2005网络配置中”，禁止除TCP/IP之外的所有协议；

-- 使用如下的T-SQL禁止默认的TCP端点
ALTER ENDPOINT [TSQL Default TCP] STATE = STOPPED

--使用如下的T-SQL建立新的TCP端点和授权
USE master
GO
-- 建立一个新的端点
CREATE ENDPOINT [TSQL User TCP] --端点名称
STATE = STARTED
AS TCP(
   LISTENER_PORT = '1433',
   LISTENER_IP = ('192.168.1.1')  -- 侦听的网络地址
)
FOR TSQL()
GO

-- 授予所有登录(或者指定登录)使用此端点的连接权限
GRANT CONNECT ON ENDPOINT::[TSQL User TCP]
TO [public]

--只有通过网络地址配置为192.168.1.1的网卡接入的客户端才能访问SQL Server
/*
安全对象，是SQL Server 数据库引擎授权系统控制对其进行访问的资源。通俗点说，就是在SQL Server权限体系下控制的对象，因为所有的对象(从服务器，到表，到视图触发器等)都在SQL Server的权限体系控制之下，所以在SQL Server中的任何对象都可以被称为安全对象。

    和主体一样，安全对象之间也是有层级，对父层级上的安全对象应用的权限会被其子层级的安全对象所继承。SQL Server中将安全对象分为三个层次,分别为:

        服务器层级
        数据库层级
        构架层级
*/
-------------------------

--登陆验证
/*
登陆的第一步，帐号验证，包括服务器验证的方式和帐号有效性（用户名和密码正确）

服务器有两种验证模式：window身份验证和混合模式

在混合模式下，sqlServer帐号必需是个有效帐号。
在window身份验证和混合模式下，window帐号必须的sqlServer中已映射到sql用户，且是window系统中有效用户，名称必须是
“域名\用户名或者组名”这样的宛全限定名称。

登陆验证是否通过跟两个方面有关：
1）sql服务器验证模式是否匹配：
	主要是window身份验证模式下，使用了sqlServer登陆名。
	--在实例的服务器属性的【安全性】可以设置验证的方式。
	
2）登陆帐号是否为有效帐号：
	window帐号是 "是window系统中有效用户",“帐号必已映射到sql用户（登陆名）”，“名称是域名\用户名或者组名”这样的完全限定名称”,"密码正确"
	sqlServer帐号是 “sqlServer中已创建登陆名”，"密码正确"

1,要知道这些内置登陆名作什么用的

以"##"开头和结尾的用户是sqlserver内部使用的帐户，由证书创建，不应该被删除。
sa :不能被删除，最高权限者。
NT Authority\networkServer ：是以网络帐户启动sqlserver服务使用的登陆名。
NT Authority\System ：本地系统帐号登陆使用的登陆名，如果sqlserver服务是以“本地系统帐户”登陆，不能删。

2，登陆帐号能分配那些权限

能在服务器级别做那些操作
1)sql服务器实例级别权限，由所属服务器固定角色决定

能对单个数据库做什么操作
2)由帐号映射到那些数据库用户而定，默认会在具体数据库中创建指定用户名。

安全对象
服务器级可以设置的安全对象：端点，登陆名，服务器


服务器角色(7)+2
bulkadmin : administer bulk operations
dbcreator : create database
diskadmin : alter resources
processadmin : alter any connection,alter server state
securityadmin: alter any login
serveradmin : alter any endpoint ,alter resources,alter server state,alter settings,shutdown,view server state
setupadmin : alter any linked server
sysadmin : control server

public角色：服务器默认角色，所有登陆名都会属于这个角色，public只有 view any database的权限
(如果你在服务器角色中没有看到public，那么很可能是因为你没有安装sql server的最新补丁包（sql server 2005 sp2)的问题)

*/



--权限控制----------------------------------------------------------------------------------------
/*
角色：服务器固定角色和数据库固定角色
固定角色是不能自定义的，角色定义了对安全对象操作的范围，用户分配所属的角色

 默认固定角色已授于服务器级所有数据库

在数据库中能进行那些操作，由数据库的用户权限限制(在数据库级别，主体是用户和角色)

1，有那些内置用户
Dbo : 数据库的默认用户，不能删除
Guest :来宾账户,允许登录名没有映射到数据库用户的情况下访问数据库。默认情况下guest用户是不启用的
INFORMATION_SCHEMA用户和sys用户拥有系统视图，这两个数据库用户不能被删除

2,所属那些角色
Public角色: 拥有的权限自动被任何主体继承，所以对于Public角色的权限修改要格外小心

数据库固定角色(8)+2
db_owner :可以执行数据库的所有配置和维护活动


db_accessadmin alter any user,create schema 访问授权管理员
db_accessadmin :connect
db_backupoperator : backup datebase,backuplog ,checkpoint
db_datereader : select
db_datawrite : delete,insert,update
db_ddladmin ： 所有ddl命令
db_securityadmin : alter any application role,alter any role,create schema,view deinition
dB_denydatareader : 拒绝 select 
db_denydatawrite :  拒绝 delete ,insert,update

*/
--每一个登陆名都会在这写入一条记录
select * from sys.sql_logins


/*
架构

理解为命名空间，


--授权

对于父安全对象上设置的权限，会被自动继承到子安全对象上。
 比如，我给予主体CareySon(登录名)对于安全对象CareySon-PC(服务器)的Select(权限),
 那么CareySon这个主体自动拥有CareySon-PC服务器下所有的数据库中表和视图等子安全对象的SELECT权限
 
授权原则：
自顶向下，由广到窄， 最小授权

服务器-数据库
角色-用户名
=号授权
*/

--语法
GRANT { ALL [ PRIVILEGES ] }
      | permission [ ( column [ ,...n ] ) ] [ ,...n ]
      [ ON [ class :: ] securable ] TO principal [ ,...n ] 
      [ WITH GRANT OPTION ] [ AS principal ]
DENY { ALL [ PRIVILEGES ] }
      | permission [ ( column [ ,...n ] ) ] [ ,...n ]
      [ ON [ class :: ] securable ] TO principal [ ,...n ] 
      [ CASCADE] [ AS principal ]
REVOKE [ GRANT OPTION FOR ]
      { 
        [ ALL [ PRIVILEGES ] ]
        |
                permission [ ( column [ ,...n ] ) ] [ ,...n ]
      }
      [ ON [ class :: ] securable ] 
      { TO | FROM } principal [ ,...n ] 
      [ CASCADE] [ AS principal ]            

grant select--权限
 ON Schema::SalesLT--类型::安全对象
  to careyson--主体

deny select--权限
 ON Schema::SalesLT--类型::安全对象
  to careyson--主体

revoke select--权限
 ON Schema::SalesLT--类型::安全对象
  to careyson--主体


/*
作业
1,清楚固定角色的作用和范围
*/
---小结

--
DENY VIEW any DATABASE to PUBLIC;

--然后给Best库的Best用户执行：
ALTER AUTHORIZATION ON DATABASE::Best TO Best