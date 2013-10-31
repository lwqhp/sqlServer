

--Ring Buffer 排查连接问题
/*
SQL Server 2008新增的一个功能，Connectivity Ring Buffer，它捕捉每一个由服务器发起的关闭连接记录(server-initiated connection closure)，
包括每一个session或登录失败事件，来解决一些特别棘手的连接问题。

为了进行有效的故障排除，Ring Buffer会尝试提供客户端的故障和服务器的关闭动作之间的关系信息。
只要服务器在线, 最高1K的Ring Buffer就会被保存，1000条记录后，Buffer开始循环覆盖，即从最老的记录开始覆盖。

该功能默认开启
*/

--DMV查询
SELECT CAST(record AS XML),* FROM sys.dm_os_ring_buffers 
WHERE ring_buffer_type='RING_BUFFER_CONNECTIVITY'


/*
Connectivity Ring Buffer 记录的三种记录类型分别是：ConnectionClose，Error，和LoginTimers
<TdsBuffersInformation>记录客户发的TDS包中有多少bytes，并且可以知道是否在TDS中有任何的错误
<TdsDisconnectFlags>记录了关闭连接的状态

<SspiProcessingInMilliseconds>21756</SspiProcessingInMilliseconds>

SSPI（Security Support Provider Interface），是一个SQL Server使用Windows Authentication的接口。
当Windows login是一个domain account，SQL Server使用SSPI和Domain Controller交互，
从而验证用户身份。记录中可以看到，SSPI过程占用了大量的时间，这表明和Domain Controller交互时有延时，
很有可能是SQL服务器和DC之间的物理连接有问题，或者DC上的一些软件问题。可以看到，我们没有进行网络抓包，
也没有重现问题，我们就已经把问题缩小到SQL Server和Domain Controller之间的交互上面来了。


<Frame>tags是什么？
通过sys.dm_os_ring_buffers DMV 可以访问一系列内部信息，它包含了但不仅限于Connectivity Ring Buffer。
作为DMV基础的一部分，大多数的Ring Buffers 提供了事件发生时的栈踪迹（stack trace），
每一个<frame>提供了一个十六进制的函数地址。这些都可以分解为函数名，并dump Sqlservr.exe进程，
在WinDbg打开dump，并采用基于函数的地址的LM命令。

----------------------------
如果你在客户端看到一个错误，但是在Ring Buffer中没有记录，这就表明服务器看到的是一种“重置”类型的连接关闭，
这种连接关闭类似于客户端正常关闭连接的行为，或者是由于服务器外部因素所造成的连接关闭；
（例如，一个网络硬件的故障）。如果是这种情况，你就需要关注潜在的网络互联问题。
如果你在Ring Buffer中看到了一个条目它可以指出为什么服务器要关闭这个链接，那么这个条目就很可能可以极大的帮助我们进行故障排查。
例如，如果你看到一个连接关闭是由于TDS包中的信息不合法，那么你就可以去检查那些可能会损坏网络包的设备，包括网卡，路由和集线器等。


通过使用一个trace flag，可以让Connectivity Ring Buffer记录所有连接关闭事件。
这样你就能观察到客户端发起的连接关闭的情形和潜在的错误。

有两个trace flag，可以用于改变Connectivity Ring Buffer 的行为。

*/
--完全关闭Connectivity Ring Buffer：
DBCC TRACEON (7826, -1)

--跟踪客户端的连接关闭
DBCC TRACEON (7827, -1)
/*
默认情况下客户端发起的连接关闭是不被记录的（因为这是正常的情况，而不是一个错误）；当一个客户结束的它的session，
它就断开。一般来说，我们建议不要去跟踪客户端发起的连接关闭，
因为真正有用的Buffer记录会被覆盖（当你有很多正常表现的连接时，这种情况发生可能性会很大），
或者会被隐藏在一个堆正常情况的记录中。这会使你错过真正的错误问题。
*/