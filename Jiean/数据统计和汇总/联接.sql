-- ��������
DECLARE @a TABLE(
	id int)

INSERT @a SELECT 1
UNION ALL SELECT 2

DECLARE @b TABLE(
	id int)

INSERT @b SELECT 2
UNION ALL SELECT 3

-- ������
-- a. ʹ�� (INNER) JOIN 
SELECT
	* 
FROM @a A
	JOIN @b B
		ON A.id = B.id

-- b. ʹ�� WHERE ����
SELECT
	*
FROM @a A, @b B
WHERE A.id = B.id
/*--���(ֻ������������ id ��ͬ�ļ�¼)
id          id
----------- ----------- 
2           2
--*/

-- ����������
-- a. ʹ�� LEFT JOIN
SELECT
	*
FROM @a A
	LEFT JOIN @b B
		ON A.id = B.id

-- B. ʹ�� *= (��������ʹ�����ַ�ʽ, ���������ȷ��ѯ)
SELECT
	*
FROM @a A, @b B
WHERE A.id *= B.id 
/*--���(����@a(��߱�)���еļ�¼,��@b(�ұ߱�)��id��@a��idƥ��ļ�¼),��ƥ�����NULL��ʾ
id          id 
----------- ----------- 
1           NULL
2           2
--*/

-- ����������
-- a. ʹ�� RIGHT JOIN
SELECT
	*
FROM @a A
	RIGHT JOIN @b B
		ON A.id = B.id

-- b. ʹ�� = * (��������ʹ�����ַ�ʽ, ���������ȷ��ѯ)
SELECT
	*
FROM @a A, @b B
WHERE A.id =* B.id
/*--���(����@b(�ұ߱�)���еļ�¼,��@a(��߱�)��id��@b��idƥ��ļ�¼),��ƥ�����NULL��ʾ
id          id 
----------- ----------- 
2           2
NULL        3
--*/

-- �����ⲿ����
SELECT
	*
FROM @a A
	FULL JOIN @b B
		ON A.id = B.id
/*--���(����@a��@b�����еļ�¼,id��ƥ�����NULL��ʾ
id          id 
----------- ----------- 
2           2
NULL        3
1           NULL
--*/

-- ��������
-- a. ʹ�� CROSS JOIN
SELECT
	*
FROM @a A
	CROSS JOIN @b B

-- b. FROM ������, ��ָ���κ�����
SELECT
	*
FROM @a A, @b B
/*--���(��һ�����ÿ����¼��ڶ���������м�¼ƥ��)
id          id 
----------- ----------- 
1           2
2           2
1           3
2           3
--*/
