
--按时间间隔生成时间区段表

	declare @splitTime int
	declare @minTime datetime
	declare @maxTime datetime
	set @minTime ='2013-7-26 10:00:00'
	set @maxTime ='2013-7-27 20:00:00'
	set @splitTime=40
	select dateadd(mi,@splitTime*number-@splitTime,@minTime) as minDate,
	case when dateadd(mi,@splitTime*number,@minTime)>=@maxTime then @maxTime else dateadd(mi,@splitTime*number,@minTime) end as maxDate
	from master..spt_values 
	where type='p' and number>0 and dateadd(mi,@splitTime*number-@splitTime,@minTime)<=@maxTime

