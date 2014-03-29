

--生成序列间断区间

--实现输出结果：
/*
开始范围 结束范围
 4        10
 14       26
 28       32
 36       41
 */

--生成测试数据:

if object_id('tbl')is not null drop table tbl
go
create table tbl(
id int not null
)
go
insert tbl
values(2),(3),(11),(12),(13),(27),(33),(34),(35),(42)

--查找法
 /*
 主要看执行计划：
 关键看优化器采用什么方式来处理外部查询中由not exists谓词代表的"间断之前的值"。这里用了merge join运算符进行
 处理，对sequal上的索引进行两次有序扫描，对于近1千万行，这比对每一行进行一次查找操作要高效得多。接着只为筛 
 选出来的值，优倾听器使用索引查找操作，取回下一个序列值。
 */
select id+1 as start_range,
	(select min(b.id) from tbl as b where b.id>a.id)-1 as end_range
from tbl a where 
	not exists(select 1 from tbl as b where b.id=a.id+1)
	and id<(select max(id) from tbl)

--子查询方法
/*
为了取回所的序列值，须要对过索引执行一次完整的扫描，对于每一行，再使用一个索引查找操作，返回其下一个值，每个
查找操作须花费3次逻辑读取，（索引有3级），所以查找就得需要大约3000000次逻辑读取。
*/
select cur+1 as start_range,nxt-1 as end_range
from (
	select id as cur,(select min(b.id) from tbl b where b.id>a.id) as nxt 
	from tbl a 
) as d
where nxt-cur>1
      

--序列值法
/*
1,给数据排序添加序值列
2，按序值列把数据转成区间表
3，通过比较区间上两值判断是否有间断，如果是连续的区间，它们之间的差等于1,否则说明该区间有间隔
4，取区间开始值的下一个值和区间结束值的上一个值则为间隔范围。

这里的merge join 开销相当大，这是按多对多联接进行处理的。

*/
;with tmp as(
	select id,row_number()over(order by id) as rownum
	from tbl
)
select cur.id+1 as strat_range,nxt.id-1 as end_range
from tmp as cur 
INNER join tmp as nxt on nxt.rownum=cur.rownum+1
where nxt.id-cur.id>1



--1）生成缺号分布区间---------------------------------------------------------------------------------------

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

--缺号分布查询
SELECT
	A.col1,
	start_col2 = A.col2 + 1,
	end_col2 = (
				-- 缺号开始记录的后一条记录编号 - 1, 即为缺号的结束编号
				SELECT
					MIN(col2) - 1
				FROM tb AA
				WHERE col1 = A.col1
					AND col2 > A.col2 )
FROM(
	SELECT
		col1, col2
	FROM tb
	UNION ALL -- 为每组编号补充查询起始编号是否缺号的辅助记录
	SELECT DISTINCT 
		col1, 0
	FROM tb
)A
	INNER JOIN(
		-- 每组数据的最大记录肯定没有后续编号, 但它不能算缺号, 因此要将其去掉
		SELECT
			col1,
			col2 = MAX(col2)
		FROM tb
		GROUP BY col1
	)B
		ON A.col1 = B.col1
			AND A.col2 < B.col2
WHERE NOT EXISTS(
		-- 筛选出每条没有后续编号的记录, 它的编号 + 1 即为缺号的开始编号
		SELECT * FROM tb
		WHERE col1 = A.col1
			AND col2 = A.col2 + 1)
ORDER BY A.col1, start_col2
/*--结果
col1       start_col2  end_col2    
-------------- -------------- ----------- 
a          1           1
a          4           5
b          2           4
--*/
GO

-- 删除测试数据
DROP TABLE tb