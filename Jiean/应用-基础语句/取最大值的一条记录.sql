

--ȡ���ֵ��һ����¼

/*
��������ķ���ֻ���ʵ���һ��ɨ�裬1 ���߼�����
��һ���not exists������ʵ���2��ɨ�裬����߼�����

��CTE���������ʹ����һ����ϵͳ��Դ��

ѡ���ٶȻ�����Դ��
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