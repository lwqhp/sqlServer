if object_id('[ta]') is not null drop table [ta]
go   
create table [ta](id int, ���ʽ varchar(3),������ nvarchar(10))
insert [ta]
select 1 ,'001', '�ֽ�' union all
select 2 ,'002', '���п�' union all
select 2 ,'003', '֧Ʊ'
go
 
if object_id('[tb]') is not null drop table [tb]
go   
create table [tb](id int,�̼� varchar(4), ���ʽ varchar(3),������ int)
insert [tb]
select 1 ,'1001','001', '100' union all
select 2 ,'1001','002', '200' union all
select 3 ,'1001','003', '300' union all
select 4 ,'1002','001', '150' union all
select 5 ,'1002','003', '250'
go
 
declare @sql varchar(8000)
set @sql = ''
select @sql = @sql + ' , max(case b.���ʽ when ''' + ���ʽ + ''' then b.������ else 0 end) [' + ������ + ']'
from ta
set @sql = 'select right(b.�̼�,1)id,b.�̼�,sum(b.������)�ܽ��'+@sql + ' from tb b join ta a on a.���ʽ=b.���ʽ group by right(b.�̼�,1),�̼�'
exec(@sql) 
 
--���
/*
id   �̼�   �ܽ��         �ֽ�          ���п�         ֧Ʊ          
---- ---- ----------- ----------- ----------- ----------- 
1    1001 600         100         200         300
2    1002 400         150         0           250
 
����Ӱ�������Ϊ 2 �У�*/


-------------------------------------------------------------------------------------
if object_id('tb1') is not null drop table tb1
go
CREATE table tb1 --���ݱ�
(
cpici varchar(10) not null,
cname varchar(10) not null,
cvalue int null 
)
--�����������
INSERT INTO tb1 values('T501','x1',31)
INSERT INTO tb1 values('T501','x1',33)
INSERT INTO tb1 values('T501','x1',5)
 
INSERT INTO tb1 values('T502','x1',3)
INSERT INTO tb1 values('T502','x1',22)
INSERT INTO tb1 values('T502','x1',3)
 
INSERT INTO tb1 values('T503','x1',53)
INSERT INTO tb1 values('T503','x1',44)
INSERT INTO tb1 values('T503','x1',50)
INSERT INTO tb1 values('T503','x1',23)
 
 SELECT * FROM tb1
--��sqlserver2000����Ҫ����������
alter table tb1 add id int identity
go
declare @s varchar(8000)
set @s='select cpici '
select @s=@s+',max(case when rn='+ltrim(rn)+' then cvalue end) as cvlue'+ltrim(rn)
from (select distinct rn from (select rn=(select count(1) from tb1 where cpici=t.cpici and id<=t.id) from tb1 t)a)t
set @s=@s+' from (select rn=(select count(1) from tb1 where cpici=t.cpici and id<=t.id),* from tb1 t
) t group by cpici'
 
exec(@s)
go
alter table tb1 drop column id 
 
--��2005�Ϳ�����row_number
declare @s varchar(8000)
set @s='select cpici '
select @s=@s+',max(case when rn='+ltrim(rn)+' then cvalue end) as cvlue'+ltrim(rn)
from (select distinct rn from (select rn=row_number()over(partition by cpici order by getdate()) from tb1)a)t
set @s=@s+' from (select rn=row_number()over(partition by cpici order by getdate()),* from tb1
) t group by cpici'
 PRINT @s
exec(@s)

 SELECT cpici ,
        MAX(CASE WHEN rn = 1 THEN cvalue
            END) AS cvlue1 ,
        MAX(CASE WHEN rn = 2 THEN cvalue
            END) AS cvlue2 ,
        MAX(CASE WHEN rn = 3 THEN cvalue
            END) AS cvlue3 ,
        MAX(CASE WHEN rn = 4 THEN cvalue
            END) AS cvlue4
 FROM   ( SELECT    rn = ROW_NUMBER() OVER ( PARTITION BY cpici ORDER BY GETDATE() ) ,
                    *
          FROM      tb1
        ) t
 GROUP BY cpici
---���
/*
cpici      cvlue1      cvlue2      cvlue3      cvlue4
---------- ----------- ----------- ----------- -----------
T501       31          33          5           NULL
T502       3           22          3           NULL
T503       53          44          50          23
����: �ۺϻ����� SET ���������˿�ֵ��
 
(3 ����Ӱ��)
 
*/