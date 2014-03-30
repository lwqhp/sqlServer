

SELECT TOP 1000 IDENTITY(INT,1,1) id 
INTO Nums
FROM sys.objects a ,sys.objects b 
go

CREATE FUNCTION dbo.fn_MutiSplitTSQL
    (
      @string NVARCHAR(MAX) ,
      @separator NCHAR(1) ,
      @Sub@separator NCHAR(1) = N','
    )
RETURNS TABLE
AS    
RETURN
SELECT  *
FROM(
	--按","拆分到行,同理,用于行转列
	/*
	col1 092-1350
	col2 099201-080901
	*/
	SELECT d.pos ,'col'+ CAST(a.id - LEN(REPLACE(LEFT(element, a.id),@Sub@separator, '')) + 1 AS VARCHAR(10)) AS attribute ,
		SUBSTRING(element, a.id,CHARINDEX(@Sub@separator,element + @Sub@separator, a.id)- a.id) AS value
	FROM ( 
		--按$拆分到行,分隔符的位置ID-去掉分隔符的字符串长度=分隔的第几个，用于分组
		SELECT a.id - LEN(REPLACE(LEFT(array, a.id),@separator, '')) + 1 AS pos ,
			SUBSTRING(array, a.id, CHARINDEX(@separator,array + @separator,a.id) - a.id) AS element
		FROM (SELECT @string AS array) AS D
		INNER JOIN dbo.Nums a ON a.id <= LEN(array) 
			AND SUBSTRING(@separator+ array, a.id, 1) = @separator
		) AS D
	INNER JOIN dbo.Nums a ON a.id <= LEN(element)
	  AND SUBSTRING(@Sub@separator+ element, a.id, 1) = @Sub@separator
  
) AS d PIVOT( MAX(value) FOR attribute IN ( col1, col2, col3, col4) ) AS P    

GO  

SELECT  col1,col2,col3,col4
FROM    dbo.fn_MutiSplitTSQL('092-1350,099201-080901,12050720,2012-6-11$092-0970,099204-072301,12050734,2012-6-11',
                             '$', ',')   
   