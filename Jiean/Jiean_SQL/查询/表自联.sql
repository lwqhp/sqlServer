
--
CREATE TABLE Sys_Index(NAME VARCHAR(20))
INSERT INTO Sys_Index
SELECT 'a' UNION ALL
SELECT 'b' UNION ALL
SELECT 'c' UNION ALL
SELECT 'd' UNION ALL
SELECT 'e' 
SELECT * FROM Sys_Index

/*
	�����ѯ�ֶ�
	1,������ID
	
	*/

--2000
SELECT *,indexID = IDENTITY(INT,1,1) INTO # FROM Sys_Index
--2005
SELECT *,ROW_NUMBER() OVER(ORDER BY name) AS indexID FROM Sys_Index
--��ѯȥ���ظ����� 
SELECT DISTINCT * FROM dbo.Sys_BillType

/*�����г�����һЩ���ݸ�ʽ*/

--a,������ͬ������ֵ

/*����--����ͬ��ֵ���飬���Խ�����������--�����ظ����ִ�����ȡ��������Сֵ�����ֵ��ƽ��ֵ������
	
*/
select * from vitae a
where (a.peopleId,a.seq) in (select peopleId,seq from vitae group by peopleId,seq having count(*) > 1)
and rowid not in (select min(rowid) from vitae group by peopleId,seq having count(*)>1)

/*
	����ͬ�������н�����ƥ��
*/
select a.* from tb a where val = (select max(val) from tb where name = a.name) order by a.NAME
select a.* from tb a where not exists(select 1 from tb where name = a.name and val > a.val)
select a.* from tb a where 1 > (select count(*) from tb where name = a.name and val > a.val ) order by a.NAME
--����ȡ��һ�γ��ֵ������ڵ�����
select a.* from tb a where val = (select top 1 val from tb where name = a.name) order by a.NAME
--�������ȡһ������
select a.* from tb a where val = (select top 1 val from tb where name = a.name order by newid()) order by a.name
select a.* from tb a inner join (select name , max(val) val from tb group by name) b on a.name = b.name and a.val = b.val order by a.name

--�塢��name����ȡ��С������(N��)val

select a.* from tb a where 2 > (select count(*) from tb where name = a.name and val < a.val ) order by a.name,a.val

select a.* from tb a where val in (select top 2 val from tb where name=a.name order by val) order by a.name,a.val

select a.* from tb a where exists (select count(*) from tb where name = a.name and val < a.val having Count(*) < 2) order by a.name,a.val


--������name����ȡ��������(N��)val

select a.* from tb a where 2 > (select count(*) from tb where name = a.name and val > a.val ) order by a.name,a.val

select a.* from tb a where val in (select top 2 val from tb where name=a.name order by val desc) order by a.name,a.val

select a.* from tb a where exists (select count(*) from tb where name = a.name and val > a.val having Count(*) < 2) order by a.name , a.val


 
--�ߣ���������������ظ������е��ж���ͬ��
SELECT  m.name ,
        m.val ,
        m.memo
FROM    ( SELECT    * ,
                    px = row_number() OVER ( ORDER BY name , val )
          FROM      tb
        ) m
WHERE   px = ( SELECT   MIN(px)
               FROM     ( SELECT    * ,
                                    px = row_number() OVER ( ORDER BY name , val )
                          FROM      tb
                        ) n
               WHERE    n.name = m.name
             )

 