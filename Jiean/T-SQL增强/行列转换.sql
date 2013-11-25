
����ʵ��
SELECT * FROM student
--һ����ת��

--SQL SERVER 2000��̬SQL��

SELECT  [Name] ,
        MAX(CASE lesson
              WHEN '����' THEN score
              ELSE 0
            END) ���� ,
        MAX(CASE lesson
              WHEN '��ѧ' THEN score
              ELSE 0
            END) ��ѧ ,
        MAX(CASE lesson
              WHEN '����' THEN score
              ELSE 0
            END) ����
FROM    student
GROUP BY [Name]



--3��ʹ��SQL Server 2000��̬SQL

--SQL SERVER 2000��̬SQL,ָ�γ̲�ֹ���ġ���ѧ�����������ſγ̡�(����ͬ)

--������sql����˳��ֵ

DECLARE @sql VARCHAR(500)
SET @sql = 'select [Name]'
SELECT  @sql = @sql + ',max(case lesson when ''' + lesson
        + ''' then score else 0 end)[' + lesson + ']'
FROM    ( SELECT DISTINCT
                    lesson
          FROM      student
        ) a
 --ͬfrom tb group by�γ̣�Ĭ�ϰ��γ�������
SET @sql = @sql + ' from student group by [Name]'
EXEC(@sql)

 

--ʹ��isnull(),������ȷ����̬����

DECLARE @sql VARCHAR(8000)
SELECT  @sql = ISNULL(@sql + ',', '') + ' max(case lesson when ''' + lesson
        + ''' then score else 0 end) [' + lesson + ']'
FROM    ( SELECT DISTINCT
                    lesson
          FROM      student
        ) AS a      
SET @sql = 'select [Name],' + @sql + ' from student group by [Name]'
EXEC(@sql)

--4��ʹ��SQL Server 2005��̬SQL

SELECT * FROM student pivot(max(score) FOR lesson in(����,��ѧ,����))a

 

--5��ʹ��SQL Server 2005��̬SQL

/*ʹ��stuff()
STUFF �������ַ���������һ�ַ��������ڵ�һ���ַ����дӿ�ʼλ��ɾ��ָ�����ȵ��ַ���
Ȼ�󽫵ڶ����ַ��������һ���ַ����Ŀ�ʼλ�á�*/

DECLARE @sql VARCHAR(8000)
SET @sql = ''--��ʼ������@sql

SELECT  @sql = @sql + ',' + lesson
FROM    student
GROUP BY lesson--������ֵ��ֵ

SET @sql = STUFF(@sql, 1, 1, '')--ȥ���׸�','
SET @sql = 'select * from student pivot(max(score) for lesson in (' + @sql
    + ')) a'
EXEC(@sql)

 

--��ʹ��isnull()

DECLARE @sql VARCHAR(8000)

--��ÿγ̼���

SELECT  @sql = ISNULL(@sql + ',', '') + lesson
FROM    student
GROUP BY lesson           

SET @sql = 'select * from student pivot(max(score) for lesson in (' + @sql
    + ')) a'

EXEC(@sql)

 

--������ת�н�������ܷ֡�ƽ����

--1��ʹ��SQL Server 2000��̬SQL
SELECT  [Name] ,
        MAX(CASE lesson
              WHEN '����' THEN score
              ELSE 0
            END) ���� ,
        MAX(CASE lesson
              WHEN '��ѧ' THEN score
              ELSE 0
            END) ��ѧ ,
        MAX(CASE lesson
              WHEN '����' THEN score
              ELSE 0
            END) ���� ,
        SUM(score) �ܷ� ,
        CAST(AVG(score * 1.0) AS DECIMAL(18, 2)) ƽ����
FROM    student
GROUP BY [Name]



--2��ʹ��SQL Server 2000��̬SQL

--SQL SERVER 2000��̬SQL

DECLARE @sql VARCHAR(500)

SET @sql = 'select [Name]'

SELECT  @sql = @sql + ',max(case lesson when ''' + lesson
        + ''' then score else 0 end)[' + lesson + ']'
FROM    ( SELECT DISTINCT
                    lesson
          FROM      student
        ) a

SET @sql = @sql
    + ',sum(score) �ܷ�,cast(avg(score*1.0) as decimal(18,2)) ƽ���� from student group by [Name]'

EXEC(@sql)

 

--3��ʹ��SQL Server 2005��̬SQL

SELECT  m.* ,
        n.�ܷ� ,
        n.ƽ����
FROM    ( SELECT    *
          FROM      student PIVOT( MAX(score) FOR lesson IN ( ����, ��ѧ, ���� ) ) a
        ) m ,
        ( SELECT    [name] ,
                    SUM(score) �ܷ� ,
                    CAST(AVG(score * 1.0) AS DECIMAL(18, 2)) ƽ����
          FROM      student
          GROUP BY  [name]
        ) n
WHERE   m.[name] = n.[name]

 

--4��ʹ��SQL Server 2005��̬SQL

--ʹ��stuff()
DECLARE @sql VARCHAR(8000)

SET @sql = ''
  --��ʼ������@sql

SELECT  @sql = @sql + ',' + lesson
FROM    student
GROUP BY lesson
--������ֵ��ֵ

--ͬselect @sql = @sql + ','+�γ� from (select distinct�γ�from student)a

SET @sql = STUFF(@sql, 1, 1, '')
--ȥ���׸�','

SET @sql = 'select m.* , n.�ܷ�,n.ƽ���� from

(select * from (select * from student) a pivot(max(score) for lesson in ('
    + @sql
    + ')) b) m ,

(select [Name],sum(score) �ܷ�, cast(avg(score*1.0) as decimal(18,2)) ƽ���� from student group by [Name]) n

where m.[Name]= n.[Name]'

EXEC(@sql)

 

--��ʹ��isnull()

DECLARE @sql VARCHAR(8000)

SELECT  @sql = ISNULL(@sql + ',', '') + lesson
FROM    student
GROUP BY lesson

SET @sql = 'select m.* , n.�ܷ�,n.ƽ���� from

(select * from (select * from student) a pivot (max(score) for lesson in ('
    + @sql
    + ')) b) m ,

(select [Name],sum(score) �ܷ�, cast(avg(score*1.0) as decimal(18,2)) ƽ���� from student group by [Name]) n

where m.[Name]= n.[Name]'

EXEC(@sql)

 

--������ת��

SELECT * FROM studentCOl
 

--2��ʹ��SQL Server 2000��̬SQL

SELECT  *
FROM    ( SELECT    [Name] ,
                    lesson = '����' ,
                    score = chinese
          FROM      studentCOl
          UNION ALL
          SELECT    [Name] ,
                    lesson = '��ѧ' ,
                    score = math
          FROM      studentCOl
          UNION ALL
          SELECT    [Name] ,
                    lesson = '����' ,
                    score = physics
          FROM      studentCOl
        ) t
ORDER BY [Name] ,
        CASE lesson
          WHEN '����' THEN 1
          WHEN '��ѧ' THEN 2
          WHEN '����' THEN 3
        END

--2��ʹ��SQL Server 2000��̬SQL

--����ϵͳ��̬���ɡ�

DECLARE @sql VARCHAR(8000)

SELECT  @sql = ISNULL(@sql + ' union all ', '') + ' select [Name], [lesson]='
        + QUOTENAME(Name, '''') + ' , [score] = ' + QUOTENAME(Name)
        + ' from studentCOl'
FROM    syscolumns
WHERE   Name != 'Name'
        AND ID = OBJECT_ID('studentCOl')--����tb������������Ϊ������������
ORDER BY colid

EXEC(@sql+' order by [Name]')

go

 

--3��ʹ��SQL Server 2005��̬SQL

SELECT [Name],lesson,score FROM studentCOl unpivot(score FOR lesson in(chinese,math,physics)) t

 

--4��ʹ��SQL Server 2005��̬SQL


DECLARE @sql NVARCHAR(4000)

SELECT  @sql = ISNULL(@sql + ',', '') + QUOTENAME(Name)
FROM    syscolumns
WHERE   ID = OBJECT_ID('studentCOl')
        AND Name NOT IN ( 'name' )
ORDER BY Colid

SET @sql = 'select [Name],lesson,score from studentCOl unpivot ([score] for [lesson] in('
    + @sql + '))b'

EXEC(@sql)