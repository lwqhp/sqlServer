
/*
������ȡ��ӽ�����һ��ֵ

����
�����ٵ�������������С�˷������ռ������ȥװ��Һ

����360����Һ��200+180��ƿ��

������
�ص������ҵ�������Һ������������һ��������С����Һ��ƿ��
���ȣ�Ϊ���ҵ�����֮��Ĵ�С�����������������������С�
Ϊ�ҵ�����һ������С������һ���������ƿ�ӣ�������ת�����䣬���ж���Һ������һ��������,�ҵ��Ǹ������¼
��Һװʢ��ʣ����Һ��������һ��ƿ�ӣ���Ҫ�õ��ݹ��������������
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

--�����ݻ���С
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