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

-- ����Ĵ洢����
CREATE PROC dbo.p_Calc
AS
SET NOCOUNT ON
DECLARE
	@Level int
SET @Level = 1

SELECT
	ID, PID, SUM_Num=Num,
	-- ��û���ӽ��ļ�¼�� Level ����Ϊ 1, ��ʾ����㲻�ü���
	Level = CASE 
				WHEN EXISTS(
						SELECT * FROM tb WHERE PID = A.ID)
					THEN 0
				ELSE 1
			END
INTO #
FROM tb A

WHILE @@ROWCOUNT > 0
BEGIN
	SET @Level = @Level + 1

	UPDATE A SET 
		Level = @Level,
		SUM_Num = ISNULL(A.SUM_Num, 0) + ISNULL(B.SUM_Num, 0)
	FROM # A
		INNER JOIN(
			SELECT
				AA.PID,
				SUM_Num = SUM(AA.SUM_Num)
			FROM # AA
				INNER JOIN(
					SELECT DISTINCT
						PID
					FROM #
					WHERE Level = @Level - 1
				)BB
					ON AA.PID = BB.PID
			WHERE NOT EXISTS(
					-- �����ĳ����������ͬ���������н�㶼��ʶΪ�Ѿ�����, �����ø������ۼ�ֵ
					SELECT * FROM #
					WHERE PID = AA.PID
						AND Level = 0)
			GROUP BY AA.PID
		)B
			ON A.ID = B.PID
END

-- ��ʾ���
SELECT
	A.*,
	B.SUM_Num
FROM tb A, # B
WHERE A.ID = B.ID
GO

-- ���ô洢���̽��м���
EXEC dbo.p_Calc
/*--���
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

-- ɾ������
DROP TABLE tb
DROP PROC dbo.p_Calc