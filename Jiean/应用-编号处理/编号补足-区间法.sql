

--编号补足--双列
--drop table #cardCode

create table #cardCode(
	shopName varchar(50),
	cardtype varchar(50),
	cardCode varchar(100)
)
go
insert into #cardCode
select 'G080','芭迪八折','8801456——8801505' 


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


--drop table #
--select * from #
--drop table #result

--循环处理每一个区间
create table #result(
	shopName varchar(50),
	cardtype varchar(50),
	cardCode varchar(100)
	)
go
declare @id tinyint 
select top 1 @id=id from #

while @@ROWCOUNT>0
begin
	insert into #result
	select shopName,cardtype, 
	newcard= case when len(startCard+number)<digit
					then preCard+right(replicate('0',digit)+cast(startCard+number as varchar),digit)
					else preCard+cast(startCard+number as varchar)
					end 
	from #,master..spt_values where type = 'P' and id=@id and startCard+number<=endCard
	delete from # where id = @id
	select top 1 @id=id from # 
end

select *,'select '''+shopName+''','''+cardtype+''','''+cardCode+''' union all' from #result


