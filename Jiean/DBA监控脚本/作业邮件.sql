DECLARE @tableHTML  NVARCHAR(MAX) ;
declare @date smalldatetime
set @date=CONVERT(char(10),GETDATE(),120)
declare @title varchar(64)
select @title=CONVERT(char(10),GETDATE(),120)+'  Jobs Report '
declare @DBA varchar(1024)
set @DBA='george@hengkangit.com;13535500271@139.com'

SET @tableHTML =
    N'<H1>Jobs Report</H1>' +
    N'<table border="1">' +
    N'<tr><th>服务器名</th><th>作业名</th>' +
    N'<th>作业启用情况</th><th>作业运行状态</th><th>作业描述</th>' +
    N'<th>作业创建时间</th><th>作业修改时间</th><th>作业下次运行时间</th></tr>' +
    CAST ( ( SELECT td = h.[server] ,       '',
                    td = j.name, '',
                    td = case when j.[enabled]=1 then '已启用' else '未启用' end ,'',
					td=case when h.run_status=0 then '作业失败' when h.run_status=1 then '作业成功' when h.run_status=2 then '作业重试' when h.run_status=3 then '作业取消' end ,'',
					td=j.[description],'',
					td=j.date_created,'',
					td=j.date_modified,'',
					td=substring(convert (char(8),m.next_run_date),1,4)+'年'
+substring(convert (char(8),m.next_run_date),5,2)+'月'
+substring(convert (char(8),m.next_run_date),7,2)+'日'
              from msdb.dbo.sysjobschedules m inner join msdb.dbo.sysjobs j on m.job_id=j.job_id
inner join msdb.dbo.sysjobschedules s on m.schedule_id=s.schedule_id
inner  join (select distinct job_id,run_status,[server] from msdb.dbo.sysjobhistory) h on m.job_id=h.job_id
order by run_status 
              FOR XML PATH('tr'), TYPE 
    ) AS NVARCHAR(MAX) ) +
    N'</table>' ;

EXEC msdb.dbo.sp_send_dbmail @recipients=@DBA,
    @subject = @title,
    @body = @tableHTML,
    @body_format = 'HTML' ;