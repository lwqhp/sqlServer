
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

--ȡ���ڲ���
select year(getdate())
select Month(getdate())
select day(getdate())

--��������ָ������
/*
	datepart �������� int ��
	datename �������� nvarchar ��
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
select dateAdd(day,+2,getdate())

--�������ڼ�Ĳ�ֵ
select dateDiff(day,getdate(),'2012-2-1')

--ȡ���ڷ�Χ
 between '2010-9-9' and '2012-9-9'


 -------==========================================================================================
 
--����
--����ϵͳĬ��1900-01-01��ͨ���·ݵĲ�������õ�����1��,ʱ����00.��-3���룬���Եõ��ϸ������һ�������

SELECT DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)
SELECT DATEADD(ms,-3,DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0))
select dateadd(mm,datediff(mm,-1,getdate()),-1)

SELECT DATEADD(dd,DATEDIFF(dd,0,getdate()), 0)
--��ȡ���µĵ�һ�죬Ȼ���һ���£�Ȼ������һ���µĵ�һ���ȥ1�켴�ɡ�
select dateAdd(month,1,dateAdd(day,1-datepart(day,GETDATE()),GETDATE()))-1
SELECT DATEADD(day,1-datepart(day,GETDATE()),GETDATE())-1

select dateadd(mm,1,dateadd(day,-day('2013-08-31'),'2013-08-31'))