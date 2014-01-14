

--网络分析
/*
byte total/sec(每秒总传输字节数) ：计数器来确定网络接口卡NIC 或网络适配器的工作状况，高值以表示大量的成功传
输，接着，将该值与反映每个适配器带宽的network interface\current bandwidth 性能计数器比较
为了使用通信有一定的余量，平均通常应该不多于容量的50%,如果该值接近于连接的容量而处理器和内存使用是适度的，
那么该连接可能是个问题

%net utilzation 网络利用率 ：计数器表示在一个网段上网络带宽的使用比例 ，这个计数器的阈值取决一网络的类型。

优化方案：
1，优化应用程序工作负载
2，增加网络适配器
3，节制和避免中断
*/