
典型实例
SELECT * FROM student
--一、行转列

--SQL SERVER 2000静态SQL。

SELECT  [Name] ,
        MAX(CASE lesson
              WHEN '语文' THEN score
              ELSE 0
            END) 语文 ,
        MAX(CASE lesson
              WHEN '数学' THEN score
              ELSE 0
            END) 数学 ,
        MAX(CASE lesson
              WHEN '物理' THEN score
              ELSE 0
            END) 物理
FROM    student
GROUP BY [Name]



--3、使用SQL Server 2000动态SQL

--SQL SERVER 2000动态SQL,指课程不止语文、数学、物理这三门课程。(以下同)

--变量按sql语言顺序赋值

DECLARE @sql VARCHAR(500)
SET @sql = 'select [Name]'
SELECT  @sql = @sql + ',max(case lesson when ''' + lesson
        + ''' then score else 0 end)[' + lesson + ']'
FROM    ( SELECT DISTINCT
                    lesson
          FROM      student
        ) a
 --同from tb group by课程，默认按课程名排序
SET @sql = @sql + ' from student group by [Name]'
EXEC(@sql)

 

--使用isnull(),变量先确定动态部分

DECLARE @sql VARCHAR(8000)
SELECT  @sql = ISNULL(@sql + ',', '') + ' max(case lesson when ''' + lesson
        + ''' then score else 0 end) [' + lesson + ']'
FROM    ( SELECT DISTINCT
                    lesson
          FROM      student
        ) AS a      
SET @sql = 'select [Name],' + @sql + ' from student group by [Name]'
EXEC(@sql)

--4、使用SQL Server 2005静态SQL

SELECT * FROM student pivot(max(score) FOR lesson in(语文,数学,物理))a

 

--5、使用SQL Server 2005动态SQL

/*使用stuff()
STUFF 函数将字符串插入另一字符串。它在第一个字符串中从开始位置删除指定长度的字符；
然后将第二个字符串插入第一个字符串的开始位置。*/

DECLARE @sql VARCHAR(8000)
SET @sql = ''--初始化变量@sql

SELECT  @sql = @sql + ',' + lesson
FROM    student
GROUP BY lesson--变量多值赋值

SET @sql = STUFF(@sql, 1, 1, '')--去掉首个','
SET @sql = 'select * from student pivot(max(score) for lesson in (' + @sql
    + ')) a'
EXEC(@sql)

 

--或使用isnull()

DECLARE @sql VARCHAR(8000)

--获得课程集合

SELECT  @sql = ISNULL(@sql + ',', '') + lesson
FROM    student
GROUP BY lesson           

SET @sql = 'select * from student pivot(max(score) for lesson in (' + @sql
    + ')) a'

EXEC(@sql)

 

--二、行转列结果加上总分、平均分

--1、使用SQL Server 2000静态SQL
SELECT  [Name] ,
        MAX(CASE lesson
              WHEN '语文' THEN score
              ELSE 0
            END) 语文 ,
        MAX(CASE lesson
              WHEN '数学' THEN score
              ELSE 0
            END) 数学 ,
        MAX(CASE lesson
              WHEN '物理' THEN score
              ELSE 0
            END) 物理 ,
        SUM(score) 总分 ,
        CAST(AVG(score * 1.0) AS DECIMAL(18, 2)) 平均分
FROM    student
GROUP BY [Name]



--2、使用SQL Server 2000动态SQL

--SQL SERVER 2000动态SQL

DECLARE @sql VARCHAR(500)

SET @sql = 'select [Name]'

SELECT  @sql = @sql + ',max(case lesson when ''' + lesson
        + ''' then score else 0 end)[' + lesson + ']'
FROM    ( SELECT DISTINCT
                    lesson
          FROM      student
        ) a

SET @sql = @sql
    + ',sum(score) 总分,cast(avg(score*1.0) as decimal(18,2)) 平均分 from student group by [Name]'

EXEC(@sql)

 

--3、使用SQL Server 2005静态SQL

SELECT  m.* ,
        n.总分 ,
        n.平均分
FROM    ( SELECT    *
          FROM      student PIVOT( MAX(score) FOR lesson IN ( 语文, 数学, 物理 ) ) a
        ) m ,
        ( SELECT    [name] ,
                    SUM(score) 总分 ,
                    CAST(AVG(score * 1.0) AS DECIMAL(18, 2)) 平均分
          FROM      student
          GROUP BY  [name]
        ) n
WHERE   m.[name] = n.[name]

 

--4、使用SQL Server 2005动态SQL

--使用stuff()
DECLARE @sql VARCHAR(8000)

SET @sql = ''
  --初始化变量@sql

SELECT  @sql = @sql + ',' + lesson
FROM    student
GROUP BY lesson
--变量多值赋值

--同select @sql = @sql + ','+课程 from (select distinct课程from student)a

SET @sql = STUFF(@sql, 1, 1, '')
--去掉首个','

SET @sql = 'select m.* , n.总分,n.平均分 from

(select * from (select * from student) a pivot(max(score) for lesson in ('
    + @sql
    + ')) b) m ,

(select [Name],sum(score) 总分, cast(avg(score*1.0) as decimal(18,2)) 平均分 from student group by [Name]) n

where m.[Name]= n.[Name]'

EXEC(@sql)

 

--或使用isnull()

DECLARE @sql VARCHAR(8000)

SELECT  @sql = ISNULL(@sql + ',', '') + lesson
FROM    student
GROUP BY lesson

SET @sql = 'select m.* , n.总分,n.平均分 from

(select * from (select * from student) a pivot (max(score) for lesson in ('
    + @sql
    + ')) b) m ,

(select [Name],sum(score) 总分, cast(avg(score*1.0) as decimal(18,2)) 平均分 from student group by [Name]) n

where m.[Name]= n.[Name]'

EXEC(@sql)

 

--二、列转行

SELECT * FROM studentCOl
 

--2、使用SQL Server 2000静态SQL

SELECT  *
FROM    ( SELECT    [Name] ,
                    lesson = '语文' ,
                    score = chinese
          FROM      studentCOl
          UNION ALL
          SELECT    [Name] ,
                    lesson = '数学' ,
                    score = math
          FROM      studentCOl
          UNION ALL
          SELECT    [Name] ,
                    lesson = '物理' ,
                    score = physics
          FROM      studentCOl
        ) t
ORDER BY [Name] ,
        CASE lesson
          WHEN '语文' THEN 1
          WHEN '数学' THEN 2
          WHEN '物理' THEN 3
        END

--2、使用SQL Server 2000动态SQL

--调用系统表动态生成。

DECLARE @sql VARCHAR(8000)

SELECT  @sql = ISNULL(@sql + ' union all ', '') + ' select [Name], [lesson]='
        + QUOTENAME(Name, '''') + ' , [score] = ' + QUOTENAME(Name)
        + ' from studentCOl'
FROM    syscolumns
WHERE   Name != 'Name'
        AND ID = OBJECT_ID('studentCOl')--表名tb，不包含列名为姓名的其他列
ORDER BY colid

EXEC(@sql+' order by [Name]')

go

 

--3、使用SQL Server 2005静态SQL

SELECT [Name],lesson,score FROM studentCOl unpivot(score FOR lesson in(chinese,math,physics)) t

 

--4、使用SQL Server 2005动态SQL


DECLARE @sql NVARCHAR(4000)

SELECT  @sql = ISNULL(@sql + ',', '') + QUOTENAME(Name)
FROM    syscolumns
WHERE   ID = OBJECT_ID('studentCOl')
        AND Name NOT IN ( 'name' )
ORDER BY Colid

SET @sql = 'select [Name],lesson,score from studentCOl unpivot ([score] for [lesson] in('
    + @sql + '))b'

EXEC(@sql)