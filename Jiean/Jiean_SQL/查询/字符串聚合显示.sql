
--SQL2000用函数:
go
IF OBJECT_ID('F_Str') IS NOT NULL 
    DROP FUNCTION F_Str
go
CREATE FUNCTION F_Str ( @Col1 INT )
RETURNS NVARCHAR(100)
AS 
    BEGIN
        DECLARE @S NVARCHAR(100)
        SELECT  @S = ISNULL(@S + ',', '') + Col2
        FROM    Tab
        WHERE   Col1 = @Col1
        RETURN @S
    END
go
SELECT DISTINCT
        Col1 ,
        Col2 = dbo.F_Str(Col1)
FROM    Tab
Go

--方法2:
--SQL2005用XML:
SELECT  a.Col1 ,
        Col2 = STUFF(b.Col2.value('/R[1]', 'nvarchar(max)'), 1, 1, '')
FROM    ( SELECT DISTINCT
                    COl1
          FROM      Tab
        ) a
        CROSS APPLY ( SELECT    COl2 = ( SELECT N',' + Col2
                                         FROM   Tab
                                         WHERE  Col1 = a.COl1
                                       FOR
                                         XML PATH('') ,
                                             ROOT('R') ,
                                             TYPE
                                       )
                    ) b

--方法3:
--SQL2005用CTE:
;
WITH    roy
          AS ( SELECT   Col1 ,
                        Col2 ,
                        row = row_number() OVER ( PARTITION BY COl1 ORDER BY COl1 )
               FROM     Tab
             ),
        Roy2
          AS ( SELECT   COl1 ,
                        CAST(COl2 AS NVARCHAR(100)) COl2 ,
                        row
               FROM     Roy
               WHERE    row = 1
               UNION ALL
               SELECT   a.Col1 ,
                        CAST(b.COl2 + ',' + a.COl2 AS NVARCHAR(100)) ,
                        a.row
               FROM     Roy a
                        JOIN Roy2 b ON a.COl1 = b.COl1
                                       AND a.row = b.row + 1
             )
    SELECT  Col1 ,
            Col2
    FROM    Roy2 a
    WHERE   row = ( SELECT  MAX(row)
                    FROM    roy
                    WHERE   Col1 = a.COl1
                  )
    ORDER BY Col1
OPTION  ( MAXRECURSION 0 )
