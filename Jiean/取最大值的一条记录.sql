

--ȡ���ֵ��һ����¼

/*
�÷���ķ�ʽ����Ҫ�Ա��������ɨ������ҳ���Ҫ�ļ�¼
�������Ƚ�

*/

if object_id('[tb]') is not null drop table [tb] 
 go 
create table [tb]([line_id] int,[p_name] varchar(10),[p_price] int)
insert [tb] select 11,'aa',25
union all select 12,'bb',22
union all select 13,'bb',29
union all select 14,'aa',30

SELECT * FROM dbo.tb

;WITH tmp as(
	SELECT *,rn=ROW_NUMBER() OVER(PARTITION BY p_name ORDER BY p_name,line_id desc) FROM tb  
)
SELECT * FROM tmp WHERE rn=1

SELECT * FROM tb a WHERE NOT EXISTS(SELECT 1 FROM tb WHERE a.p_name = p_name AND a.line_id<line_id)