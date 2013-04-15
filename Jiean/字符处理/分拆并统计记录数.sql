
/*
Ҫ��ͳ������COL��ÿ��������ĳ��ֵĸ����ͳ��ֹ���¼�ļ�¼����
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
SELECT
	data = SUBSTRING(A.col, B.ID, CHARINDEX(',', A.col + ',', B.ID) - B.ID),
	row_count = COUNT(DISTINCT A.ID),
	data_numbers = COUNT(*)
FROM tb A, # B
WHERE b.ID <= LEN(A.col)
	AND SUBSTRING(',' + A.col, B.ID, 1) =	','
GROUP BY SUBSTRING(A.col, B.ID, CHARINDEX(',', A.col + ',', B.ID) - B.ID)
DROP TABLE #
GO

-- ɾ����������
DROP TABLE tb
