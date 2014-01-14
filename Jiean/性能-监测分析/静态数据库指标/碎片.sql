

--碎片
/*
碎片在表中的数据被修改时产生，当插入或者更新表中的数据时，表的对应索引被修改，如果对索引的修改不能容纳于同
一个页面中，可能导致索引叶子页面分割，一个新的叶子页面将被添加以包含原来页面的部份，并且维持索引键中行的逻
辑顺序，虽然新叶子页面维护原始页面中行的逻辑顺序，但是这个新的页面通常在磁盘上不与原来页面相邻。
*/

SELECT * FROM sys.dm_db_index_physical_stats

SELECT * FROM sys.dm_db_index_usage_stats

--返回数据库中平均碎片大于30的所有对象
SELECT * FROM sys.dm_db_index_physical_stats(db_id('test'),NULL,NULL,NULL,'Limited')
WHERE avg_fragmentation_in_percent>30
ORDER BY OBJECT_NAME(OBJECT_ID)
/*
avg_fragmentation_in_percent  显示 聚集索引或非聚集索引的逻加碎片，返回索引的叶级无序页的百分比，以于堆来
说，显示的则是区级碎片
*/

--返回指定数据库，表，索引的碎片
SELECT * FROM sys.dm_db_index_physical_stats(DB_ID('test'),OBJECT_ID('tb'),2,NULL,'Limited')

--索引的使用情况
/*
数据库中创建有用的索引需要考虑数据库读写性能，在加速select 查询的同时，索引减慢了数据的修改，必须平衡读取
与数据修秘诀带来的索引开销的代价和受益

可以通过视图sys.dm_db_index_usage_state 确定未使用的索引，它会返回有关索引查找，找描，更新或查找的次数
的统计信息，也返回引用索引的最后时间
*/