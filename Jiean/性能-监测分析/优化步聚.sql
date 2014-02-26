

/*语句优化步聚*/

/*
1)从实例级别入手，找出什么类型的等待占用了大部分的等待时间

2)找出和等待有关的队列信息，以找出有问题的资源，比如：
等待和io有着，可查看io相关的计数器

page life expectancy 没有被引用的页在缓冲池中平均停留时间。


3）细化到数据库、文件级别
找出哪些数据库占用了大部份等待开销，在数据库内，还需要再细化到文件类型(数据和日志)，因为文件的类型决定了要
采取的行动方案。

4)细化到进程级别
也就是要找出优化的进程（存储过程，查询等），一般用跟踪比较好

5）优化索引和查询