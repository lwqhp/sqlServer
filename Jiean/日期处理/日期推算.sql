
--����һ��ָ�������ڣ��������һ�����ڵ�

DECLARE @dt datetime
SET @dt=GETDATE()

DECLARE @number int
SET @number=3

/*----��----*/
--1������ĵ�һ������һ��
--A. ��ĵ�һ��
SELECT CONVERT(char(5),@dt,120)+'1-1'

--B. ������һ��
SELECT CONVERT(char(5),@dt,120)+'12-31'

/*----����----*/
--2��ָ���������ڼ��ȵĵ�һ������һ��
--A. ���ȵĵ�һ��
SELECT CONVERT(datetime,
	CONVERT(char(8),
		DATEADD(Month,
			DATEPART(Quarter,@dt)*3-Month(@dt)-2,
			@dt),
		120)+'1')

--B. ���ȵ����һ�죨CASE�жϷ���
SELECT CONVERT(datetime,
	CONVERT(char(8),
		DATEADD(Month,
			DATEPART(Quarter,@dt)*3-Month(@dt),
			@dt),
		120)
	+CASE WHEN DATEPART(Quarter,@dt) in(1,4)
		THEN '31'ELSE '30' END)

--C. ���ȵ����һ�죨ֱ�����㷨��
SELECT DATEADD(Day,-1,
	CONVERT(char(8),
		DATEADD(Month,
			1+DATEPART(Quarter,@dt)*3-Month(@dt),
			@dt),
		120)+'1')


/*----�·�----*/
--3��ָ�����������·ݵĵ�һ������һ��
--A. �µĵ�һ��
SELECT CONVERT(datetime,CONVERT(char(8),@dt,120)+'1')

--B. �µ����һ��
SELECT DATEADD(Day,-1,CONVERT(char(8),DATEADD(Month,1,@dt),120)+'1')

--C. �µ����һ�죨����ʹ�õĴ��󷽷���
SELECT DATEADD(Month,1,DATEADD(Day,-DAY(@dt),@dt))


--4��ָ�����������ܵ�����һ��
SELECT DATEADD(Day,@number-DATEPART(Weekday,@dt),@dt)



/*----��----*/

DECLARE @dt datetime
SET @dt=GETDATE()

DECLARE @number int
SET @number=3
--5��ָ�����������ܵ��������ڼ�
--A.  ��������Ϊһ�ܵĵ�1��
SELECT DATEADD(Day,@number-(DATEPART(Weekday,@dt)+@@DATEFIRST-1)%7,@dt)

--B.  ����һ��Ϊһ�ܵĵ�1��
SELECT DATEADD(Day,@number-(DATEPART(Weekday,@dt)+@@DATEFIRST-2)%7-1,@dt)
