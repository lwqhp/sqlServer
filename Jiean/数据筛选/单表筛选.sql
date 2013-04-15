--��ĳһ�ֶη���ȡ���(С)ֵ�����е�����
--(���¾���.ع��(ʮ�������,�صñ�ɽѩ������) 2007-10-23���㽭����)
/*
�������£�
name val memo
a    2   a2(a�ĵڶ���ֵ)
a    1   a1--a�ĵ�һ��ֵ
a    3   a3:a�ĵ�����ֵ
b    1   b1--b�ĵ�һ��ֵ
b    3   b3:b�ĵ�����ֵ
b    2   b2b2b2b2
b    4   b4b4
b    5   b5b5b5b5b5
*/
--�������������ݣ�
SELECT  * FROM tb
DROP TABLE tb

create table tb(name nvarchar(10),val int,memo varchar(20))
insert into tb values('a',    1,   N'a1--a�ĵ�һ��ֵ')
insert into tb values('a',    3,   N'a3:a�ĵ�����ֵ')
insert into tb values('b',    1,   N'b1--b�ĵ�һ��ֵ')
insert into tb values('b',    3,   N'b3:b�ĵ�����ֵ')
insert into tb values('b',    2,   N'b2b2b2b2')
insert into tb values('b',    4,   N'b4b4')
insert into tb values('b',    5,   N'b5b5b5b5b5')
go

--һ����name����ȡval����ֵ�����е����ݡ�
--����1����������name�ֶι�����ȡval���ֵ��Ӧ�ļ�¼
SELECT a.* FROM tb a
WHERE val =(SELECT max(val) FROM tb WHERE name = a.name )
ORDER BY a.name

--����2����������name�ֶι������ҳ�һ��������val�����ֵ��¼����������Ϊ���
SELECT * FROM tb a 
WHERE NOT EXISTS(SELECT * FROM tb WHERE name = a.name AND val > a.val)

select a.* from tb a where 1 > (select count(*) from tb where name = a.name and val > a.val ) order by a.name

--����3����������ɸѡ�����ֵ���������������name�����ֶκ�val�ֶ�.
SELECT a.* FROM tb a 
INNER JOIN (SELECT name,max(val) AS val FROM tb GROUP BY name) b
ON a.name = b.name 
AND a.val = b.val
ORDER BY a.name

/*
name       val         memo                 
---------- ----------- -------------------- 
a          3           a3:a�ĵ�����ֵ
b          5           b5b5b5b5b5
*/

--������name����ȡval��С��ֵ�����е����ݡ�
--����1��
select a.* from tb a where val = (select min(val) from tb where name = a.name) order by a.name
--����2��
select a.* from tb a where not exists(select 1 from tb where name = a.name and val < a.val)
--����3��
select a.* from tb a,(select name,min(val) val from tb group by name) b where a.name = b.name and a.val = b.val order by a.name
--����4��
select a.* from tb a inner join (select name , min(val) val from tb group by name) b on a.name = b.name and a.val = b.val order by a.name
--����5
select a.* from tb a where 1 > (select count(*) from tb where name = a.name and val < a.val) order by a.name
/*
name       val         memo                 
---------- ----------- -------------------- 
a          1           a1--a�ĵ�һ��ֵ
b          1           b1--b�ĵ�һ��ֵ
*/

--������name����ȡ��һ�γ��ֵ������ڵ����ݡ�
--,��������ȡ��name�ֶι����ĵ�һ����¼�Ƚ�
SELECT a.* FROM tb a 
WHERE val = (SELECT TOP 1 val FROM tb WHERE name = a.name)
ORDER BY a.name


/*
name       val         memo                 
---------- ----------- -------------------- 
a          2           a2(a�ĵڶ���ֵ)
b          1           b1--b�ĵ�һ��ֵ
*/

--�ġ���name�������ȡһ�����ݡ�
select a.* from tb a where val = (select top 1 val from tb where name = a.name order by newid()) order by a.name
/*
name       val         memo                 
---------- ----------- -------------------- 
a          1           a1--a�ĵ�һ��ֵ
b          5           b5b5b5b5b5
*/

