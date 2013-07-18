
if object_id('[tb]') is not null drop table [tb] 
create table tb(id int, value varchar(10))  
insert into tb values(1, 'aa')  
insert into tb values(1, 'bb')  
insert into tb values(2, 'aaa')  
insert into tb values(2, 'bbb')  
insert into tb values(2, 'ccc')  
go  

SELECT * FROM tb

SELECT id,VALUE=STUFF((SELECT ','+b.value FROM tb b WHERE a.id = b.id FOR XML PATH('')),1,1,'') FROM tb a GROUP BY id