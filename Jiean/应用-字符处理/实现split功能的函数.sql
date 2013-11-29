/*
功能：实现split功能的函数
*/

create function dbo.fn_split
(
@inputstr varchar(8000),
@seprator varchar(10)
)
returns @temp table (a varchar(200))
as

begin
declare @i int

set @inputstr = rtrim(ltrim(@inputstr))
set @i = charindex(@seprator, @inputstr)

while @i >= 1
begin
insert @temp values(left(@inputstr, @i - 1))

set @inputstr = substring(@inputstr, @i + 1, len(@inputstr) - @i)
set @i = charindex(@seprator, @inputstr)
end

if @inputstr <> '\'
insert @temp values(@inputstr)

return
end
go

--调用

declare @s varchar(1000)

set @s='1,2,3,4,5,6,7,8,55'

select * from dbo.fn_split(@s,',')

drop function dbo.fn_split 