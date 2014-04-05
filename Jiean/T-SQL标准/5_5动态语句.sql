
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


--动态sql语句基本语法 
--1 :普通SQL语句可以用Exec执行 

eg:   Select * from tableName 
         Exec('select * from tableName') 
         Exec sp_executesql N'select * from tableName'    -- 请注意字符串前一定要加N 

--2:字段名，表名，数据库名之类作为变量时，必须用动态SQL 

eg:   
declare @fname varchar(20) 
set @fname = 'FiledName' 
Select @fname from tableName              -- 错误,不会提示错误，但结果为固定值FiledName,并非所要。 
Exec('select ' + @fname + ' from tableName')     -- 请注意 加号前后的 单引号的边上加空格 

--当然将字符串改成变量的形式也可 
declare @fname varchar(20) 
set @fname = 'FiledName' --设置字段名 

declare @s varchar(1000) 
set @s = 'select ' + @fname + ' from tableName' 
Exec(@s)                -- 成功 
exec sp_executesql @s   -- 此句会报错 



declare @s Nvarchar(1000)  -- 注意此处改为nvarchar(1000) 
set @s = 'select ' + @fname + ' from tableName' 
Exec(@s)                -- 成功     
exec sp_executesql @s   -- 此句正确 

3. 输出参数 
declare @num int, 
        @sqls nvarchar(4000) 
set @sqls='select count(*) from tableName' 
exec(@sqls) 
--如何将exec执行结果放入变量中？ 

declare @num int,@sqls nvarchar(4000) 
set @sqls='select @a=count(*) from tableName ' 
exec sp_executesql @sqls,N'@a int output',@num output 
select @num 