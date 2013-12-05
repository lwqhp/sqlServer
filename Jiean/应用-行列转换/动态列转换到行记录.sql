


IF OBJECT_ID('[#tb]') IS NOT NULL DROP TABLE [tb]
GO
create table #tb(姓名 varchar(10) , 课程 varchar(10) , 分数 int)
insert into #tb values('张三' , '语文' , 74)
insert into #tb values('张三' , '数学' , 83)
insert into #tb values('张三' , '物理' , 93)
insert into #tb values('李四' , '语文' , 74)
insert into #tb values('李四' , '数学' , 84)
insert into #tb values('李四' , '物理' , 94)
go 

SELECT * FROM #tb

SELECT 姓名,
	SUM(CASE 课程 WHEN '语文' THEN 分数 ELSE '' END) 语文,
	SUM(CASE 课程 WHEN '数学' THEN 分数 ELSE '' END) 数学,
	SUM(CASE 课程 WHEN '物理' THEN 分数 ELSE '' END) 物理,
	CAST(AVG(分数*1) AS DECIMAL(24,2)) AS 平均分,
	SUM(分数) AS 总分
FROM #tb GROUP BY 姓名

--动态sql

declare @sql varchar(8000)
set @sql = 'select 姓名 '
select @sql = @sql + ' , sum(case 课程 when ''' + 课程 + ''' then 分数 else 0 end) [' + 课程 + ']'
from (select distinct 课程 from #tb) as a
set @sql = @sql + ' , cast(avg(分数*1.0) as decimal(18,2)) 平均分 , sum(分数) 总分 from #tb group by 姓名'
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

-- 查询处理
DECLARE
	@s nvarchar(4000)
-- a. 交叉报表处理代码头
SET @s = N'
SELECT
	Year'

--生成列记录水平显示的处理代码拼接
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
-- 拼接交叉报表处理尾部, 并且执行拼接后的动态SQL语句
PRINT @s
EXEC(
	@s + N'
FROM #tb1
GROUP BY Year
')
/*--结果
Year        Q1_Amount   Q1_Money    Q2_Amount   Q2_Money
----------- ----------- ----------- ----------- ----------
1990        3.6         10.90       2.6         9.20
1991        6.8         36.50       4.3         20.45
--*/
GO

-- 删除示例环境
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
--SQL SERVER 2005 动态SQL。
declare @sql varchar(8000)
select @sql = isnull(@sql + '],[' , '') + 课程 from #tb group by 课程
set @sql = '[' + @sql + ']'
exec ('select * from #tb a pivot (max(分数) for 课程 in (' + @sql + ')) b')
--得到SQL SERVER 2005 静态SQL。
select * from #tb pivot (max(分数) for 课程 in (语文,数学,物理)) b 


-------牛------------------------------------------------------------------------------------------------
--> 生成测试数据表: [#tb2]
IF OBJECT_ID('[#tb2]') IS NOT NULL
    DROP TABLE [#tb2]
GO
CREATE TABLE [#tb2] ([date] [datetime],[name] [nvarchar](10),[price] [int])
INSERT INTO [#tb2]
SELECT '2010-1-1','张三','10' UNION ALL
SELECT '2010-1-1','李四','20' UNION ALL
SELECT '2010-1-3','王五','30'
 
--SELECT * FROM [#tb2]
 
-->SQL查询如下:
DECLARE @s VARCHAR(MAX),@s1 VARCHAR(MAX)
SELECT @s=ISNULL(@s+',','')+QUOTENAME(name),
       @s1=ISNULL(@s1+',','')+'SUM(ISNULL('+name+',0)) ['+name+']'
FROM #tb2 
GROUP BY name
ORDER BY MIN(date)
--SELECT @s,@s1
EXEC('
    SELECT ISNULL(CONVERT(VARCHAR(10), date, 23),''合计'') 日期,'+@s1+',MAX(合计) 合计
    FROM (
        SELECT *,SUM(price)OVER(PARTITION BY date) 合计 
        FROM #tb2
        ) a 
        PIVOT(SUM(price) FOR name IN('+@s+'))b
    GROUP BY CONVERT(VARCHAR(10), date, 23)
    WITH ROLLUP
')
/*
日期         李四          张三          王五          合计
---------- ----------- ----------- ----------- -----------
2010-01-01 20          10          0           30
2010-01-03 0           0           30          30
合计         20          10          30          30
 
(3 行受影响)
*/



if object_id('#tb12') is not null drop table #tb12
go
CREATE table #tb12 --数据表
(
cpici varchar(10) not null,
cname varchar(10) not null,
cvalue int null
)
--插入测试数据
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



--在sqlserver2000里需要用自增辅助
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

--再2005就可以用row_number
declare @s varchar(8000)
set @s='select cpici '
select @s=@s+',max(case when rn='+ltrim(rn)+' then cvalue end) as cvlue'+ltrim(rn)
from (select distinct rn from (select rn=row_number()over(partition by cpici order by getdate()) from #tb12)a)t
set @s=@s+' from (select rn=row_number()over(partition by cpici order by getdate()),* from #tb12
) t group by cpici'

exec(@s)

---结果
/*
cpici      cvlue1      cvlue2      cvlue3      cvlue4
---------- ----------- ----------- ----------- -----------
T501       31          33          5           NULL
T502       3           22          3           NULL
T503       53          44          50          23
警告: 聚合或其他 SET 操作消除了空值。

(3 行受影响)

*/


--测试用
IF OBJECT_ID('[tb]') IS NOT NULL DROP TABLE [tb]
GO
create table tb(电话号码 varchar(15), 通话时长 int ,行业 varchar(10))
insert tb
select '13883633601', 10 ,'餐饮' union all
select '18689704236', 20 ,'物流' union all
select '13883633601', 20 ,'物流' union all
select '13883633601', 20 ,'汽车' union all
select '18689704236', 20 ,'医疗' union all
select '18689704236', 20 ,'it' union all
select '18689704236', 20 ,'汽车' union all
select '13883633601', 50 ,'餐饮'
go

declare @sql varchar(8000)
set @sql='select 电话号码,sum(通话时长) 通话总和'
select @sql=@sql+',max(case when rowid='+ltrim(rowid)+' then 行业 else '''' end) as [行业'+ltrim(rowid)+']'
from (select distinct rowid from (select (select count(distinct 行业) from tb where 电话号码=t.电话号码 and 行业<=t.行业) rowid
from tb t) a) b
set @sql=@sql+' from ( select * , (select count(distinct 行业) from tb where 电话号码=t.电话号码 and 行业<=t.行业) rowid
from tb t ) t group by 电话号码'
exec(@sql)

--结果
/*

（所影响的行数为 8 行）

电话号码            通话总和        行业1        行业2        行业3        行业4       
--------------- ----------- ---------- ---------- ---------- ----------
13883633601     100         餐饮         汽车         物流        
18689704236     80          it         汽车         物流         医疗

（所影响的行数为 2 行）

*/

 