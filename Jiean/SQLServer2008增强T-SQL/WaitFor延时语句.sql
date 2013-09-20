

--WaitFor 延时语句

--SQL2005增强功能，可以控制脚本执行时间


--指定时间执行
USE AdventureWorksDW2008R2
go

WAITFOR TIME '9:12'
PRINT GETDATE()
SELECT * FROM DimDate

--延时执行
WAITFOR DELAY '00:00:10' --Delay延时最多不能超过24小时
SELECT * FROM DimDate


--参数延时

--一个存储过程Demo，传入延时时间，执行内部脚本
USE AdventureWorksDW2008R2
go

IF object_id('dbo.Tsp_WaitFor_Delay','P') IS NOT NULL DROP PROC dbo.Tsp_WaitFor_Delay
go
create PROC dbo.Tsp_WaitFor_Delay(
	@DelayTime CHAR(8)
)
AS
begin 
	IF ISDATE(@DelayTime)=0
	BEGIN
		SELECT '非法时间段'+@DelayTime
		RETURN;
	END
	DECLARE @curTime DATETIME
	SET @curTime =GETDATE()
	WAITFOR DELAY @DelayTime
	SELECT '此脚本已延时'+CAST(DATEDIFF(ss,@curTime,GETDATE()) AS VARCHAR)+'秒执行'

END

EXEC Tsp_WaitFor_Delay '00:00:10'