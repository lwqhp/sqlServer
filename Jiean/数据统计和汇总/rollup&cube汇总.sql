
--with rollup 和 with cube

/*
用在group by 之后，在group by 的基础上，按分组关键字进行汇总合计
比如：按a,b,c进行分组，with rollup 汇总（从右到左），则已分组的基础上 
	1）按a,b分组，对c进行汇总，生成一条汇总记录
	2）按a分组，对b,c进行汇总
	3) 按a,b,c分组进行汇总，即总计

GROUPING(列)函数: 由rollup汇总返回的null列为1,反之为0
	意义：	当按c来汇总的时候，c列为null,a,b列保留
			当按b,c来汇总的时候，b,c列为null,a列保留
*/

drop table #t
create table #t(a int,b int,c int,d int,e int)
insert into #t values(1,2,3,4,5)
insert into #t values(1,2,3,4,6)
insert into #t values(1,2,3,4,7)
insert into #t values(1,2,3,4,8)
insert into #t values(1,3,3,4,5)
insert into #t values(1,3,3,4,6)
insert into #t values(1,3,3,4,8)
insert into #t values(1,3,3,4,7)

insert into #t values(2,2,2,4,5)
insert into #t values(2,2,3,4,6)
insert into #t values(2,2,4,4,7)
insert into #t values(2,2,5,4,8)
insert into #t values(2,3,6,4,5)
insert into #t values(2,3,3,4,6)
insert into #t values(2,3,3,4,8)
insert into #t values(2,3,3,4,7)

select * from #t

select case when grouping(a)=1 then '合计' else cast(a as varchar) end a,
sum(b),sum(c),sum(d),sum(e) from #t group by a with rollup

select a,sum(b),sum(c),sum(d),sum(e) from #t group by a


--------------------
select case when grouping(a)=1 then '合计' else cast(a as varchar) end a,
    b,
sum(c),sum(d),sum(e) from #t 
group by a,b with rollup 
having grouping(a)=1 or grouping(b)=0 

--------------------

select case when grouping(a)=1 then '合计' else cast(a as varchar) end a,
    b,
sum(c),sum(d),sum(e) from #t 
group by a,b with rollup

--------------------
--select a,b,c,sum(d),sum(e) from #t  group by a,b,c
select case when grouping(a)=1 then '合计' else cast(a as varchar) end a,
    b,
    c,
sum(d),sum(e) from #t 
group by a,b,c with rollup 
having grouping(c)=0 or grouping(a)=1
--------------------
select a,b,c,sum(d),sum(e) from #t  group by a,b,c
select case when grouping(a)=1 then '合计' else cast(a as varchar) end a,
    b,
    c,
sum(d),sum(e) from #t 
group by a,b,c with rollup 
--having grouping(c)=0 or grouping(a)=1
--------------------
select case when grouping(a)=1 then '合计' else cast(a as varchar) end a,
    case when grouping(b)=1 and grouping(a)=0 then '小计' else cast(b as varchar) end b,
    case when grouping(c)=1 and grouping(b)=0 then '小计' else cast(c as varchar) end c,
sum(d),sum(e) from #t 
group by a,b,c with rollup 

--------------------
select case when grouping(a)=1 then '合计' 
    when grouping(b)=1 then cast(a as varchar)+'小计'
    else cast(a as varchar) end a,
    case when grouping(b)=0 and grouping(c)=1 
    then cast(b as varchar)+'小计' else cast(b as varchar) end b,
    case when grouping(c)=1 and grouping(b)=0 
    then '' else cast(c as varchar) end c,
sum(d),sum(e) from #t 
group by a,b,c with rollup 

--------------------
select case when grouping(a)=1 then '合计' else cast(a as varchar) end a,
    b,
    case when grouping(c)=1 and grouping(b)=0 then '小计' else cast(c as varchar) end c,
sum(d),sum(e) from #t 
group by a,b,c with rollup 
having grouping(a)=1 or grouping(b)=0
--------------------
select a,
    b,
    c,
sum(d),sum(e) from #t 
group by a,b,c  with rollup 

--------------------
select case when grouping(a)=1 then '合计' else cast(a as varchar) end a,
    case when grouping(b)=1 and grouping(a)=0 then '小计' else cast(b as varchar) end b,
    c,
sum(d),sum(e) from #t 
group by a,b,c with rollup 
having grouping(a)=1 or grouping(b)=1 or grouping(c)=0