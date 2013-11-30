

--索引
/*
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
*/