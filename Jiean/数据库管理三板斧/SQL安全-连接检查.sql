

--连接检查
/*
不用传统的步骤方法，而是用层次深入的检查

开始:
尝试连接，定位有可能原因的范围
1，正常连接，判断错误信息是否是连接问题
2，指定协议连接，判断协议是否正常通信

找原因：
---------------第一层-----------------------------------------
最外围window事件，查看事件日志是否干净，发生什么错误.

---------------第二层--检查服务器端配置的设置----------------------------------------------
启用或禁止相关的网络协议：
SqlServer配置管理器-->SqlServer网络配置，端口设置

注册表：HKEY_LOCAL_MACHINE\SHOTWARE\Microsoft\Microsoft SqlServer\MSSQL.X\SMSQLServer
\SuperSocketNetLib下的各个项目里。

---------------第三层--检查服务器端配置是否生效----------------------------------------------

a)ipconfig /all //查看本机IP
b)netstart -an  //查看端口是否启用
c)telnet ip地址 端口号  //使用远程连接端口，查看ip,端口是否可以连接

d)如果用其它协议能连上服务器，也可以查看日志，查看服务是否侦听协议

查看sql日志：源：服务器
1,Shared Memory正常启动信息：
Server local connection provider is ready to accept connection on [ \\.\pipe\SQLLocal\SQL2008 ].

2，Named Pipe正常启动信息：
Server named pipe provider is ready to accept connection on [ \\.\pipe\MSSQL$SQL2008\sql\query ].

3，TCP/IP正常启动信息，可以看到SqlServer实例 在侦听的IP地址和端口号：
Server is listening on [ 'any' <ipv4> 52604]. //侦听所有IP地址的52604端口
Server is listening on [ 127.0.0.1 <ipv4> 52605]. //侦听本机的52604端口

SqlServer Bowroer服务
*/