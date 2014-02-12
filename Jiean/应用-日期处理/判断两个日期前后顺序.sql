

--判断两个日期前后顺序
/*
利用sign函数正负值判断两个日期的大小,sign返回两个值的差的对比值，>0 返回1,=0 返回0 ,<0返回-1
*/

--利用和基准时间的差，再比较返回值的大小，而决定日期前后

declare @d1 date
declare @d2 date
set @d1 = '2014-01-01'
set @d2 = '2014-02-11'

select case  sign(datediff(day,0,@d1)-datediff(day,0,@d2)) 
 when 1 then @d1
 when 0 then @d1
 when -1 then @d2
 end