


IF OBJECT_ID('[#tb]') IS NOT NULL DROP TABLE [tb]
GO
create table #tb(���� varchar(10) , �γ� varchar(10) , ���� int)
insert into #tb values('����' , '����' , 74)
insert into #tb values('����' , '��ѧ' , 83)
insert into #tb values('����' , '����' , 93)
insert into #tb values('����' , '����' , 74)
insert into #tb values('����' , '��ѧ' , 84)
insert into #tb values('����' , '����' , 94)
go 

SELECT * FROM #tb

SELECT ����,
	SUM(CASE �γ� WHEN '����' THEN ���� ELSE '' END) ����,
	SUM(CASE �γ� WHEN '��ѧ' THEN ���� ELSE '' END) ��ѧ,
	SUM(CASE �γ� WHEN '����' THEN ���� ELSE '' END) ����,
	CAST(AVG(����*1) AS DECIMAL(24,2)) AS ƽ����,
	SUM(����) AS �ܷ�
FROM #tb GROUP BY ����

--��̬sql

declare @sql varchar(8000)
set @sql = 'select ���� '
select @sql = @sql + ' , sum(case �γ� when ''' + �γ� + ''' then ���� else 0 end) [' + �γ� + ']'
from (select distinct �γ� from #tb) as a
set @sql = @sql + ' , cast(avg(����*1.0) as decimal(18,2)) ƽ���� , sum(����) �ܷ� from #tb group by ����'
exec(@sql)


--=====================================================================================

CREATE TABLE #tb1(
	Year int,
	Quarter int,
	Quantity decimal(10,1),
	Price decimal(10,2)
)
INSERT #tb1 SELECT 1990, 1, 1.1, 2.5
UNION ALL SELECT 1990, 1, 1.2, 3.0
UNION ALL SELECT 1990, 2, 1.2, 3.0
UNION ALL SELECT 1990, 1, 1.3, 3.5
UNION ALL SELECT 1990, 2, 1.4, 4.0
UNION ALL SELECT 1991, 1, 2.1, 4.5
UNION ALL SELECT 1991, 2, 2.1, 4.5
UNION ALL SELECT 1991, 2, 2.2, 5.0
UNION ALL SELECT 1991, 1, 2.3, 5.5
UNION ALL SELECT 1991, 1, 2.4, 6.0
GO

-- ��ѯ����
DECLARE
	@s nvarchar(4000)
-- a. ���汨�������ͷ
SET @s = N'
SELECT
	Year'

--�����м�¼ˮƽ��ʾ�Ĵ������ƴ��
SELECT
	@s = @s
		+ N', ' + QUOTENAME(N'Q' + CAST(Quarter as varchar) + N'_Amount')
		+ N' = SUM(
				CASE Quarter
					WHEN ' + CAST(Quarter as varchar)
		+ N' THEN Quantity
				END)'
		+ N', ' + QUOTENAME(N'Q' + CAST(Quarter as varchar) + N'_Money')
		+ N' = CONVERT(decimal(10, 2), SUM(
				CASE Quarter
					WHEN ' + CAST(Quarter as varchar)
		+ N' THEN Quantity * Price
				END))'
FROM #tb1
GROUP BY Quarter
-- ƴ�ӽ��汨����β��, ����ִ��ƴ�Ӻ�Ķ�̬SQL���
PRINT @s
EXEC(
	@s + N'
FROM #tb1
GROUP BY Year
')
/*--���
Year        Q1_Amount   Q1_Money    Q2_Amount   Q2_Money
----------- ----------- ----------- ----------- ----------
1990        3.6         10.90       2.6         9.20
1991        6.8         36.50       4.3         20.45
--*/
GO

-- ɾ��ʾ������
DROP TABLE #tb1



--SELECT  Year ,
--        [Q1_Amount] = SUM(CASE Quarter
--                            WHEN 1 THEN Quantity
--                          END) ,
--        [Q1_Money] = CONVERT(DECIMAL(10, 2), SUM(CASE Quarter
--                                                   WHEN 1
--                                                   THEN Quantity * Price
--                                                 END)) ,
--        [Q2_Amount] = SUM(CASE Quarter
--                            WHEN 2 THEN Quantity
--                          END) ,
--        [Q2_Money] = CONVERT(DECIMAL(10, 2), SUM(CASE Quarter
--                                                   WHEN 2
--                                                   THEN Quantity * Price
--                                                 END))
--FROM    #tb1
--GROUP BY Year


------------------------------------------------------------------------------------
--SQL SERVER 2005 ��̬SQL��
declare @sql varchar(8000)
select @sql = isnull(@sql + '],[' , '') + �γ� from #tb group by �γ�
set @sql = '[' + @sql + ']'
exec ('select * from #tb a pivot (max(����) for �γ� in (' + @sql + ')) b')
--�õ�SQL SERVER 2005 ��̬SQL��
select * from #tb pivot (max(����) for �γ� in (����,��ѧ,����)) b 


-------ţ------------------------------------------------------------------------------------------------
--> ���ɲ������ݱ�: [#tb2]
IF OBJECT_ID('[#tb2]') IS NOT NULL
    DROP TABLE [#tb2]
GO
CREATE TABLE [#tb2] ([date] [datetime],[name] [nvarchar](10),[price] [int])
INSERT INTO [#tb2]
SELECT '2010-1-1','����','10' UNION ALL
SELECT '2010-1-1','����','20' UNION ALL
SELECT '2010-1-3','����','30'
 
--SELECT * FROM [#tb2]
 
-->SQL��ѯ����:
DECLARE @s VARCHAR(MAX),@s1 VARCHAR(MAX)
SELECT @s=ISNULL(@s+',','')+QUOTENAME(name),
       @s1=ISNULL(@s1+',','')+'SUM(ISNULL('+name+',0)) ['+name+']'
FROM #tb2 
GROUP BY name
ORDER BY MIN(date)
--SELECT @s,@s1
EXEC('
    SELECT ISNULL(CONVERT(VARCHAR(10), date, 23),''�ϼ�'') ����,'+@s1+',MAX(�ϼ�) �ϼ�
    FROM (
        SELECT *,SUM(price)OVER(PARTITION BY date) �ϼ� 
        FROM #tb2
        ) a 
        PIVOT(SUM(price) FOR name IN('+@s+'))b
    GROUP BY CONVERT(VARCHAR(10), date, 23)
    WITH ROLLUP
')
/*
����         ����          ����          ����          �ϼ�
---------- ----------- ----------- ----------- -----------
2010-01-01 20          10          0           30
2010-01-03 0           0           30          30
�ϼ�         20          10          30          30
 
(3 ����Ӱ��)
*/



if object_id('#tb12') is not null drop table #tb12
go
CREATE table #tb12 --���ݱ�
(
cpici varchar(10) not null,
cname varchar(10) not null,
cvalue int null
)
--�����������
INSERT INTO #tb12 values('T501','x1',31)
INSERT INTO #tb12 values('T501','x1',33)
INSERT INTO #tb12 values('T501','x1',5)

INSERT INTO #tb12 values('T502','x1',3)
INSERT INTO #tb12 values('T502','x1',22)
INSERT INTO #tb12 values('T502','x1',3)

INSERT INTO #tb12 values('T503','x1',53)
INSERT INTO #tb12 values('T503','x1',44)
INSERT INTO #tb12 values('T503','x1',50)
INSERT INTO #tb12 values('T503','x1',23)



--��sqlserver2000����Ҫ����������
alter table #tb12 add id int identity
go
declare @s varchar(8000)
set @s='select cpici '
select @s=@s+',max(case when rn='+ltrim(rn)+' then cvalue end) as cvlue'+ltrim(rn)
from (select distinct rn from (select rn=(select count(1) from #tb12 where cpici=t.cpici and id<=t.id) from #tb12 t)a)t
set @s=@s+' from (select rn=(select count(1) from #tb12 where cpici=t.cpici and id<=t.id),* from #tb12 t
) t group by cpici'

exec(@s)
go
alter table #tb12 drop column id

--��2005�Ϳ�����row_number
declare @s varchar(8000)
set @s='select cpici '
select @s=@s+',max(case when rn='+ltrim(rn)+' then cvalue end) as cvlue'+ltrim(rn)
from (select distinct rn from (select rn=row_number()over(partition by cpici order by getdate()) from #tb12)a)t
set @s=@s+' from (select rn=row_number()over(partition by cpici order by getdate()),* from #tb12
) t group by cpici'

exec(@s)

---���
/*
cpici      cvlue1      cvlue2      cvlue3      cvlue4
---------- ----------- ----------- ----------- -----------
T501       31          33          5           NULL
T502       3           22          3           NULL
T503       53          44          50          23
����: �ۺϻ����� SET ���������˿�ֵ��

(3 ����Ӱ��)

*/


--������
IF OBJECT_ID('[tb]') IS NOT NULL DROP TABLE [tb]
GO
create table tb(�绰���� varchar(15), ͨ��ʱ�� int ,��ҵ varchar(10))
insert tb
select '13883633601', 10 ,'����' union all
select '18689704236', 20 ,'����' union all
select '13883633601', 20 ,'����' union all
select '13883633601', 20 ,'����' union all
select '18689704236', 20 ,'ҽ��' union all
select '18689704236', 20 ,'it' union all
select '18689704236', 20 ,'����' union all
select '13883633601', 50 ,'����'
go

declare @sql varchar(8000)
set @sql='select �绰����,sum(ͨ��ʱ��) ͨ���ܺ�'
select @sql=@sql+',max(case when rowid='+ltrim(rowid)+' then ��ҵ else '''' end) as [��ҵ'+ltrim(rowid)+']'
from (select distinct rowid from (select (select count(distinct ��ҵ) from tb where �绰����=t.�绰���� and ��ҵ<=t.��ҵ) rowid
from tb t) a) b
set @sql=@sql+' from ( select * , (select count(distinct ��ҵ) from tb where �绰����=t.�绰���� and ��ҵ<=t.��ҵ) rowid
from tb t ) t group by �绰����'
exec(@sql)

--���
/*

����Ӱ�������Ϊ 8 �У�

�绰����            ͨ���ܺ�        ��ҵ1        ��ҵ2        ��ҵ3        ��ҵ4       
--------------- ----------- ---------- ---------- ---------- ----------
13883633601     100         ����         ����         ����        
18689704236     80          it         ����         ����         ҽ��

����Ӱ�������Ϊ 2 �У�

*/

 