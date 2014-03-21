--确实范围和现有范围（也称间断和孤岛问题）
--1、缺失范围（间断）
/*
收集人：TravyLee
时间：2012-03-25
如有引用，请标明“此内容源自MSSQL2008技术内幕之T-SQL”
*/
/*
求解间断问题有几种方法，小弟我选择性能较高的三种（使用游标的方法省略
有兴趣不全的大哥大姐请回复）
---------------------------------------------------------------------
间断问题的解决方案1；使用子查询
step 1：找到间断之前的值，每个值增加一个间隔
step 2：对于没一个间断的起点，找出序列中现有得值，再减去一个间隔
本人理解为：找到原数据表中的值加一减一是否存在，若有不妥，望纠正
生成测试数据:
go
if object_id('tbl')is not null 
drop table tbl
go
create table tbl(
id int not null
)
go
insert tbl
values(2),(3),(11),(12),(13),(27),(33),(34),(35),(42)
要求：找到上表数据中的不存在的id的范围，
--实现输出结果：
/*
开始范围 结束范围
 4        10
 14       26
 28       32
 36       41
 */
 按照每个步骤实现：
 step 1：找到间断之前的值，每个值增加一个间隔
 我们可以清楚的发现，要找的间断范围的起始值实际上就是我们
 现有数据中的某些值加1后存不存在现有数据表中的问题，通过
 子查询实现：
 
 select id+1 as start_range from tbl as a
 where not exists(select 1 from tbl as b
 where b.id=a.id+1)and id<(select max(id) from tbl)
 --此查询语句实现以下输出：
 /*
 start_range
 4
 14
 28
 36
 */
 step 2：对于没一个间断的起点，找出序列中现有得值，再减去一个间隔
 
 select id+1 as start_range,(select min(b.id) from tbl as b
 where b.id>a.id)-1 as end_range
 from tbl a where not exists(select 1 from tbl as b
                        where b.id=a.id+1)
     and id<(select max(id) from tbl)
 --输出结果：
 /*
   start_range	end_range
   4	10
   14	26
   28	32
   36	41
 */
通过以上的相关子查询我们实现了找到原数据表中的间断范围。
而且这种方式的效率较其他方式有绝对的优势


间断问题的解决方案2；使用子查询（主意观察同1的区别）
step 1:对每个现有的值匹配下一个现有的值，生成一对一对的当
       前值和下一个值
step 2:只保留下一个值减当前值大于1的间隔值对
step 3:对剩下的值对，将每个当前值增加1个间隔，将每个下一
       个值减去一个间隔

--转换成T-SQL语句实现：
--step 1:
select id as cur,(select min(b.id) from tbl b where
         b.id>a.id) as nxt from tbl a
--此子查询生成的结果：
/*
 cur	nxt
 2	 3
 3	 11
 11	 12
 12	 13
 13	 27
 27	 33
 33	 34
 34	 35
 35	 42
 42	 NULL
 */
 step 2 and step 3:
 select cur+1 as start_range,nxt-1 as end_range
 from (select id as cur,(select min(b.id) from tbl b 
 where b.id>a.id) as nxt from tbl a ) as d
      where nxt-cur>1
--生成结果：
/*
 start_range	 end_range
 4	 10
 14	 26
 28	 32
 36	 41
*/
 间断问题的解决方案3；使用排名函数实现
 
 此种方法与第二种类似,这里我一步实现：
 
 ;with c as
 (
   select id,row_number()over(order by id) as rownum
   from tbl
 )
 select cur.id+1 as strat_range,nxt.id-1 as end_range
        from c as cur join c as nxt
   on nxt.rownum=cur.rownum+1
  where nxt.id-cur.id>1

--输出结果：
 /*
 strat_range	end_range
 4	 10
 14	 26
 28	 32
 36	 41
 */
 
*/
--2、先有范围（孤岛）
/*
以上测试数据，试下如下输出：
/*
开始范围 结束范围
2        3
11       13
27       27
33       35
42       42
*/
和间断问题一样，孤岛问题也有集中解决方案，这里也只介绍三种
省略了用游标的实现方案：

孤岛问题解决方案1：使用子查询和排名计算
step 1:找出间断之后的点，为他们分配行号（这是孤岛的起点）
step 2:找出间断之前的点，为他们分配行号（这是孤岛的终点）
step 3:以行号相等作为条件，匹配孤岛的起点和终点

--实现代码:
    with startpoints as
    (
      select id,row_number()over(order by id) as rownum
           from tbl as a where not exists(
        select 1 from tbl as b where b.id=a.id-1) 
     /*
     此查询语句单独运行的结果：
     id	rownum
     2	1
     11	2
     27	3
     33	4
     42	5
     */
    ),
    endpoinds as
    (
      select id,row_number()over(order by id) as rownum
          from tbl as a where not exists(
        select 1 from tbl as b where b.id=a.id+1)
   /*
     此查询语句单独运行的结果：
     id	rownum
     3	1
     13	2
     27	3
     35	4
     42	5
    */
    )
    select s.id as start_range,e.id as end_range
    from startpoints as s
    inner join endpoinds as e
    on e.rownum=s.rownum
--运行结果:   
/*
 start_range	end_range
 2	3
 11	13
 27	27
 33	35
 42	42
*/

孤岛问题解决方案2：使用基于子查询的组标识符

--直接给出代码：

with d as
(
  select id,(select min(b.id) from tbl b where b.id>=a.id
      and not exists (select * from tbl c where c.id=b.id+1)) as grp
  from tbl a
)
select min(id) as start_range,max(id) as end_range
from d group by grp
/*
start_range	end_range
2	3
11	13
27	27
33	35
42	42
*/


孤岛问题解决方案3：使用基于子查询的组标识符:

step 1:按照id顺序计算行号:
   select id ,row_number()over(order by id) as rownum from tbl
/*
id	rownum
2	1
3	2
11	3
12	4
13	5
27	6
33	7
34	8
35	9
42	10
*/
step 2：生成id和行号的差:
   select id,id-row_number()over(order by id) as diff from tbl
/*
id	diff
2	1
3	1
11	8
12	8
13	8
27	21
33	26
34	26
35	26
42	32
*/
这里解释一下这样做的原因；
   因为在孤岛范围内，这两个序列都以相同的时间间隔来保持增长，所以
   这时他们的差值保持不变。只要遇到一个新的孤岛，他们之间的差值就
   会增加。这样做的目的为何，第三步将为你说明。
step 3:分别取出第二个查询中生成的相同的diff的值的最大id和最小id
    with t as(
      select id,id-row_number()over(order by id) as diff from tbl
    )
    select min(id) as start_range,max(id) as end_range from t
       group by diff
/*
start_range	end_range
2	3
11	13
27	27
33	35
42	42
*/

求孤岛问题，低三种方法效率较前两种较高，具有比较强的技巧性
希望在实际运用中采纳。
*/