

--�������м������

--ʵ����������
/*
��ʼ��Χ ������Χ
 4        10
 14       26
 28       32
 36       41
 */

--���ɲ�������:

if object_id('tbl')is not null drop table tbl
go
create table tbl(
id int not null
)
go
insert tbl
values(2),(3),(11),(12),(13),(27),(33),(34),(35),(42)

--���ҷ�
 /*
 ��Ҫ��ִ�мƻ���
 �ؼ����Ż�������ʲô��ʽ�������ⲿ��ѯ����not existsν�ʴ����"���֮ǰ��ֵ"����������merge join���������
 ������sequal�ϵ�����������������ɨ�裬���ڽ�1ǧ���У���ȶ�ÿһ�н���һ�β��Ҳ���Ҫ��Ч�öࡣ����ֻΪɸ 
 ѡ������ֵ����������ʹ���������Ҳ�����ȡ����һ������ֵ��
 */
select id+1 as start_range,
	(select min(b.id) from tbl as b where b.id>a.id)-1 as end_range
from tbl a where 
	not exists(select 1 from tbl as b where b.id=a.id+1)
	and id<(select max(id) from tbl)

--�Ӳ�ѯ����
/*
Ϊ��ȡ����������ֵ����Ҫ�Թ�����ִ��һ��������ɨ�裬����ÿһ�У���ʹ��һ���������Ҳ�������������һ��ֵ��ÿ��
���Ҳ����뻨��3���߼���ȡ����������3���������Բ��Ҿ͵���Ҫ��Լ3000000���߼���ȡ��
*/
select cur+1 as start_range,nxt-1 as end_range
from (
	select id as cur,(select min(b.id) from tbl b where b.id>a.id) as nxt 
	from tbl a 
) as d
where nxt-cur>1
      

--����ֵ��
/*
1,���������������ֵ��
2������ֵ�а�����ת�������
3��ͨ���Ƚ���������ֵ�ж��Ƿ��м�ϣ���������������䣬����֮��Ĳ����1,����˵���������м��
4��ȡ���俪ʼֵ����һ��ֵ���������ֵ����һ��ֵ��Ϊ�����Χ��

�����merge join �����൱�����ǰ���Զ����ӽ��д���ġ�

*/
;with tmp as(
	select id,row_number()over(order by id) as rownum
	from tbl
)
select cur.id+1 as strat_range,nxt.id-1 as end_range
from tmp as cur 
INNER join tmp as nxt on nxt.rownum=cur.rownum+1
where nxt.id-cur.id>1



--1������ȱ�ŷֲ�����---------------------------------------------------------------------------------------

CREATE TABLE tb(
	col1 varchar(10),
	col2 int)
INSERT tb SELECT 'a', 2
UNION ALL SELECT 'a', 3
UNION ALL SELECT 'a', 6
UNION ALL SELECT 'a', 7
UNION ALL SELECT 'a', 8
UNION ALL SELECT 'b', 1
UNION ALL SELECT 'b', 5
UNION ALL SELECT 'b', 6
UNION ALL SELECT 'b', 7
GO

--ȱ�ŷֲ���ѯ
SELECT
	A.col1,
	start_col2 = A.col2 + 1,
	end_col2 = (
				-- ȱ�ſ�ʼ��¼�ĺ�һ����¼��� - 1, ��Ϊȱ�ŵĽ������
				SELECT
					MIN(col2) - 1
				FROM tb AA
				WHERE col1 = A.col1
					AND col2 > A.col2 )
FROM(
	SELECT
		col1, col2
	FROM tb
	UNION ALL -- Ϊÿ���Ų����ѯ��ʼ����Ƿ�ȱ�ŵĸ�����¼
	SELECT DISTINCT 
		col1, 0
	FROM tb
)A
	INNER JOIN(
		-- ÿ�����ݵ�����¼�϶�û�к������, ����������ȱ��, ���Ҫ����ȥ��
		SELECT
			col1,
			col2 = MAX(col2)
		FROM tb
		GROUP BY col1
	)B
		ON A.col1 = B.col1
			AND A.col2 < B.col2
WHERE NOT EXISTS(
		-- ɸѡ��ÿ��û�к�����ŵļ�¼, ���ı�� + 1 ��Ϊȱ�ŵĿ�ʼ���
		SELECT * FROM tb
		WHERE col1 = A.col1
			AND col2 = A.col2 + 1)
ORDER BY A.col1, start_col2
/*--���
col1       start_col2  end_col2    
-------------- -------------- ----------- 
a          1           1
a          4           5
b          2           4
--*/
GO

-- ɾ����������
DROP TABLE tb