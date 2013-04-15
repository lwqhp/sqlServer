
/*
Ҫ��ͳ����COL��ÿ�����������NUMƽ��ֵ������ÿ����¼���������NUMֵ����Ҫ����������Ķ���ҵ����NUM��
*/
-- ��������
CREATE TABLE tb(
	ID int,
	col varchar(50),
	num int)
INSERT tb SELECT 1, 'aa,bb,cc', 10
UNION ALL SELECT 2, 'aa,aa,bb', 20
UNION ALL SELECT 3, 'aa,aa,bb', 20
UNION ALL SELECT 4, 'dd,ccc,c', 30
UNION ALL SELECT 5, 'ddaa,ccc', 40
UNION ALL SELECT 6, 'eee,ee,c', 50
GO

-- ͳ�Ʒ��� A
-- �ֲ�����Ҫ�ĸ�����ļ�¼��(������ֱ�Ӵ���,���Ը���col1�����������ݳ���������)
DECLARE
	@len int
SELECT TOP 1
	@len = LEN(col) + 1
FROM tb
ORDER BY LEN(col) DESC

-- ���û��Ҫ�ֲ��������, ��ֱ���˳�
IF ISNULL(@len,1) = 1
	RETURN

-- �ֲ�����
SET ROWCOUNT @len
SELECT
	ID = IDENTITY(int, 1, 1)
INTO # FROM dbo.syscolumns A, dbo.syscolumns B
ALTER TABLE # ADD
	PRIMARY KEY(
		ID)
SET ROWCOUNT 0

--ͳ�ƴ���
-- a. �ֲ����ݵ���ʱ��
SELECT 
	A.num,
	A.ID,
	gid = b.ID,  -- ÿ�����������ַ����еĿ�ʼλ��
	data = SUBSTRING(A.col, B.ID, CHARINDEX(',', A.col + ',', B.ID) - B.ID)
INTO #t FROM tb A, # B
WHERE b.ID <= LEN(A.col)
	AND SUBSTRING(',' + A.col, B.ID,1) = ','

SELECT
	A.data,
	AVG_num = CAST(
			-- ��������������ƽ��ֵ
			AVG(
				-- ����ÿ���������������ڼ�¼��Ӧ�÷����ֵ
				CASE 
					-- ÿһ��������, ʹ������ - �����������Ѿ����������֮����Ϊ������¼���������ֵ
					WHEN A.gid = 1 THEN A.num - CAST(A.num as float) / B.cnt * (B.cnt - 1)
					ELSE CAST(A.num as float) / B.cnt END
			) as decimal(10,2))
FROM #t A,
	(   -- ÿ����¼�����������
		SELECT
			ID,
			cnt = COUNT(*)
		FROM #t
		GROUP BY ID
	)B
WHERE A.ID = B.ID
GROUP BY A.data
DROP TABLE #, #t
GO


-- ͳ�Ʒ��� B
-- �ֲ�����Ҫ�ĸ�����ļ�¼��(������ֱ�Ӵ���,���Ը���col1�����������ݳ���������)
DECLARE
	@len int
SELECT TOP 1
	@len = LEN(col) + 1
FROM tb
ORDER BY LEN(col) DESC

-- ���û��Ҫ�ֲ��������, ��ֱ���˳�
IF ISNULL(@len,1) = 1
	RETURN

-- �ֲ�����
SET ROWCOUNT @len
SELECT
	ID = IDENTITY(int, 1, 1)
INTO # FROM dbo.syscolumns A, dbo.syscolumns B
ALTER TABLE # ADD
	PRIMARY KEY(
		ID)
SET ROWCOUNT 0

SELECT
	data,
	AVG_num = CAST(
			-- ��������������ƽ��ֵ
			AVG(
				-- ����ÿ���������������ڼ�¼��Ӧ�÷����ֵ
				CASE 
					-- ÿһ��������, ʹ������ - �����������Ѿ����������֮����Ϊ������¼���������ֵ
					WHEN gid = 1 THEN num - CAST(num as float) / cnt * (cnt - 1)
					ELSE CAST(num as float) / cnt END
			) as decimal(10,2))
FROM(
	SELECT
		a.num,
		gid=b.ID,  -- ÿ�����������ַ����еĿ�ʼλ��
		data = SUBSTRING(A.col, B.ID, CHARINDEX(',', A.col + ',', B.ID) - B.ID),
		-- ÿ����¼����������Ŀ
		cnt = LEN(A.col) - LEN(REPLACE(A.col, ',', '')) + 1
	FROM tb A, # B
	WHERE b.ID <= LEN(A.col)
		AND SUBSTRING(',' + A.col, B.ID,1) = ','
)A
GROUP BY data
DROP TABLE #
GO

-- ɾ����������
DROP TABLE tb
