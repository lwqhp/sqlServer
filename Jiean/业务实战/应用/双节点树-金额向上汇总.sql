
--双节点树金额向上汇总----------------------------------

alter table Bas_InterCompany add payAmount money

;with tmp as(
	select ROW_NUMBER() over(order by vendcustID)*100 as amount,* from Bas_InterCompany
)
update a set a.payamount= b.amount
from Bas_InterCompany a
inner join tmp b on a.vendcustID = b.vendcustID

--select * from Bas_InterCompany
/*
利用树结构的深度路径来关联
*/
;with tmp as(
	select CompanyID,vendcustID,ParentID,payAmount,cast (vendcustID as varchar) as 'PathDept' from Bas_InterCompany where ParentID is null
	union all
	select a.CompanyID,a.vendcustID,a.ParentID,a.payAmount,cast(b.PathDept+'.'+a.vendcustID as varchar) as 'PathDept' from Bas_InterCompany a
	inner join tmp b on a.CompanyID = b.CompanyID and a.ParentID = b.vendcustID
)
select a.CompanyID,a.vendCustID,sum(b.payAmount) as SumAmount from tmp a
inner join tmp b on a.CompanyID = b.CompanyID and b.pathDept like a.pathDept+'%'
group by a.CompanyID,a.vendCustID

