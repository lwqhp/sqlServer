

--Top �ؼ�����ǿ--------------------

use AdventureWorks2012
go

--ԭTop(n)�ؼ��� ���ؼ�¼����ǰn�ʼ�¼
select top(10) * from person.ContactType

--��Sql2008�ж�top(n)��������ǿ��֧�ֲ�����Χ��������delete ,update DML���

declare @num int
set @num=10
select top(@num) * from person.ContactType

--��delete��update�����ʹ��TOP(n),��ʵ�ִ����ݷֿ���������ƴ�����������������ı�Ĳ�����,������־�Ŀ���������
declare @dt datetime
set @dt =getdate()
while (select count(*) from person.ContactType where ModifiedDate<@dt)>0
begin 
	update top(5) person.ContactType set ModifiedDate=getdate() where  ModifiedDate<@dt
	waitfor delay '00:00:05'
end

--ɾ���ظ���¼
while 1=1
begin 
	delete top(1) from person.ContactType
	where name in(
		select name from person.ContactType group by name having count(*)>1
	)
	if @@rowcount =0 return;
end
