
�ַ�����һ����char��varchar��������(���ַ���)���Ϊ8000�ֽڣ�����8000���ֽڵ��ı���Ҫʹ��ntext����text�����������洢�� 

����������һ����binary��varbinary ���Ϊ8 KB�������� 8 KB �Ŀɱ䳤�ȵĶ��������ݣ�
�� Microsoft Word �ĵ���Microsoft Excel ���ӱ�񡢰���λͼ��ͼ��ͼ�ν�����ʽ (GIF) �ļ�������ͼ��ר���� (JPEG) 
	�ļ���ʹ��image �����������洢�� 

ntext��text �� image ���������ڵ���ֵ�п��԰����ǳ���������������ɴ� 2 GB��

Text�ֶ����Ͳ���ֱ����replace�������滻��������updatetext�� 

�ֶαȽϲ����á�where �ֶ� = ��ĳ���ݡ�,������like�����棻 

updatetextʱ����dest_text_ptrֵΪNULLʱ�ᱨ����ע�⡣������Ϣ����UpdateText ���������� NULL textptr��text��ntext �� image ָ�룩��
ע�⣬BLOB��ΪNULL�������в�Ϊ��ʱ��dest_text_prtΪNOT NULL����BOLB������Ϊ�գ�
��dest_text_prtΪNULL��delete_length����С�ڵ����ֶ��ܳ��ȣ����򱨴�
ɾ������  ���ڿ��õ� text��ntext �� image ���ݷ�Χ�ڡ� 

PATINDEX / CHARINDEX ����������ָ��ģʽ�Ŀ�ʼλ�á�PATINDEX ��ʹ��ͨ�����
�� CHARINDEX �����ԡ�IS NULL��IS NOT NULL �� LIKE����Щ�� WHERE �Ӿ��ж� text / ntext������Ч�Ľ��е������Ƚ����㡣
����֮�⣬PATINDEX Ҳ������ WHERE �Ӿ��У� 

ʹ�� TEXTVALID ������ı�ָ���Ƿ���ڡ�������Ч�ı�ָ��ʱ������ʹ�� UPDATETEXT��WRITETEXT �� READTEXT��
����SELECT 'Valid (if 1) Text data' 
   = TEXTVALID ('pub_info.logo', TEXTPTR(logo)) FROM pub_info WHERE logo like '%hello%'��  

LENֻ�Զ��ַ�����Ч������text/ntext/image���ͣ���ʹ��DATALENGTH���õ����ݳ���

/*
Ntext,text,image�������ͣ����ڴ洢���ͷ� Unicode �ַ���Unicode �ַ������������ݵĹ̶����ȺͿɱ䳤���������͡�
							Unicode ����ʹ�� UNICODE UCS-2 �ַ���
							
text�������ͣ������ڵ�server2000��ǰ�����ݿ���һ��TEXT ����洢��ʵ������һ��ָ�룬
��ָ��һ����8KB ��8192 ���ֽڣ�Ϊ��λ������ҳ��Data Page������Щ����ҳ�Ƕ�̬���Ӳ����߼����������ġ�
��SQL Server 2000 �У���TEXT ��IMAGE ���͵�����ֱ�Ӵ�ŵ�����������У������Ǵ�ŵ���ͬ������ҳ�С� 
��ͼ��������ڴ洢TEXT ��IMA- GE ���͵Ŀռ䣬����Ӧ�����˴��̴����������ݵ�I/O ������
�ڱ��п��Կ�������<long text>���ֶΡ�

�����ֶ����ԣ���Ϊһҳ����ԣ���Ϊ��
*/

--��Դ����������ͣ����Բ��ö������ֽ����ķ�ʽ��ȡ����Ҫʹ�õ����������ͷ���

--���ر��ʽ��ռ�õ��ֽ���,Ҳ�����ڴ����л��
datalength(expression) 

--�����е��ı�ʵ��ָ��ֵ,Ϊ������ֵ
textptr(COLUMN)

--ָ�����ݶ�λ������ָ���ı��ĵ�һ�γ���λ��
patindex(['%pattern%'],expression)

--��ָ֤����Ч��
TEXTVALID(['table.column'],text_ptr)

--ָ���� SELECT ��䷵�ص� text �� ntext ���ݵĴ�С��
SET TEXTSIZE

--ȡ��ָ��λ�õ��ֽ�
substring(expression,start,length)

--�ֶεĶ�ȡ�����£�д��
--��ָ����ƫ������ʼ��ȡָ�����ֽ���
READTEXT{ table.column text_ptr offset size } [ HOLDLOCK ] 

--���ʵ���λ�ø��� text��ntext �� image �е�һ����
UPDATETEXT

--���º��滻���� text��ntext �� image �ֶ�
--��������е� text��ntext �� image �н�������־��¼�Ľ���ʽ���¡�
--����佫������д����Ӱ������е��κ��������ݡ�WRITETEXT ��䲻��������ͼ�е� text��ntext �� image ���ϡ�
WRITETEXT


