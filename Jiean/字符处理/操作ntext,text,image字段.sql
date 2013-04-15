
字符类型一般用char和varchar数据类型(短字符型)，最长为8000字节，超过8000个字节的文本就要使用ntext或者text数据类型来存储； 

二进制类型一般用binary、varbinary ，最长为8 KB，储超过 8 KB 的可变长度的二进制数据，
如 Microsoft Word 文档、Microsoft Excel 电子表格、包含位图的图像、图形交换格式 (GIF) 文件和联合图像专家组 (JPEG) 
	文件，使用image 数据类型来存储。 

ntext、text 和 image 数据类型在单个值中可以包含非常大的数据量，最大可达 2 GB。

Text字段类型不能直接用replace函数来替换，必须用updatetext； 

字段比较不能用　where 字段 = ‘某数据’,可以用like来代替； 

updatetext时，若dest_text_ptr值为NULL时会报错，需注意。错误信息：向UpdateText 函数传递了 NULL textptr（text、ntext 或 image 指针）；
注意，BLOB列为NULL而所在行不为空时，dest_text_prt为NOT NULL，若BOLB所在行为空，
则dest_text_prt为NULL。delete_length必须小于等于字段总长度，否则报错：
删除长度  不在可用的 text、ntext 或 image 数据范围内。 

PATINDEX / CHARINDEX 函数都返回指定模式的开始位置。PATINDEX 可使用通配符，
而 CHARINDEX 不可以。IS NULL、IS NOT NULL 和 LIKE，这些是 WHERE 子句中对 text / ntext类型有效的仅有的其它比较运算。
除此之外，PATINDEX 也可用于 WHERE 子句中； 

使用 TEXTVALID 来检查文本指针是否存在。在无有效文本指针时，不能使用 UPDATETEXT、WRITETEXT 或 READTEXT；
例，SELECT 'Valid (if 1) Text data' 
   = TEXTVALID ('pub_info.logo', TEXTPTR(logo)) FROM pub_info WHERE logo like '%hello%'；  

LEN只对短字符型有效，对于text/ntext/image类型，则使用DATALENGTH来得到数据长度

/*
Ntext,text,image数据类型：用于存储大型非 Unicode 字符、Unicode 字符及二进制数据的固定长度和可变长度数据类型。
							Unicode 数据使用 UNICODE UCS-2 字符集
							
text数据类型，在早期的server2000以前，数据库中一个TEXT 对象存储的实际上是一个指针，
它指向一个以8KB （8192 个字节）为单位的数据页（Data Page）。这些数据页是动态增加并被逻辑链接起来的。
在SQL Server 2000 中，则将TEXT 和IMAGE 类型的数据直接存放到表的数据行中，而不是存放到不同的数据页中。 
这就减少了用于存储TEXT 和IMA- GE 类型的空间，并相应减少了磁盘处理这类数据的I/O 数量。
在表中可以看到类似<long text>的字段。

由于字段是以８Ｋ为一页，针对８Ｋ为点
*/

--针对此类数据类型，可以采用二进制字节流的方式读取，需要使用到几个函数和方法

--返回表达式所占用的字节数,也可以在错误中获得
datalength(expression) 

--返回列的文本实际指针值,为二进制值
textptr(COLUMN)

--指定内容定位，返回指定文本的第一次出现位置
patindex(['%pattern%'],expression)

--验证指针有效性
TEXTVALID(['table.column'],text_ptr)

--指定由 SELECT 语句返回的 text 和 ntext 数据的大小。
SET TEXTSIZE

--取出指定位置的字节
substring(expression,start,length)

--字段的读取，更新，写入
--从指定的偏移量开始读取指定的字节数
READTEXT{ table.column text_ptr offset size } [ HOLDLOCK ] 

--在适当的位置更改 text、ntext 或 image 列的一部分
UPDATETEXT

--更新和替换整个 text、ntext 或 image 字段
--允许对现有的 text、ntext 或 image 列进行无日志记录的交互式更新。
--该语句将彻底重写受其影响的列中的任何现有数据。WRITETEXT 语句不能用在视图中的 text、ntext 和 image 列上。
WRITETEXT


--在查询分析器中查看８Ｋ内的字段内容
--工具--选项--结果--每列最多显示字符数:8000
SELECT * FROM [TABLE]

--更新
varchar和nvarchar类型是支持replace，所以如果你的text不超过8000可以先转换成前面两种类型再使用replace。
update 表名
set 字段名=replace(convert(varchar(8000),字段名),'要替换的字符','替换成的值')



--如果你的text大于8000，可以用下面的方法：
--测试数据
CREATE TABLE tb(col ntext)
INSERT tb VALUES(REPLICATE( '0001,0002,0003,0004,0005,0006,0007,0008,0009,0100,'
+'220000001,302000004,500200006,700002008,900002120,',800))
DECLARE @p binary(16)
SELECT @p=TEXTPTR(col) FROM tb
UPDATETEXT tb.col @p NULL 0 tb.col @p
GO

