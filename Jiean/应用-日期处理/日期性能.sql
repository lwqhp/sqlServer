/*
һ�������ڴ����ϳ��ֵ�����Ч�����⣺
1������ʧЧ��ȱ�������������ò���
2��ѭ�������������䣺�󲿷ݵ����ⶼ���Ը�Ϊ��������ѭ����ʽ���
3)�����������ã��ַ��ͺ��������ͼ������ʽת�����ַ��Ͳ���ֱ��Ӧ��ϵͳ�����ں�����

a.��ͬ���������ͻ�ͬһ���������ͼ�Ƚϲ�������ת������ͬ���������ͱȽϻ�������ת��

b.���ڸ�ʽ�ǹ̶����ȵģ�������ת�����ַ���ʱ��char

���������ܵ��²�ѯ
1,����ʱ����datediff�������ڲ�ֵ�����Ƚ�
2,����ת������convert ת���ֶκ��ٱȽ�
3,����ʱ�亯���������۳��꣬�£��պ��ٱȽ�

*/

--��������ת��
/*
dateadd���ص���smalldatetime��ʽ
���浽datetime���ͱ����У�ȫ�����棬û��ת��
���浽smallDatetime���ͱ����У���sdtֻ��ȷ�����ӣ�����벿�����������봦��
���浽�ַ������У�û����ʾ������ת���Ļ���sql�ᰴϵͳĬ�����ڸ�ʽ��ʽת���ַ�������������02 28 2014 11:59PM
*/
declare @dt datetime,@dt1 smalldatetime,@dt2 varchar(30)

 SELECT @dt=DATEADD(ms,-3,DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)),
	@dt1=DATEADD(ms,-3,DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)),
	@dt2=DATEADD(ms,-3,DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0))
select @dt,@dt1,@dt2


--����ת������
/*��һ������ת�����ڣ���������ϵͳĬ��ʱ��(1900-01-01)��������������
ͬ��ȡ���ڵ�����Ҳ������������ʾ���ڡ�*/
declare @dt datetime
set @dt = datediff(day,0,getdate())
select  @dt

select datediff(day,0,getdate())

select datepart(minute,getdate())

select datename(minute,getdate())

--��Ч�����ڴ���
/*�ڲ�ѯ�ֶ������˼��㣬��ζ�ű����ÿ����¼�Ĳ�ѯ�ֶ������㣬���жϼ�������ֵ�Ƿ���ڼ�ƥ��*/

--��ѯ���յ�����
where datediff(day,datefield,getdate())=0

--��ѯ������ӵļ�¼
where datediff(minute,datefield,getdate()) between 0 and 5

--��ѯָ�����µ�����
where year(datefield) = 2009 and month(datefield) =4
where convert(varchar(6),datefield,112) = '200904'

--��ѯָ��ʱ����ڵļ�¼
where convert(varchar(8),datefield,112) between '20050505' and '20090909'

/*�Ż��Ĳ�ѯ*/

--��ѯ���յ�����
where datefields >= convert(varchar(10),getdate(),120) 
and datefields < convert(varchar(10),getdate()+1,120)
--��ѯ������ӵļ�¼
where datefields between dateadd(minute,-5,getdate()) and getdate() 
--��ѯָ�����µ�����
where datefields >='20050505' and datefields <'20090909'
--��ѯָ��ʱ����ڵļ�¼
where datefields >='20050505' and datefields <'20090909'


/*
�������ͱ��ַ����͵����ڸ����д������ƣ���Ҫ������ת���ַ����ͺ������Ƚ�
��������ָ�ʽ���ɺ��������ͱȽϣ����ɵ�ִ�мƻ�һ��һ���ġ�
*/

CREATE TABLE #tmp(
t1 DATETIME
)

INSERT INTO #tmp
VALUES('2014-01-01 23:50:50.934'),('2014-01-02 23:50:50.934'),('2014-01-03')

SET STATISTICS PROFILE ON 
SELECT * FROM #tmp
WHERE t1>=CAST(2014*10000+1*100+1 AS CHAR(8)) AND t1<=CAST(2014*10000+1*100+2 AS CHAR(8))
SET STATISTICS PROFILE OFF 


SET STATISTICS PROFILE ON 
SELECT * FROM #tmp
WHERE t1>='20140101' AND t1<='20140102'
SET STATISTICS PROFILE OFF 