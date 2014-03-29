
/*
按区间取最接近的上一个值

需求：
用最少的容器个数，最小浪费容器空间的容器去装溶液

比如360的溶液用200+180的瓶子

分析：
重点在于找到大于溶液但该容器的下一个容器又小于溶液的瓶子
首先，为了找到容器之间的大小关联，把容器排序生成序列。
为找到比上一个容器小，比下一个容器大的瓶子，把序列转成区间，以判断溶液落在那一个区间上,找到那个区间记录
溶液装盛后，剩余溶液继续找下一个瓶子，需要用到递归完成整个操作。
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

SELECT NULL Startcapacity,(SELECT MAX(capacity) FROM #container) Endcapacity
INTO #container2
UNION all
SELECT a.capacity Startcapacity ,b.capacity Endcapacity 
FROM #container a
LEFT JOIN #container b ON a.id = b.id-1

--SELECT * FROM #container

--DECLARE @capacity_pre INT

--SELECT @capacity_pre,capacity,@capacity_pre=capacity FROM #container

--SELECT * FROM #container2

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