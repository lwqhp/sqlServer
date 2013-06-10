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
    N'<tr><th>��������</th><th>��ҵ��</th>' +
    N'<th>��ҵ�������</th><th>��ҵ����״̬</th><th>��ҵ����</th>' +
    N'<th>��ҵ����ʱ��</th><th>��ҵ�޸�ʱ��</th><th>��ҵ�´�����ʱ��</th></tr>' +
    CAST ( ( SELECT td = h.[server] ,       '',
                    td = j.name, '',
                    td = case when j.[enabled]=1 then '������' else 'δ����' end ,'',
					td=case when h.run_status=0 then '��ҵʧ��' when h.run_status=1 then '��ҵ�ɹ�' when h.run_status=2 then '��ҵ����' when h.run_status=3 then '��ҵȡ��' end ,'',
					td=j.[description],'',
					td=j.date_created,'',
					td=j.date_modified,'',
					td=substring(convert (char(8),m.next_run_date),1,4)+'��'
+substring(convert (char(8),m.next_run_date),5,2)+'��'
+substring(convert (char(8),m.next_run_date),7,2)+'��'
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