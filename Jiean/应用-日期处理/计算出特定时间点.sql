


----(1)��ĵ�һ������һ��-----------------------------------------------------------------------------

/*����ĵ�һ������һ��
һ��ĵ�һ���µ�һ������һ�������һ�춼�ǹ̶��ģ�ȡ���ƴ�Ӽ���
*/
--A. ��ĵ�һ��
SELECT CONVERT(char(5),getdate(),120)+'1-1'

--B. ������һ��
SELECT CONVERT(char(5),getdate(),120)+'12-31'


--(2)���ȵĵ�һ������һ��------------------------------------------------------------------------
/*
һ����4�����ȣ�һ������3����,datepart��quarter�ɷ������������ļ���
������*3�õ����ڼ��ȵ����һ���·�,��ȥ2������¼��ĵ�һ������
��һ���·ݼ�ȥ��ǰ�·ݵõ���ǰ�·����һ���·ݵ�ƫ����
ͬ�����һ���·ݼ�ȥ��ǰ�·ݵõ���ǰ�·������һ���µ�ƫ����
*/
--A. ���ȵĵ�һ��
SELECT CONVERT(datetime,
	CONVERT(char(8),
		DATEADD(Month,
			DATEPART(Quarter,getdate())*3-Month(getdate())-2,
			getdate()),
		120)+'1')

--B. ���ȵ����һ�죨CASE�жϷ���
SELECT CONVERT(datetime,
	CONVERT(char(8),
		DATEADD(Month,
			DATEPART(Quarter,getdate())*3-Month(getdate()),
			getdate()),
		120)
	+CASE WHEN DATEPART(Quarter,getdate()) in(1,4)
		THEN '31'ELSE '30' END)

--C. ���ȵ����һ�죨ֱ�����㷨��
SELECT DATEADD(Day,-1,
	CONVERT(char(8),
		DATEADD(Month,
			1+DATEPART(Quarter,getdate())*3-Month(getdate()),
			getdate()),
		120)+'1')


----(3)�·ݵĵ�һ������һ��-------------------------------------------------------------
/*����ϵͳĬ��1900-01-01��ͨ���·ݵļ���(��Ϊ�������ڲ���)�����õ�����1��,ʱ����00.��-3���룬
���Եõ��ϸ������һ�������*/

--A. �µĵ�һ��
SELECT CONVERT(datetime,CONVERT(char(8),getdate(),120)+'1')
SELECT DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)

--B. �µ����һ��
SELECT DATEADD(Day,-1,CONVERT(char(8),DATEADD(Month,1,getdate()),120)+'1')
select dateadd(mm,datediff(mm,-1,getdate()),-1)

--C. �µ����һ�죨����ʹ�õĴ��󷽷���
SELECT DATEADD(Month,1,DATEADD(Day,-DAY(getdate()),getdate()))


--4��ָ�����������ܵ�����һ��
SELECT DATEADD(Day,3-DATEPART(Weekday,getdate()),getdate())



IF object_id('tempdb..#dateList') IS NOT NULL DROP TABLE #dateList
CREATE TABLE #dateList(billdate DATETIME)
go
INSERT INTO #dateList
SELECT '2013-08-31' UNION ALL
SELECT '2013-08-01' UNION ALL 
SELECT '2013-08-08' UNION ALL 
SELECT '2013-08-12' UNION ALL 
SELECT '2013-07-21' UNION ALL 
SELECT '2013-07-05' UNION ALL 
SELECT '2012-08-01' UNION ALL 
SELECT '2012-08-31' UNION ALL 
SELECT '2013-05-03' UNION ALL 
SELECT '2013-05-04' 

--���·�
DECLARE @startdate varchar(30)
SET @startdate ='2013-08-15 23:36:34'

SELECT DATEADD(month,DATEDIFF(month,-1,dateadd(year,-1,@startdate)),0)
SELECT * FROM #dateList 
WHERE billdate >= DATEADD(month,DATEDIFF(month,0,@startdate),0)
	AND billdate < DATEADD(month,DATEDIFF(month,-1,@startdate),0)
	
--ȥ��ͬ��
SELECT * FROM #dateList 
WHERE billdate >= DATEADD(month,DATEDIFF(month,0,dateadd(year,-1,@startdate)),0)
	AND billdate < DATEADD(month,DATEDIFF(month,-1,dateadd(year,-1,@startdate)),0)

--(4)�ܵļ���----------------------------------------------------------------------------------
select @@datefirst
SET DATEFIRST 7 --�鿴�������ܵĵ�һ�������ڼ�
select datepart(weekday,getdate()) --�������������ܵĵڼ���
select datepart(week,getdate()) --��������������ĵڼ���
/*
һ�ܵĵ�һ�����ڼ��Ǹ������ݿ��趨��,Ĭ������������Ϊһ�ܵĿ�ʼ,@@datefirst=7
datepart(weekday,getdate())�������������ܵĵڼ���
һ�̶ܹ���7�죬7-���������ܵ����������������������һ���ƫ����
*/

--���ݵ�ǰ�����������һ���ƫ�����������������
with tmp as(
	select 1 as dwnum,getdate() as startDate,dateadd(day,7-datepart(weekday,getdate()),getdate()) as endDate
	union all
	select a.dwnum+1 as dwnum,dateadd(day,1,a.enddate),dateadd(day,7,a.enddate) 
	from tmp a where a.startDate<='2014-03-05' 
)
select * from tmp


/*
��ѯ���������ǵ��µĵڼ���

��һ�ܵĿ�ʼ�����ջ�����һ����Ӱ��
*/
--��ѯ���������µĵڼ���:�������ڵĵڼ���-�������������µ�һ���Ǳ���ĵڼ���
declare @date datetime;
set @date = getdate()

select datepart(week,@date) --�����ǵ���ĵڼ���
	-datepart(week,dateadd(month,datediff(month,0,@date),0))--�������������µ�һ���Ǳ���ĵڼ���
	+1 
select datepart(week,@date)
	-datepart(week,dateadd(day,1-datepart(day,@date),@date))
	+1 

-- ��ѯ���������ܵĵ�һ��
SELECT	@date_begin = DATEADD(Day, - (DATEPART(Weekday, @Date) + @@DATEFIRST - 2) % 7, @Date),
	@Date = DATEADD(Week, 1, @date_begin),
	@date_begin_previous = DATEADD(Week, - 1, @date_begin)

---(5)������һ��ʱ���--------------------------------------------------------------
SELECT DATEADD(ms,-3,DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0))
SELECT DATEADD(dd,DATEDIFF(dd,0,getdate()), 0)

-- ȥ�������е�ʱ�䲿��
SET @Date = DATEDIFF(Day, 0, ISNULL(@Date, GETDATE()))