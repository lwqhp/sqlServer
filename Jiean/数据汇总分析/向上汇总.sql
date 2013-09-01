

--数据向上汇总
IF object_id('tempdb..#tb') IS NOT NULL DROP TABLE #tb
CREATE TABLE #tb(id INT ,VALUE int)
go

INSERT INTO #tb
SELECT 1,10 UNION ALL
SELECT 2,20 UNION ALL
SELECT 3,30 UNION ALL
SELECT 4,40 
--select * from #tb
;WITH summ AS(
	SELECT id,VALUE,VALUE AS num FROM #tb WHERE id = 1 
	UNION ALL 
	SELECT  a.id,a.VALUE,a.value+b.VALUE AS num  FROM #tb a,summ b WHERE a.id=b.id+1 
)
SELECT * FROM summ ORDER BY id

/*
	id=1 =>1,10 ->summ虚表 t1 
	union all
	num 和summ关联 ->summ生成虚表t2
	union all
		summ是包含子表，进入summ内部
		num和summ虚表t2关联 --生成虚表t3
	union all
			再进入summ内部
			num和summ虚表t3关联 --生成虚表t4
	
*/