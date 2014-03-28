
/*������Ϣ*/
/*
 SQL Server �е��������Ͱ���datetime ��smalldatetime�����ܴ������ʶ��Ϊ 1753��--9999�������ڵ�ֵ��û�е����������ͻ�ʱ���͡�
 
 datetime:���ʹ����1753��1��1��-9999��12��31�յ����ں�ʱ�����ݣ���ȷ��Ϊ�ٷ�֮���롣
			�洢����Ϊ8�ֽڣ����ں�ʱ�����4���ֽڴ洢��
 smalldatetime:���ʹ����1900��1��1��-2079��6��6�յ�ʱ�ں�ʱ�����ݡ���ȷ�����ӡ�
			�洢����Ϊ4�ֽڡ�
			
SqlServer���Ի��������ڸ�ʽ��Ӱ��

SET LANGUAGE ָ��SqlServer����
SET DATEFIRST {number | @number_var} ����һ�ܵĵ�һ�������ڼ����������û�����Ч��
	1~��ʾһ�ܵĵ�һ��������һ��7~��ʾһ�ܵĵ�һ���ӦΪ�����ա�
*/

--ȡ��ǰ����
SELECT getdate()

--������ʽ�Ƿ�Ϊ��Ч����
isdate(expression)

--����ֱ���ṩ�����ھ��������ڸ�ʽ���ַ����ṩ��������ʹ��convert�������ڸ�ʽת��ʱ��
--Ҫ�Ȱ����ڸ�ʽ���ַ���ת��Ϊ�����ͣ�Ȼ���������convert�������ڸ�ʽת����
CONVERT(data_type,expression,style)
cast(expression)

--ȡ���ڲ���
select year(getdate())
select Month(getdate())
select day(getdate())

--��������ָ������
/*
DATENAME(datepart,date)--����nvarchar,�� SET DATEFIRST �� SET DATELANGUAGEѡ��������йء�
DATEPART(datepart,date)--����int
DATEPART(weekday,date)--�������ڼ��㷽ʽ����������Ϊһ�ܵĵ�һ�죬��SET DATEFIRSTѡ���й�
year(date)--����int
month(date)--����int
day(date)--����int
*/
select datename(year,getdate())
select datename(month,getdate())--'01'

select datepart(year,getdate())
select datepart(month,getdate())--1

select datepart(minute,getdate())
/*
	year 	yy, yyyy
	quarter 	qq, q ����
	month 	mm, m
	dayofyear 	dy, y
	day 	dd, d
	week 	wk, ww ��������ߵĵڼ�������
	weekday 	dw ���ڼ�
	Hour 	hh
	minute 	mi, n
	second 	ss, s
	millisecond 	ms ����
*/


/*-------------------��������------------------*/

--������������
select dateAdd(day,2,getdate())

--���ڲ�ֵ���㺯��:����������������ָ�����ֵı߽���
SELECT DATEDIFF(datepart,startdate,enddate)--����integer

--ȡ���ڷ�Χ
 between '2010-9-9' and '2012-9-9'


 ---���ڸ�ʽ��------------------------------------------------------------------------------
 
--�����ڸ�ʽ�� yyyy-m-d
select replace(CONVERT(nvarchar(10),getdate(),120),N'-0','-')

--�����ڸ�ʽ��yyyy��mm��dd��[stuffɾ��ָ�����ȵ��ַ�����ָ������ʼ�������һ���ַ�]
SELECT stuff(stuff(CONVERT(char(8),getdate(),112),5,0,N'��'),8,0,N'��')+N'��'
SELECT datename(year,getdate())+N'��'+datename(month,getdate())+N'��'+datename(day,getdate())+N'��'--set language���öԴ˷�����Ӱ��

--�����ڸ�ʽ��yyyy��m��d��
SELECT datename(year,getdate())+N'��'+cast(datepart(month,getdate()) as varchar)+N'��'+datename(day,getdate())+N'��'

--��������+ʱ���ʽ��yyyy-mm-dd hh:mi:ss:mmm [�˽�convert����ʽ����]
SELECT CONVERT(char(11),getdate(),120) + CONVERT(char(12),getdate(),114)
