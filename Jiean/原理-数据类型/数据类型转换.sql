

--数据类型的隐式转换

/*
数据类型的优先级：
	从优先级较低的数据类型向优先级较高的数据类型转换。

			real -> xml -> sql_variant -> user-defined data types (highest)

   日期类型： time -> date -> smalldatetime -> datetime -> datetime2 -> datetimeoffset 

   数值类型： bit -> tinyint -> smallint -> int -> bigint -> smallmoney -> money -> decimal -> float

   大数据类型： image -> text -> ntext

   标积类型：	uniqueidentifier -> timestamp
	
   字符类型：  char -> varchar (including varchar(max) ) -> nchar -> nvarchar (including nvarchar(max) )

   二进制数类型： binary (lowest) -> varbinary (including varbinary(max) )


作业：
1，熟记各数据类型的优先级
2,练习子父级类型和同类型的数据转换

*/


/*
在SQL语句中有两种场景需要考虑数据类型转换:

1)set select子句  给变量赋值或写入表列。
2)where 条件子句  左右两边表达式的比较

不同的数据类型之间的转换可能会出现一些错误情况

a,两种数据类型不兼容，这是无法转换的
b,两种数据类型兼容，但需要显式的转换
c,根据转换规则，转换可能会出现有损转换或转换失败。

作业：
1，类型转换在不同子句中的区别
2，类型转换的兼容性
*/
--类型不兼容
DECLARE   @a INT
DECLARE   @b DATE
SET           @a = @b

--显式转换对不兼容类型无效
DECLARE @a INT
DECLARE @b DATE
SET @a = CONVERT(INT,@b)

--兼容类型，但需要显式转换
DECLARE @a INT
DECLARE @b DATETIME
SET @a = @b 

DECLARE @a INT
DECLARE @b DATETIME
SET @a = CONVERT (INT ,@b)



--转换规则
/*
1）在 赋值和写入子句中，明确将右边表达式转换到左边表达式的数据类型
2) 在条件子句中，默认按数据类型优先级从低向高转换，当不同的数据类型之间转换时，可能会出现有损转换或转换失败

在显式的高优先级向低优称级类型转换，会出现数据被载断，甚至转换失败。这里重点说明下不同类型间的隐式转换：

a)当整型和浮点类型比较时，向浮点类型转换可能会出现有损转换
b)当字符和数值类型比较时，向数值类型转换可能会出现转换失败
*/

--错误写法
DECLARE @a INT
DECLARE @b DATETIME
SET CONVERT(DATETIME,@a) = @b

SET STATISTICS PROFILE ON  

--按数据类型优先级，@a转成日期类型
DECLARE @a INT
DECLARE @b DATETIME
SELECT 0 WHERE @a = @b

  |--Compute Scalar(DEFINE:([Expr1000]=(0)))
       |--Filter(WHERE:(STARTUP EXPR(CONVERT_IMPLICIT(datetime,[@a],0)=[@b])))
            |--Constant Scan


--整型和浮点类型的转换可能会出现有损转换
DECLARE @a INT
DECLARE @b REAL
DECLARE @c INT
SET @a = 1000000001
SET @b = CONVERT(REAL,@a)
SET @c = CONVERT(INT,@b)
SELECT @a AS 'INT', @b AS 'REAL', @c AS 'INT'


-- 高优先级向低优先级类型转换，可能会出现转换失败
DECLARE @a REAL
DECLARE @b INT
SET @a = 1e13
SET @b = CONVERT(INT,@a)


--字符类型向高优先级整型转换，会有可能出现不确定结果，甚至转换失败。
DECLARE @a INT
DECLARE @b CHAR(4)
SET @a = 1SET @b = @a
SELECT @a AS a, @b AS b,
    CASE WHEN   @a = '1 '  THEN 'True' ELSE 'False' END AS [a = '1'],
    CASE WHEN   @a = '+1' THEN 'True' ELSE 'False' END AS [a = '+1'],
    CASE WHEN   @b = '1'   THEN 'True' ELSE 'False' END AS [b = '1'],
    CASE WHEN   @b = '+1' THEN 'True' ELSE 'False' END AS [b = '+1']
    
--非Unicode和Unicode类型比较，会隐式把非Unicode向高优先级Unicode类型转换
DECLARE @a VARCHAR(20)
SELECT 0 WHERE @a = N'a'   
 
  |--Compute Scalar(DEFINE:([Expr1000]=(0)))
       |--Filter(WHERE:(STARTUP EXPR(CONVERT_IMPLICIT(nvarchar(20),[@a],0)=N'a')))
            |--Constant Scan

--类型不相同的记录插入,则隐式把数据类型转成目标表类型
create table #tmp(cardid varchar(30),cardcode nvarchar(80))
create table #tmp2(cardid varchar(30),cardcode varchar(80))
insert into #tmp2
select * from #tmp
|--Compute Scalar(DEFINE:([Expr1008]=CONVERT_IMPLICIT(varchar(80),[tempdb].[dbo].[#tmp].[cardcode],0)))
    |--Table Scan(OBJECT:([tempdb].[dbo].[#tmp]))
    
    
---------------------------------------------
/*
浮点类型
根据ieee 754标准Float类型使用二进制格式编码实数数据。
并不是所有在进进制中描述的信息都能使用二进制存储，出于一些必要的因素，浮点数通常会舍入到一个非常接近的值。
*/

DECLARE @float FLOAT
DECLARE @decimal DECIMAL(9,4)

SET @float=59.95
SET @decimal=59.95

SELECT @float*100000000000,@decimal*100000000000