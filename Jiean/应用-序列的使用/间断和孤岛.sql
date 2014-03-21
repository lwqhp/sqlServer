--ȷʵ��Χ�����з�Χ��Ҳ�Ƽ�Ϻ͹µ����⣩
--1��ȱʧ��Χ����ϣ�
/*
�ռ��ˣ�TravyLee
ʱ�䣺2012-03-25
�������ã��������������Դ��MSSQL2008������Ļ֮T-SQL��
*/
/*
����������м��ַ�����С����ѡ�����ܽϸߵ����֣�ʹ���α�ķ���ʡ��
����Ȥ��ȫ�Ĵ������ظ���
---------------------------------------------------------------------
�������Ľ������1��ʹ���Ӳ�ѯ
step 1���ҵ����֮ǰ��ֵ��ÿ��ֵ����һ�����
step 2������ûһ����ϵ���㣬�ҳ����������е�ֵ���ټ�ȥһ�����
�������Ϊ���ҵ�ԭ���ݱ��е�ֵ��һ��һ�Ƿ���ڣ����в��ף�������
���ɲ�������:
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
Ҫ���ҵ��ϱ������еĲ����ڵ�id�ķ�Χ��
--ʵ����������
/*
��ʼ��Χ ������Χ
 4        10
 14       26
 28       32
 36       41
 */
 ����ÿ������ʵ�֣�
 step 1���ҵ����֮ǰ��ֵ��ÿ��ֵ����һ�����
 ���ǿ�������ķ��֣�Ҫ�ҵļ�Ϸ�Χ����ʼֵʵ���Ͼ�������
 ���������е�ĳЩֵ��1��治�����������ݱ��е����⣬ͨ��
 �Ӳ�ѯʵ�֣�
 
 select id+1 as start_range from tbl as a
 where not exists(select 1 from tbl as b
 where b.id=a.id+1)and id<(select max(id) from tbl)
 --�˲�ѯ���ʵ�����������
 /*
 start_range
 4
 14
 28
 36
 */
 step 2������ûһ����ϵ���㣬�ҳ����������е�ֵ���ټ�ȥһ�����
 
 select id+1 as start_range,(select min(b.id) from tbl as b
 where b.id>a.id)-1 as end_range
 from tbl a where not exists(select 1 from tbl as b
                        where b.id=a.id+1)
     and id<(select max(id) from tbl)
 --��������
 /*
   start_range	end_range
   4	10
   14	26
   28	32
   36	41
 */
ͨ�����ϵ�����Ӳ�ѯ����ʵ�����ҵ�ԭ���ݱ��еļ�Ϸ�Χ��
�������ַ�ʽ��Ч�ʽ�������ʽ�о��Ե�����


�������Ľ������2��ʹ���Ӳ�ѯ������۲�ͬ1������
step 1:��ÿ�����е�ֵƥ����һ�����е�ֵ������һ��һ�Եĵ�
       ǰֵ����һ��ֵ
step 2:ֻ������һ��ֵ����ǰֵ����1�ļ��ֵ��
step 3:��ʣ�µ�ֵ�ԣ���ÿ����ǰֵ����1���������ÿ����һ
       ��ֵ��ȥһ�����

--ת����T-SQL���ʵ�֣�
--step 1:
select id as cur,(select min(b.id) from tbl b where
         b.id>a.id) as nxt from tbl a
--���Ӳ�ѯ���ɵĽ����
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
--���ɽ����
/*
 start_range	 end_range
 4	 10
 14	 26
 28	 32
 36	 41
*/
 �������Ľ������3��ʹ����������ʵ��
 
 ���ַ�����ڶ�������,������һ��ʵ�֣�
 
 ;with c as
 (
   select id,row_number()over(order by id) as rownum
   from tbl
 )
 select cur.id+1 as strat_range,nxt.id-1 as end_range
        from c as cur join c as nxt
   on nxt.rownum=cur.rownum+1
  where nxt.id-cur.id>1

--��������
 /*
 strat_range	end_range
 4	 10
 14	 26
 28	 32
 36	 41
 */
 
*/
--2�����з�Χ���µ���
/*
���ϲ������ݣ��������������
/*
��ʼ��Χ ������Χ
2        3
11       13
27       27
33       35
42       42
*/
�ͼ������һ�����µ�����Ҳ�м��н������������Ҳֻ��������
ʡ�������α��ʵ�ַ�����

�µ�����������1��ʹ���Ӳ�ѯ����������
step 1:�ҳ����֮��ĵ㣬Ϊ���Ƿ����кţ����ǹµ�����㣩
step 2:�ҳ����֮ǰ�ĵ㣬Ϊ���Ƿ����кţ����ǹµ����յ㣩
step 3:���к������Ϊ������ƥ��µ��������յ�

--ʵ�ִ���:
    with startpoints as
    (
      select id,row_number()over(order by id) as rownum
           from tbl as a where not exists(
        select 1 from tbl as b where b.id=a.id-1) 
     /*
     �˲�ѯ��䵥�����еĽ����
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
     �˲�ѯ��䵥�����еĽ����
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
--���н��:   
/*
 start_range	end_range
 2	3
 11	13
 27	27
 33	35
 42	42
*/

�µ�����������2��ʹ�û����Ӳ�ѯ�����ʶ��

--ֱ�Ӹ������룺

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


�µ�����������3��ʹ�û����Ӳ�ѯ�����ʶ��:

step 1:����id˳������к�:
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
step 2������id���кŵĲ�:
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
�������һ����������ԭ��
   ��Ϊ�ڹµ���Χ�ڣ����������ж�����ͬ��ʱ��������������������
   ��ʱ���ǵĲ�ֵ���ֲ��䡣ֻҪ����һ���µĹµ�������֮��Ĳ�ֵ��
   �����ӡ���������Ŀ��Ϊ�Σ���������Ϊ��˵����
step 3:�ֱ�ȡ���ڶ�����ѯ�����ɵ���ͬ��diff��ֵ�����id����Сid
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

��µ����⣬�����ַ���Ч�ʽ�ǰ���ֽϸߣ����бȽ�ǿ�ļ�����
ϣ����ʵ�������в��ɡ�
*/