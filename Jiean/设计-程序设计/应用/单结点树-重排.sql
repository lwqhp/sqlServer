-- 测试数据
drop table #t
create TABLE #t (Code varchar(10))
INSERT #t SELECT '1'
UNION ALL SELECT '3'
UNION ALL SELECT '302'
UNION ALL SELECT '305'
UNION ALL SELECT '305001'
UNION ALL SELECT '305005'
UNION ALL SELECT '6'
UNION ALL SELECT '601'

--select * from #t
--前提要求：编号排好序
select right((select count(Code) from #t where len(Code)=1 and Code<=a.Code),1)--第一级仅统计截止当前记录为止, 出现过的一级编码的次数
	+ case when len(a.Code)>1  then 
		right(100+(select count(Code) from #t where Code like left(a.Code,1)+ '__' and Code<=a.Code),2) 
		else '' end
	+ case when len(a.Code)>3  then
		right(1000+(select count(Code) from #t where Code LIKE LEFT(A.Code, 3) + '___' and Code<=a.Code),3) 
		else '' end
	,* from #t a


-- 显示处理结果
SELECT * FROM #t
/*--结果
Code
----------
1
2
201
202
202001
202002
3
301
--*/
