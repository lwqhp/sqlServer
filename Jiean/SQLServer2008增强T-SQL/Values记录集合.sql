
--Values ��¼����--------------------------

use AdventureWorks2012
go

--ԭValues����insert into ����б�ʾһ����¼���������
insert into [Person].[ContactType] 
values('test',getdate())

--����sql2008�еõ���ǿ���������Ա�ʾһ���¼����,���ú�select ..union all��ͬ���Ҹ����
insert into [Person].[ContactType]
values('test2',getdate()),
	  ('test3',getdate()),
	  ('test4',getdate())

select * 
from (
	values('test2',getdate()),
		('test3',getdate()),
		('test4',getdate())
) a(name,modifieDate)
inner join [Person].[ContactType]  b on a.name = b.Name


