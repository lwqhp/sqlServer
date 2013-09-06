

/*
访问sqlServer,即在sqlServer上建立一个连接。
如果客户端和SQLServer服务器在同一台机器上，这个连接就是本地连接。
如果客户端是在另一台机器上，那么连接要通过网络层。

连接建立后，客户端需要告诉sqlServer自己是谁，sqlserver需要认证是否为合法的sqlserver用户，从面赋预它预先设置好的
权力，这些工作由客户端数据驱动程序(ODBC,OLE DB Native Client JDBC等)和sqlserver交互完成，成功扣客户端用户才能开始
访问数据。

下面重点了解客户端和sqlServre 建立连接过程

sqlServer提供4种连接的通道(网络协议)
默认sqlServer配置4种通信协议 ：TCP/IP,VIA,Named Pipe ,Shared Memory

协议可在sqlserver配置管理器里查看和设置
shared memory协议仅能连接到本机的实例，在本机上仅使用此协议连接，可检查服务器sqlserver是否正常.
Named Pipes :为局域网而开发的协议。
TCP/IP : internet通信协议，适合所有场合，默认端口是1433
VIA : 和VIA硬件一同使用的协议，默认关闭。

*/