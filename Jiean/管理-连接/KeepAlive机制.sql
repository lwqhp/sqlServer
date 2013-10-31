

--KeepAlive(保持活动状态)机制
/*
一个TCP/IP连接，当该连接空闲时间(没有任何网络层的数据包交互)超过keepAlive所设定的时间，SqlServer将关闭该连接,回收该连接所占用的资源.

设置及运行机制--------

在'配置工具'->'sqlserver配置管理工具'->sqlserver网络配置，设置TCP/IP协议的保持活动状态,默认是30秒,keepaliveinterval 为1秒，
window TCP配置的TCPMaxDataRetransmissions默认为5次

当TCP连接空闲了30秒，那么TCP会发送第一个KEEPALIVE检查，如果失败，那么tcp会每隔1秒重发keepalive包，直到重发5次。
如果5次检测依然失败，则该连接就被关闭。

同理，客户端也可以配置自己的KeepAlive时间，区别在于这是针对客户端的连接监控，客户端tcp通过keepalive包监控连接情况，
如果它发现连接有问题，就会关闭连接。

？这个连接机制能反映些什么呢
1,如果连接出现异常，比如客户端突然失去响应,没有任何交互行为，当这种情况超过35秒后，服务器就会彻底断开连接.

2,连接即使没有任何人使用，只要keepalive检测包正常响应，则连接会一则存在，可以查看连接的空闲时间。

3,在平时做trace跟踪的时候，就建议用spid来筛选，因为这个特性，连接进程会因为关掉而跟踪不到。
*/
--查看连接空闲时间
select session_id,
last_read,datediff(ss,last_read,getdate()),
last_write,datediff(ss,last_write,getdate()),
* from sys.dm_exec_connections