


 
 


--������������
dateadd(datepart,number,date)

--������Ϣ��ȡ����:��ȡ����ָ������
DATENAME(datepart,date)--����nvarchar,�� SET DATEFIRST �� SET DATELANGUAGEѡ��������йء�
DATEPART(datepart,date)--����int
DATEPART(weekday,date)--�������ڼ��㷽ʽ����������Ϊһ�ܵĵ�һ�죬��SET DATEFIRSTѡ���й�
year(date)--����int
month(date)--����int
day(date)--����int

--���ڲ�ֵ���㺯��:����������������ָ�����ֵı߽���
DATEDIFF(datepart,startdate,enddate)--����integer

--�������ں���
getdate()
isdate(expression)
--����ֱ���ṩ�����ھ��������ڸ�ʽ���ַ����ṩ��������ʹ��convert�������ڸ�ʽת��ʱ��Ҫ�Ȱ����ڸ�ʽ���ַ���ת��Ϊ�����ͣ�Ȼ���������convert�������ڸ�ʽת����
CONVERT(data_type,expression,style)
cast(expression)


/*
-----------���ڸ�ʽ��---------------------
*/
--�����ڸ�ʽ�� yyyy-m-d
replace(CONVERT(nvarchar(10),getdate(),120),N'-0','-')
--�����ڸ�ʽ��yyyy��mm��dd��[stuffɾ��ָ�����ȵ��ַ�����ָ������ʼ�������һ���ַ�]
stuff(stuff(CONVERT(char(8),getdate(),112),5,0,N'��'),8,0,N'��')+N'��'
datename(year,getdate())+N'��'+datename(month,getdate())+N'��'+datename(day,getdate())+N'��'--set language���öԴ˷�����Ӱ��
--�����ڸ�ʽ��yyyy��m��d��
datename(year,getdate())+N'��'+cast(datepart(month,getdate()) as varchar)+N'��'+datename(day,getdate())+N'��'
--��������+ʱ���ʽ��yyyy-mm-dd hh:mi:ss:mmm [�˽�convert����ʽ����]
CONVERT(char(11),getdate(),120) + CONVERT(char(12),getdate(),114)

/*
--------------�������㴦��----------------------
*/

--ָ�����ڵĸ���ĵ�һ������һ��
CONVERT(char(5),getdate(),120) +N'1-1'
CONVERT(char(5),getdate(),120) +N'12-31'

--ָ���������ڼ��ȵĵ�һ������һ��
CONVERT(datetime,
	CONVERT(char(8),
	dateadd(month,
		datepart(quarter,getdate())*3-month(getdate())-2,
		getdate())
	,120)
+'1')
--���һ��
convert(datetime,
	convert(char(8),
	dateadd(month,
		datepart(quarter,getdate())*3-month(getdat()),
		getdate())
	,120)
	+ case when datepart(quarter,getdate()) in(1,4)
	then '31' else '30' end
)
dateadd(day,-1,
	convert(char(8),
	dateadd(month,
		1+datepart(quarter,getdate())*3-month(getdate()),
		getdate())
		,120 )+'1')

--��ҵ����ǰ���������µĵ�һ������һ��



--ָ�����������ܵ�����һ�� number Ϊ��
dateadd(day,number-datepart(weekday,getdate()),getdate())
--ָ�����������ܵ��������ڼ�
dateadd(day,number-(datepart(weekday,getdate())+@@DATEFIRST-2)%7-1,getdate())


