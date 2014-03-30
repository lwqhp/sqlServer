
--字典
IF OBJECT_ID('TB') IS NOT NULL DROP TABLE TB
GO
CREATE TABLE TB(COL1 VARCHAR(MAX),COL2 VARCHAR(MAX))

INSERT INTO TB 
select '重','AGAIN'
union all
select '严重','Serious'
union all
select '误','ERR'
union all
select '误','ERR'
union all
select '在','In'
union all
select '国','country'
union all
select '爱','Love'
union all
select '中国人','Chinese'
union all
select '中国','China'
union all
select '家','Home'
    
GO

--select * from TB

--从最长开始匹配
drop table #tmp
select COL1,COL2,len(COL1) lenNum into #tmp from TB

--select * from #tmp

DECLARE @STR VARCHAR(MAX),@I INT ,@STR_RESULT VARCHAR(MAX)

set @STR = '中国人爱国'
select @STR=replace(@STR,COL1,'_'+COL2+'_') 
from #tmp 
where charindex(COL1,@STR)>0
order by lenNum DESC

select @STR,replace(replace(replace(@STR,'__','>>'),'_',''),'>>','_')

--网友提供
SELECT @STR='中国人爱国',@STR_RESULT='',@I=1
WHILE @I<=LEN(@STR)
BEGIN
	IF EXISTS(SELECT 1 FROM TB WHERE COL1 LIKE SUBSTRING(@STR,@I,1)+'%' AND @I+LEN(COL1)<=LEN(@STR)+1 AND STUFF(@STR,1,@I-1,'') LIKE COL1+'%')
		BEGIN
		SELECT TOP 1 @STR_RESULT=@STR_RESULT+COL2+'_',@I=@I+LEN(COL1)
				FROM TB
		WHERE COL1 LIKE SUBSTRING(@STR,@I,1)+'%' AND @I+LEN(COL1)<=LEN(@STR)+1 AND STUFF(@STR,1,@I-1,'') LIKE COL1+'%'
				ORDER BY LEN(COL1) DESC
	END
		ELSE
	BEGIN
			SELECT @STR_RESULT=@STR_RESULT+SUBSTRING(@STR,@I,1)
		SET @I=@I+1
	END
	END



IF @STR_RESULT LIKE '%[_]' SET @STR_RESULT=LEFT(@STR_RESULT,LEN(@STR_RESULT)-1)

SELECT @STR_RESULT