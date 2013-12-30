

--创建数据库

/*
基于系统数据库model的默认配置（数据库model是随sqlserver一起安装的系统数据库，并为创建在sqlserver实例中的所
有其他数据库定义了模块，如果创建数据库时除了数据库名称年没有指定任何选项，选项的值将基于系统数据库model）
*/
CREATE DATABASE test2

--查看
EXEC sp_helpdb 'test2'

--修改兼容级别
ALTER DATABASE test2
SET COMPATIBILITY_LEVEL=100


--创建数据库

CREATE DATABASE test3
ON PRIMARY ( --主数据文件
	NAME  = 'test301',  --逻辑名
	FILENAME = 'e:\test301.mdf', --文件名
	SIZE=3Mb, --初始大小
	MAXSIZE=UNLIMITED, --文件最大值
	FILEGROWTH=10MB --增长量
),( --逗号分隔数据文件
	NAME = 'test302',
	FILENAME='e:\test3012.ndf',
	size=1MB,
	MAXSIZE=30,
	FILEGROWTH=5%
)
LOG ON( --日志文件另起一行
	NAME = 'test03_log',
	FILENAME='e:\test03_log.ldf',
	size=504KB,
	MAXSIZE=100MB,
	FILEGROWTH=10%
)
DROP DATABASE test3
/*
文件组
默认情况，创建的数据库，数据文件属于主文件组，其包含主数据文件，以及其他没有显式分配到不同文件组的数据文件。

用户也可以自定义文件组

*/

CREATE DATABASE test4
ON PRIMARY(
	NAME = 'test04',
	FILENAME ='e:\test0401.mdf',
	SIZE=3MB,
	MAXSIZE=UNLIMITED,
	FILEGROWTH=5MB
),
FILEGROUP fg2 DEFAULT( --创建一个新的文件组fg2,default表示任何创建新的数据库对象都将放在这个组中
	NAME='test0402',
	FILENAME='e:\test0402.ndf',
	SIZE=1MB,
	MAXSIZE=UNLIMITED,
	FILEGROWTH=1mb
)
LOG ON(
	NAME = 'test02_log',
	FILENAME='e:\test02_log.ldf',
	SIZE=504KB,
	MAXSIZE=100MB,
	FILEGROWTH=10%
)

DROP DATABASE test4

----------------------------------------------------------------------------------------------
--设置数据库用户访问

SELECT user_access_desc,* FROM  sys.databases WHERE name = 'test'

ALTER DATABASE test
SET SINGLE_USER | RESTRICTED_USER | MULTI_USER
WITH ROLLBACK  AFTER  INTEGER [seconds] | ROLLBACK IMMEDIATE | NO_WAIT 

/*
single_user,单用户模式，只允许一个用户访问,除非使用终止选项，否则会封锁修改，直到所有其他用户从数据库中断开
连接
resticted_user : 只有sysadmin,dbcreator或dbowner角色的成员可以访问数据库
multi_user : 对数据库有权限 用户都允许访问

rollback after integer 指定打开的数据库事务在指一的秒数后回滚
rollback immediate 立即回滚打开的事务
no_wait 如果不能立即完成将引起语句执行失败（为了可以成功执行，使用这个选项需要数据库中没有打开的事务）

根据应用程序处理未完成的进程的方法，以这种方式取消打开的事务可能会在应用程序中引发问题，要记住这个重要的问题
要尽可能在不活动或没有事务活动的期间尝试改变用户访问模式。
*/

--数据库改名
--需要把数据库切到master下，用单模式也可以
ALTER DATABASE test4
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE

ALTER DATABASE test4
MODIFY NAME = new_test4

ALTER DATABASE new_test4
SET MULTI_USER

--删除数据库

ALTER DATABASE new_test4
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE

DROP DATABASE new_test4

--分离数据库(删除，但保留数据库文件)

ALTER DATABASE new_test4
SET SINGLE_USER	
WITH ROLLBACK IMMEDIATE

EXEC sp_detach_db 'new_test4','false' --true 表示分离数据库之前不会更新统计信息

--附加数据库

--附加原来的数据库，但用新的数据库名称
CREATE DATABASE new_test5
ON(FILENAME='e:\test4.mdf')--文件路径
FOR ATTACH /*attach 指定使用在分离的数据库中使用的所有原始文件来创建数据库，当指定attach_rebuild_log,并且事
务日志文件不可用时，sqlserver将重建事务日志文件*/