/*
-------���ڼӼ�����----------------------
����dateadd�������㡣
������ָ�������У����ϻ��ȥ������ڲ��֡�
˼·������Ҫ�ľ��ǰ�Ҫ�Ӽ��������ַ��ֽ⣬Ȼ����ݷֽ�Ľ����ָ�����ڵĶ�Ӧ���ڲ��ּ�����Ӧ��ֵ��
�ȶ����ʽ��y-m-d h:m:s.m | -y-m-d h:m:m.m
Ҫ�Ӽ��������ַ����뷽ʽ�������ַ�����ͬ��������ʱ�䲿���ÿո�ָ�����ǰ���һ�ַ�����Ǽ��ŵĻ���
��ʾ�����������������ӷ�������������ַ�ֻ�������֣�����Ϊ�����ַ��У������������Ϣ��

ȷ���������ַ���ʽ�󣬴������Ϳ�������ȷ������ȡ�����ַ��ĵ�һ���ַ����жϴ���ʽ��
Ȼ��Ҫ�Ӽ��������ַ����ո����Ϊ���ں�ʱ�������֣��������ڲ��ִӵ�λ����λ������ȡ�������ݽ��д���
����ʱ��Ӹ�λ����λ��������.
*/

/*
��ʽ��y-m-d h:m:s.m | -y-m-d h:m:m.m
����Ĭ�����죬ʱ��Ĭ����Сʱ���ո�ָ����ں�ʱ��
*/
CREATE FUNCTION dbo.f_DateADD(
@Date     datetime,
@DateStr   varchar(23)
)RETURNS datetime
AS
BEGIN
 DECLARE @bz int,@s varchar(12),@i int
 IF @DateStr IS NULL OR @Date IS NULL
  OR(CHARINDEX('.',@DateStr)>0
   AND @DateStr NOT LIKE '%[:]%[:]%.%')
   
  RETURN(NULL)
 IF @DateStr='' RETURN(@Date)
 --�жϼӼ�,��ʽ���ַ���
 SELECT @bz=CASE
   WHEN LEFT(@DateStr,1)='-' THEN -1
   ELSE 1 END,
  @DateStr=CASE
   WHEN LEFT(@Date,1)='-'
   THEN STUFF(RTRIM(LTRIM(@DateStr)),1,1,'')
   ELSE RTRIM(LTRIM(@DateStr)) END
   --�����ڲ���
 IF CHARINDEX(' ',@DateStr)>1
  OR CHARINDEX('-',@DateStr)>1
  OR(CHARINDEX('.',@DateStr)=0
   AND CHARINDEX(':',@DateStr)=0)
 BEGIN
  SELECT @i=CHARINDEX(' ',@DateStr+' ')
   ,@s=REVERSE(LEFT(@DateStr,@i-1))+'-'
   ,@DateStr=STUFF(@DateStr,1,@i,'')
   ,@i=0
  WHILE @s>'' and @i<3
   SELECT @Date=CASE @i
     WHEN 0 THEN DATEADD(Day,@bz*REVERSE(LEFT(@s,CHARINDEX('-',@s)-1)),@Date)
     WHEN 1 THEN DATEADD(Month,@bz*REVERSE(LEFT(@s,CHARINDEX('-',@s)-1)),@Date)
     WHEN 2 THEN DATEADD(Year,@bz*REVERSE(LEFT(@s,CHARINDEX('-',@s)-1)),@Date)
    END,
    @s=STUFF(@s,1,CHARINDEX('-',@s),''),
    @i=@i+1   
 END
 --��ʱ�䲿��
 IF @DateStr>''
 BEGIN
  IF CHARINDEX('.',@DateStr)>0
   SELECT @Date=DATEADD(Millisecond
     ,@bz*STUFF(@DateStr,1,CHARINDEX('.',@DateStr),''),
     @Date),
    @DateStr=LEFT(@DateStr,CHARINDEX('.',@DateStr)-1)+':',
    @i=0
  ELSE
   SELECT @DateStr=@DateStr+':',@i=0
  WHILE @DateStr>'' and @i<3
   SELECT @Date=CASE @i
     WHEN 0 THEN DATEADD(Hour,@bz*LEFT(@DateStr,CHARINDEX(':',@DateStr)-1),@Date)
     WHEN 1 THEN DATEADD(Minute,@bz*LEFT(@DateStr,CHARINDEX(':',@DateStr)-1),@Date)
     WHEN 2 THEN DATEADD(Second,@bz*LEFT(@DateStr,CHARINDEX(':',@DateStr)-1),@Date)
    END,
    @DateStr=STUFF(@DateStr,1,CHARINDEX(':',@DateStr),''),
    @i=@i+1
 END
 RETURN(@Date)
