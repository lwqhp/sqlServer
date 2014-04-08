

--SQL Nexus
/*
主要记录工具自带的监测脚本的

启用选项：enabled = "true"

默认情况，PerfStats会从运行的本地计算机上所有的实例中收集数据。
指定实例：instance name = 'mssqlserver'

如果从故障转移群集收集数据，那么两个参数都需要指定，计算机名是虚拟实例名称的第一部分，实例名是第二部份，
不使用物理节点的计算机名
<machine name = ".">
<instance name ="MSSQLSERVER">

导入数据
sqlNexus数据库一次只能存储一个实例的数据，因此在每次运行导入的时候都会重新创建。

*/