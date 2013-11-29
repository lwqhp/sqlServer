-- ��������
DECLARE @t TABLE(
	No varchar(10))
INSERT @t SELECT '1'
UNION ALL SELECT '3'
UNION ALL SELECT '302'
UNION ALL SELECT '305'
UNION ALL SELECT '305001'
UNION ALL SELECT '305005'
UNION ALL SELECT '6'
UNION ALL SELECT '601'

-- ���ű���
UPDATE A SET 
	No = RIGHT(( -- ���ŵ�һ������
					SELECT
						COUNT(DISTINCT No)
					FROM @t
					WHERE LEN(No) = 1   -- �ж��Ƿ��һ������
						AND No <= A.No  -- ��ͳ�ƽ�ֹ��ǰ��¼Ϊֹ, ���ֹ���һ������Ĵ���
				), 1)
		+ CASE  -- ���ŵڶ�������
				WHEN LEN(No) > 1        -- ����������ڶ�������ļ�¼
					THEN RIGHT(100 + (
									SELECT
										COUNT(DISTINCT No)
									FROM @t
									WHERE No LIKE LEFT(A.NO, 1) + '__'  -- �ж��Ƿ�ڶ�������
										AND No <= A.No -- ��ͳ�ƽ�ֹ��ǰ��¼Ϊֹ, ���ֹ��Ķ�������Ĵ���
								), 2)
				ELSE ''
			END
		+ CASE -- ���ŵ���������
			WHEN LEN(No) > 3           -- �������������������ļ�¼
				THEN RIGHT(1000 + (
								SELECT
									COUNT(DISTINCT No)
								FROM @t
								WHERE No LIKE LEFT(A.NO, 3) + '___' -- �ж��Ƿ����������
									AND No <= A.No -- ��ͳ�ƽ�ֹ��ǰ��¼Ϊֹ, ���ֹ�����������Ĵ���
								), 3)
			ELSE '' END
FROM @t A

-- ��ʾ������
SELECT * FROM @t
/*--���
No
----------
1
2
201
202
202001
202002
3
301
--*/
