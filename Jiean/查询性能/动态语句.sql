
/*
动态语句里的建表只在exec()范围里有效，需要在外面可访问，1建实体表或是全局临时表
*/

if object_id('tempdb.dbo.#a') is not null drop table #a
create table #a(
	shopid varchar(20),
	stockQty	int,
	standardQty int
)

insert into #a
select 'A',40,50 union all
select 'B',20,30 union all
select 'C',11,22

--select * from #a

create unique index PK_shopID on #a(shopid)
if object_id('tempdb.dbo.#b') is not null drop table #b
create table #b(companyID varchar(20))
insert into #b(companyID)values('YBL')
--alter table #b add shopidA varchar(20),stockQtyA	int,standardQtyA int
--	update #b set shopidA='A',stockQtyA=40,standardQtyA=50
--	select * from #b
declare @shopid varchar(20)
declare @sql nvarchar(max)
declare @stockQty varchar(10),@standardQty varchar(10)
set @shopid= (select top 1 shopid from #a)
set @sql=''
while @shopid is not null
begin 
	select @stockQty =stockQty,@standardQty=standardQty from #a where shopid = @shopid
	set @sql=@sql+N'
	alter table #b add shopid'+@shopid+' varchar(20),stockQty'+@shopid+'	int,standardQty'+@shopid+' int
	update #b set [shopid'+@shopid+']='''+@shopid+''',[stockQty'+@shopid+']='+@stockQty+',[standardQty'+@shopid+']='+@standardQty+'
'
--print @sql

	delete #a where shopid=@shopid
	set @shopid = (select top 1 shopid from #a)
end
print @sql
exec(@sql)
select * from  #b
