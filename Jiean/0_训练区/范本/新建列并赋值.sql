
--新建列并赋值
if COL_LENGTH('BC_Sal_OrderMaster','IsAutoMerge') is null
begin
Alter Table BC_Sal_OrderMaster Add IsAutoMerge bit
 declare @sql130606 varchar(max)
 set @sql130606='  
 update BC_Sal_OrderMaster set IsAutoMerge=0
 where IsAutoMerge is null
 '
 execute(@sql130606)

end