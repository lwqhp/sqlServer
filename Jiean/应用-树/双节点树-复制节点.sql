--复制一颗节点树
if exists(select 1 from sys.objects where name = 'fn_CopyNodes' and type ='TF') drop function  fn_CopyNodes
go
create function fn_CopyNodes(
	@id varchar(30),	--起始节点
	@pid varchar(30),	--要挂靠节点
	@newid int = null	--新编码的开始值,如果指定为 NULL,则为表中的最大编码 + 1
) returns @t table(oldID varchar(30),VendcustID int,ParentID int,[level] int)
as
begin 
	if @newid is null
		select @newid=max(replace(vendcustID,CompanyID,''))+1
		from Bas_InterCompany
		group by CompanyID
		
	declare @level INT
	DECLARE @maxnode INT 
	DECLARE @curnode INT
	set @level =0
	SET @curnode=0
	insert into @t
	select @id as OldID,@newid as VendcustID,replace(@pid,CompanyID,'') as ParentID,@level  from Bas_InterCompany where vendcustID=@id
	
	IF @@ROWCOUNT >0 SET @maxnode=@newid
	
	while @maxnode>@curnode
	begin 
		set @level= @level+1
		SET @curnode=@maxnode
		insert into @t
		select a.vendcustID,@curnode+row_number() over(order by a.vendCustID),
		b.VendcustID as ParentID,
		@level 
		from Bas_InterCompany a
		inner join @t b on a.ParentID = b.oldID
		where b.level=@level-1
		SET @maxnode = @curnode+@@rowcount
		
	end
	--失败,花了两小时在这钻牛角
	--;with tmp as(
	--	select companyID,@id as OldID,@newid as VendcustID,@pid as ParentID 
	--	from Bas_InterCompany 
	--	where vendcustID=@id
	--	union all
	--	select a.CompanyID,
	--	a.vendcustID as OldID, 
	--	b.VendcustID+@@ROWCOUNT+cast(row_number() over(order by a.vendcustID) as int)-1 VendcustID,
	--	----b.VendcustID+1+@@ROWCOUNT as VendcustID,
	--	cast(a.CompanyID+right(replicate('0',4)+cast(b.VendcustID as varchar),4) as varchar) as ParentID
	--	from Bas_InterCompany a
	--	inner join tmp b on a.CompanyID = b.CompanyID and a.ParentID =b.OldID
	--)
	--insert into @t
	--select OldID,VendcustID,ParentID from tmp
	return;
end

select  
b.oldID,
a.CompanyID+right(replicate('0',4)+cast(b.VendcustID as varchar),4)  as VendcustID,
a.CompanyID+right(replicate('0',4)+cast(b.ParentID as varchar),4)  as ParentID
from Bas_InterCompany a
cross apply fn_CopyNodes(a.vendcustID,'PT0006',null) b
where a.vendcustID='PT0003'
