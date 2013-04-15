
/*
为了能正确地区分字符串边界符和字符中包含的字符串边界符，sql 要求字符串中出现的字符串边界符，一律用2
个字符串边界符表示，否则sql无法识别哪些是字符串边界符，哪些是字符串中包含的字符。

概论：取--存
方法一:减法  :   按分隔符取值，然后裁掉。
方法二:加法  :   按分隔符加上union all select,直接构建虚拟的表集
方法三:标记法:   建临时表标记分隔符位置，再截取。

*/




--A)把子符串拆分到表

/*--------循环截取---------------
charindex找出分隔符位置，len截取，stuff替换掉，循环。
*/

CREATE FUNCTION dbo.f_splitSTR(
	@s   varchar(8000),   --待分拆的字符串
	@split varchar(10)     --数据分隔符
)RETURNS @re TABLE(
		col varchar(100))
AS
BEGIN
	DECLARE 
		@splitlen int

	-- 取分隔符的长度, 在分隔符后面加一个字符是为了避免分隔符以空格结束时, 取不到正确的长度
	SET @splitlen = LEN(@split + 'a') - 2
	-- 如果待分拆的字符串中存在数据分隔符, 则循环取出每个数据项
	WHILE CHARINDEX(@split, @s)>0
	BEGIN
		-- 取第一个数据分隔符前的数据项
		INSERT @re VALUES(LEFT(@s, CHARINDEX(@split, @s) - 1))
		-- 将已经取出的第一个数据项和数据分隔符从待分拆的字符串中去掉
		SET @s = STUFF(@s, 1, CHARINDEX(@split, @s) + @splitlen, '')
	END
	-- 保存最后一个数据项(最后一个数据项后面没有数据分隔符, 故在前面的循环中不会被处理)
	INSERT @re VALUES(@s)
	RETURN
END
GO



/*==============================================*/

--3.2.3.1 使用临时性分拆辅助表法
CREATE FUNCTION dbo.f_splitSTR(
	@s   varchar(8000),  --待分拆的字符串
	@split varchar(10)     --数据分隔符
)RETURNS @re TABLE(
	col varchar(100))
AS
BEGIN
	--创建分拆处理的辅助表(用户定义函数中只能操作表变量)
	DECLARE @t TABLE(
		ID int IDENTITY,
		b bit)    -- 这个只是一个辅助字段(因为要生成自增列数据, 所以要多一个字符来插入数据)
	INSERT @t(
		b) 
	SELECT TOP 8000 
		0 
	FROM dbo.syscolumns A, dbo.syscolumns B

	INSERT @re
	SELECT
		-- 对于每个数据分隔符的位置, 取其之后的数据项
        -- 需要说明的是, 由于在 WHERE 条件处理时, 待分拆字符串前面增加了一个数据分隔符, 所以 ID 所代表的, 是数据项的真实开始位置, 而不是数据分隔符的位置
		SUBSTRING(@s, ID, CHARINDEX(@split, @s + @split, ID) - ID)
	FROM @t
	WHERE CHARINDEX(@split, @split + @s, ID) = ID  -- 取每个数据项前面的数据分隔符的位置, 并处理该位置的记录
                         -- ^^^^^^^^^^^ 在待分拆的字符串前面加一个数据分隔符是为了处理第一个数据项
		AND ID <= LEN(@s + 'a')      -- 仅需要处理待分拆字符串长度的那些记录
	RETURN
END
GO

 

 

/*==============================================*/

--3.2.3.2 使用永久性分拆辅助表法
--字符串分拆辅助表
SELECT TOP 8000 ID=IDENTITY(int,1,1) INTO dbo.tb_splitSTR
FROM syscolumns a,syscolumns b
GO

--字符串分拆处理函数
CREATE FUNCTION f_splitSTR(
@s     varchar(8000),  --待分拆的字符串
@split  varchar(10)     --数据分隔符
)RETURNS TABLE
AS
RETURN(
 SELECT col=CAST(SUBSTRING(@s,ID,CHARINDEX(@split,@s+@split,ID)-ID) as varchar(100))
 FROM tb_splitSTR
 WHERE ID<=LEN(@s+'a')
  AND CHARINDEX(@split,@split+@s,ID)=ID)
GO


--B.把记录中指定字段的所有字符串分拆到表

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
--3.2.4分拆数据到列
/*
	1，将要分析的数据保存到一个临时表中.
	2,在临时表中新建一列，将待分析的列中的第一个数据项保存到新建的列中，同时将已经保存到新列的数
	据项及其后的数据分隔符从待分析的列中清除。
	3，循环2
	4，从临时表中删除待分析的列，及循环省理中多生成的一个空列。
*/
declare @t table(col varchar(50))
insert into @t select 'aa,ab,ac'
insert into @t select '1,2,3'

declare @i int,@s varchar(1000)
set @i=0
select col into #t from @t
while @@rowcount>0   --开始循环
 begin
  select @i=@i+1, @s='alter table #t add col' + cast(@i as varchar) +' varchar(10)'  --修改表结构，添加一列
 exec(@s)
 set @s=' update #t set col'+cast(@i as varchar)
  +'=left(col,charindex('','',col+'','')-1),
   col=stuff(col,1,charindex('','',col+'',''),'''')
  where col>'''''   --修改刚添加的那一列值,然后截断col列
 exec(@s)
end   --结束循环
--删除col列和最后一列
set @s='alter table #t drop column col,col'+cast(@i as varchar)

exec(@s)
select * from #t
drop table #t

 

 

/*==============================================*/

if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[f_splitSTR]') and xtype in (N'FN', N'IF', N'TF'))
drop function [dbo].[f_splitSTR]
GO

--3.2.5 将数据项按数字与非数字再次拆份
CREATE FUNCTION f_splitSTR(
@s   varchar(8000),    --待分拆的字符串
@split varchar(10)     --数据分隔符
)RETURNS @re TABLE(No varchar(100),Value varchar(20))
AS
BEGIN
 --创建分拆处理的辅助表(用户定义函数中只能操作表变量)
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

--3.2.6 分拆短信数据
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

 