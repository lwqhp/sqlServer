
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
	CASE WHEN a.inqty-b.outqty<=0 THEN 0 ELSE a.inqty-b.outqty end as NewInqty,
	CASE WHEN b.outqty-a.inqty<=0 THEN 0 ELSE b.outqty-a.inqty END as diff 
	from #inInv2 a 
	inner join #outInv b on a.materialID = b.materialID
	where id = 1 

	union all

	select a.id,a.batchno,a.materialID,b.indate,a.inqty,
	CASE WHEN a.inqty-b.diff<=0 THEN 0 ELSE a.inqty-b.diff END  as NewInqty,
	CASE WHEN b.diff-a.inqty<=0 THEN 0 ELSE b.diff-a.inqty END as diff
	from #inInv2 a
	INNER  join tmp b on a.materialID = b.materialID and a.id = b.id+1 
	WHERE b.diff>0
	
)
select * from tmp where NewInqty>0

005	M00B	2013-09-01 00:00:00.000	20	5	0
031	M00B	2013-09-01 00:00:00.000	10	10	0
056	M00A	2013-09-01 00:00:00.000	5	5	0