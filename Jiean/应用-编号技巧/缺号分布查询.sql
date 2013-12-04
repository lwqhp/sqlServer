--��������
CREATE TABLE tb(
	col1 varchar(10),
	col2 int)
INSERT tb SELECT 'a', 2
UNION ALL SELECT 'a', 3
UNION ALL SELECT 'a', 6
UNION ALL SELECT 'a', 7
UNION ALL SELECT 'a', 8
UNION ALL SELECT 'b', 1
UNION ALL SELECT 'b', 5
UNION ALL SELECT 'b', 6
UNION ALL SELECT 'b', 7
GO

--ȱ�ŷֲ���ѯ
SELECT
	A.col1,
	start_col2 = A.col2 + 1,
	end_col2 = (
				-- ȱ�ſ�ʼ��¼�ĺ�һ����¼��� - 1, ��Ϊȱ�ŵĽ������
				SELECT
					MIN(col2) - 1
				FROM tb AA
				WHERE col1 = A.col1
					AND col2 > A.col2 )
FROM(
	SELECT
		col1, col2
	FROM tb
	UNION ALL -- Ϊÿ���Ų����ѯ��ʼ����Ƿ�ȱ�ŵĸ�����¼
	SELECT DISTINCT 
		col1, 0
	FROM tb
)A
	INNER JOIN(
		-- ÿ�����ݵ�����¼�϶�û�к������, ����������ȱ��, ���Ҫ����ȥ��
		SELECT
			col1,
			col2 = MAX(col2)
		FROM tb
		GROUP BY col1
	)B
		ON A.col1 = B.col1
			AND A.col2 < B.col2
WHERE NOT EXISTS(
		-- ɸѡ��ÿ��û�к�����ŵļ�¼, ���ı�� + 1 ��Ϊȱ�ŵĿ�ʼ���
		SELECT * FROM tb
		WHERE col1 = A.col1
			AND col2 = A.col2 + 1)
ORDER BY A.col1, start_col2
/*--���
col1       start_col2  end_col2    
-------------- -------------- ----------- 
a          1           1
a          4           5
b          2           4
--*/
GO

-- ɾ����������
DROP TABLE tb