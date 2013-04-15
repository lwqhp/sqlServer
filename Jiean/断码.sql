
create table sd_mat_size(sizeCode varchar(20))
insert into sd_mat_size
select 'M' union all
select 'L' union all
select 'XL' union all
select 'XXL' union all

create table sd_mat_material(materialID varchar(20),sizeid varchar(20))
insert into sd_mat_material
select 'd','l' union all
select 'd','xxl' union all
select 'a','xxl' union all
select 'b','m' union all
select 'b','xxl' union all
select 'c','m' union all
select 'c','l' union all
select 'c','xl' union all
select 'c','xxl' union all


--尺码加编号
select identity(int,1,1) as id,* 
into #sd_mat_size
from sd_mat_size

--drop  table #temp_mat

--生成中间对应表
select materialid,id 
into #temp_mat
from sd_mat_material a left join #sd_mat_size b
on a.sizeid = b.sizecode
group by materialid,id

--select * from #temp_mat
--连续两个空的是断码
select * from #temp_mat a
where a.id>2 and not exists(select * from #temp_mat where materialid = a.materialid  and id = a.id-1)
and not exists(select * from #temp_mat where materialid = a.materialid and id = a.id-2 )

--有两个空的，可以不连续，也算是断码
select materialid from #temp_mat a
where a.id>1 and not exists(select * from #temp_mat where materialid = a.materialid  and id = a.id-1)
group by materialid
having count(*)>1

