

--Identity����
/*
��������Ū���Ʒ�ʽ�������Ͳ�����
��������ȷ�������ּ������ţ�����Ҫ����ʱ������������Դ����������ɺ���ͷ�������
*/

IF OBJECT_ID('dbo.Sequence') IS NOT NULL DROP TABLE dbo.Sequence;
CREATE TABLE dbo.Sequence(val INT);
GO
INSERT INTO dbo.Sequence VALUES(0);
GO
IF OBJECT_ID('dbo.GetSequence') IS NOT NULL
  DROP PROC dbo.GetSequence;
GO

--ȡ��Ŵ洢����
CREATE PROC dbo.GetSequence
  @val AS INT OUTPUT
AS
UPDATE dbo.Sequence
  SET @val = val = val + 1; --����һ��ԭ�Ӳ�����@val��valͬʱ��val+1����
GO

--ȡ���
DECLARE @key AS INT;
EXEC dbo.GetSequence @val = @key OUTPUT;
SELECT @key;

-- ����
UPDATE dbo.Sequence SET val = 0;
GO


--һ�η��ض�����
ALTER PROC dbo.GetSequence
  @val AS INT OUTPUT,
  @n   AS INT = 1
AS
UPDATE dbo.Sequence
  SET @val = val = val + @n; --���µ����ֵ

SET @val = @val - @n + 1; --���ص�һ��ֵ
GO

DECLARE @firstkey AS INT, @rc AS INT;

IF OBJECT_ID('tempdb..#CustsStage') IS NOT NULL DROP TABLE #CustsStage;

SELECT custid, ROW_NUMBER() OVER(ORDER BY (SELECT 0)) AS rownum
INTO #CustsStage 
FROM Performance.dbo.Customers
WHERE custname = N'Cust_1';

SET @rc = @@rowcount;
EXEC dbo.GetSequence @val = @firstkey OUTPUT, @n = @rc;

SELECT custid, @firstkey + rownum - 1 AS keycol
FROM #CustsStage;
GO


-----���������------------------------------------
/*
���������Խ��һ���Ĳ������⣬���п��ܻ���ּ����
������ֻ�ڵ�������ֵʱ����Ƭ�ã���ֹ������̻����ͬ��ֵ����������������ڼ䱻������
*/

IF OBJECT_ID('dbo.Sequence') IS NOT NULL DROP TABLE dbo.Sequence;
CREATE TABLE dbo.Sequence(val INT IDENTITY);
GO


IF OBJECT_ID('dbo.GetSequence') IS NOT NULL
  DROP PROC dbo.GetSequence;
GO

CREATE PROC dbo.GetSequence
  @val AS INT OUTPUT
AS
BEGIN TRAN
  SAVE TRAN S1; --������ֻΪ����һ������㣬
  INSERT INTO dbo.Sequence DEFAULT VALUES;
  SET @val = SCOPE_IDENTITY();
  ROLLBACK TRAN S1;--�ع����᳷���Ա����ĸ�ֵ��Ҳ���᳷����ʶֵ�ĵ�����
COMMIT TRAN--��ʶ��Դ�������ⲿ����� ���ڼ䱻����������ֻ�ڵ���ʱ����Ƭ�á�
GO

--ȡ�����
DECLARE @key AS INT;
EXEC dbo.GetSequence @val = @key OUTPUT;
SELECT @key;

-- ����
TRUNCATE TABLE dbo.Sequence;
GO

/*
ע��Ҳ���Բ������������������ŵĲ�����������Ҫ����
*/