--�塢��name����ȡ��С������(N��)val
--������valֵ��������val�Ƚϣ�С�ڵļ�¼�ڣ�����
SELECT a.* FROM tb a 
WHERE  EXISTS(SELECT 0 FROM tb WHERE name = a.name AND val < a.val having count(*) <2)

select a.* from tb a where 2 > (select count(*) from tb where name = a.name and val < a.val ) order by a.name,a.val
select a.* from tb a where val in (select top 2 val from tb where name=a.name order by val) order by a.name,a.val
select a.* from tb a where exists (select count(*) from tb where name = a.name and val < a.val having Count(*) < 2) order by a.name,a.val
/*
name       val         memo                 
---------- ----------- -------------------- 
a          1           a1--a�ĵ�һ��ֵ
a          2           a2(a�ĵڶ���ֵ)
b          1           b1--b�ĵ�һ��ֵ
b          2           b2b2b2b2
*/

--������name����ȡ��������(N��)val
select a.* from tb a where 2 > (select count(*) from tb where name = a.name and val > a.val ) order by a.name,a.val
select a.* from tb a where val in (select top 2 val from tb where name=a.name order by val desc) order by a.name,a.val
select a.* from tb a where exists (select count(*) from tb where name = a.name and val > a.val having Count(*) < 2) order by a.name , a.val
/*
name       val         memo                 
---------- ----------- -------------------- 
a          2           a2(a�ĵڶ���ֵ)
a          3           a3:a�ĵ�����ֵ
b          4           b4b4
b          5           b5b5b5b5b5
*/
--�ߣ���������������ظ������е��ж���ͬ��
/*
�������£�
name val memo
a    2   a2(a�ĵڶ���ֵ)
a    1   a1--a�ĵ�һ��ֵ
a    1   a1--a�ĵ�һ��ֵ
a    3   a3:a�ĵ�����ֵ
a    3   a3:a�ĵ�����ֵ
b    1   b1--b�ĵ�һ��ֵ
b    3   b3:b�ĵ�����ֵ
b    2   b2b2b2b2
b    4   b4b4
b    5   b5b5b5b5b5

--��sql server 2000��ֻ����һ����ʱ�������������һ�������У��ȶ�valȡ������С��Ȼ����ͨ����������ȡ���ݡ�
--�������������ݣ�
create table tb(name varchar(10),val int,memo varchar(20))
--insert into tb values('a',    2,   N'a2(a�ĵڶ���ֵ)')
--insert into tb values('a',    1,   N'a1--a�ĵ�һ��ֵ')
--insert into tb values('a',    1,   N'a1--a�ĵ�һ��ֵ')
--insert into tb values('a',    3,   N'a3:a�ĵ�����ֵ')
--insert into tb values('a',    3,   N'a3:a�ĵ�����ֵ')
--insert into tb values('b',    1,   N'b1--b�ĵ�һ��ֵ')
--insert into tb values('b',    3,   N'b3:b�ĵ�����ֵ')
--insert into tb values('b',    2,   N'b2b2b2b2')
--insert into tb values('b',    4,   N'b4b4')
--insert into tb values('b',    5,   N'b5b5b5b5b5')
go

select * from tb
drop table tb
SELECT * FROM temp
*/

SELECT *,indexid = IDENTITY(int,1,1) 
INTO temp
FROM tb  

select * from
(
  select t.* from temp t where val = (select min(val) from temp where name = t.name)
) m where indexid = (select min(indexid) from
(
  select t.* from temp t where val = (select min(val) from temp where name = t.name)
) n where n.name = m.name)

drop table tb,tmp

