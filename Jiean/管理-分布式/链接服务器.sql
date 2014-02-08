

--链接服务器
/*
跨平台数据访问是通过OLEDB 访问接口连接远程的数据源，oledb 由微软开发，是用来提供到各种不同的数据源的一致
性访问 的一组组件对象模型COM接。为了建立从sqlServer实例到另一数据源的访问，需要选择适当的oledb访问接口。

概括的说，链接服务器是建立到远程数据源的连接的一种途径，依赖用来设置链接服务器的oleDB驱动可以执行分布式
查询来检索数据，或在远程数据源上执行操作。
*/

--创建链接

EXEC sp_addlinkedserver @server='Joerod\node2',@srvproduct='SQL Server'

--修改链接服务器属性
EXEC sys.sp_serveroption @server = 'Joerod\node2', -- sysname
    @optname = 'query timeout', -- varchar(35)
    @optvalue = N'60' -- nvarchar(128)

--查看链接服务器信息
SELECT * FROM sys.servers WHERE is_linked=1

--删除
EXEC sp_dropserver @server='Joerod\node2',
@droplogins='droplogins' --删除链接服务器前要删除登录名映射

--创建链接服务器登录名
/*
当在链接服务器上执行分布式查询时，sqlserver会将本地登录和凭据映射到链接服务器，基于远程数据源的安全性，凭
据可能会被接受或是拒绝。
*/

--显示创建登陆名映射
EXEC sp_addlinkedsrvlogin @rmtsrvname='joeprod\node2',
@useself='false',--使用远程服器的帐套
@locallogin=NULL,--所有本地sqlserver连接的登妹名都会射到test登录名上
@rmtuser = 'test',--以这个用户执行远程服务器上的查询
@rmtpassword='test1'

--查看链接登录名
SELECT * FROM sys.linked_logins	a
INNER JOIN sys.servers b ON a.server_id = b.servier_id
LEFT JOIN sys.server_principals c ON c.principal_id = a.local_principal_id
WHERE b.is_lined=1

--删除链接服务器登妹名
EXEC sp_droplinkedsrvlogin @rmtsrvname='joeprod\node2',@locallogin=NULL

--其它分布式查询------------------------------------------------------------------------------
/*
OpenQuery 命令通过发送以传递查询形式，来查询链接服务器，传递查询在远程服务器上完整地执行，并且将结果返回
到调用的查询。
*/
SELECT * FROM OPENQUERY([joeprod],'select * from master.sys.dm_os_erformance_counters')

--openrowset创建一个到数据源的临时的连接，没有使用既有的链接服务器连接查询远程数据源
SELECT * FROM OPENROWSET('oledb接口标识符','serverName','username','pwd','t-sql')

--从文件中读取数据
SELECT * FROM OPENROWSET(BULK 'c:\a.txt' --数据文件
,FORMATFILE='c:\b.txt' --数据格式文件
,FIRSTROW=1 --开始导入的行号
,MAXERRORS=5 --错误允许的行数
,ERRORFILE='c:\c.txt'--保存被拒绝行的错误文件
,SINGLE_CLOB --以ascii文本的格式导入数据
) AS contacttype