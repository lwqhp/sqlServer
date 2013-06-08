
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
	单表查询手段
	1,加自增ID
	
	*/

--2000
SELECT *,indexID = IDENTITY(INT,1,1) INTO # FROM Sys_Index
--2005
SELECT *,ROW_NUMBER() OVER(ORDER BY name) AS indexID FROM Sys_Index
--查询去掉重复数据 
SELECT DISTINCT * FROM dbo.Sys_BillType

/*单表中常见的一些数据格式*/

--a,列有相同的数据值

/*分组--把相同列值分组，可以进行组内运算--计算重复出现次数，取分组内最小值，最大值，平均值等运算
	
*/
select * from vitae a
where (a.peopleId,a.seq) in (select peopleId,seq from vitae group by peopleId,seq having count(*) > 1)
and rowid not in (select min(rowid) from vitae group by peopleId,seq having count(*)>1)

/*
	在相同数据列中进行再匹配
*/
select a.* from tb a where val = (select max(val) from tb where name = a.name) order by a.NAME
select a.* from tb a where not exists(select 1 from tb where name = a.name and val > a.val)
select a.* from tb a where 1 > (select count(*) from tb where name = a.name and val > a.val ) order by a.NAME
--分组取第一次出现的行所在的数据
select a.* from tb a where val = (select top 1 val from tb where name = a.name) order by a.NAME
--分组随机取一条数据
select a.* from tb a where val = (select top 1 val from tb where name = a.name order by newid()) order by a.name
select a.* from tb a inner join (select name , max(val) val from tb group by name) b on a.name = b.name and a.val = b.val order by a.name

--五、按name分组取最小的两个(N个)val

select a.* from tb a where 2 > (select count(*) from tb where name = a.name and val < a.val ) order by a.name,a.val

select a.* from tb a where val in (select top 2 val from tb where name=a.name order by val) order by a.name,a.val

select a.* from tb a where exists (select count(*) from tb where name = a.name and val < a.val having Count(*) < 2) order by a.name,a.val


--六、按name分组取最大的两个(N个)val

select a.* from tb a where 2 > (select count(*) from tb where name = a.name and val > a.val ) order by a.name,a.val

select a.* from tb a where val in (select top 2 val from tb where name=a.name order by val desc) order by a.name,a.val

select a.* from tb a where exists (select count(*) from tb where name = a.name and val > a.val having Count(*) < 2) order by a.name , a.val


 
--七，如果整行数据有重复，所有的列都相同。
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

 