--�ڲ�ѯ�������в鿴�����ڵ��ֶ�����
--����--ѡ��--���--ÿ�������ʾ�ַ���:8000
SELECT * FROM [TABLE]

--����
varchar��nvarchar������֧��replace������������text������8000������ת����ǰ������������ʹ��replace��
update ����
set �ֶ���=replace(convert(varchar(8000),�ֶ���),'Ҫ�滻���ַ�','�滻�ɵ�ֵ')



--������text����8000������������ķ�����
--��������
CREATE TABLE tb(col ntext)
INSERT tb VALUES(REPLICATE( '0001,0002,0003,0004,0005,0006,0007,0008,0009,0100,'
+'220000001,302000004,500200006,700002008,900002120,',800))
DECLARE @p binary(16)
SELECT @p=TEXTPTR(col) FROM tb
UPDATETEXT tb.col @p NULL 0 tb.col @p
GO

/*
��Ϣ 7118������ 16��״̬ 1���� 4 ��
�����Ͷ���(LOB)��������Լ�ʱ����֧�������滻��
�������ֹ��
declare @p binary(16)
select @p = textptr(col) from tb
updatetext tb.col @p null 0 tb.col @p
*/

--�滻������
DECLARE @sourceStr nvarchar(1000),@objStr nvarchar(1000)
SELECT @sourceStr='0001' --Ҫ�滻���ַ���
,@objStr='1111' --�滻�ɸ��ַ���

DECLARE @p_col varbinary(16)
DECLARE @s_StartPat int,@subStr nvarchar(4000),@subStr_len int
DECLARE @s_len int,@cutLen int,@search_start int,@pos int

--�滻�����������
SELECT
--����Ҫ�ж�ÿ�ν�ȡ����,���һ�����滻����λ�õĴ���
@s_len=LEN(@sourceStr),

--����ÿ��Ӧ�ý�ȡ�����ݵĳ���,��ֹREPLACE���������
@cutLen=CASE WHEN LEN(@objStr)>LEN(@sourceStr)
THEN 4000/LEN(@objStr)*LEN(@sourceStr)
ELSE 4000 END


--�滻����Ŀ�ʼλ��
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
	--�õ����һ�����滻���ݵ�λ��
	WHILE CHARINDEX(@sourceStr,@subStr,@search_start)>0
		SET @search_start=@s_len
		+CHARINDEX(@sourceStr,@subStr,@search_start)

	--�����Ҫ,��������,ͬʱ�ж���һ��ȡ��λ�õ�ƫ����
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
	--��ȡ��һ��Ҫ���������
	SELECT @s_StartPat=@s_StartPat+LEN(@subStr)-@search_start+1,
	@subStr=SUBSTRING(col,@s_StartPat,@cutLen),
	@subStr_len=LEN(@subStr),
	@search_start=0
	FROM tb
END
GO

--��ʾ������
SELECT datalength(col),* FROM tb
DROP TABLE tb
����˵�������ntext�ֶε��滻�������Ҫ����text�ֶΣ�ֻ��Ҫ��ת����ntext�ֶ�Ȼ�󱣴�����ʱ�����棬
�������Ժ��ٴ���ʱ��д��text�����ˡ�
��ʵһ����text��ntext�ֶ���Щ����ץ����������ȥ����ġ�


1���滻

--�������ݲ��Ի���
create table #tb(aa text)
insert into #tb select 'abc123abc123,asd'

--�����滻���ַ���
declare @s_str varchar(8000),@d_str varchar(8000)
select @s_str='123', --Ҫ�滻���ַ���
         @d_str='000' --�滻�ɵ��ַ���

--�ַ����滻����
--��ȡ��ֵַ���ַ�����ʼ��ַ������
declare @p varbinary(16),@postion int,@rplen int
select @p=textptr(aa),@rplen=len(@s_str),@postion=charindex(@s_str,aa)-1 from #tb
while @postion>0
begin
   updatetext #tb.aa @p @postion @rplen @d_str
   select @postion=charindex(@s_str,aa)-1 from #tb
end

--��ʾ���
select * from #tb

--ɾ�����ݲ��Ի���
drop table #tb

2��ȫ���滻

DECLARE @ptrval binary(16)
DECLARE @ptrvld int
SELECT @ptrval = TEXTPTR(aa), @ptrvld = TEXTVALID('#tb.aa', TEXTPTR(AA))  FROM  #tb  WHERE aa like '%����2%'
-- һ��Ҫ���������жϣ��������Ҳ���Ŀ���ļ�ָ����һ��SQL�ͻᱨ������Ҫ����
if @ptrval is not null and  @ptrvld = 1
   UPDATETEXT #tb.aa @ptrval 0 null '����3'

3�����ֶ�β���


--������ӵĵ��ַ���
declare @s_str varchar(8000)
select @s_str='*C'   --Ҫ��ӵ��ַ���
--�ַ�����Ӵ���
declare @p varbinary(16),@postion int,@rplen int
select @p=textptr(detail) from test where id='001'
updatetext test.detail @p null null @s_str

