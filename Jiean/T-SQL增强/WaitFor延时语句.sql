

--WaitFor ��ʱ���

--SQL2005��ǿ���ܣ����Կ��ƽű�ִ��ʱ��


--ָ��ʱ��ִ��
USE AdventureWorksDW2008R2
go

WAITFOR TIME '9:12'
PRINT GETDATE()
SELECT * FROM DimDate

--��ʱִ��
WAITFOR DELAY '00:00:10' --Delay��ʱ��಻�ܳ���24Сʱ
SELECT * FROM DimDate


--������ʱ

--һ���洢����Demo��������ʱʱ�䣬ִ���ڲ��ű�
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
		SELECT '�Ƿ�ʱ���'+@DelayTime
		RETURN;
	END
	DECLARE @curTime DATETIME
	SET @curTime =GETDATE()
	WAITFOR DELAY @DelayTime
	SELECT '�˽ű�����ʱ'+CAST(DATEDIFF(ss,@curTime,GETDATE()) AS VARCHAR)+'��ִ��'

END

EXEC Tsp_WaitFor_Delay '00:00:10'