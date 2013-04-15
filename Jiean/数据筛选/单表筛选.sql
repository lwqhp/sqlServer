--按某一字段分组取最大(小)值所在行的数据
--(爱新觉罗.毓华(十八年风雨,守得冰山雪莲花开) 2007-10-23于浙江杭州)
/*
数据如下：
name val memo
a    2   a2(a的第二个值)
a    1   a1--a的第一个值
a    3   a3:a的第三个值
b    1   b1--b的第一个值
b    3   b3:b的第三个值
b    2   b2b2b2b2
b    4   b4b4
b    5   b5b5b5b5b5
*/
--创建表并插入数据：
SELECT  * FROM tb
DROP TABLE tb

create table tb(name nvarchar(10),val int,memo varchar(20))
insert into tb values('a',    1,   N'a1--a的第一个值')
insert into tb values('a',    3,   N'a3:a的第三个值')
insert into tb values('b',    1,   N'b1--b的第一个值')
insert into tb values('b',    3,   N'b3:b的第三个值')
insert into tb values('b',    2,   N'b2b2b2b2')
insert into tb values('b',    4,   N'b4b4')
insert into tb values('b',    5,   N'b5b5b5b5b5')
go

--一、按name分组取val最大的值所在行的数据。
--方法1：内联，以name字段关联，取val最大值对应的记录
SELECT a.* FROM tb a
WHERE val =(SELECT max(val) FROM tb WHERE name = a.name )
ORDER BY a.name

--方法2：内联，以name字段关联，找出一条比现在val还大的值记录，不存在则为最大
SELECT * FROM tb a 
WHERE NOT EXISTS(SELECT * FROM tb WHERE name = a.name AND val > a.val)

select a.* from tb a where 1 > (select count(*) from tb where name = a.name and val > a.val ) order by a.name

--方法3：并联，与筛选出最大值结果并联，条件是name关联字段和val字段.
SELECT a.* FROM tb a 
INNER JOIN (SELECT name,max(val) AS val FROM tb GROUP BY name) b
ON a.name = b.name 
AND a.val = b.val
ORDER BY a.name

/*
name       val         memo                 
---------- ----------- -------------------- 
a          3           a3:a的第三个值
b          5           b5b5b5b5b5
*/

--二、按name分组取val最小的值所在行的数据。
--方法1：
select a.* from tb a where val = (select min(val) from tb where name = a.name) order by a.name
--方法2：
select a.* from tb a where not exists(select 1 from tb where name = a.name and val < a.val)
--方法3：
select a.* from tb a,(select name,min(val) val from tb group by name) b where a.name = b.name and a.val = b.val order by a.name
--方法4：
select a.* from tb a inner join (select name , min(val) val from tb group by name) b on a.name = b.name and a.val = b.val order by a.name
--方法5
select a.* from tb a where 1 > (select count(*) from tb where name = a.name and val < a.val) order by a.name
/*
name       val         memo                 
---------- ----------- -------------------- 
a          1           a1--a的第一个值
b          1           b1--b的第一个值
*/

--三、按name分组取第一次出现的行所在的数据。
--,内联，与取出name字段关联的第一条记录比较
SELECT a.* FROM tb a 
WHERE val = (SELECT TOP 1 val FROM tb WHERE name = a.name)
ORDER BY a.name


/*
name       val         memo                 
---------- ----------- -------------------- 
a          2           a2(a的第二个值)
b          1           b1--b的第一个值
*/

--四、按name分组随机取一条数据。
select a.* from tb a where val = (select top 1 val from tb where name = a.name order by newid()) order by a.name
/*
name       val         memo                 
---------- ----------- -------------------- 
a          1           a1--a的第一个值
b          5           b5b5b5b5b5
*/

--五、按name分组取最小的两个(N个)val
--内联，val值与内联表val比较，小于的记录在２条内
SELECT a.* FROM tb a 
WHERE  EXISTS(SELECT 0 FROM tb WHERE name = a.name AND val < a.val having count(*) <2)

