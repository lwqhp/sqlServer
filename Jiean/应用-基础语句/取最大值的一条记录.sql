

--取最大值的一条记录

/*
分组排序的方法只需对实体表一次扫描，1 次逻辑读。
而一般的not exists方法对实体表2次扫描，多次逻辑读。

但CTE分组排序会使用我一部的系统资源。

选择：速度还是资源。
*/

if object_id('[tb]') is not null drop table [tb] 
 go 
create table [tb]([line_id] int,[p_name] varchar(10),[p_price] int)
insert [tb] select 11,'aa',25
union all select 12,'bb',22
union all select 13,'bb',29
union all select 14,'aa',30

SELECT * FROM dbo.tb
SET STATISTICS PROFILE ON
SET STATISTICS IO ON
SET STATISTICS TIME ON

CREATE NONCLUSTERED INDEX IX_tb ON tb(line_id,p_name)

CREATE NONCLUSTERED INDEX IX_tb ON tb(line_id)

DROP INDEX IX_tb ON tb

;WITH tmp as(
	SELECT *,rn=ROW_NUMBER() OVER(PARTITION BY p_name ORDER BY line_id, p_name desc) FROM tb  
)
SELECT * FROM tmp WHERE rn=1

SELECT * FROM tb a WHERE NOT EXISTS(SELECT 1 FROM tb WHERE a.p_name = p_name AND a.line_id<line_id)

SET STATISTICS PROFILE OFF 
SET STATISTICS IO OFF
SET STATISTICS TIME OFF