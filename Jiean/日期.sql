

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