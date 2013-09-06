
--计算存跌，先进先出
create table #inInv(BatchNo varchar(20),materialID varchar(20),inDate datetime,inQty int)
insert into #inInv
select '001','M00A','2013-09-01',50 union all
select '002','M00A','2013-09-02',10 union all
select '005','M00B','2013-09-01',20 union all
select '031','M00B','2013-09-03',10 union all
select '056','M00A','2013-09-04',5

create table #outInv(MaterialID varchar(20),outQty int)
insert into #outInv
select 'M00A',60 union all
select 'M00B',15 

select *,row_number() over(partition by materialID order by indate) as id 
into #inInv2
from #inInv 

--select * from #inInv2
--select * from #outInv


;with tmp as(
	select id,a.batchno,a.materialID,a.indate,a.inqty,
	case when a.inqty-b.outqty<=0 then 0 else a.inqty-b.outqty end as NewInqty,
	case when b.outqty-a.inqty <=0 then 0 else b.outqty-a.inqty end as diff from #inInv2 a 
	inner join #outInv b on a.materialID = b.materialID
	where id = 1 

	union all

	select b.id,b.batchno,a.materialID,a.indate,b.inqty,
	case when b.inqty-a.diff<=0 then 0 else b.inqty-a.diff end as NewInqty,
	case when a.diff-b.inqty <=0 then 0 else a.diff-b.inqty  end as diff
	from tmp a
	inner join #inInv2 b on a.materialID = b.materialID and b.id = a.id+1
	
)
select * from tmp where NewInqty>0