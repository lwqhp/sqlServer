

--�ж���������ǰ��˳��
/*
����sign��������ֵ�ж��������ڵĴ�С,sign��������ֵ�Ĳ�ĶԱ�ֵ��>0 ����1,=0 ����0 ,<0����-1
*/

--���úͻ�׼ʱ��Ĳ�ٱȽϷ���ֵ�Ĵ�С������������ǰ��

declare @d1 date
declare @d2 date
set @d1 = '2014-01-01'
set @d2 = '2014-02-11'

select case  sign(datediff(day,0,@d1)-datediff(day,0,@d2)) 
 when 1 then @d1
 when 0 then @d1
 when -1 then @d2
 end