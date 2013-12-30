

--管理数据库文件

--添加文件,不需要将数据库设置为离线

ALTER DATABASE Test
ADD [log] FILE (
	NAME ='test02',
	FILENAME='e:\test02.mdf',
	SIZE=1MB,
	MAXSIZE=UNLIMITED,
	FILEGROWTH=1mb
)
TO FILEGROUP[primary] --指定添加新文件的文件组


--删除据文件或日志文件
/*
如果需要通过在一个磁盘上创建新文件然后删除旧文件，将文件从一个磁盘、阵列重新分配到不同的磁盘/阵列，就可能
希望进行这个操作
*/
--查看逻辑名
SELECT * FROM sys.database_files

--清空文件中的内容
DBCC SHRINKFILE(test,EMPTYFILE)


ALTER DATABASE Test
REMOVE FILE test02

--重新分配数据文件

--离线
ALTER DATABASE Test
SET OFFLINE

--把数据文件移到新目录f:\
--修改数据库配置
ALTER DATABASE Test
MODIFY FILE (
	NAME = 'test',
	FILENAME='f:\test.mdf'
)

--联机
ALTER DATABASE Test
SET ONLINE

--修改数据文件的逻辑名
/*
可以不将数据库置为离线，数据库的逻辑名不会影响数据库本身的功能，允许出于一致性和命名约定的原因而修改名称
*/
ALTER DATABASE Test
MODIFY FILE (
	NAME ='test',newname = 'testnew'
)

--增加数据库文件的大小和增长
ALTER DATABASE Test
MODIFY FILE(
	NAME='test',
	SIZE = 30MB,
	MAXSIZE = UNLIMITED,
	FILEGROWTH=50mb
)

--添加数据文件组
ALTER DATABASE Test
ADD FILE(
	NAME ='test02',
	FILENAME='e:\test02.ndf',
	SIZE=10MB,
	MAXSIZE=UNLIMITED,
	FILEGROWTH=50mb
)
TO FILEGROUP [fg2]

--设置默认文件组
ALTER DATABASE Test
MODIFY FILEGROUP fg2 DEFAULT

--删除文件组

--删除文件组中的文件
ALTER DATABASE Test
MOVE FILE test02

--删除文件组
ALTER DATABASE Test
MOVE FILEGROUP [fg2]


--设置数据库只读
ALTER DATABASE Test
SET READ_ONLY | READ_WRITE	

--文件组只读
ALTER DATABASE Test
MODIFY FILEGROUP fg2 READ_ONLY