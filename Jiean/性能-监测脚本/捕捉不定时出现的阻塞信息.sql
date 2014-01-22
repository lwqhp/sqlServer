
/*
捕捉不定时出现的阻塞信息
*/

use master
go

while 1=1
begin 
print 'start time:'+convert(varchar(20),getdate(),121)
print 'running processes'
select spid,blocked,waittype,waittime,lastwaittype,waitresource,dbid,uid,cpu,
physical_io,memusage,login_time,last_batch,
open_tran,status,hostname,program_name,cmd,net_library,loginame 
from sysprocesses
--where (kpid<>0) or (spid<51)
--change it if you only want to see the working processe
print '********lockinfo*******'
select convert(smallint,req_spid) as spid,
rsc_dbid as dbid,
rsc_objid as objID,
rsc_indid as indid,
substring(v.name,1,4) as type,
substring(rsc_text,1,32) as resource,
substring(u.name,1,8)as mode,
substring(x.name,1,5) as status
from master.dbo.syslockinfo,
master.dbo.spt_values v,
master.dbo.spt_values x,
master.dbo.spt_values u
where master.dbo.syslockinfo.rsc_type = v.number
and v.type = 'LR'
and master.dbo.syslockinfo.req_status = x.number
and x.type = 'LS'
and master.dbo.syslockinfo.req_mode +1 = u.number
and u.type = 'L'
--and substring(x.name,1,5) ='WAIT'
order by spid
print 'inputbuffer for running processes'
declare @spid varchar(6)
declare ibuffer cursor fast_forward for
select cast(spid as varchar(6)) as spid from sysprocesses where spid>50
open ibuffer
fetch next from ibuffer into @spid
while (@@fetch_status !=-1)
begin 
	print ''
	print 'dbcc inputbuffer for spid '+ @spid
	exec('dbcc inputbuffer('+@spid+')')
	fetch next from ibuffer into @spid
end
deallocate ibuffer
waitfor delay '0:0:10'

end

>sqlcmd -e -s ggg|denali -iblocking-sql -w2000 -olog.out


