	
/*
--���������б�-------------
����ָ����ݵĹ�����/��Ϣ���б�

*/
CREATE FUNCTION dbo.f_getdate(
@year int,    --Ҫ��ѯ�����
@bz bit       --@bz=0 ��ѯ������,@bz=1 ��ѯ��Ϣ��,@bz IS NULL ��ѯȫ������
)RETURNS @re TABLE(id int identity(1,1),Date datetime,Weekday nvarchar(3))
AS
BEGIN
    DECLARE @tb TABLE(ID int IDENTITY(0,1),Date datetime)
    INSERT INTO @tb(Date) SELECT TOP 366 DATEADD(Year,@YEAR-1900,'1900-1-1')
    FROM sysobjects a ,sysobjects b
    UPDATE @tb SET Date=DATEADD(DAY,id,Date)
    DELETE FROM @tb WHERE Date>DATEADD(Year,@YEAR-1900,'1900-12-31')
    
    IF @bz=0
        INSERT INTO @re(Date,Weekday)
        SELECT Date,DATENAME(Weekday,Date)
        FROM @tb
        WHERE (DATEPART(Weekday,Date)+@@DATEFIRST-1)%7 BETWEEN 1 AND 5
    ELSE IF @bz=1
        INSERT INTO @re(Date,Weekday)
        SELECT Date,DATENAME(Weekday,Date)
        FROM @tb
        WHERE (DATEPART(Weekday,Date)+@@DATEFIRST-1)%7 IN (0,6)
    ELSE
        INSERT INTO @re(Date,Weekday)
        SELECT Date,DATENAME(Weekday,Date)
        FROM @tb
        
    RETURN
END
GO