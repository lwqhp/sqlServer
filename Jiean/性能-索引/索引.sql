

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