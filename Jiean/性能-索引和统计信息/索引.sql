

--索引
/*
一个索引：是指按B树结构组织的索引页集合，在这个索引B树结构中的每一页称为一个索引节点，B树的项端节点称
为根节点，索引中的底层节点称为叶节点，根节点与叶李点之间的任何索引级别统称为中间级。索引页中的每个
索引行包含一个键值和一个指针，该指针指向B树上的某一中间级页或叶级索引中的某个数据行，这是一个双向
链接列表。


其中，叶级别也是聚集索引和非聚集索引的主要区别：如果是聚集索引，叶级别是实际的数据页本身，而非聚集索引则是指
向堆或聚集索引数据页的指针。

索引有一些限制，比如索引键列组合起来不能超过900字节，一个索引中最多可以使用16个键列，在索引键中不可以使用大
值对象数据类型。

语法结构
CREATE [UNIQUE] [CLUSTERED|NONCLUSTERED] 
    INDEX   index_name
     ON table_name (column_name…)
      [WITH FILLFACTOR=x]
       UNIQUE表示唯一索引，可选
       CLUSTERED、NONCLUSTERED表示聚集索引还是非聚集索引，可选
       FILLFACTOR表示填充因子，指定一个0到100之间的值，该值指示索引页填满的空间所占的百分比

来点通俗的吧
CREATE [索引类型] INDEX 索引名称 ON 表名(列名)
WITH FILLFACTOR = 填充因子值0~100

用create index 命令可以创建两种索引类型，聚集索引和非聚集索引(默认情况下是非聚集索引),以及带唯一约束的非聚集索引，又叫唯一索引

几种索引，约束间的关系

建表或是在表设计中添加主键的同时，会默认生成一个聚集索引
唯一索引是对索引列的唯一约束，可以有多个唯一索引（因为其本质是非聚集索引）,允许索引列null值存在。
GO

一些指导些建议
1,基于高优先级和使用频繁的查询增加索引
2，选择很少改变，高度唯一数据类型宽度狭窄的列作为聚集索引键
3，非聚集索引对返回小的数据集非较有较，对大的数据集一般
4，为那些定位在只读文件组或数据库上的索引使用100%填充因子，因为完成查询的结果集需要较少的数据页，所以这减少
了i/o操作并且可以提升查询性能。
*/

--创建索引
SELECT * FROM a
CREATE NONCLUSTERED INDEX IX_aa ON a(a)

--索引排序
CREATE NONCLUSTERED INDEX IX_aa2 ON a(a DESC)--默认是升序

--查看索引
EXEC sp_helpindex 'a'

SELECT * FROM sys.indexes WHERE object_id = object_id('a')

--禁用索引
SELECT * FROM a
/*因为聚集索引的叶级别就是实际的表数据本身，禁用意味着同时表数据不可访问,但索引的定义还保留在系统表中，
对于表上的非聚集索引，索引数据真天从数据库中删除了，对于表上的聚集索引，数据仍留在磁盘上，但因为索引是
禁用的，你不可以查询它，对于视图上的聚集或非聚集索引，索引数据从数据库中被删除。

*/
ALTER INDEX PK_a ON a DISABLE

--删除索引
DROP INDEX a.PK_a
/*
不可以使用drop index删除因创建primary key ak unique constaint 而产生的索引，如果你删除在其上拥有非聚集索引
聚集索引，为了交换聚集索引键到堆的行标识符，那些非聚集索引也将被重建。
*/

--索引重建和修改(不能改名)
CREATE CLUSTERED INDEX PK_a ON a(a) 
WITH (DROP_EXISTING=on) 

ALTER INDEX ALL ON a REBUILD 


--将新的列添加到即有的非聚集索引中
CREATE NONCLUSTERED INDEX IX_aa ON a(a,a2) WITH (DROP_EXISTING=ON)

-- 在tempdb中创建临时索引
/*
如果索引创建时间比期望的要长很多，可以尝试使用索引选项sort_in_tempdb，来把索引放在tempdb数据库中，而不是使用
索引所在的用户数据库，来提升索引创建性能(对于大型表)
*/

CREATE NONCLUSTERED INDEX IX_aaa ON a(a,a2) WITH(SORT_IN_TEMPDB=ON)

