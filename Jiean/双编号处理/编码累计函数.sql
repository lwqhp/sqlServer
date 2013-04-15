CREATE TABLE tb(
	ID int
		PRIMARY KEY,
	PID int,
	Num int
)
INSERT tb SELECT 1, NULL, 100
UNION ALL SELECT 2, 1   , 200
UNION ALL SELECT 3, 2   , 300
UNION ALL SELECT 4, 3   , 400
UNION ALL SELECT 5, 1   , 500
UNION ALL SELECT 6, NULL, 600
UNION ALL SELECT 7, NULL, 700
UNION ALL SELECT 8, 7   , 800
UNION ALL SELECT 9, 7   , 900
GO

-- 得到每个结点的编码累计
CREATE FUNCTION dbo.f_id()
RETURNS @t TABLE(
			ID int,
			Level int,
			SID varchar(8000))
AS
BEGIN
	DECLARE
		@Level int
	SET @Level = 1
	
	INSERT @t
	SELECT
		ID, @Level, ',' + CAST(ID as varchar) + ','
	FROM tb
	WHERE PID IS NULL
	WHILE @@ROWCOUNT > 0
	BEGIN
		SET @Level = @Level + 1

		INSERT @t
		SELECT
			A.ID, @Level, B.SID + CAST(A.ID as varchar) + ','
		FROM tb A, @t B
		WHERE A.PID = B.ID
			AND B.Level = @Level - 1
	END
	RETURN
END
GO

-- 调用函数实现实现累计
SELECT
	A.ID, A.PID, A.Num,
	SUM_Num = SUM(B.Num)
FROM tb A,
	dbo.f_id() A1,
	tb B,
	dbo.f_id() B1
WHERE A.ID = A1.ID
	AND B.ID = B1.ID
	AND B1.SID LIKE A1.SID + '%'
GROUP BY A.ID, A.PID, A.Num
/*--结果
ID          PID         Num         SUM_Num
----------- ----------- ----------- -----------
1           NULL        100         1500
2           1           200         900
3           2           300         700
4           3           400         400
5           1           500         500
6           NULL        600         600
7           NULL        700         2400
8           7           800         800
9           7           900         900
--*/
GO

-- 删除测试
DROP TABLE tb
DROP FUNCTION dbo.f_id