
--字符串分割到列
create function Fn_splitVal(
	@s varchar(500),
	@split varchar(10)
)returns @t table(val varchar(50))
as
begin 
	declare @splitLen int 
	set @splitLen = len(@split+'a ')-2
	while len(@s)>0 and charindex(@split,@s+@split)>0
	begin 
		insert into @t
		select substring(@s,1,charindex(@split,@s+@split)-1)
		set @s = stuff(@s,1,charindex(@split,@s+@split)+@splitLen,'')
	end
	return;
end

declare @text varchar(100) ='TOM 2013-11-19 Data'
select [TOM] as val1,[2013-11-19] as val2,[Data] as val3 
from Fn_splitVal(@text,' ') pivot(max(val) for val in([TOM],[2013-11-19],[Data])) a
/*
val1                                               val2                                               val3
-------------------------------------------------- -------------------------------------------------- --------------------------------------------------
TOM                                                2013-11-19                                         Data

(1 行受影响)


*/