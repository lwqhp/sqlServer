

/*
访问sqlServer,即在sqlServer上建立一个连接。
如果客户端和SQLServer服务器在同一台机器上，这个连接就是本地连接。
如果客户端是在另一台机器上，那么连接要通过网络层。

连接建立后，客户端需要告诉sqlServer自己是谁，sqlserver需要认证是否为合法的sqlserver用户，从面赋预它预先设置好的
权力，这些工作由客户端数据驱动程序(ODBC,OLE DB Native Client JDBC等)和sqlserver交互完成，成功后客户端用户才能开始
访问数据。

下面重点了解客户端和sqlServre 建立连接过程

---------------第一层--连接方式----------------------------------------------

sqlServer提供4种连接的通道(网络协议)
默认sqlServer配置4种通信协议 ：TCP/IP,VIA,Named Pipe ,Shared Memory


Shared Memory （lpc）:最简单协议，不需要什么设置，只能连接同一台订算上运行的sqlserver实例。
多用在检测连接故障中以确定连接问题是和网络层有关，还是和sqlserver自己有关系。本地连接速度最快。

TCP/IP ：标准的网络通信协议,适合所有场合，默认端口是1433

Named Pipe :局域网传输协议，基于命名管道的连接方式。
	服务器通过CreateNamedPipe函数创建命名管道并进行监听。
	客户端使用API函数连接到服务器的命名管道。
	命名管道可以配置工具协议里查看和设置 \\.\pipe\MSSQL$SQL2008\sql\query
使用命名管道有一些好处：仅限于内网，安全性高，连接命名管道要通过windows认证，使用window 内置的安
全机制，如果你没有访问sqlServer服务器的文件系统的权限，也就无法使用命名管道访问sqlServer

VIA : 和VIA硬件一同使用的协议，默认关闭。

2），SqlServer提供3种数据驱动控件的支持实现数据访问

客户端应用可以使用sqlServer支持的数据驱动组件与sqlServer连接访问
1，MDAC(Microsoft 数据访问组件)
这个组件包括传统的ODBC和OLEDB接口，主要是非.net的应用服务

2,SQL Servr Native Client
这个基于OLEDB 和ODBC的独立数据访问应用程序编程接口(API),包含sql2005,2008中引入的新功能。
主要用于客户端工具连接到sqlServer网络库，仅影响跟随sqlserver 一起启动的客户端工具和依赖于sqlServer工具之类的应用程序

3，Microsoft JDBC Provider
专门供JAva应用程序使用的数据接口。

---------------第二层--连接机制----------------------------------------------
使用基于命名管道的Named Pipe局域网传输协议，需要指定管道的名字.

使用TCP/IP协议
sqlServer通过侦听指定的端口传入的请求来进行连接。（在TCP/IP 路由顺通的前提下），相应的应用对特定
服务器(IP地址)的指定端口发送请求连接。


对于不确定端口号的连接请求，sqlServer采用SSRP协议侦听UDP1434端口来把服务器实例的端口号和管道信息
返回给应用端，而负责这一过程的就是Sql Server Borwser服务。
SSB 侦听UDP端口，并接爱未经身份验证的请注，为了防止恶意用户利用这个服务攻击sqlServer 服务器，SSB
将设置在低特权用户的安全上下文中运行。
SSB的权限有：
1，拒绝通过网络访问该计算机。
2，拒绝本地登录。
3，拒绝以批处理作业登录
4，拒绝通过“终端服务”登录。
5，作为服务登录
6，读取和写入与网络通信相关的sqlServer注册表项。




---------------第四层--客户端连接----------------------------------------------
1，客户端使用与服务器端交集的协议进行连接请求

	TCP/命名通道设置：
a,MDAC数据库接口 ：运行cliconfg.exe

b,SqlServer配置管理器-->Sql Native Client 10.0配置--启用客户端使用的协议

2，对于服务器上的多个不同实例，通过先对UDP 1434向sqlserverBrowser通信，Sql Server Browser会
告诉客户端它想要连接的实例的端口号和管理名字。这对于客户端来讲这是透明的。

3，客户端使用指定协议连接顺序：
a,在连接字符串中指定网络协议
	server=[protocol:]Server[,port] 或者 NetWork= dbnmpntw(named pipe)| dbmssocn(TCP/IP)
	例子：tcp:IF-PC\SQL2008,52604
b,使用别名设置代替服务器名+端口号 不行啊

c,寻找相应数据驱动程序的"LastConnect"注册表记录。

d,最终按照数据库驱动程序的网络配置优先级选择网络协议，询问SSB 动态得知端口号或管道名字。

---------------第五层--连接机制深入----------------------------------------------
命名管道
这是建立在服务器的PIC$共享基础上，通过IPC$共享来进行通信，管道的名称也与网络共享类似，都是格式

首先，sqlServer在服务器上创建一个命名管道并监听它，然后客户端即连接到这个管道上来进行对话，对每
一个客户端管道连接请求sqlServer都会创建一个新的管道实例来与之进行通信。

命名管道的格式：
\\server\Pipe\path_name
server:管道所在服务器的名字，本地服务器用. 表示。
Pipe : 固定硬编码。表明是管道协议。
path_name : 命名管道的名字，可以是多级目录。sqlserver监听的是两级目录,即\sql\query.
	例如：默认实例 ：\\.\pipe\query 
		  命名实例： \\.\pipe\Mssql$instancename\sql\query
注：名字可以在SqlServer服务器配置工具中进行设置。



---------------第六层--连接实战----------------------------------------------

命名管道

在SSMS中的服务器处输入命名管道路径地址即可，跟客户端是否启用管道协议无关，不理解

检查环节
1,服务器端是否正确配置命名管道并确认sqlserver已经临听了命名管道协议
2，使用客户端网络实用工具检查客户端的连接协议配置，确何启用了命名管道。而且和sqlServer服务器
监听的一致，另要仔细查看是否存在错误的sqlServer别名。
3，检查网络连通性，例如要确保不但能ping 通sqlserver服务器的IP地址，也能够ping 通sqlserver服务器的名称。
4，检查客户端是否能够通过sqlSerer服务器的windows认证。
	net view \\servername
	net use \\serername\IPC$
5,确保客户端登录帐号有权限访问sqlServer,建议使用sqlserver帐号能连通之后，再使用windows帐号。

有两个方法检查连接的结果
a,select net_library from master..sysprocesses where spid>50
b,在 obdcad32.exe中建立DSN连接来测试
	通过查看连接返回的使用协议和错误信息了解连接状态
	net helpmsg 53 //查看错误代码说明
	
TCP/IP连接

首先要为sqlServer所在机器的网卡配置好TCP/IP协议并获得一个IP地址(通过静态指定分配或从DHCP服务
器动态获得)，接下来要通过服务器端网络配置工具配置sqlServer监听TCP/IP协议。

注：如查机器的IP地址改变，只需重新启动sqlserver就可以了，sqlserver 会自动监听机器的新IP地址，
无须重新安装或配置sqlServer.

监听端口号在服务器配置工具里设置
端口默认是1433,它可以指定一个固定端口号，一般是1024以下或者5000以上，也可以是动态端口，由sqlserver
每次启动绑定。

检查端口号的方法
netstat -an //列出系统所有使用中的端口号。
1，验证sqlserver是否确实监听了 TCP/ip协议
查看有服务器sql日志

2,验证服务器监听的tcp/ip端口和客户端配置的默认值 或别名中指定的值一致。

3，检查网络连通性
要确保不但能够ping 通sqlServer服务器的IP地址，也能够ping通sqlServer服务器的名称，如果ping 服务
器名字有问题，说明DNS或wins服务器配置有问题，可以在hosts文件(system32\drivers\etc)中手工加入
IP地址和服务器对 
169.254.217.132	SQL2008

如果ping IP都有问题，则要检查网络的配置。

4，使用telNet命令检查sqlServer监听的端口
telnet 169.254.217.132 1433

5,检查登录用户的sqlserver访问权限

特殊：
在ssms中指定连接的协议和端口
tcp:if-pc\sql2008,26052


---------------检查服务器端配置的设置----------------------------------------------
启用或禁止相关的网络协议：
SqlServer配置管理器-->SqlServer网络配置，端口设置

注册表：HKEY_LOCAL_MACHINE\SHOTWARE\Microsoft\Microsoft SqlServer\MSSQL.X\SMSQLServer
\SuperSocketNetLib下的各个项目里。

*/