END
GO


/*-------��������--------------

���������ڵ�������ӵ��뵱ǰ������ͬ��Ȼ�����뵱ǰ���ڱȽϣ�����Ǵ��ڣ�
������Ϊ��ǰ���ڼ�ȥ�������ڵĽ���ټ�һ�꣬��������������ֱ�����

��ҵ���������
*/

datediff(year,'1999-09-09',getdate())
	-CASE WHEN
	dateadd(year,datediff(year,'1999-09-09',getdate()),'1999-09-09')>getdate()
	THEN 1 ELSE 0 END 


/*
��ѯָ��ʱ����ڹ����յ���
˼·�����������ڵ����ת������ʼ���ں󣬳��������ڿ�ʼ���ںͽ������ڵļ�¼.
���������ڵ����ת�����������ں󣬳��������ڿ�ʼ���ںͽ������ڵļ�¼
*/
SELECT @dt1 ='2003-12-05',@dt2 ='2004-02-28'
SELECT * FROM @t
WHERE dateadd(year,datediff(year,birthday,@dt1),birthday)
	BETWEEN @dt1 AND @dt2
OR dateadd(year,datediff(year,birthday,@dt2),birthday)
	BETWEEN @dt1 AND @dt2
	
	
/*
--���������б�-------------
����ָ����ݵĹ�����/��Ϣ���б�

*/
CREATE FUNCTION dbo.f_getdate(
@year int,    --Ҫ��ѯ�����
@bz bit       --@bz=0 ��ѯ������,@bz=1 ��ѯ��Ϣ��,@bz IS NULL ��ѯȫ������
)RETURNS @re TABLE(id int identity(1,1),Date datetime,Weekday nvarchar(3))
AS
BEGIN
    DECLARE @tb TABLE(ID int IDENTITY(0,1),Date datetime)
    INSERT INTO @tb(Date) SELECT TOP 366 DATEADD(Year,@YEAR-1900,'1900-1-1')
    FROM sysobjects a ,sysobjects b
    UPDATE @tb SET Date=DATEADD(DAY,id,Date)
    DELETE FROM @tb WHERE Date>DATEADD(Year,@YEAR-1900,'1900-12-31')
    
    IF @bz=0
        INSERT INTO @re(Date,Weekday)
        SELECT Date,DATENAME(Weekday,Date)
        FROM @tb
        WHERE (DATEPART(Weekday,Date)+@@DATEFIRST-1)%7 BETWEEN 1 AND 5
    ELSE IF @bz=1
        INSERT INTO @re(Date,Weekday)
        SELECT Date,DATENAME(Weekday,Date)
        FROM @tb
        WHERE (DATEPART(Weekday,Date)+@@DATEFIRST-1)%7 IN (0,6)
    ELSE
        INSERT INTO @re(Date,Weekday)
        SELECT Date,DATENAME(Weekday,Date)
        FROM @tb
        
    RETURN
END
GO

/*
--�����б�-----------
    ����ָ�����ڶε������б�
*/

