-- 雇员数据
CREATE TABLE Employee(
	ID int              -- 雇员编号(主键)
		PRIMARY KEY,
	Name nvarchar(10),   -- 雇员名称
	Dept nvarchar(10)    -- 所属部门
)
INSERT Employee SELECT 1, N'张三', N'大客户部'
UNION  ALL      SELECT 2, N'李四', N'大客户部'
UNION  ALL      SELECT 3, N'王五', N'销售一部'

-- 费用表
CREATE TABLE Expenses(
	EmployeeID int,        -- 雇员编号
	Sort nvarchar(10), -- 费用类别
	Date Datetime,         -- 发生日期
	[Money] decimal(10,2)  -- 发生金额
)
INSERT Expenses SELECT 1, N'销售', '2004-01-01', 100
UNION  ALL      SELECT 1, N'销售', '2004-01-02', 150
UNION  ALL      SELECT 1, N'销售', '2004-12-01', 200
UNION  ALL      SELECT 1, N'销售', '2005-01-10',  80
UNION  ALL      SELECT 1, N'销售', '2005-01-15',  90
UNION  ALL      SELECT 1, N'成本', '2005-01-21',   8
UNION  ALL      SELECT 2, N'成本', '2004-12-01',   2
UNION  ALL      SELECT 2, N'销售', '2005-01-10',  10
UNION  ALL      SELECT 2, N'销售', '2005-01-15',  40
UNION  ALL      SELECT 2, N'成本', '2005-01-21',   8
UNION  ALL      SELECT 3, N'销售', '2004-01-01', 200
UNION  ALL      SELECT 3, N'销售', '2004-12-10',  80
UNION  ALL      SELECT 3, N'销售', '2005-01-15',  90
UNION  ALL      SELECT 3, N'销售', '2005-01-21',   8
GO

--统计
DECLARE 
	@YearMonth char(6)
SET @YearMonth = '200501' -- 统计的年月

-- 统计处理
-- a. 统计区间设置
DECLARE
	@Last_YearMonth char(6),
	@Previous_YearMonth char(6)
SELECT
	-- 去年同期的年月
	@Last_YearMonth = CONVERT(char(6), DATEADD(Year, -1, @YearMonth + '01'), 112),
	-- 上一期的年月
	@Previous_YearMonth = CONVERT(char(6), DATEADD(Month, -1, @YearMonth + '01'), 112)

-- b. 统计查询
SELECT
	Dept,
	Sort = CASE
				WHEN GROUPING(Name) = 0 THEN Sort
				WHEN GROUPING(Name) = 1 THEN Sort + N' - 合计'
			END,
	Name = CASE
				WHEN GROUPING(Name) = 0 THEN Name
				WHEN GROUPING(Name) =1 THEN N''
			END,
	CurrentMoney = SUM(CurrentMoney),
	PreviousMoney = SUM(PreviousMoney),
	-- 本期与上期的差异
	PreviousDiff = SUM(CurrentMoney) - SUM(PreviousMoney),
	-- 本期与上期的变化变化情况
	PreviousDiffFlag = CASE
					WHEN SUM(PreviousMoney) = 0 THEN '----'
					ELSE SUBSTRING(N'↓－↑', CONVERT(int, SIGN(SUM(CurrentMoney) - SUM(PreviousMoney)) + 2), 1)
						+ CONVERT(varchar,
								CONVERT(decimal(10, 2),
									ABS(SUM(CurrentMoney) - SUM(PreviousMoney)) * 100 / SUM(PreviousMoney)
								)) + '%'
				END,
	LastMoney = SUM(LastMoney),
	-- 本期与去年同期的差异
	LastDiff = SUM(CurrentMoney) - SUM(LastMoney),
	-- 本期与去年同期的变化变化情况
	LastDiffFlag = CASE
					WHEN SUM(LastMoney) = 0 THEN '    ----'
					ELSE SUBSTRING(N'↓－↑', CONVERT(int, SIGN(SUM(CurrentMoney) - SUM(LastMoney)) + 2), 1)
						+ CONVERT(varchar,
								CONVERT(decimal(10, 2),
									ABS(SUM(CurrentMoney) - SUM(LastMoney)) * 100 / SUM(LastMoney)
								)) + '%'
				END
FROM(
	SELECT  -- 本期数据
		A.Dept, B.Sort, A.Name,
		CurrentMoney = [Money],
		PreviousMoney = CONVERT(decimal(10,2), 0),
		LastMoney = CONVERT(decimal(10,2), 0)
	FROM Employee A, Expenses B
	WHERE A.ID = B.EmployeeID
		AND B.Date >= CONVERT(datetime, @YearMonth + '01')
		AND B.Date < DATEADD(Month, 1, @YearMonth + '01')
	UNION ALL
	SELECT  -- 上期数据
		A.Dept, B.Sort, A.Name,
		CurrentMoney = CONVERT(decimal(10,2), 0),
		PreviousMoney = [Money],
		LastMoney = CONVERT(decimal(10,2), 0)
	FROM Employee A, Expenses B
	WHERE A.ID = B.EmployeeID
		AND B.Date >= CONVERT(datetime, @Previous_YearMonth + '01')
		AND B.Date < DATEADD(Month, 1, @Previous_YearMonth + '01')
	UNION ALL
	SELECT  -- 去年同期数据
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
/*--结果
Dept		Sort		Name	CurrentMoney	PreviousMoney	PreviousDiff	PreviousDiffFlag	LastMoney	LastDiff	LastDiffFlag
----------- ----------- ------- --------------- --------------- --------------- ------------------- ----------- ----------- ----------------
大客户部	成本		李四	8.00			2.00			6.00			↑300.00%			0.00		8.00	    ----
大客户部	成本		张三	8.00			0.00			8.00			----				0.00		8.00	    ----
大客户部	成本 - 合计			16.00			2.00			14.00			↑700.00%			0.00		16.00	    ----
大客户部	销售		李四	50.00			0.00			50.00			----				0.00		50.00	    ----
大客户部	销售		张三	170.00			200.00			-30.00			↓15.00%				250.00		-80.00		↓32.00%
大客户部	销售 - 合计			220.00			200.00			20.00			↑10.00%				250.00		-30.00		↓12.00%
销售一部	销售		王五	98.00			80.00			18.00			↑22.50%				200.00		-102.00		↓51.00%
销售一部	销售 - 合计			98.00			80.00			18.00			↑22.50%				200.00		-102.00		↓51.00%
--*/
GO

DROP TABLE Employee, Expenses