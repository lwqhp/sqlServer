
/*
��null ֵ��ʾ��ֵδ֪�������û����Ժ���ӵ����ݣ���ֵ��ͬ�ڿհ׻���ֵ��û��������ȵĿ�ֵ��
�Ƚ�������ֵ���򽫿�ֵ���κ�����������ȽϾ�����δ֪nuknown
*/ 
-- NULL �� IN �� NOT IN ��ѯ��Ӱ�����

-- ��������
DECLARE @1 TABLE(
	col1 int)

INSERT @1 SELECT 1
UNION ALL SELECT NULL
UNION ALL SELECT 2

DECLARE @2 TABLE(
	col1 int)

INSERT @2 SELECT 1

-- ��ѯ
SELECT
	[@1�ܼ�¼��] = COUNT(*)
FROM @1
-- ���: 3

SELECT
	[@1��@2���д��ڵļ�¼��] = COUNT(*)
FROM @1
WHERE col1 IN(
		SELECT col1 FROM @2)
-- ���: 1

SELECT 
	[@1��@2���в����ڵļ�¼��] = COUNT(*)
FROM @1
WHERE col1 NOT IN(
		SELECT col1 FROM @2)
-- ���: 1
-- ��ѯ���˵��: @2����1,��@1��nullֵȥ��@2��ֵ�Ƚϣ����صĽ����null

-- ��@2�в���һ��NULLֵ
INSERT @2 SELECT NULL

SELECT
	[@1��@2���д��ڵļ�¼��] = COUNT(*)
FROM @1
WHERE col1 IN(
		SELECT col1 FROM @2)
-- ���: 1


SELECT
	[@1��@2���д��ڵļ�¼��] = COUNT(*)
FROM @1
WHERE col1 NOT IN(		
		SELECT col1 FROM @2)
-- ���: 0
-- ��ѯ���˵��: @2����nullֵ��¼����@1������ֵ��@2��null�Ƚ϶��᷵��null, ���@2�е�nullֵƥ�䣬����0


--�ȵ�@1�е�null��¼���ٲ���
delete @1 from @1 where col1 is null

SELECT
	[@1��@2���д��ڵļ�¼��] = COUNT(*)
FROM @1
WHERE col1 NOT IN(		
		SELECT col1 FROM @2)
-- ���: 0
-- ��ѯ���˵��: @2����nullֵ��¼����@1������ֵ��@2��null�Ƚ϶��᷵��null, ���@2�е�nullֵƥ�䣬����0
GO





-- ʹ�� EXISTS ��ѯ���� NULL ֵ�Բ�ѯ�����Ӱ��
-- ��������
DECLARE @1 TABLE(
	col1 int)

INSERT @1 SELECT 1
UNION ALL SELECT NULL
UNION ALL SELECT 2

DECLARE @2 TABLE(
	col1 int)

INSERT @2 SELECT 1
UNION ALL SELECT NULL

SELECT
	[@1��@2���д��ڵļ�¼��] = COUNT(*) 
FROM @1 A
WHERE EXISTS(
		SELECT * FROM @2
		WHERE col1 = A.col1)
-- ���: 1

SELECT
	[@1��@2���в����ڵļ�¼��] = COUNT(*) 
FROM @1 a
WHERE NOT EXISTS(
		SELECT * FROM @2
		WHERE col1 = A.col1)
-- ���: 2
