/*
--�����б�-----------
    ����ָ�����ڶε������б�
*/

CREATE FUNCTION dbo.f_getdate(
@begin_date Datetime,  --Ҫ��ѯ�Ŀ�ʼ����
@end_date Datetime,    --Ҫ��ѯ�Ľ�������
@bz bit                --@bz=0 ��ѯ������,@bz=1 ��ѯ��Ϣ��,@bz IS NULL ��ѯȫ������
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