--控制创建索引的并行执行计划
/*
 限制索引创建的并发性可能会提升在创建过程中用户活动的并发性，但也可能增加索引创建花费的时间。maxdop并不能保
 证slqserver将实际使用指定的处理器的数量，它只是确保sqlserver不会超过maxdop的限定值。
*/

CREATE NONCLUSTERED INDEX IX_aaaa ON a(a,a2) WITH (MAXDOP=2)

--在创建索引的过程中允许用户表访问
/*
只有共享意向锁保持在源表上，而不是索引创建过程中的默认的长时间表锁保持行为。
*/
CREATE NONCLUSTERED INDEX IX_aaaaa ON a(a,a2) WITH (ONLINE=ON)


--包含索引
/*
包含索引可以允许添加最多1023个非键列到非聚集索引，通过创建覆盖索引帮助提升查询性能，这些非键列没有存储在索
引的所有级别上，而只是存在于非聚集索引的叶级别上.
只可以对非聚集索引使用，并且仍然不可以包含废弃的image,ntext,以及text数据类型。
*/

CREATE NONCLUSTERED INDEX IX_a5 ON a(a,a2) INCLUDE(a,a2)

--填充因子
/*
索引的填充因子百分比：是指首次创建索引时索引页的叶级别充满程度，如果没有显式设置填充因子，则它默认为0,既尽
最大可能来填充页。

索引页的可用空间 允许插入新行时不拆分页，添加新行到充满的索引页会引发页拆分，为了得到空间，会从既有的充满的
页移动一半的行到新页，大量的页拆分会减慢insert操作，但是另一方面，充满的数据页允许更快的读取活动，国为数拓
库引擎可以从更少的数据页中检索更多的行。

100%的填充因子可以提升读取的性能，但是会减慢写活动的性能引发频繁的页拆分，因为数据库引擎为了在数据页中得到
空间必须持续地交换行的位置。太低的填充因子会给行插入带来益处，但它也会减慢读取操作，因为要检索所有需要的行
必须访问更多的数据页，经验的做法是，为几乎没有数据修改活动的表使用100%填充因子，低活动的使用80-90,中等活
动的使用60-70,为索引键上的高活动使用50或更低百分比
*/

CREATE NONCLUSTERED INDEX IX_a6 ON a(a,a2) 
WITH (PAD_INDEX=ON --删除并重建索引
,FILLFACTOR=50)


--禁用页和/或行索引锁定
ALTER INDEX dbo.a.IX_a ON dbo.a 
SET (ALLOW_PAGE_LOCKS=OFF,ALLOW_ROW_LOCKS=of) --禁用页锁和行锁，只可以使用表锁


--在文件组上创建索引
/*
文件组可以用来帮助管理超大型数据库，通过文件组一方面可以进行单独的备份，另一方面如果文件组的文件存在于分离
的磁盘阵列中时也会提升i/o性能，默认如果没有显式地指定，索引会创建在与底层表相同的文件组中。
*/

CREATE NONCLUSTERED INDEX IX_a6 ON a(a,a2) ON [文件组]


--索引分区
/*
如果两个表中的两列频繁联结，并且使用同一分区函数，同一数据类型，同样的分区数与边界，则可能会提升查询联结性
能，然而，出于管理与性能方面的原因，通常的方法将更可能是使用索引与表的对齐分区方案。
*/

CREATE NONCLUSTERED INDEX IX_a6 ON a(a,a2) ON [HitDateRangeScheme](HitDate)--应用分区方案

--筛选索引
/*
通过使用筛选特性来创建需要比全表索引更少存储空间的微调的索引，如果大部分查询都是查询表中一小部分数据，筛选
索引将会提升i/o性能，也会减少磁盘存储。
*/
CREATE NONCLUSTERED INDEX IX_a6 ON a(a,a2) 
WHERE a >=1 AND a<=10

--压缩索引

CREATE NONCLUSTERED INDEX IX_a6 ON a(a,a2)  WITH (DATA_COMPRESSION=PAGE) --创建用 with

ALTER INDEX IX_a6 ON a REBUILD WITH (DATA_COMPRESSION=row)--with子句在rebuild关键字之后