/*
name       val         memo
---------- ----------- --------------------
a          1           a1--a�ĵ�һ��ֵ
b          1           b1--b�ĵ�һ��ֵ

(2 ����Ӱ��)
*/
--��sql server 2005�п���ʹ��row_number����������Ҫʹ����ʱ��
--�������������ݣ�
create table tb(name varchar(10),val int,memo varchar(20))
insert into tb values('a',    2,   'a2(a�ĵڶ���ֵ)')
insert into tb values('a',    1,   'a1--a�ĵ�һ��ֵ')
insert into tb values('a',    1,   'a1--a�ĵ�һ��ֵ')
insert into tb values('a',    3,   'a3:a�ĵ�����ֵ')
insert into tb values('a',    3,   'a3:a�ĵ�����ֵ')
insert into tb values('b',    1,   'b1--b�ĵ�һ��ֵ')
insert into tb values('b',    3,   'b3:b�ĵ�����ֵ')
insert into tb values('b',    2,   'b2b2b2b2')
insert into tb values('b',    4,   'b4b4')
insert into tb values('b',    5,   'b5b5b5b5b5')
go

select m.name,m.val,m.memo from
(
  select * , px = row_number() over(order by name , val) from tb
) m where px = (select min(px) from
(
  select * , px = row_number() over(order by name , val) from tb
) n where n.name = m.name)

drop table tb

/*
name       val         memo
---------- ----------- --------------------
a          1           a1--a�ĵ�һ��ֵ
b          1           b1--b�ĵ�һ��ֵ

(2 ����Ӱ��)
*/

--SQL Server��ɾ���ظ����ݵļ�������
--�����
Create Table #tmp(
work_code	Varchar(10)	Null,
min_seq		Integer		Null, --�����ļ�¼�ɣ�
mstrmk		Char(1)		Null) --��������Y

Insert Into #tmp(work_code,mstrmk)
Select work_code,'N'
From skills
Group By work_code
Having Count(*) > 1
Order By work_code

Update #tmp Set min_seq = (Select Min(sid) From skills Where skills.work_code = #tmp.work_code)

