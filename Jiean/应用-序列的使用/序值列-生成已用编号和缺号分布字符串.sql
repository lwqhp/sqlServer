-- �������ñ�ŷֲ��ַ����ĺ���
CREATE FUNCTION dbo.f_GetStrSeries(
	@col1 varchar(10)
)RETURNS varchar(8000)
AS
BEGIN
	DECLARE
		@re varchar(8000),
		@pid int
	SELECT
		@re = '',
		@pid = -1  -- ����ʼ��ŵ�ǰһ���������Ϊ -1, �������Դ����ʼ��� 1(�����ʼ���Ϊ1)
	SELECT
		@re = CASE
				-- ����Ҫ�����������
				WHEN col2 = @pid + 1 THEN @re
			ELSE @re
				+ CASE 
					-- �ж���������Ƿ�ֻ��һ��(���� 1, 2, 4, 6 �е� 4), �����, �򲻴���
					WHEN RIGHT(@re, CHARINDEX(',', REVERSE(@re) + ',') - 1) = @pid THEN ''
					-- ����Ƕ��������ŵĽ������, ����Ͻ������
					ELSE CAST(- @pid as varchar)
				END
				+ ',' + CAST(col2 as varchar) 
			END,
		@pid = col2
	FROM tb
	WHERE col1 = @col1
	ORDER BY col2
	RETURN(
		STUFF(@re, 1, 2, '')
		+ CASE 
			WHEN RIGHT(@re, CHARINDEX(',', REVERSE(@re)+ ',') - 1) = @pid THEN ''
			ELSE CAST(- @pid as varchar)
		END)
END
GO

--����ȱ�ŷֲ��ַ����ĺ���
CREATE FUNCTION dbo.f_GetStrNSeries(
@col1 varchar(10)
)RETURNS VARCHAR(8000)
AS
BEGIN
	DECLARE
		@re varchar(8000),
		@pid int
	SELECT
		@re = '',
		@pid = 0
	SELECT
		@re = CASE 
				-- ����Ҫ�����������
				WHEN col2 = @pid + 1 THEN @re
				ELSE @re + ','
					-- ȱ�ŵĿ�ʼ���(��һ����¼�ı�� + 1)
					+ CAST(@pid + 1 as varchar)
					-- ���ȱ�ŵĽ�������뿪ʼ���һ��, �򲻴���, �������ȱ�ŵĽ������
					+ CASE
						WHEN @pid + 1 = col2 - 1 THEN ''
						ELSE CAST(1 - col2 as varchar)
					END
				END,
		@pid = col2
	FROM tb
	WHERE col1 = @col1
	ORDER BY col2
	RETURN(STUFF(@re, 1, 1, ''))
END
GO

--���ò���
--��������
CREATE TABLE tb(
	col1 varchar(10),
	col2 int)
INSERT tb SELECT 'a', 2
UNION ALL SELECT 'a', 3
UNION ALL SELECT 'a', 5
UNION ALL SELECT 'a', 8
UNION ALL SELECT 'a', 9
UNION ALL SELECT 'b', 1
UNION ALL SELECT 'b', 5
UNION ALL SELECT 'b', 6
UNION ALL SELECT 'b', 7

SELECT * FROM dbo.tb
--��ѯ
SELECT 
	col1,
	col2_Series = dbo.f_GetStrSeries(col1),
	col2_Series = dbo.f_GetStrNSeries(col1)
FROM tb
GROUP BY col1
/*--���
col1       col2_Series       col2_Series 
-------------- ------------------------ --------------
a          2-3,5,8-9        1,4,6-7
b          1,5-7           2-4
--*/
GO

-- ɾ������
DROP TABLE tb
DROP FUNCTION dbo.f_GetStrSeries, dbo.f_GetStrNSeries