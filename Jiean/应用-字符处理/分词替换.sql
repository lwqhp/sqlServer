
--�ֵ�
IF OBJECT_ID('TB') IS NOT NULL DROP TABLE TB
GO
CREATE TABLE TB(COL1 VARCHAR(MAX),COL2 VARCHAR(MAX))

INSERT INTO TB 
select '��','AGAIN'
union all
select '����','Serious'
union all
select '��','ERR'
union all
select '��','ERR'
union all
select '��','In'
union all
select '��','country'
union all
select '��','Love'
union all
select '�й���','Chinese'
union all
select '�й�','China'
union all
select '��','Home'
    
GO

--select * from TB

--�����ʼƥ��
drop table #tmp
select COL1,COL2,len(COL1) lenNum into #tmp from TB

--select * from #tmp

DECLARE @STR VARCHAR(MAX),@I INT ,@STR_RESULT VARCHAR(MAX)

set @STR = '�й��˰���'
select @STR=replace(@STR,COL1,'_'+COL2+'_') 
from #tmp 
where charindex(COL1,@STR)>0
order by lenNum DESC

select @STR,replace(replace(replace(@STR,'__','>>'),'_',''),'>>','_')

--�����ṩ
SELECT @STR='�й��˰���',@STR_RESULT='',@I=1
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