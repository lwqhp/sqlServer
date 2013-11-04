


--数据文件收缩
/*
1,在压缩或清空数据文件之前，首先要清除不再需要的数据
delete  命令不能释放空间
truncate table  drop table 可以释放空间，因为
a)所用的事务日志空间较少
b)使用的锁通常较少
c)表中将毫无例外地不留下任何页。

两种方法处理delete后的空页
a),创建聚集索引，重建索引释放空余页面
b),新建一张表，把数据倒过去，drop 掉旧表。

2，收缩数据库
*/
--收缩指定数据库中的所有数据文件和日志文件的大小
DBCC SHRINKDATABASE

--收缩当前数据库指定数据文件或日志文件的大小
--或者通过将数据从指定的文件移动到相同文件组中的其他文件来清空文件，以允许从数据库中删除该文件
DBCC SHRINKFILE

/*
收缩数据库注意点：
1）首先要了解数据文件当前的使用情况，收缩量不可能超过当前文件的空闲空间的大小，如果想要压缩数据库的大小，首先
要认数据文件里的确有相应未被使用的空间，如果空间都在使用中要先确认大量占用空间的对象（表和索引），然后通过归档
历鸣数据，把空间释放出来。

2）主数据文件是不能被清空的，能被完全清空的只有辅助数据文件。

3）娄据要把一个文件组整 个清空，要删除分配在这个文件组上的对象或者把它们移到其它文件组上

4）数据文件里有空间，但不能清空，是因为数据文件里面虽然有很多的空的页面，但是这些页面分散在各个区里，使得整个文件没有很多空的区。
dbcc shrinkfile做的都是区一级的动作，不会把一个区里面的空页移除，合并区。

5）对于区里放的是text和image之类的数据类型，重建索引并不影响它们的空间，可以先把这些可能有问题的对象都找出来，
然后重建它们。

*/

--利用dbcc extentinfo命令打出数据文件里的所有区的分配信息计算第个对象理论上区的数目和实际的数目，如果实际数
--目远大于理论数据，那这个对象就是碎片过多，可以考虑重建对象。

CREATE TABLE extentinfo(
FILE_ID SMALLINT,
page_id INT,
pg_alloc INT,
ext_size INT,
obj_id INT,
index_id INT,
partition_number INT,
partition_id BIGINT,
iam_chain_type VARCHAR(50),
pfs_bytes VARBINARY(10)
)
go
CREATE PROCEDURE import_extentinfo
AS
DBCC extentinfo('lwqhp')
GO

INSERT extentinfo
EXEC import_extentinfo
go

SELECT 
FILE_ID,obj_id,index_id,partition_id,ext_size,
'actual extent count'=COUNT(*),'actual page count'=SUM(pg_alloc),
'possible extent count'=CEILING(SUM(pg_alloc)*1.0/ext_size),
'possible extents / actual extents'=(CEILING(SUM(pg_alloc)*1.0/ext_size)*100.00)/COUNT(*)
 FROM extentinfo
GROUP BY FILE_ID,obj_id,index_id,partition_id,ext_size
HAVING COUNT(*)-CEILING(SUM(pg_alloc)*1.0/ext_size)>0
ORDER BY partition_id,obj_id,index_id,file_id
