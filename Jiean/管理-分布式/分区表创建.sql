

--分区表
/*
表分区提供了内建的方法来水平划分表和/或索引中的数据，同时要管理一个逻辑对明。
水平分区是指每一个分区都有同样数量的列，只是减少了行的数量。

分区能使超大型表和索引的管理变得简单，减少加载时间，改善查询时间，并允许更小的维护窗口

实现分区表有两个步聚:
1)创建分区函数和分区方案

分区函数用于根据某列的值来将列映射到分区
分区方案引用定义的分区函数，并把分区映射到实际的文件组。

2）把分区方案绑定到表上
*/

--策略
/*
把一个超大表的数据水平划分，也就是根据某个列，比如时间，把几组行映射到磁盘上不同的底层物理文件中。
以提高管理和性能。
*/

--为数据库增加新的文件组
ALTER DATABASE AdventureWorks
ADD FILEGROUP hit1

ALTER DATABASE AdventureWorks
ADD FILEGROUP hit2

--为新添加的文件组创建数据文件
ALTER DATABASE AdventureWorks
ADD FILE (
	NAME = 'awhit1',
	FILENAME='d:\aqhit1.ndf',
	SIZE=1MB
)
TO FILEGROUP hit1

ALTER DATABASE AdventureWorks
ADD FILE (
	NAME = 'awhit2',
	FILENAME='d:\awhit2.ndf',
	SIZE=1MB
)
TO FILEGROUP hit2


--创建分区函数：定义划分成多少个区
CREATE PARTITION FUNCTION hitDataRange(datetime) --数据类型，不能是大值数据类型，这里扫日期
AS RANGE LEFT --定义划分的间隔，定义时间值属于边界的那一侧，是以靠左为准，还是靠右
FOR VALUES('2013/1/1','2014/1/1')-- 定义两个时间区域，这将会对应到不同的分区


--创建分区案，绑定到实际文件组
CREATE PARTITION SCHEME hitdataRangeScheme  --分区方案名称
AS PARTITION hitDataRange --指定分区函数
TO(hit1,hit2)--对应的两个文件组

--绑定到表
CREATE TABLE sales.websiteHits(
	websiteHitID BIGINT NOT NULL IDENTITY(1,1),
	hitDate DATETIME NOT NULL,
	CONSTRAINT PK_websithits PRIMARY KEY(websiteHitID,hitDate)
)
ON hitdataRangeScheme(hitDate) --绑定，必须是主键或主键的一部份


------------------------------------------------------------------------------------------

--查看数据属于那个分区
SELECT hitdate,$PARTITION.hitDataRange(hitdate) PARTITION --调用分区函数
FROM sales.websiteHits

--分割或创建一个新的分区

--把一个现有的文件组加入到队列（没有的话，先创建一个）
ALTER PARTITION SCHEME hitdateRangeScheme --修改分区方案
NEXT USED [Primary] --这里是把主分区加到队列里

--分区函数是对间隔的划分，这里再划分一个间隔
ALTER PARTITION FUNCTION hitDateRange()
SPLIT RANGE('2012/1/1')

--移除分区：其本质是把两个分区合并成一个，行重新分与到目标合并的分区中

ALTER PARTITION FUNCTION hitDaterange()
MERGE RANGE('2012/1/1')--移除2012年这个分区

-----------------------------------------------------------------------------------------------

--分区移动

--一个保存历史数据的新表
CREATE TABLE sales.websiteHitsHistory
(
	websitehitid BIGINT NOT NULL IDENTITY(1,1),
	hitdate DATETIME NOT NULL,
	CONSTRAINT PK_websitehitsHistory PRIMARY KEY(websitehitid,hitdate)
)
ON hitdateRangeScheme(hitdate)

--把原表的第3分区移到新表
ALTER TABLE sales.websitehits 
SWITCH PARTITION 3
TO sales.websiteHitsHistory PARTITION 3 --指定目标表和要接受转移数据的目标表和分区
/*
在表之间转移分区比手动执行行操作（insert ..select ）快很多，因为并不是真正移动物理数据，只是修改了有关分区目
前保存在哪 里的元娄据，同样要记住，任何即有表的目标分区必须是空的才能作为目的分区，如果它是一个未分区的表，
这也必须是空的。
*/

--删除分区函数和方案，要先删除引用的表，再能删除
DROP PARTITION SCHEME hitDaterangeScheme
DROP PARTITION FUNCTION hitdateRange