CREATE TABLE tb(
	Name varchar(10),
	Score decimal(10,2))
INSERT tb SELECT 'aa', 99
UNION ALL SELECT 'bb', 56
UNION ALL SELECT 'cc', 56
UNION ALL SELECT 'dd', 77
UNION ALL SELECT 'ee', 78
UNION ALL SELECT 'ff', 76
UNION ALL SELECT 'gg', 78
UNION ALL SELECT 'ff', 50
GO

select *,place=dense_rank() over(order by score desc) from tb 
-- �������ɷ�ʽ1 : Score �ظ�ʱ�ϲ�����
SELECT
	*,
	Place = (
			SELECT
				-- Score �ظ�ֻͳ��һ��
				COUNT(DISTINCT Score) 
			FROM tb
			WHERE Score >= a.Score)
FROM tb A
ORDER BY Place
/*--���
Name       Score        Place 
---------------- ----------------- ----------- 
aa         99.00        1
ee         78.00        2
gg         78.00        2
dd         77.00        3
ff         76.00        4
bb         56.00        5
cc         56.00        5
ff         50.00        6
--*/

--�������ɷ�ʽ,Score�ظ�ʱ�������ο�ȱ
SELECT
	*,
	Place = 1 + (
			SELECT				
				COUNT(Score) 
			FROM tb
			-- ͳ���ڱ���¼��Score ֮ǰ�Ѿ����ֹ��ļ�¼��, + 1 ��Ϊ����¼��Place
			WHERE Score > a.Score)
FROM tb A
ORDER BY Place

/*--���
Name       Score        Place 
--------------- ----------------- ----------- 
aa         99.00        1
ee         78.00        2
gg         78.00        2
dd         77.00        4
ff         76.00        5
bb         56.00        6
cc         56.00        6
ff         50.00        8
--*/
GO

-- ɾ�����Ի���
DROP TABLE tb