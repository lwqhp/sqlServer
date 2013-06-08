
--动态sql 例子
declare @TableName varchar(200)
set @TableName='TmpBaseCustomer_9'
declare @sql nvarchar(4000)
set @sql=N'
declare @RepeatStr varchar(1000)
declare @clName    varchar(200)
declare @total    int
set @RepeatStr=''''
declare curCustomer CURSOR for
select 名称,count(名称) as total from '+quotename(@TableName)+' group by 名称 having(count(*))>1
open curCustomer
fetch next from curCustomer into @clName,@total
while @@Fetch_Status=0
begin
    if (@total>1)
        begin
            set @RepeatStr=@RepeatStr+'',''+@clName+''有【''+cast(@total as varchar)+''】行''            
        end
    fetch next from curCustomer into @clName,@total
end
close curCustomer
deallocate curCustomer
select @nRepeatStr=@RepeatStr
'
declare @nRepeatStr varchar(1000)

exec sp_executesql @sql,
    N'@nRepeatStr varchar(1000) out',
    @nRepeatStr out

select @nRepeatStr