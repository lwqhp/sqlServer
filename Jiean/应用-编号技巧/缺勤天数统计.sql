--������������֮�����Ĺ�������
CREATE FUNCTION dbo.f_WorkDateDiff(
	@dt_begin datetime,
	@dt_end datetime
)RETURNS int
AS
BEGIN
	DECLARE
		@workday int,
		@i int,
		@bz bit,
		@dt datetime

	-- �����ʼ���� > ����ʱ��, �򽻻���������, �����ñ�־
	-- �������ĺô��Ǻ���Ĵ�����ͬһ�������
	IF @dt_begin > @dt_end
		SELECT
			@bz=1,
			@dt = @dt_begin,
			@dt_begin = @dt_end,
			@dt_end=@dt
	ELSE
		SET @bz=0

	SELECT
		-- ��������
		@i = (DATEDIFF(Day, @dt_begin, @dt_end) + 1) / 7,
		@workday = @i * 5,  -- ���ܹ�������
		@dt_begin = DATEADD(Day, @i * 7, @dt_begin)
	-- ��������ܹ�������
	WHILE @dt_begin <= @dt_end
	BEGIN
		SELECT
			@workday = CASE 
						WHEN (@@DATEFIRST + DATEPART(Weekday, @dt_begin) - 1) % 7 BETWEEN 1 AND 5
							THEN @workday + 1
						ELSE @workday
					END,
			@dt_begin = @dt_begin + 1
	END

	RETURN(
		CASE
			WHEN @bz = 1 THEN - @workday
			ELSE @workday
		END)
END
GO

--��������
CREATE TABLE tb(
	Name varchar(10),
	WorkDate datetime)
INSERT tb SELECT 'aa', '2005-01-03'
UNION ALL SELECT 'aa', '2005-01-04'
UNION ALL SELECT 'aa', '2005-01-05'
UNION ALL SELECT 'aa', '2005-01-06'
UNION ALL SELECT 'aa', '2005-01-07'
UNION ALL SELECT 'aa', '2005-01-10'
UNION ALL SELECT 'aa', '2005-01-14'
UNION ALL SELECT 'aa', '2005-01-17'
UNION ALL SELECT 'bb', '2005-01-11'
UNION ALL SELECT 'bb', '2005-01-12'
UNION ALL SELECT 'bb', '2005-01-13'
UNION ALL SELECT 'bb', '2005-01-10'
UNION ALL SELECT 'bb', '2005-01-14'
UNION ALL SELECT 'bb', '2005-01-20'
GO

--ȱ��ͳ��
DECLARE
	@dt_begin datetime,
	@dt_end datetime
SELECT
	@dt_begin = '2005-1-1', --ͳ�ƵĿ�ʼ����
	@dt_end = '2005-1-20'   --ͳ�ƵĽ�������

--ͳ��
SELECT
	Name,
	Days = SUM(Days)
FROM(
	SELECT
		Name,
		Days = dbo.f_WorkDateDiff(
				DATEADD(Day, 1, WorkDate),
				-- ȱ�����ڵĽ�������, ���û��, ��Ϊ��ѯ�Ľ�������
				ISNULL(
					(
						SELECT
							DATEADD(Day, -1, MIN(WorkDate))
						FROM tb AA
						WHERE Name = A.Name 
							AND WorkDate > A.WorkDate
								AND WorkDate <= @dt_end
					), @dt_end)
			)
	FROM(
		SELECT
			Name,
			WorkDate
		FROM tb
		WHERE WorkDate BETWEEN @dt_begin AND @dt_end
		UNION ALL --Ϊÿ���Ų����ѯ��ʼ����Ƿ�ȱ�ŵĸ�����¼
		SELECT DISTINCT
			Name,
			DATEADD(Day, -1, @dt_begin)
		FROM tb
		WHERE WorkDate BETWEEN @dt_begin AND @dt_end
	)a
	WHERE 
		-- �����㹤����
		(@@DATEFIRST+DATEPART(Weekday, WorkDate) - 1) % 7 BETWEEN 1 AND 5
		AND NOT EXISTS(
				-- û����һ�쿼�ڼ�¼�ļ�¼, �������ڼ�1��Ϊȱ�ڵĿ�ʼ����
				SELECT * FROM tb 
				WHERE WorkDate BETWEEN @dt_begin AND @dt_end
					AND Name = A.Name 
					AND dbo.f_WorkDateDiff(WorkDate, A.WorkDate) = -2)
)AA
GROUP BY Name
/*--���
Name       Days 
---------------- ----------- 
aa         6
bb         8
--*/
GO

-- ɾ�����Ի���
DROP TABLE tb
DROP FUNCTION f_WorkDateDiff