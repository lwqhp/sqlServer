
/*������Ϣ*/

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

