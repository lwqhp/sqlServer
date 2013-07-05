

/*
----从容量的角度是看数据类型-----------------------------------------------------------------

想像一本汉字词典： 由<数据页>和<索引页>组成,一个数据页8K,记录存储在数据页上，单条记录不能跨数据页

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

smallmoney 精度10位，小数位固定4位（十万以内）,占4字节.（精度10位以下，建议用smallmoney类型，少5个字节）
*/


-----日期类型-----------
/*
datetime和smalldate

datetime 从 1753 年 1 月 1 日到 9999 年 12 月 31 日 ,精确到百分之三秒 ，占8字节
smalldate 从 1900 年 1 月 1 日到 2079 年 6 月 6 日,精确到分钟，四舍五入，占4字节

注：datetime 精确到百分之三秒，所以毫秒要-3倍数才有效果
	smalldate 精确到分种，29.998 秒或更低会被舍掉,29.999 秒或更高会进1分钟。
*/


