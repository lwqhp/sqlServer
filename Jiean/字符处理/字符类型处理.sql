
/*
字符串类型 影响字符串的存贮使用
排序规则 是字符串的物理存贮，字符集，大小写等
*/
--执行动态T-SQL语句
EXECUTE
sp_executesql --这个执行效率更高

DECLARE @s varchar(100)
SET @s = 'adfafwehfdgdp'

--字符串长度
SELECT len(@s)

--返回字符串中指定表达式的起始位置。在 expression2 中搜索 expression1 的起始字符位置
CHARINDEX ( expression1 , expression2 [ , start_location ] ) 
 
 --删除指定长度的字符并在指定的起始点插入另一组字符。
STUFF ( character_expression, start, length, character_expression ) 

--返回字符、二进制、文本或图像表达式的一部分。 
SUBSTRING ( expression, start, length ) 
 
--对于所有有效的文本和字符数据类型，返回指定表达式中模式第一次出现的起始位置，如果未找到模式，则返回零。
PATINDEX ( '%pattern%', expression )

--按相反顺序返回字符表达式。
REVERSE(character_expression)
 
--将第一个字符串表达式中第二个给定字符串表达式的所有实例都替换为第三个表达式。
REPLACE ( 'string_expression1' , 'string_expression2' , 'string_expression3' )
 



 



 




/*
动态sqlSQL语句法
利用select expression结合UNION ALL 来直接构建虚拟的表集的原理，将待分析字符串中的数据分隔符替换言之
构建虚拟表集所需要的UNION SELECT.
*/
declare @s varchar(100),@sql varchar(1000)
set @s='1,2,3,4,5,6,7,8,9,10'
set @sql='select col='''+ replace(@s,',',''' union all select ''')+''''
PRINT @sql
exec (@sql)


/*
  排序规则问题。名称前半部份是指本排序规则所支持的字符集。如：

  Chinese_PRC_CS_AI_WS

  前半部份，指UNICODE字符集，Chinese_PRC_指针对大陆简体字UNICODE的排序规则。排序规则的后半部份即后缀含义：

  _BIN 二进制排序
  _CI(CS) 是否区分大小写，CI不区分，CS区分
  _AI(AS) 是否区分重音，AI不区分，AS区分　　　
  _KI(KS) 是否区分假名类型，KI不区分，KS区分　
  _WI(WS) 是否区分宽度WI不区分，WS区分　

  区分大小写： 如果想让比较将大写字母和小写字母视为不等，请选择该选项。
  区分重音： 如果想让比较将重音和非重音字母视为不等，请选择该选项。如果选择该选项，比较还将重音不同的字母视为不等。
  区分假名： 如果想让比较将片假名和平假名日语音节视为不等，请选择该选项。
  区分宽度： 如果想让比较将半角字符和全角字符视为不等，请选择该选项

  两个数据的排序规则不同，所以造成排序规则冲突。

  你可以显示指定排序规则，如：

  select name,id from database1..sysobjects where xtype ='U' collate Chinese_PRC_CI_AS
  and name in ( select name from ReportServer..sysobjects where xtype='U' collate Chinese_PRC_CI_AS)

  当然如果连个数据库间经常要进行数据比较，最好修改其中一个数据的排序规则：

  alter database database_name collate collate_name

  在对数据库应用不同排序规则之前，请确保已满足下列条件：

  您是当前数据库的唯一用户。
  没有依赖数据库排序规则的架构绑定对象。
  如果数据库中存在下列依赖于数据库排序规则的对象，则 ALTER DATABASE database_name COLLATE 语句将失败。SQL Server 将针对每一个阻塞 ALTER 操作的对象返回一个错误消息：
  通过 SCHEMABINDING 创建的用户定义函数和视图。
  计算列。
  CHECK 约束。
  表值函数返回包含字符列的表，这些列继承了默认的数据库排序规则。
  改变数据库的排序规则不会在任何数据对象的系统名称中产生重复名称。
  如果改变排序规则后出现重复的名称，则下列命名空间可能导致改变数据库排序规则的操作失败：
  对象名，如过程、表、触发器或视图。
  架构名称
  主体，例如组、角色或用户。
  标量类型名，如系统和用户定义类型。
  全文目录名称。
  对象内的列名或参数名。
  表范围内的索引名。
  由新的排序规则产生的重复名称将导致更改操作失败，SQL Server 将返回错误消息，指出重复名称所在的命名空间。
*/