CREATE FUNCTION dbo.f_getdate(
@begin_date Datetime,  --Ҫ��ѯ�Ŀ�ʼ����
@end_date Datetime,    --Ҫ��ѯ�Ľ�������
@bz bit                --@bz=0 ��ѯ������,@bz=1 ��ѯ��Ϣ��,@bz IS NULL ��ѯȫ������
)RETURNS @re TABLE(id int identity(1,1),Date datetime,Weekday nvarchar(3))
AS
BEGIN
    DECLARE @tb TABLE(ID int IDENTITY(0,1),a bit)
    INSERT INTO @tb(a) SELECT TOP 366 0
    FROM sysobjects a ,sysobjects b
    
    IF @bz=0
        WHILE @begin_date<=@end_date
        BEGIN
            INSERT INTO @re(Date,Weekday)
            SELECT Date,DATENAME(Weekday,Date)
            FROM(
                SELECT Date=DATEADD(Day,ID,@begin_date)
                FROM @tb                
            )a WHERE Date<=@end_date
                AND (DATEPART(Weekday,Date)+@@DATEFIRST-1)%7 BETWEEN 1 AND 5
            SET @begin_date=DATEADD(Day,366,@begin_date)
        END
    ELSE IF @bz=1
        WHILE @begin_date<=@end_date
        BEGIN
            INSERT INTO @re(Date,Weekday)
            SELECT Date,DATENAME(Weekday,Date)
            FROM(
                SELECT Date=DATEADD(Day,ID,@begin_date)
                FROM @tb                
            )a WHERE Date<=@end_date
                AND (DATEPART(Weekday,Date)+@@DATEFIRST-1)%7 in(0,6)
            SET @begin_date=DATEADD(Day,366,@begin_date)
        END
    ELSE
        WHILE @begin_date<=@end_date
        BEGIN
            INSERT INTO @re(Date,Weekday)
            SELECT Date,DATENAME(Weekday,Date)
            FROM(
                SELECT Date=DATEADD(Day,ID,@begin_date)
                FROM @tb                
            )a WHERE Date<=@end_date
            SET @begin_date=DATEADD(Day,366,@begin_date)
        END
    RETURN
END
GO

select @@DATEFIRST

set datefirst 1

---��һ������,���ɱ��ܵ������б�:
declare @date datetime
set @date=getdate()
select @date+1-datepart(dw,@date) --ȡָ�����������ܵ�����һ,Ĭ����������һ�ܵĵ�һ��

select dateadd(dd,a.number,DATEADD(Day,1-(DATEPART(Weekday,GETDATE())+@@DATEFIRST-2)%7-1,GETDATE()))
from master..spt_values a
where type='p'
    and number<=6


declare @d datetime
set @d = getdate()
select dateadd(d,n,@d) as t
from (select -1 as n union all select -2 union all select -3 union all select -4 union all select -5 union all select -6 union all
      select 1 union all select 2 union all select 3 union all select 4 union all select 5 union all select 6 union all select 0) t
where datepart(wk,@d)=datepart(wk,dateadd(d,n,@d)) 


DECLARE @dt datetime
SET @dt=GETDATE()
 
DECLARE @number int
SET @number=3 --ָ�����ڼ�
--ָ�����������ܵ��������ڼ�
--A.  ��������Ϊһ�ܵĵ�1��
SELECT DATEADD(Day,1-(DATEPART(Weekday,GETDATE())+@@DATEFIRST-1)%7,GETDATE())
 
--B.  ����һ��Ϊһ�ܵĵ�1��
SELECT DATEADD(Day,1-(DATEPART(Weekday,GETDATE())+@@DATEFIRST-2)%7-1,GETDATE())
/*
�����·��б�
ʵ��ͳ��ÿ���·ݵ�money�ϼƣ�����û�����ݵ��·ݣ���ʾΪ0����ͳ���У�Ϊ�˲���ȱ�ٵ��·ݣ�ʹ��select
���union all��乹��һ������1-12��12����¼�������
*/
select @@datefirst
set datefirst 1

/*
��ѯ���������ǵ��µĵڼ���
���������ǵ���ĵڼ���-�������������µ�һ���ǵ���ĵڼ���
��һ�ܵĿ�ʼ�����ջ�����һ����Ӱ��
*/
declare @date datetime;
set @date = getdate()

select datepart(week,@date)-datepart(week,dateadd(month,datediff(month,0,@date),0))+1 
select datepart(week,@date)-datepart(week,dateadd(day,1-datepart(day,@date),@date))+1 

SELECT a.[month],[month]=isnull(b.[monty],0)
FROM (
	SELECT [month] =1 UNION ALL
	SELECT [month] =2 )a
	LEFT JOIN (
		SELECT [month]=month(date),[month] = sum([month])
		FROM @t
		GROUP BY month(date)
		)b ON a.[month] = b.[month]