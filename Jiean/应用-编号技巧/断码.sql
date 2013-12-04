
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


--����ӱ��
select identity(int,1,1) as id,* 
into #sd_mat_size
from sd_mat_size

--drop  table #temp_mat

--�����м��Ӧ��
select materialid,id 
into #temp_mat
from sd_mat_material a left join #sd_mat_size b
on a.sizeid = b.sizecode
group by materialid,id

--select * from #temp_mat
--���������յ��Ƕ���
select * from #temp_mat a
where a.id>2 and not exists(select * from #temp_mat where materialid = a.materialid  and id = a.id-1)
and not exists(select * from #temp_mat where materialid = a.materialid and id = a.id-2 )

--�������յģ����Բ�������Ҳ���Ƕ���
select materialid from #temp_mat a
where a.id>1 and not exists(select * from #temp_mat where materialid = a.materialid  and id = a.id-1)
group by materialid
having count(*)>1

