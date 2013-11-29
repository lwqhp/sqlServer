-- ��Ա����
CREATE TABLE Employee(
	ID int              -- ��Ա���(����)
		PRIMARY KEY,
	Name nvarchar(10),   -- ��Ա����
	Dept nvarchar(10)    -- ��������
)
INSERT Employee SELECT 1, N'����', N'��ͻ���'
UNION  ALL      SELECT 2, N'����', N'��ͻ���'
UNION  ALL      SELECT 3, N'����', N'����һ��'

-- ���ñ�
CREATE TABLE Expenses(
	EmployeeID int,        -- ��Ա���
	Sort nvarchar(10), -- �������
	Date Datetime,         -- ��������
	[Money] decimal(10,2)  -- �������
)
INSERT Expenses SELECT 1, N'����', '2004-01-01', 100
UNION  ALL      SELECT 1, N'����', '2004-01-02', 150
UNION  ALL      SELECT 1, N'����', '2004-12-01', 200
UNION  ALL      SELECT 1, N'����', '2005-01-10',  80
UNION  ALL      SELECT 1, N'����', '2005-01-15',  90
UNION  ALL      SELECT 1, N'�ɱ�', '2005-01-21',   8
UNION  ALL      SELECT 2, N'�ɱ�', '2004-12-01',   2
UNION  ALL      SELECT 2, N'����', '2005-01-10',  10
UNION  ALL      SELECT 2, N'����', '2005-01-15',  40
UNION  ALL      SELECT 2, N'�ɱ�', '2005-01-21',   8
UNION  ALL      SELECT 3, N'����', '2004-01-01', 200
UNION  ALL      SELECT 3, N'����', '2004-12-10',  80
UNION  ALL      SELECT 3, N'����', '2005-01-15',  90
UNION  ALL      SELECT 3, N'����', '2005-01-21',   8
GO

--ͳ��
DECLARE 
	@YearMonth char(6)
SET @YearMonth = '200501' -- ͳ�Ƶ�����

-- ͳ�ƴ���
-- a. ͳ����������
DECLARE
	@Last_YearMonth char(6),
	@Previous_YearMonth char(6)
SELECT
	-- ȥ��ͬ�ڵ�����
	@Last_YearMonth = CONVERT(char(6), DATEADD(Year, -1, @YearMonth + '01'), 112),
	-- ��һ�ڵ�����
	@Previous_YearMonth = CONVERT(char(6), DATEADD(Month, -1, @YearMonth + '01'), 112)

-- b. ͳ�Ʋ�ѯ
SELECT
	Dept,
	Sort = CASE
				WHEN GROUPING(Name) = 0 THEN Sort
				WHEN GROUPING(Name) = 1 THEN Sort + N' - �ϼ�'
			END,
	Name = CASE
				WHEN GROUPING(Name) = 0 THEN Name
				WHEN GROUPING(Name) =1 THEN N''
			END,
	CurrentMoney = SUM(CurrentMoney),
	PreviousMoney = SUM(PreviousMoney),
	-- ���������ڵĲ���
	PreviousDiff = SUM(CurrentMoney) - SUM(PreviousMoney),
	-- ���������ڵı仯�仯���
	PreviousDiffFlag = CASE
					WHEN SUM(PreviousMoney) = 0 THEN '----'
					ELSE SUBSTRING(N'������', CONVERT(int, SIGN(SUM(CurrentMoney) - SUM(PreviousMoney)) + 2), 1)
						+ CONVERT(varchar,
								CONVERT(decimal(10, 2),
									ABS(SUM(CurrentMoney) - SUM(PreviousMoney)) * 100 / SUM(PreviousMoney)
								)) + '%'
				END,
	LastMoney = SUM(LastMoney),
	-- ������ȥ��ͬ�ڵĲ���
	LastDiff = SUM(CurrentMoney) - SUM(LastMoney),
	-- ������ȥ��ͬ�ڵı仯�仯���
	LastDiffFlag = CASE
					WHEN SUM(LastMoney) = 0 THEN '    ----'
					ELSE SUBSTRING(N'������', CONVERT(int, SIGN(SUM(CurrentMoney) - SUM(LastMoney)) + 2), 1)
						+ CONVERT(varchar,
								CONVERT(decimal(10, 2),
									ABS(SUM(CurrentMoney) - SUM(LastMoney)) * 100 / SUM(LastMoney)
								)) + '%'
				END
FROM(
	SELECT  -- ��������
		A.Dept, B.Sort, A.Name,
		CurrentMoney = [Money],
		PreviousMoney = CONVERT(decimal(10,2), 0),
		LastMoney = CONVERT(decimal(10,2), 0)
	FROM Employee A, Expenses B
	WHERE A.ID = B.EmployeeID
		AND B.Date >= CONVERT(datetime, @YearMonth + '01')
		AND B.Date < DATEADD(Month, 1, @YearMonth + '01')
	UNION ALL
	SELECT  -- ��������
		A.Dept, B.Sort, A.Name,
		CurrentMoney = CONVERT(decimal(10,2), 0),
		PreviousMoney = [Money],
		LastMoney = CONVERT(decimal(10,2), 0)
	FROM Employee A, Expenses B
	WHERE A.ID = B.EmployeeID
		AND B.Date >= CONVERT(datetime, @Previous_YearMonth + '01')
		AND B.Date < DATEADD(Month, 1, @Previous_YearMonth + '01')
	UNION ALL
	SELECT  -- ȥ��ͬ������
		A.Dept, B.Sort, A.Name,
		CurrentMoney = CONVERT(decimal(10,2), 0),
		PreviousMoney = CONVERT(decimal(10,2), 0),
		LastMoney = [Money]
	FROM Employee A, Expenses B
	WHERE A.ID = B.EmployeeID
		AND B.Date >= CONVERT(datetime, @Last_YearMonth + '01')
		AND B.Date < DATEADD(Month, 1, @Last_YearMonth + '01')
)A
GROUP BY Dept, Sort, Name WITH ROLLUP
HAVING GROUPING(Name) = 0
	OR GROUPING(Name) = 1 AND GROUPING(Sort) = 0
/*--���
Dept		Sort		Name	CurrentMoney	PreviousMoney	PreviousDiff	PreviousDiffFlag	LastMoney	LastDiff	LastDiffFlag
----------- ----------- ------- --------------- --------------- --------------- ------------------- ----------- ----------- ----------------
��ͻ���	�ɱ�		����	8.00			2.00			6.00			��300.00%			0.00		8.00	    ----
��ͻ���	�ɱ�		����	8.00			0.00			8.00			----				0.00		8.00	    ----
��ͻ���	�ɱ� - �ϼ�			16.00			2.00			14.00			��700.00%			0.00		16.00	    ----
��ͻ���	����		����	50.00			0.00			50.00			----				0.00		50.00	    ----
��ͻ���	����		����	170.00			200.00			-30.00			��15.00%				250.00		-80.00		��32.00%
��ͻ���	���� - �ϼ�			220.00			200.00			20.00			��10.00%				250.00		-30.00		��12.00%
����һ��	����		����	98.00			80.00			18.00			��22.50%				200.00		-102.00		��51.00%
����һ��	���� - �ϼ�			98.00			80.00			18.00			��22.50%				200.00		-102.00		��51.00%
--*/
GO

DROP TABLE Employee, Expenses