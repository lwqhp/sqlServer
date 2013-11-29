
/*
Ϊ������ȷ�������ַ����߽�����ַ��а������ַ����߽����sql Ҫ���ַ����г��ֵ��ַ����߽����һ����2
���ַ����߽����ʾ������sql�޷�ʶ����Щ���ַ����߽������Щ���ַ����а������ַ���

���ۣ�ȡ--��
����һ:����  :   ���ָ���ȡֵ��Ȼ��õ���
������:�ӷ�  :   ���ָ�������union all select,ֱ�ӹ�������ı�
������:��Ƿ�:   ����ʱ���Ƿָ���λ�ã��ٽ�ȡ��

*/




--A)���ӷ�����ֵ���

/*--------ѭ����ȡ---------------
charindex�ҳ��ָ���λ�ã�len��ȡ��stuff�滻����ѭ����
*/

CREATE FUNCTION dbo.f_splitSTR(
	@s   varchar(8000),   --���ֲ���ַ���
	@split varchar(10)     --���ݷָ���
)RETURNS @re TABLE(
		col varchar(100))
AS
BEGIN
	DECLARE 
		@splitlen int

	-- ȡ�ָ����ĳ���, �ڷָ��������һ���ַ���Ϊ�˱���ָ����Կո����ʱ, ȡ������ȷ�ĳ���
	SET @splitlen = LEN(@split + 'a') - 2
	-- ������ֲ���ַ����д������ݷָ���, ��ѭ��ȡ��ÿ��������
	WHILE CHARINDEX(@split, @s)>0
	BEGIN
		-- ȡ��һ�����ݷָ���ǰ��������
		INSERT @re VALUES(LEFT(@s, CHARINDEX(@split, @s) - 1))
		-- ���Ѿ�ȡ���ĵ�һ������������ݷָ����Ӵ��ֲ���ַ�����ȥ��
		SET @s = STUFF(@s, 1, CHARINDEX(@split, @s) + @splitlen, '')
	END
	-- �������һ��������(���һ�����������û�����ݷָ���, ����ǰ���ѭ���в��ᱻ����)
	INSERT @re VALUES(@s)
	RETURN
END
GO



/*==============================================*/

--3.2.3.1 ʹ����ʱ�Էֲ�����
CREATE FUNCTION dbo.f_splitSTR(
	@s   varchar(8000),  --���ֲ���ַ���
	@split varchar(10)     --���ݷָ���
)RETURNS @re TABLE(
	col varchar(100))
AS
BEGIN
	--�����ֲ���ĸ�����(�û����庯����ֻ�ܲ��������)
	DECLARE @t TABLE(
		ID int IDENTITY,
		b bit)    -- ���ֻ��һ�������ֶ�(��ΪҪ��������������, ����Ҫ��һ���ַ�����������)
	INSERT @t(
		b) 
	SELECT TOP 8000 
		0 
	FROM dbo.syscolumns A, dbo.syscolumns B

	INSERT @re
	SELECT
		-- ����ÿ�����ݷָ�����λ��, ȡ��֮���������
        -- ��Ҫ˵������, ������ WHERE ��������ʱ, ���ֲ��ַ���ǰ��������һ�����ݷָ���, ���� ID �������, �����������ʵ��ʼλ��, ���������ݷָ�����λ��
		SUBSTRING(@s, ID, CHARINDEX(@split, @s + @split, ID) - ID)
	FROM @t
	WHERE CHARINDEX(@split, @split + @s, ID) = ID  -- ȡÿ��������ǰ������ݷָ�����λ��, �������λ�õļ�¼
                         -- ^^^^^^^^^^^ �ڴ��ֲ���ַ���ǰ���һ�����ݷָ�����Ϊ�˴����һ��������
		AND ID <= LEN(@s + 'a')      -- ����Ҫ������ֲ��ַ������ȵ���Щ��¼
	RETURN
END
GO

 

 

/*==============================================*/

--3.2.3.2 ʹ�������Էֲ�����
--�ַ����ֲ�����
SELECT TOP 8000 ID=IDENTITY(int,1,1) INTO dbo.tb_splitSTR
FROM syscolumns a,syscolumns b
GO

--�ַ����ֲ�����
CREATE FUNCTION f_splitSTR(
@s     varchar(8000),  --���ֲ���ַ���
@split  varchar(10)     --���ݷָ���
)RETURNS TABLE
AS
RETURN(
 SELECT col=CAST(SUBSTRING(@s,ID,CHARINDEX(@split,@s+@split,ID)-ID) as varchar(100))
 FROM tb_splitSTR
 WHERE ID<=LEN(@s+'a')
  AND CHARINDEX(@split,@split+@s,ID)=ID)
GO


--B.�Ѽ�¼��ָ���ֶε������ַ����ֲ𵽱�

