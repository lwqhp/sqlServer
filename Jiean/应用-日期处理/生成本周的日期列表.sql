
---��һ������,���ɱ��ܵ������б�:
declare @date datetime
set @date=getdate()
select @date+1-datepart(dw,@date) --ȡָ�����������ܵ�����һ,Ĭ����������һ�ܵĵ�һ��

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
