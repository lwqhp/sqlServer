1��varchar��nvarchar������֧��replace������������text������8000������ת����ǰ������������ʹ��replace��
update ����
set �ֶ���=replace(convert(varchar(8000),�ֶ���),'Ҫ�滻���ַ�','�滻�ɵ�ֵ')
2��������text����8000������������ķ�����
--��������
CREATE TABLE tb(col ntext)
INSERT tb VALUES(REPLICATE( '0001,0002,0003,0004,0005,0006,0007,0008,0009,0100,'
+'220000001,302000004,500200006,700002008,900002120,',800))
DECLARE @p binary(16)
SELECT @p=TEXTPTR(col) FROM tb
UPDATETEXT tb.col @p NULL 0 tb.col @p
GO

--�滻������
DECLARE @s_str nvarchar(1000),@r_str nvarchar(1000)
SELECT @s_str='00' --Ҫ�滻���ַ���
,@r_str='0000' --�滻�ɸ��ַ���

DECLARE @p varbinary(16)
DECLARE @start int,@s nvarchar(4000),@len int
DECLARE @s_len int,@step int,@last_repl int,@pos int

--�滻�����������
SELECT
--����Ҫ�ж�ÿ�ν�ȡ����,���һ�����滻����λ�õĴ���
@s_len=LEN(@s_str),

--����ÿ��Ӧ�ý�ȡ�����ݵĳ���,��ֹREPLACE���������
@step=CASE WHEN LEN(@r_str)>LEN(@s_str)
THEN 4000/LEN(@r_str)*LEN(@s_str)
ELSE 4000 END

--�滻����Ŀ�ʼλ��
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
--�õ����һ�����滻���ݵ�λ��
WHILE CHARINDEX(@s_str,@s,@last_repl)>0
SET @last_repl=@s_len
+CHARINDEX(@s_str,@s,@last_repl)

--�����Ҫ,��������,ͬʱ�ж���һ��ȡ��λ�õ�ƫ����
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
--��ȡ��һ��Ҫ���������
SELECT @start=@start+LEN(@s)-@last_repl+1,
@s=SUBSTRING(col,@start,@step),
@len=LEN(@s),
@last_repl=0
FROM tb
END
GO

--��ʾ������
SELECT datalength(col),* FROM tb
DROP TABLE tb
����˵�������ntext�ֶε��滻�������Ҫ����text�ֶΣ�ֻ��Ҫ��ת����ntext�ֶ�Ȼ�󱣴�����ʱ�����棬�������Ժ��ٴ���ʱ��д��text�����ˡ�
��ʵһ����text��ntext�ֶ���Щ����ץ����������ȥ����ġ