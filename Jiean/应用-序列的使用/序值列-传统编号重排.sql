--��������
CREATE TABLE tb(
	ID1 char(2) NOT NULL,
	ID2 char(4) NOT NULL,
	col int,
	PRIMARY KEY(
		ID1, ID2))
INSERT tb SELECT 'aa', '0001', 1
UNION ALL SELECT 'aa', '0003', 2
UNION ALL SELECT 'aa', '0004', 3
UNION ALL SELECT 'bb', '0005', 4
UNION ALL SELECT 'bb', '0006', 5
UNION ALL SELECT 'cc', '0007', 6
UNION ALL SELECT 'cc', '0009', 7
GO

--���ű�Ŵ���
UPDATE A SET
	ID2 = RIGHT(
			10000 + (
				SELECT COUNT(*) FROM tb
				WHERE ID1 = A.ID1
					AND ID2 <= A.ID2),
			4)
FROM tb A
SELECT * FROM tb
/*--���
ID1  ID2  col
---- ---- ----------- 
aa   0001 1
aa   0002 2
aa   0003 3

bb   0001 4
bb   0002 5

cc   0001 6
cc   0002 7
--*/
GO

-- ɾ�����Ի���
DROP TABLE tb



--ʹ����ʱ��ʵ�ֱ������----------------------

CREATE TABLE tb(
	ID1 char(2) NOT NULL,
	ID2 char(4) NOT NULL,
	col int,
	PRIMARY KEY(
		ID1, ID2))
INSERT tb SELECT 'aa', '0001', 1
UNION ALL SELECT 'aa', '0003', 2
UNION ALL SELECT 'aa', '0004', 3
UNION ALL SELECT 'bb', '0005', 4
UNION ALL SELECT 'bb', '0006', 5
UNION ALL SELECT 'cc', '0007', 6
UNION ALL SELECT 'cc', '0009', 7
GO

SELECT * FROM dbo.tb
-- ���ű�Ŵ���
-- a. ����Ҫ���ű�ŵ�˳�����ɴ���ʶ�е���ʱ��
SELECT
	ID = IDENTITY(int,0,1),
	*
INTO # FROM tb
ORDER BY ID1, ID2

-- ������ʱ��, �����ű��
UPDATE A SET
	ID2 = RIGHT(10001 + b1.ID - b2.ID, 4)
FROM tb A
	INNER JOIN # B1
		ON A.ID1 = B1.ID1
			AND A.ID2 = B1.ID2
	INNER JOIN(
		-- ��ʱ����, ÿ��ID1 ��Ӧ�ı�ʶ����Сֵ(ͨ��ÿ����¼�ı�ʶ��ֵ��ȥ�����Сֵ, ��Ϊ�ü�¼������ID1 �е����(�ӿ�ʼ))
		SELECT
			ID1, 
			ID = MIN(ID)
		FROM #
		GROUP BY ID1
	)B2
		ON B1.ID1 = B2.ID1
DROP TABLE #
SELECT * FROM tb
/*--���
ID1  ID2  col
---- ---- ----------- 
aa   0001 1
aa   0002 2
aa   0003 3
bb   0001 4
bb   0002 5
cc   0001 6
cc   0002 7
--*/
GO

-- ɾ������
DROP TABLE tb