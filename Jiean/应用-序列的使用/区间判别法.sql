
/*
按区间取最接近的上一个值
*/
IF OBJECT_ID('tempdb..#container') 	IS NOT NULL DROP TABLE #container

create table #container(
id int identity,
capacity int
)
go

INSERT INTO #container
SELECT * FROM (VALUES(10),(20),(30),(50),(80),(100),(110),(150),(180),(200)) a(capacity)
ORDER BY capacity DESC 


IF object_id('tempdb.dbo.#container2') is NOT NULL 
DROP TABLE #container2

SELECT a.capacity Startcapacity ,b.capacity Endcapacity 
INTO #container2
FROM #container a
RIGHT JOIN #container b ON b.id =a.id+1 
UNION 
SELECT a.capacity Startcapacity ,b.capacity Endcapacity 
FROM #container a
LEFT  JOIN #container b ON b.id =a.id+1 



--测试容积大小
declare @value int=456

;WITH tmp as(
	SELECT ISNULL(Startcapacity,Endcapacity) AS Startcapacity,@value-ISNULL(Startcapacity,Endcapacity) AS diffML 
	FROM #container2 
	WHERE (Startcapacity>=@value OR Startcapacity IS NULL ) 
		AND (@value>Endcapacity OR Endcapacity IS NULL)
	UNION ALL
	SELECT ISNULL(b.Startcapacity,Endcapacity) AS Startcapacity,a.diffML-ISNULL(b.Startcapacity,Endcapacity) AS diffML
	FROM tmp a,#container2 b
	where (b.Startcapacity>=a.diffMl OR b.Startcapacity IS NULL )  
		AND (a.diffML>b.Endcapacity OR b.Endcapacity IS NULL)
		AND a.diffML>0
)
SELECT @value as value, 
stuff((SELECT '+'+ CONVERT(VARCHAR(30),Startcapacity)+'*'+ cast(COUNT(Startcapacity) AS VARCHAR)
FROM tmp GROUP BY Startcapacity ORDER BY Startcapacity DESC   FOR XML PATH('')),1,1,'') AS result