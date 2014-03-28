
---给一个日期,生成本周的日期列表:
declare @date datetime
set @date=getdate()
select @date+1-datepart(dw,@date) --取指定日期所在周的星期一,默认星期日是一周的第一天

select dateadd(dd,a.number,DATEADD(Day,1-(DATEPART(Weekday,GETDATE())+@@DATEFIRST-2)%7-1,GETDATE()))
from master..spt_values a
where type='p'
    and number<=6


declare @d datetime
set @d = getdate()
select dateadd(d,n,@d) as t
from (select -1 as n union all select -2 union all select -3 union all select -4 union all select -5 union all select -6 union all
      select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 0) t
where datepart(wk,@d)=datepart(wk,dateadd(d,n,@d)) 
