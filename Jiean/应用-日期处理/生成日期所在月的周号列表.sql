--�������������µĵڼ���
/*
���������������-���������µ���һ���µ����������͵�������µ�����
*/
declare @startDate datetime
declare @endDate datetime
set @startDate='2013-08-03'
set @endDate='2013-10-23'

select datepart(week,@startDate+number)
-datepart(week,dateadd(day,1-datepart(day,@startDate+number),@startDate+number))+1 as weekNum, 
@startDate+number as rangeDate
from master..spt_values where type = 'P' and number<=datediff(day,@startDate,@endDate)