/*
消息 7118，级别 16，状态 1，第 4 行
将大型对象(LOB)分配给它自己时，仅支持完整替换。
语句已终止。
declare @p binary(16)
select @p = textptr(col) from tb
updatetext tb.col @p null 0 tb.col @p
*/

--替换处理定义
DECLARE @sourceStr nvarchar(1000),@objStr nvarchar(1000)
SELECT @sourceStr='0001' --要替换的字符串
,@objStr='1111' --替换成该字符串

DECLARE @p_col varbinary(16)
DECLARE @s_StartPat int,@subStr nvarchar(4000),@subStr_len int
DECLARE @s_len int,@cutLen int,@search_start int,@pos int

--替换处理参数设置
SELECT
--用于要判断每次截取数据,最后一个被替换数据位置的处理
@s_len=LEN(@sourceStr),

--设置每次应该截取的数据的长度,防止REPLACE后数据溢出
@cutLen=CASE WHEN LEN(@objStr)>LEN(@sourceStr)
THEN 4000/LEN(@objStr)*LEN(@sourceStr)
ELSE 4000 END


--替换处理的开始位置
SELECT @s_StartPat=PATINDEX('%'+@sourceStr+'%',col),
	@p_col=TEXTPTR(col),
	@subStr=SUBSTRING(col,@s_StartPat,@cutLen),
	@subStr_len=LEN(@subStr),
	@search_start=0
FROM tb
WHERE PATINDEX('%'+@sourceStr+'%',col)>0
	AND TEXTVALID('tb.col',TEXTPTR(col))=1
	
WHILE @subStr_len>=@s_len
BEGIN
	--得到最后一个被替换数据的位置
	WHILE CHARINDEX(@sourceStr,@subStr,@search_start)>0
		SET @search_start=@s_len
		+CHARINDEX(@sourceStr,@subStr,@search_start)

	--如果需要,更新数据,同时判断下一个取数位置的偏移量
	IF @search_start=0
		SET @search_start=@s_len
	ELSE
		BEGIN
		SELECT @search_start=CASE
			WHEN @subStr_len<@search_start THEN 1
			WHEN @subStr_len-@search_start>=@s_len THEN @s_len
			ELSE @subStr_len-@search_start+2 END,
			@subStr=REPLACE(@subStr,@sourceStr,@objStr),
			@pos=@s_StartPat-1
			UPDATETEXT TB.col @p @pos @subStr_len @subStr
		END
	--获取下一个要处理的数据
	SELECT @s_StartPat=@s_StartPat+LEN(@subStr)-@search_start+1,
	@subStr=SUBSTRING(col,@s_StartPat,@cutLen),
	@subStr_len=LEN(@subStr),
	@search_start=0
	FROM tb
END
GO

--显示处理结果
SELECT datalength(col),* FROM tb
DROP TABLE tb
上面说的是针对ntext字段的替换处理，如果要处理text字段，只需要先转换成ntext字段然后保存在临时表里面，
处理完以后再从临时表写回text就行了。
其实一般象text，ntext字段这些都是抓到程序里面去处理的。


1、替换

--创建数据测试环境
create table #tb(aa text)
insert into #tb select 'abc123abc123,asd'

--定义替换的字符串
declare @s_str varchar(8000),@d_str varchar(8000)
select @s_str='123', --要替换的字符串
         @d_str='000' --替换成的字符串

--字符串替换处理
--获取列址值，字符串开始地址，长度
declare @p varbinary(16),@postion int,@rplen int
select @p=textptr(aa),@rplen=len(@s_str),@postion=charindex(@s_str,aa)-1 from #tb
while @postion>0
begin
   updatetext #tb.aa @p @postion @rplen @d_str
   select @postion=charindex(@s_str,aa)-1 from #tb
end

--显示结果
select * from #tb

--删除数据测试环境
drop table #tb

2、全部替换

DECLARE @ptrval binary(16)
DECLARE @ptrvld int
SELECT @ptrval = TEXTPTR(aa), @ptrvld = TEXTVALID('#tb.aa', TEXTPTR(AA))  FROM  #tb  WHERE aa like '%数据2%'
-- 一定要加上条件判断，否则若找不到目标文件指针下一句SQL就会报错（很重要！）
if @ptrval is not null and  @ptrvld = 1
   UPDATETEXT #tb.aa @ptrval 0 null '数据3'

3、在字段尾添加


--定义添加的的字符串
declare @s_str varchar(8000)
select @s_str='*C'   --要添加的字符串
--字符串添加处理
declare @p varbinary(16),@postion int,@rplen int
select @p=textptr(detail) from test where id='001'
updatetext test.detail @p null null @s_str

