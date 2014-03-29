
/*
利用序列表的数值递增及表关系，产生一个源表的递增数据集。

源表有递增数值的范围，在与序列表cross join时要做条件判断
id	shopName	cardtype	startCard	endCard	preCard	digit
1	G080		芭迪八折	8801456		8801466			7
2	G080		芭迪八折	8801601		8801620			7

--输出结果
1	G080	芭迪八折	8801463
1	G080	芭迪八折	8801464
1	G080	芭迪八折	8801465
1	G080	芭迪八折	8801466

2	G080	芭迪八折	8801601
2	G080	芭迪八折	8801602
2	G080	芭迪八折	8801603


*/

--编号补足--双列
--drop table #cardCode
IF object_id('tempdb.dbo.#cardCode') IS NOT NULL DROP TABLE #cardCode
create table #cardCode(
	shopName varchar(50),
	cardtype varchar(50),
	cardCode varchar(100)
)
go
insert into #cardCode
select 'G080','芭迪八折','8801456——8801466' UNION ALL
select 'G080','芭迪八折','8801601——8801620' 


--统一分隔符
update #cardCode set cardCode= replace(cardCode,'—','-')
--select * from #cardCode

--去掉公司代码
;with tmp as(
	select shopName,cardtype,
	startCard=left(cardCode,charindex('-',cardCode+'-')-1),
	endCard =right(cardCode,charindex('-',reverse('-'+cardCode))-1)
	from #cardCode
)
select  identity(int,1,1) as id,shopName,cardtype,
startCard=stuff(startCard,1,patindex('%[0-9]%',startCard)-1,''),
endCard =stuff(endCard,1, patindex('%[0-9]%',endCard)-1,''),
preCard = left(startCard,patindex('%[0-9]%',startCard)-1),
digit = len(stuff(endCard,1, patindex('%[0-9]%',endCard)-1,''))
into #
from tmp

--select * from #

select id,shopName,cardtype, 
	newcard= case when len(startCard+number)<digit
					then preCard+right(replicate('0',digit)+cast(startCard+number as varchar),digit)
					else preCard+cast(startCard+number as varchar)
					end 
	from #,master..spt_values where type = 'P' and startCard+number<=endCard


