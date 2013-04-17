
--with rollup �� with cube

/*
����group by ֮����group by �Ļ����ϣ�������ؼ��ֽ��л��ܺϼ�
���磺��a,b,c���з��飬with rollup ���ܣ����ҵ��󣩣����ѷ���Ļ����� 
	1����a,b���飬��c���л��ܣ�����һ�����ܼ�¼
	2����a���飬��b,c���л���
	3) ��a,b,c������л��ܣ����ܼ�

GROUPING(��)����: ��rollup���ܷ��ص�null��Ϊ1,��֮Ϊ0
	���壺	����c�����ܵ�ʱ��c��Ϊnull,a,b�б���
			����b,c�����ܵ�ʱ��b,c��Ϊnull,a�б���
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

select case when grouping(a)=1 then '�ϼ�' else cast(a as varchar) end a,
sum(b),sum(c),sum(d),sum(e) from #t group by a with rollup

select a,sum(b),sum(c),sum(d),sum(e) from #t group by a


--------------------
select case when grouping(a)=1 then '�ϼ�' else cast(a as varchar) end a,
    b,
sum(c),sum(d),sum(e) from #t 
group by a,b with rollup 
having grouping(a)=1 or grouping(b)=0 

--------------------

select case when grouping(a)=1 then '�ϼ�' else cast(a as varchar) end a,
    b,
sum(c),sum(d),sum(e) from #t 
group by a,b with rollup

--------------------
--select a,b,c,sum(d),sum(e) from #t  group by a,b,c
select case when grouping(a)=1 then '�ϼ�' else cast(a as varchar) end a,
    b,
    c,
sum(d),sum(e) from #t 
group by a,b,c with rollup 
having grouping(c)=0 or grouping(a)=1
--------------------
select a,b,c,sum(d),sum(e) from #t  group by a,b,c
select case when grouping(a)=1 then '�ϼ�' else cast(a as varchar) end a,
    b,
    c,
sum(d),sum(e) from #t 
group by a,b,c with rollup 
--having grouping(c)=0 or grouping(a)=1
--------------------
select case when grouping(a)=1 then '�ϼ�' else cast(a as varchar) end a,
    case when grouping(b)=1 and grouping(a)=0 then 'С��' else cast(b as varchar) end b,
    case when grouping(c)=1 and grouping(b)=0 then 'С��' else cast(c as varchar) end c,
sum(d),sum(e) from #t 
group by a,b,c with rollup 

--------------------
select case when grouping(a)=1 then '�ϼ�' 
    when grouping(b)=1 then cast(a as varchar)+'С��'
    else cast(a as varchar) end a,
    case when grouping(b)=0 and grouping(c)=1 
    then cast(b as varchar)+'С��' else cast(b as varchar) end b,
    case when grouping(c)=1 and grouping(b)=0 
    then '' else cast(c as varchar) end c,
sum(d),sum(e) from #t 
group by a,b,c with rollup 

--------------------
select case when grouping(a)=1 then '�ϼ�' else cast(a as varchar) end a,
    b,
    case when grouping(c)=1 and grouping(b)=0 then 'С��' else cast(c as varchar) end c,
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
select case when grouping(a)=1 then '�ϼ�' else cast(a as varchar) end a,
    case when grouping(b)=1 and grouping(a)=0 then 'С��' else cast(b as varchar) end b,
    c,
sum(d),sum(e) from #t 
group by a,b,c with rollup 
having grouping(a)=1 or grouping(b)=1 or grouping(c)=0