Update #tmp
Set mstrmk = 'Y'
Where Exists(Select * From skills Where skills.work_code = #tmp.work_code And Not(skills.master is null Or skills.master = ''))

Select * From #tmp

 Delete From skills
 Where Exists(Select * From #tmp Where #tmp.work_code = skills.work_code And #tmp.mstrmk = 'N' And #tmp.min_seq <> skills.sid) Or
 	(Exists(Select * From #tmp Where #tmp.work_code = skills.work_code And #tmp.mstrmk = 'Y') And (skills.master is null or skills.master = ''))

-----------------------�����ķָ���--------------------------------------------

���ݿ��ʹ�ù��������ڳ������������ʱ��������ظ����ݣ��ظ����ݵ��������ݿⲿ�����ò�����ȷ���á���



���������������ϵ��ظ���¼��һ����ȫ�ظ��ļ�¼��Ҳ�������ֶξ��ظ��ļ�¼�����ǲ��ֹؼ��ֶ��ظ��ļ�¼������Name�ֶ��ظ����������ֶβ�һ���ظ����ظ����Ժ��ԡ�

����1�����ڵ�һ���ظ����Ƚ����׽����ʹ��

select distinct * from tableName

�����Ϳ��Եõ����ظ���¼�Ľ������

����2�������ظ�����ͨ��Ҫ�����ظ���¼�еĵ�һ����¼��������������

�����������ظ����ֶ�ΪName,Address��Ҫ��õ��������ֶ�Ψһ�Ľ����

select identity(int,1,1) as autoID, * into #Tmp from tableName
select min(autoID) as autoID into #Tmp2 from #Tmp group by Name,autoID
select * from #Tmp where autoID in(select autoID from #tmp2)

�������һ��select���õ���Name��Address���ظ��Ľ������������һ��autoID�ֶΣ�ʵ��дʱ����д��select�Ӿ���ʡȥ���У�

---------------------------------���ǿɰ��ķָ���---------------------------------
SQL DISTINCT�ظ�������ͳ�Ʒ��� group by �ظ����ݵĸ���ͳ�� ɾ���ظ�������

DISTINCT �ؼ��ֿɴ� SELECT ���Ľ���г�ȥ�ظ����С����û��ָ�� DISTINCT����ô�����������У������ظ����С� 
select count(distinct t.destaddr)     from nbyd_send t     where t.input_time > to_date('2007-2-1','yyyy-mm-dd') and t.input_time < to_date('2007-3-1','yyyy-mm-dd')

����ͳ�Ƴ�һ�����е��û�������

������ο��ٵ�֪����ÿһ�������ظ��ĸ�������Ľ��:���÷��麯����SQL���
select t.tel,count(*) from nbyd_deliver t   group   by t.tel ;group by ����ظ����ݵĸ���ͳ�������ڸ��ֹ�ϵ�����ݿ�,��oracle,SQL Server

��ѯ�ظ�������
select * from (select v.xh,count(v.xh) num from sms.vehicle v group by v.xh) where num>1;--169

select v.xh,count(v.xh) num from sms.vehicle v group by v.xh having count(v.xh)=2;

ɾ���ظ�������

create table mayong as (select distinct* from sms.vehicle);

delete from sms.vehicle ;

insert into sms.vehicle select * from mayong;


��������������ȫ�ظ���¼��ɾ��

�������ڱ������м�¼��ȫһ�����������������������ȡ��ȥ���ظ����ݺ�ļ�¼��
select distinct * from ����
���Խ���ѯ�ļ�¼�ŵ���ʱ���У�Ȼ���ٽ�ԭ���ı��¼ɾ���������ʱ������ݵ���ԭ���ı��С����£�
CREATE TABLE ��ʱ�� AS (select distinct * from ����);
drop table ��ʽ��;
insert into ��ʽ�� (select * from ��ʱ��);
drop table ��ʱ��;

���������ɾ��һ������ظ����ݣ������Ƚ�һ����ʱ����ȥ���ظ����ݺ�����ݵ��뵽��ʱ��Ȼ���ڴ���ʱ�����ݵ�����ʽ���У����£�

INSERT INTO t_table_bak
select distinct * from t_table;

---------------------------------���ǿɰ��ķָ���---------------------------------

SQL Server��ɾ���ظ��������ķ���

��������ԭ�������ݿ��г��������ǲ�ϣ�����ֵ��ظ����ݣ�������Щ�ظ������ݽ���ɾ����ʱ��������ַ������ҷ������������е�һ�ַ�����������ʱ��ķ�����SQL�ű����£�


select distinct * into #Tmp from tableName
drop table tableName
select * into tableName from #Tmp
drop table #Tmp
�����÷�������ʹ��select distinct������ظ����б�����д�뵽��ʱ��#Tmp�У�Ȼ��ɾ��ԭ���ı��ٽ���ʱ���е�����д�뵽tableName�У����ɾ����ʱ��
�������ַ���ִ��Ч����һ�����棬����������ݿ�����text���͵��ֶεĻ�������ִ�У��ǳ����о����ԡ�

���������ṩһ��ͨ�õķ�������ִ��Ч��Ҳ�Ƿǳ�����ģ��̱����£�

����: cleanRepeatedRows2.sql
declare @max int,@rowname varchar(400)
declare cur_rows cursor local for
     select repeatedrow,count(*) from tableName group by repeatedrow having count(*) > 1

open cur_rows
fetch cur_rows into @rowname ,@max
while @@fetch_status=0
begin
     select @max = @max -1
     set rowcount @max
     delete from tableName where repeatedrow = @rowname
     fetch cur_rows into @rowname ,@max
end
close cur_rows
����set rowcount 0��˵��һ�£���������������������һ���Ǽ�¼�ظ�������������һ���Ǽ�¼�ظ��ֶε�ֵ�������������Լ����ȿɸ�����ʵ�ʵ��ֶν��ж��壻����������һ���α꣬���α���Ҫ���г��ظ��������Լ��ظ�����

����Ȼ����α겢����ȡ�����ݣ����С�select @max = @max -1��������˼�Ǳ���һ���ظ����ݣ�ʣ�µ���һɾ�������ر��α꣬�㶨��

����ִ����̱�֮�����ʹ������Ḻ̌�����Ƿ����ظ������ݣ�

select repeatedrow,count(*) from tableName group by repeatedrow having count(*) > 1