select a.* from tb a where 2 > (select count(*) from tb where name = a.name and val < a.val ) order by a.name,a.val
select a.* from tb a where val in (select top 2 val from tb where name=a.name order by val) order by a.name,a.val
select a.* from tb a where exists (select count(*) from tb where name = a.name and val < a.val having Count(*) < 2) order by a.name,a.val
/*
name       val         memo                 
---------- ----------- -------------------- 
a          1           a1--a的第一个值
a          2           a2(a的第二个值)
b          1           b1--b的第一个值
b          2           b2b2b2b2
*/

--六、按name分组取最大的两个(N个)val
select a.* from tb a where 2 > (select count(*) from tb where name = a.name and val > a.val ) order by a.name,a.val
select a.* from tb a where val in (select top 2 val from tb where name=a.name order by val desc) order by a.name,a.val
select a.* from tb a where exists (select count(*) from tb where name = a.name and val > a.val having Count(*) < 2) order by a.name , a.val
/*
name       val         memo                 
---------- ----------- -------------------- 
a          2           a2(a的第二个值)
a          3           a3:a的第三个值
b          4           b4b4
b          5           b5b5b5b5b5
*/
--七，如果整行数据有重复，所有的列都相同。
/*
数据如下：
name val memo
a    2   a2(a的第二个值)
a    1   a1--a的第一个值
a    1   a1--a的第一个值
a    3   a3:a的第三个值
a    3   a3:a的第三个值
b    1   b1--b的第一个值
b    3   b3:b的第三个值
b    2   b2b2b2b2
b    4   b4b4
b    5   b5b5b5b5b5

--在sql server 2000中只能用一个临时表来解决，生成一个自增列，先对val取最大或最小，然后再通过自增列来取数据。
--创建表并插入数据：
create table tb(name varchar(10),val int,memo varchar(20))
--insert into tb values('a',    2,   N'a2(a的第二个值)')
--insert into tb values('a',    1,   N'a1--a的第一个值')
--insert into tb values('a',    1,   N'a1--a的第一个值')
--insert into tb values('a',    3,   N'a3:a的第三个值')
--insert into tb values('a',    3,   N'a3:a的第三个值')
--insert into tb values('b',    1,   N'b1--b的第一个值')
--insert into tb values('b',    3,   N'b3:b的第三个值')
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
a          1           a1--a的第一个值
b          1           b1--b的第一个值

(2 行受影响)
*/
--在sql server 2005中可以使用row_number函数，不需要使用临时表。
--创建表并插入数据：
create table tb(name varchar(10),val int,memo varchar(20))
insert into tb values('a',    2,   'a2(a的第二个值)')
insert into tb values('a',    1,   'a1--a的第一个值')
insert into tb values('a',    1,   'a1--a的第一个值')
insert into tb values('a',    3,   'a3:a的第三个值')
insert into tb values('a',    3,   'a3:a的第三个值')
insert into tb values('b',    1,   'b1--b的第一个值')
insert into tb values('b',    3,   'b3:b的第三个值')
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
a          1           a1--a的第一个值
b          1           b1--b的第一个值

(2 行受影响)
*/

--SQL Server中删除重复数据的几个方法
--经典的
Create Table #tmp(
work_code	Varchar(10)	Null,
min_seq		Integer		Null, --保留的记录ＩＤ
mstrmk		Char(1)		Null) --保留条件Y

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

-----------------------华丽的分割线--------------------------------------------

数据库的使用过程中由于程序方面的问题有时候会碰到重复数据，重复数据导致了数据库部分设置不能正确设置……



　　有两个意义上的重复记录，一是完全重复的记录，也即所有字段均重复的记录，二是部分关键字段重复的记录，比如Name字段重复，而其他字段不一定重复或都重复可以忽略。

　　1、对于第一种重复，比较容易解决，使用

select distinct * from tableName

