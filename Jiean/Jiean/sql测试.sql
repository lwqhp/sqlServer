



--首先，准备一个有100万记录的测试表：



create table NUM (n int primary key, s varchar(128))
GO
set nocount on
declare @n int
set @n=1000000
while @n>0 begin
    insert into NUM
          select @n,'Value: '+convert(varchar,@n)
    set @n=@n-1
    end
GO


SELECT * FROM num
create procedure T1
    @total int
as
    create table #T (n int, s varchar(128))
    insert into #T select n,s from NUM
          where n%100>0 and n<=@total
    declare @res varchar(128)
    select @res=max(s) from NUM
          where n<=@total and
              not exists(select * from #T
              where #T.n=NUM.n)
GO
