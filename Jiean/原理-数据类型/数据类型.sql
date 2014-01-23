

/*
作业：
1，找出自己还不熟悉的类型，细看
2,每种类型的长度


----从容量的角度是看数据类型-----------------------------------------------------------------

想像一本汉字词典： 由<数据页>和<索引页>组成,一个数据页8K,记录存储在数据页上，单条记录不能跨数据页

建议：
1，不同的数据种类存在对应的数据类型中，因为不同数据类型之间计算，可能会降低性能。
2，如果字符数据类型列的值使用相同或者相似长度的字符，建议使用固定长度的数据类型，变长列会增加一些存储空间，
但是它们只为使用的字符分配存储空间，这会增加一定的性能开销。
3，选择保存数据需要的最小的数值或字符数据类型，能增加8KB的数据页中能保存的行数，减少数据库需要的总存储空间，
并且可能提升索引性能（更小的索引键）


*/
--所以下面的SQL 语句创建表会报警告信息：

CREATE TABLE [dbo].[TestTable] (
[ID] [int] IDENTITY (1, 1) NOT NULL ,
[content1] [nvarchar] (4000) NULL ,
[content2] [nvarchar] (4000) NULL
)

--Warning: The table 'TestTable' has been created but its maximum row size (16029) exceeds the maximum number of bytes per row (8060). INSERT or UPDATE of a row in this table will fail if the resulting row length exceeds 8060 bytes.

--但是表仍然被创建了。但是在你做 Insert Update 操作的时候，就会报错误信息。

--解决方法：

--重新设计表结构。把它分成两个表，或者用Text字段。

--Text 字段由于它的存储方式。他在数据行只占16个字节的指针。


-----字符-----------
/*
char,nchar,varchar nvarchar

char 固定长度，不管你够不够，他都会补足
varchar 不固定长度，跟据你的输入来确定容量
nchar,nvarchar Unicode类型，双字节存储，相同容量，内容减半
*/

-----整型数值-----------

/*
bigint 从 -2^63 (-9223372036854775808) 到 2^63-1 (9223372036854775807) 
	长度达到19位，占8个字节

int 从 -2^31 (-2,147,483,648) 到 2^31 - 1 (2,147,483,647)
	长度达到10位，占4个字节

smallint 从 -2^15 (-32,768) 到 2^15 - 1 (32,767)
	长度达到5位（万位），占2个字节

tinyint 从 0 到 255
	长度255 ，占1个字节,不包含负数

数字最好都用数值类型，例电话11位，用字符型varchar(11)要占11个字节，用bigint只用8个字节			
*/

-----浮点数值-----------
/*
精度数值和非精度数值

精度数值 decimal和numeric(p,s)  长度38位
	精度1-9		占5字节
	精度10-19   占9字节
	精度20-28   占13字节
	精度29-38   占17字节

近似数据类型 float和real float长度15位，real 长度24位
	float(1-24)精度7位(不设默认是7位),不设小数位 占4字节
	float(25-53)精度15位,不设小数位 占8字节
	real精度24位 占4字节

用科学记数法表示,对超过精度采用上舍入（Round up 或称为只入不舍）方式进行存储.当（且仅当）要舍入的数是一个非零数时，对其保留数字部分的 最低有效位上的数值加1 ，并进行必要的进位。
*/
--数据类型转换
declare @var float
set @var = 98333456.87334
select @var,convert(varchar(20),@var),str(@var,20,6),convert(varchar(20),convert(decimal(20,5),@var))


-----特殊数值 钱-----------
/*
money和smallmoney是固定精度类型
money 精度19位，小数位固定4位 占8字节.(精度超过9位,小于19位，建议用money类型，少1字节)

smallmoney 精度10位，小数位固定4位（十万以内）,占4字节.（精度10位以下，建议用smallmoney类型，少1个字节）
*/


-----日期类型-----------
/*
datetime和smalldate

datetime 从 1753 年 1 月 1 日到 9999 年 12 月 31 日 ,精确到百分之三秒 ，占8字节
smalldate 从 1900 年 1 月 1 日到 2079 年 6 月 6 日,精确到分钟，四舍五入，占4字节

注：datetime 精确到百分之三秒，所以毫秒要-3倍数才有效果
	smalldate 精确到分种，29.998 秒或更低会被舍掉,29.999 秒或更高会进1分钟。

datetime2 类型是datetime的扩展，日期范围更大，小数精度更高,可以精确到纳秒 .9999999
date 只保存日期，默认格式为YYYY-MM-DD
time 只保存时间,格式：hh:mm:ss[.nnnnnnn] 精度可以达到100纳秒  
datetimeoffset 存储的日期和时间（24小时制）是时区一致的。时间部分能够支持如DATETIME2和TIME数据类型那样的高达100纳秒的精度。
	DATETIMEOFFSET需要8到10字节的磁盘空间开销
*/

-----二进制类型-----------
/*
binary 固定长度二进制类型,最多8000B
bit 位类型，只有0和1
varbinary 变长的二进制数据类型
image 存储超过8KB的可变长的二进制数据
*/

/*
sysname
sysname 数据类型用于表列、变量以及用于存储对象名的存储过程参数。sysname 的精确定义与标识符规则有关。因此，
它可能会因 SQL Server 实例的不同而有所不同。除了 sysname 在默认情况下为 NOT NULL 之外，sysname 的功能
与 nvarchar(128) 相同。在早期版本的 SQL Server 中，sysname 被定义为 varchar(30)

这个可以在一些系统表中看到（如sysobjects表的name字段就是sysname类型的）的，
因此 sysname类型直接决定了tablename的字符空间，如6.5之前的表名不支持中文，而2000以后的表名就支持中文，
就是因为sysname再两个版本中的含义不一样

table_name、column_name等可以是由用户自己输入的符合sysname类型的的数据，说明这些名称是sysname类型的，
因此，这些名称你可以使用nvarchar(128)的任意字符串；而数据类型（如column1_datatype）、
主键标示（如columns_in_primary_key）等就不是sysname类型的，区别就在这里。（帮助理解的句子，外引，自注！）


大值类型
varchar(max) == text
nvarchar(max) == ntext
varbinary(max)== image

操作行为和varchar(n)是一样的，可以存储2^30-1个字节,支持查找，支持触发器



--表类型
table 不能在create table的时候作为列类型，它用于表变量或者表值函数中行的存储

--时间截类型
timestamp 指定了数据库级别的唯一数字，当行修改后会更新

--全球唯一标识类型
uniquedentifier 存储16字节的GUID

--XML数据
xml 保存本地的XML数据
*/