CREATE TABLE tb(col varchar(50))
INSERT tb SELECT 'a,b,c'
UNION ALL SELECT 'aa,bb'

 SELECT TOP 50 ID = IDENTITY(int,1,1)
 INTO #
 FROM dbo.syscolums A,dbo.syscolumns B
 
 SELECT col = SUBSTRING(A.col,B.ID,charindex(',',A.col+',',B.ID)-B.ID)
 FROM tb A,# B
 WHERE B.ID <= len(A.col)
  AND charindex(',',','+A.col,B.ID) = B.ID
  
  DROP TABLE #

 

 

/*==============================================*/
--3.2.4�ֲ����ݵ���
/*
	1����Ҫ���������ݱ��浽һ����ʱ����.
	2,����ʱ�����½�һ�У��������������еĵ�һ��������浽�½������У�ͬʱ���Ѿ����浽���е���
	����������ݷָ����Ӵ����������������
	3��ѭ��2
	4������ʱ����ɾ�����������У���ѭ��ʡ���ж����ɵ�һ�����С�
*/
declare @t table(col varchar(50))
insert into @t select 'aa,ab,ac'
insert into @t select '1,2,3'

declare @i int,@s varchar(1000)
set @i=0
select col into #t from @t
while @@rowcount>0   --��ʼѭ��
 begin
  select @i=@i+1, @s='alter table #t add col' + cast(@i as varchar) +' varchar(10)'  --�޸ı�ṹ�����һ��
 exec(@s)
 set @s=' update #t set col'+cast(@i as varchar)
  +'=left(col,charindex('','',col+'','')-1),
   col=stuff(col,1,charindex('','',col+'',''),'''')
  where col>'''''   --�޸ĸ���ӵ���һ��ֵ,Ȼ��ض�col��
 exec(@s)
end   --����ѭ��
--ɾ��col�к����һ��
set @s='alter table #t drop column col,col'+cast(@i as varchar)

exec(@s)
select * from #t
drop table #t

 

 

/*==============================================*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[f_splitSTR]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[f_splitSTR]
GO

--3.2.5 �������������������ٴβ��
CREATE FUNCTION f_splitSTR(
@s   varchar(8000),    --���ֲ���ַ���
@split varchar(10)     --���ݷָ���
)RETURNS @re TABLE(No varchar(100),Value varchar(20))
AS
BEGIN
 --�����ֲ���ĸ�����(�û����庯����ֻ�ܲ��������)
 DECLARE @t TABLE(ID int IDENTITY,b bit)
 INSERT @t(b) SELECT TOP 8000 0 FROM syscolumns a,syscolumns b

 INSERT @re
 SELECT No=REVERSE(STUFF(col,1,PATINDEX('%[^-^.^0-9]%',col+'a')-1,'')),
  Value=REVERSE(LEFT(col,PATINDEX('%[^-^.^0-9]%',col+'a')-1))
 FROM(
  SELECT col=REVERSE(SUBSTRING(@s,ID,CHARINDEX(@split,@s+@split,ID)-ID))
  FROM @t
  WHERE ID<=LEN(@s+'a')
   AND CHARINDEX(@split,@split+@s,ID)=ID)a
 RETURN
END
GO


/*==============================================*/

--3.2.6 �ֲ��������
CREATE FUNCTION f_splitSTR(@s varchar(8000))
RETURNS @re TABLE(split varchar(10),value varchar(100))
AS
BEGIN
 DECLARE @splits TABLE(split varchar(10),splitlen as LEN(split))
 INSERT @splits(split)
 SELECT 'AC' UNION ALL
 SELECT 'BC' UNION ALL
 SELECT 'CC' UNION ALL
 SELECT 'DC' 
 DECLARE @pos1 int,@pos2 int,@split varchar(10),@splitlen int
 SELECT TOP 1
  @pos1=1,@split=split,@splitlen=splitlen
 FROM @splits
 WHERE @s LIKE split+'%'
 WHILE @pos1>0
 BEGIN
  SELECT TOP 1
   @pos2=CHARINDEX(split,@s,@splitlen+1)
  FROM @splits
  WHERE CHARINDEX(split,@s,@splitlen+1)>0
  ORDER BY CHARINDEX(split,@s,@splitlen+1)
  IF @@ROWCOUNT=0
  BEGIN
   INSERT @re VALUES(@split,STUFF(@s,1,@splitlen,''))
   RETURN
  END
  ELSE
  BEGIN
   INSERT @re VALUES(@split,SUBSTRING(@s,@splitlen+1,@pos2-@splitlen-1))
   SELECT TOP 1
    @pos1=1,@split=split,@splitlen=splitlen,@s=STUFF(@s,1,@pos2-1,'')
   FROM @splits
   WHERE STUFF(@s,1,@pos2-1,'') LIKE split+'%'
  END
 END
 RETURN
END
GO

 