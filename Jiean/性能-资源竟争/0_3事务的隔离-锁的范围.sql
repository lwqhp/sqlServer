

--锁机制
/*
锁是事务隔离的一部份，sqlServer通过不同的资源申请不同的锁，然后针对锁的状态定义隔离级别和访问方法。
阻塞进事务隔离的体现，锁的粒度，时间是阻塞的源头。

在实际应用中，我们心中必须要有谱的是:
事务会产生什么锁，锁的范围有多大。时间有多久，其它那些事务产生的锁是兼容的。

通常我们说事务被隔离了，事务的范围过大，形成过多的事务被隔离出去了，这里的范围指的是指的粒度。

1）锁的粒度范围
索引锁：KEY 锁定索引上的某一行或某个索引键，用于防止糿读的索引行锁，也叫做键范围锁，这种锁类型使用范围和行组
	件，这个范围表示两个连续的索引键之间的索引键的范围，行组件表示索引实体上的锁类型。
行锁：RID 用于锁定堆中的某一行。
表锁：TABLE 锁定包括所有数据和索引的整个表。
页锁：PAGE 锁定数据库中的一个8KB页，例如数据页或索引页
范围锁：Extent 一组连续的8页
文件锁：FILE 锁定数据库文件
分区锁：HoBT 用于锁定表下面的某一个分区partition
数据库锁： DATABASE 锁定整个数据库

特殊锁：
应用程序专用锁：Application ：应用程序专用的资源
元数据锁：MetaDate
分配单元：Allocation_unit:一系列根据数据类型分组的相关页面，例如数据行，索引行，大型对象数据行

锁级别并不需要由用户来指定，锁管理器会自动确定，在访问少量行时，它一般首先行级和键锁以帮助并发，但如果多个行
锁的开锁变得很高，锁管理器自动选择合适的高级别锁。比如当单个t-sql语句在单个表或索引上获取5000多个锁或者sql
server实例 中的锁的数量超过可用内存阈值的时候，sqlserver会尝试启动锁升级。

执行一个查询时，sqlserver确定查询中引用的数据库对象所需要的锁级别，并且在获得必要的锁之后开始执行查询，在查
询执行期间，锁管理记录查询请求的锁数量，并且确定是否需要交从当前级别提升到更高级别。
可见，锁升级阈值由slqserver在事务期间动态确定，行锁和页面锁在事务超过阈值时自动升级为表锁，在锁升级到表级锁
时，所有该表上的较低级锁自动释放，锁管理器的动态锁升级特性优化了查询的加锁开销。

应用申请的锁粒度越小，产生阻塞的概率就会越小，如果一个连接会经常蝇请页面级，表级，甚至数据库一级的锁资源，程序
产生阻塞的可能性就会越大。
a,一个事务内部要访问或者修改的数据量越大，它所要申请的锁的数目就会越多，粒度也就可能越大
b,一个事务做的事情越复杂，它要申请的锁的范围也就会越大
c,一个事务延续的时间越长，它持有的锁的时间也会越长。
*/
--行锁
/*
这是数据库上范围最小的锁，表示格式为：databaseID:fileID:pageID:slot(row)
slot(row)表示在该页面中该行的置
*/
SELECT * FROM sys.dm_tran_locks
SELECT OBJECT_NAME(281474979397632) --resource_associated_entity_id 表名
SELECT DB_NAME(14) --resource_database_id 数据库名

--键锁，又叫索引锁
/*
对于聚集索引，表的数据页面和聚集索引的叶子页面相同，因为表和聚集索引的行相同，从表或聚集索引中访问行时，在
该聚集索引行或有限范围的行中只能获得一个关键字锁。

如果表具有聚集索引，那么数据行就在聚集索引的叶级别并且是被键锁而不是行锁锁定的。
*/
--查看键锁的特定资源
SELECT resource_description FROM sys.dm_tran_locks

--页锁
/*
申请一个8K页面锁，并标识为PAG锁。从查询计划中，锁管理器确定获得多个RID/KEY锁的资源压力如果压力较大，锁管理
器请深圳市一个PAG锁来替代。

页级锁减少锁开锁从而增进单个查询的性能，但是它阻塞该页面上所有行的访问从而损害数据库并发性。
格式：DatabaseID:fileID:pageID
*/

--区锁，也叫范围锁
/*
区是指一组连续8个8k的页面，这种锁用于在一个表上执行alter index rebuild命令并且该表从现有的区移动到新的区时，
在这期间，区的完整性用EXT锁来保护。
*/

--堆或B-树锁
/*
这是在堆或者B-树对象上的锁，通常指分区上的锁。
*/

--表锁
/*
在一个表上的表级锁保留了对整个表及其所有索引的访问，当执行一个查询时，锁管理器自动确定获得多个较低级别的锁
的开销，如果确定获取行级锁或页锁的资源压力较高，锁管理器直接为查询获取一个表级锁。

表级锁相对于其他锁来说需要的开销最少，从而改进了单个查询的性能，但同时，表锁阻塞囊个表包括索引上的所有写
请求，它可能显著损害数据并发性。

格式：databaseID:objectID
*/

--数据库锁
/*
当应用程序建立一个数据库连接时，锁管理器分配一个据库共享锁给对应的spid,这阻止用户意外地在其他用户连接时载
或者恢复数据库。
*/

--锁对象的实例需要从sys.partitions视图获取
SELECT 
request_session_id AS spid,
DB_NAME(resource_database_id) AS dbname,
CASE WHEN resource_type = 'object' THEN OBJECT_NAME(resource_associated_entity_id)
	WHEN resource_associated_entity_id = 0 THEN 'n/a'
	ELSE OBJECT_NAME(p.object_id) END AS entity_name,
	index_id,
	resource_type AS RESOURCE,
	resource_description AS DESCRIPTION,
	request_mode AS mode,
	request_status AS status
 FROM sys.dm_tran_locks t 
LEFT JOIN sys.partitions p ON p.partition_id = t.resource_associated_entity_id
WHERE resource_database_id = DB_ID()