　　就可以得到无重复记录的结果集。

　　2、这类重复问题通常要求保留重复记录中的第一条记录，操作方法如下

　　假设有重复的字段为Name,Address，要求得到这两个字段唯一的结果集

select identity(int,1,1) as autoID, * into #Tmp from tableName
select min(autoID) as autoID into #Tmp2 from #Tmp group by Name,autoID
select * from #Tmp where autoID in(select autoID from #tmp2)

　　最后一个select即得到了Name，Address不重复的结果集（但多了一个autoID字段，实际写时可以写在select子句中省去此列）

---------------------------------我是可爱的分割线---------------------------------
SQL DISTINCT重复的数据统计方法 group by 重复数据的个数统计 删除重复的数据

DISTINCT 关键字可从 SELECT 语句的结果中除去重复的行。如果没有指定 DISTINCT，那么将返回所有行，包括重复的行。 
select count(distinct t.destaddr)     from nbyd_send t     where t.input_time > to_date('2007-2-1','yyyy-mm-dd') and t.input_time < to_date('2007-3-1','yyyy-mm-dd')

可以统计出一个月中的用户数量。

关于如何快速得知里面每一个号码重复的个数问题的解答:利用分组函数的SQL语句
select t.tel,count(*) from nbyd_deliver t   group   by t.tel ;group by 解决重复数据的个数统计适用于各种关系型数据库,如oracle,SQL Server

查询重复的数据
select * from (select v.xh,count(v.xh) num from sms.vehicle v group by v.xh) where num>1;--169

select v.xh,count(v.xh) num from sms.vehicle v group by v.xh having count(v.xh)=2;

删除重复的数据

create table mayong as (select distinct* from sms.vehicle);

delete from sms.vehicle ;

insert into sms.vehicle select * from mayong;


　　二、对于完全重复记录的删除

　　对于表中两行记录完全一样的情况，可以用下面语句获取到去掉重复数据后的记录：
select distinct * from 表名
可以将查询的记录放到临时表中，然后再将原来的表记录删除，最后将临时表的数据导回原来的表中。如下：
CREATE TABLE 临时表 AS (select distinct * from 表名);
drop table 正式表;
insert into 正式表 (select * from 临时表);
drop table 临时表;

　　如果想删除一个表的重复数据，可以先建一个临时表，将去掉重复数据后的数据导入到临时表，然后在从临时表将数据导入正式表中，如下：

INSERT INTO t_table_bak
select distinct * from t_table;

---------------------------------我是可爱的分割线---------------------------------

SQL Server中删除重复数据最快的方法

由于种种原因，在数据库中出现了我们不希望出现的重复数据，当对这些重复的数据进行删除的时候有许多种方法。我发现在网上流行的一种方法是利用临时表的方法，SQL脚本如下：


select distinct * into #Tmp from tableName
drop table tableName
select * into tableName from #Tmp
drop table #Tmp
　　该方法首先使用select distinct命令将不重复的列表数据写入到临时表#Tmp中，然后删除原来的表，再将临时表中的数据写入到tableName中，最后删除临时表。
但是这种方法执行效率是一个方面，另外如果数据库中有text类型的字段的话将不能执行，非常的有局限性。

　　下面提供一个通用的方法并且执行效率也是非常不错的，教本如下：

下载: cleanRepeatedRows2.sql
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
　　set rowcount 0简单说明一下：首先声明了两个变量，一个是记录重复的数量，另外一个是记录重复字段的值，变量的类型以及长度可根据你实际的字段进行定义；接下来声明一个游标，该游标主要是列出重复的数据以及重复的数

量；然后打开游标并从中取出数据，其中“select @max = @max -1”这句的意思是保留一条重复数据，剩下的逐一删除；最后关闭游标，搞定。

　　执行完教本之后可以使用下面的教本检查是否含有重复的数据：

select repeatedrow,count(*) from tableName group by repeatedrow having count(*) > 1