--��������
CREATE TABLE tb(
	col1 varchar(10),
	col2 int)
INSERT tb SELECT 'a', 2
UNION ALL SELECT 'a', 3
UNION ALL SELECT 'a', 6
UNION ALL SELECT 'a', 7
UNION ALL SELECT 'a', 8
UNION ALL SELECT 'b', 3
UNION ALL SELECT 'b', 5
UNION ALL SELECT 'b', 6
UNION ALL SELECT 'b', 7
GO

-- ���ñ�ŷֲ���ѯ - ��ʱ��
-- a. ��ʼ���
SELECT
	id = IDENTITY(int),
	col1,
	col2
INTO #1
FROM tb A
WHERE NOT EXISTS(
		SELECT * FROM tb
		WHERE col1 = A.col1
			AND col2 = A.col2 - 1)

-- b. �������
SELECT
	id = IDENTITY(int),
	col2
INTO #2
FROM tb A
WHERE NOT EXISTS(
		SELECT * FROM tb
		WHERE col1 = A.col1
			AND col2 = A.col2 + 1)

-- c. ��ѯ���
SELECT
	A.col1, 
	start_col2 = A.col2,
	end_col2 = B.col2
FROM #1 A, #2 B
WHERE A.id = B.id
DROP TABLE #1, #2
/*--���
col1       start_col2  end_col2    
---------- ----------- ----------- 
a          2           3
a          6           8
b          3           3
b          5           7
--*/
GO


-- ���ñ�ŷֲ���ѯ - �Ӳ�ѯ��
SELECT
	col1,
	start_col2 = col2,
	end_col2=(
			SELECT
				-- ��Сһ��������ż�Ϊ��ǰ��¼��ʼ���֮��Ľ������
				MIN(col2)
			FROM tb AA
			WHERE col1 = A.col1
				-- ��ʼ���֮��Ľ������
				AND col2 >= A.col2
				AND NOT EXISTS(
						SELECT * FROM tb
						WHERE col1 = AA.col1
							AND col2 = AA.col2 + 1))
FROM tb A
WHERE NOT EXISTS( -- ɸѡ����ʼ��ŵļ�¼
		SELECT * FROM tb
		WHERE col1 = A.col1
			AND col2 = A.col2 - 1)
GO

-- ɾ�����Ի���
DROP TABLE tb
