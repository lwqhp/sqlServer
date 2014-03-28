-- ͼ���������ݱ�

CREATE TABLE tb(
	Books nvarchar(30), -- ����
	Date datetime,      -- ��������
	Sales int           -- ��������
)
-- ���ɲ�������(�����������)
INSERT tb
SELECT 
	char(65 + ABS(CHECKSUM(NEWID())) % 26),
	DATEADD(Day, 1 - ABS(CHECKSUM(NEWID())) % 500, GETDATE()),
	ABS(CHECKSUM(NEWID()) % 360) + 1
FROM dbo.sysobjects A, dbo.sysobjects B
--��ʾ����
SELECT * FROM tb
GO

--���а���Ĵ洢����
CREATE PROC dbo.p_Qry
	@Type  nchar(1) = N'��',  -- ���а�������(�ա��ܡ��¡�������)
	@Date  datetime = NULL,   -- ���а�����, ��ָ��Ϊ��ǰ����
	@TopN int = 10            -- ��ʾ�ļ�¼��
AS
SET NOCOUNT ON
DECLARE
	@date_begin_previous datetime,
	@date_begin datetime

-- �������
IF CHARINDEX(@Type, N'�����¼���') = 0
	SET @Type = N'��'

-- ȥ�������е�ʱ�䲿��
SET @Date = DATEDIFF(Day, 0, ISNULL(@Date, GETDATE()))

IF ISNULL(@TopN, 0) < 1
	SET @TopN = 10

-- ���� @Type �����������ʼ����
IF @Type = N'��'
	SELECT
		@date_begin = @Date,
		@Date = DATEADD(Day, 1, @Date),
		@date_begin_previous = DATEADD(Day, -1, @date_begin)
ELSE IF @Type = N'��'
	SELECT
		-- ��ѯ���������ܵĵ�һ��
		@date_begin = DATEADD(Day, - (DATEPART(Weekday, @Date) + @@DATEFIRST - 2) % 7, @Date),
		@Date = DATEADD(Week, 1, @date_begin),
		@date_begin_previous = DATEADD(Week, - 1, @date_begin)
ELSE IF @Type = N'��'
	SELECT 
		-- ��ѯ���������µĵ�һ��
		@date_begin = CONVERT(char(6), @Date, 112) + '01',
		@Date = DATEADD(Month, 1, @date_begin),
		@date_begin_previous = DATEADD(Month, -1, @date_begin)
ELSE IF @Type = N'��'
	SELECT 
		-- ��ѯ�������ڼ��ĵ�һ��
		@date_begin = CONVERT(char(6),
						DATEADD(Month, DATEPART(Quarter, @Date) * 3 - Month(@Date) - 2, @Date),
						112) + '01',
		@Date = DATEADD(Month, 3, @date_begin),
		@date_begin_previous = DATEADD(Month, -3, @date_begin)
ELSE
	SELECT 
		@date_begin = CONVERT(char(4), @Date,112) + '0101',
		@Date = DATEADD(Year, 1, @date_begin),
		@date_begin_previous = DATEADD(Year, -1, @date_begin)

SELECT
	@Date, @date_begin, @date_begin_previous

-- ȡ�������ݵ���ʱ��
SET ROWCOUNT @TopN
-- a. ������������
SELECT
	Books,
	Sales_Amount = SUM(Sales)
INTO #1
FROM tb
WHERE Date >= @date_begin
	AND Date < @Date
GROUP BY Books
ORDER BY Sales_Amount DESC

-- b. ������������
SELECT
	Books,
	Sales_Amount = SUM(Sales)
INTO #2
FROM tb
WHERE Date >= @date_begin_previous
	AND Date < @date_begin
GROUP BY Books
ORDER BY Sales_Amount DESC

-- c. ��ʾ���
SELECT 
	A.Books,
	A.Sales_Amount,
	A.Place,
	Description = CASE 
					WHEN B.Books IS NULL THEN N'�����ϰ�'
					WHEN A.Place = B.Place THEN N'��'
					WHEN A.Place > B.Place THEN N'��' + RTRIM(A.Place - B.Place) + N'λ'
					ELSE N'��' + RTRIM(B.Place - A.Place) + N'λ'
				END,
	Sales_Amount_previous = B.Sales_Amount,
	Place_previous = B.Place
FROM(
	SELECT
		Books,
		Sales_Amount,
		Place = 1 + (
					SELECT
						COUNT(Sales_Amount)
					FROM #1
					WHERE Sales_Amount > AA.Sales_Amount)
	FROM #1 AA
)A
	LEFT JOIN(
		SELECT
			Books,
			Sales_Amount,
			Place = 1 + (
						SELECT
							COUNT(Sales_Amount)
						FROM #2
						WHERE Sales_Amount > BB.Sales_Amount)
		FROM #2 BB
	)B
		ON A.Books = B.Books
ORDER BY A.Place
GO

-- ����ʾ��
EXEC dbo.p_Qry N'��'
EXEC dbo.p_Qry N'��'
EXEC dbo.p_Qry N'��'
EXEC dbo.p_Qry N'��'
EXEC dbo.p_Qry N'��'
GO

-- ɾ�����Ի���
DROP PROC dbo.p_Qry
DROP TABLE tb