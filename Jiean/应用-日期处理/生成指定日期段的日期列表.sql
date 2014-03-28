/*
--生成列表-----------
    生成指定日期段的日期列表
*/

CREATE FUNCTION dbo.f_getdate(
@begin_date Datetime,  --要查询的开始日期
@end_date Datetime,    --要查询的结束日期
@bz bit                --@bz=0 查询工作日,@bz=1 查询休息日,@bz IS NULL 查询全部日期
)RETURNS @re TABLE(id int identity(1,1),Date datetime,Weekday nvarchar(3))
AS
BEGIN
    DECLARE @tb TABLE(ID int IDENTITY(0,1),a bit)
    INSERT INTO @tb(a) SELECT TOP 366 0
    FROM sysobjects a ,sysobjects b
    
    IF @bz=0
        WHILE @begin_date<=@end_date
        BEGIN
            INSERT INTO @re(Date,Weekday)
            SELECT Date,DATENAME(Weekday,Date)
            FROM(
                SELECT Date=DATEADD(Day,ID,@begin_date)
                FROM @tb                
            )a WHERE Date<=@end_date
                AND (DATEPART(Weekday,Date)+@@DATEFIRST-1)%7 BETWEEN 1 AND 5
            SET @begin_date=DATEADD(Day,366,@begin_date)
        END
    ELSE IF @bz=1
        WHILE @begin_date<=@end_date
        BEGIN
            INSERT INTO @re(Date,Weekday)
            SELECT Date,DATENAME(Weekday,Date)
            FROM(
                SELECT Date=DATEADD(Day,ID,@begin_date)
                FROM @tb                
            )a WHERE Date<=@end_date
                AND (DATEPART(Weekday,Date)+@@DATEFIRST-1)%7 in(0,6)
            SET @begin_date=DATEADD(Day,366,@begin_date)
        END
    ELSE
        WHILE @begin_date<=@end_date
        BEGIN
            INSERT INTO @re(Date,Weekday)
            SELECT Date,DATENAME(Weekday,Date)
            FROM(
                SELECT Date=DATEADD(Day,ID,@begin_date)
                FROM @tb                
            )a WHERE Date<=@end_date
            SET @begin_date=DATEADD(Day,366,@begin_date)
        END
    RETURN
END
GO
