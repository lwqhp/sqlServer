

--����
--����ϵͳĬ��1900-01-01��ͨ���·ݵĲ�������õ�����1��,ʱ����00.��-3���룬���Եõ��ϸ������һ�������

SELECT DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0)
SELECT DATEADD(ms,-3,DATEADD(mm,DATEDIFF(mm,0,GETDATE()),0))

SELECT DATEADD(dd,DATEDIFF(dd,0,getdate()), 0)
--��ȡ���µĵ�һ�죬Ȼ���һ���£�Ȼ������һ���µĵ�һ���ȥ1�켴�ɡ�
select dateAdd(month,1,dateAdd(day,1-datepart(day,GETDATE()),GETDATE()))-1
SELECT DATEADD(day,1-datepart(day,GETDATE()),GETDATE())-1