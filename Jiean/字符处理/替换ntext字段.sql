1。varchar和nvarchar类型是支持replace，所以如果你的text不超过8000可以先转换成前面两种类型再使用replace。
update 表名
set 字段名=replace(convert(varchar(8000),字段名),'要替换的字符','替换成的值')
2。如果你的text大于8000，可以用下面的方法：
--测试数据
CREATE TABLE tb(col ntext)
INSERT tb VALUES(REPLICATE( '0001,0002,0003,0004,0005,0006,0007,0008,0009,0100,'
+'220000001,302000004,500200006,700002008,900002120,',800))
DECLARE @p binary(16)
SELECT @p=TEXTPTR(col) FROM tb
UPDATETEXT tb.col @p NULL 0 tb.col @p
GO

--替换处理定义
DECLARE @s_str nvarchar(1000),@r_str nvarchar(1000)
SELECT @s_str='00' --要替换的字符串
,@r_str='0000' --替换成该字符串

DECLARE @p varbinary(16)
DECLARE @start int,@s nvarchar(4000),@len int
DECLARE @s_len int,@step int,@last_repl int,@pos int

--替换处理参数设置
SELECT
--用于要判断每次截取数据,最后一个被替换数据位置的处理
@s_len=LEN(@s_str),

--设置每次应该截取的数据的长度,防止REPLACE后数据溢出
@step=CASE WHEN LEN(@r_str)>LEN(@s_str)
THEN 4000/LEN(@r_str)*LEN(@s_str)
ELSE 4000 END

--替换处理的开始位置
SELECT @start=PATINDEX('%'+@s_str+'%',col),
@p=TEXTPTR(col),
@s=SUBSTRING(col,@start,@step),
@len=LEN(@s),
@last_repl=0
FROM tb
WHERE PATINDEX('%'+@s_str+'%',col)>0
AND TEXTVALID('tb.col',TEXTPTR(col))=1
WHILE @len>=@s_len
BEGIN
--得到最后一个被替换数据的位置
WHILE CHARINDEX(@s_str,@s,@last_repl)>0
SET @last_repl=@s_len
+CHARINDEX(@s_str,@s,@last_repl)

--如果需要,更新数据,同时判断下一个取数位置的偏移量
IF @last_repl=0
SET @last_repl=@s_len
ELSE
BEGIN
SELECT @last_repl=CASE
WHEN @len<@last_repl THEN 1
WHEN @len-@last_repl>=@s_len THEN @s_len
ELSE @len-@last_repl+2 END,
@s=REPLACE(@s,@s_str,@r_str),
@pos=@start-1
UPDATETEXT TB.col @p @pos @len @s
END
--获取下一个要处理的数据
SELECT @start=@start+LEN(@s)-@last_repl+1,
@s=SUBSTRING(col,@start,@step),
@len=LEN(@s),
@last_repl=0
FROM tb
END
GO

--显示处理结果
SELECT datalength(col),* FROM tb
DROP TABLE tb
上面说的是针对ntext字段的替换处理，如果要处理text字段，只需要先转换成ntext字段然后保存在临时表里面，处理完以后再从临时表写回text就行了。
其实一般象text，ntext字段这些都是抓到程序里面去处理的。