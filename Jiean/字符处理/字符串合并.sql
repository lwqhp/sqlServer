
/*
�ѱ����ֶμ�¼����һ����Ҫ��ϲ���һ���ַ����ֶ�
*/

--3.3.1 ʹ���α귨�����ַ����ϲ������ʾ����
--���������
CREATE TABLE tb(
	col1 varchar(10),
	col2 int)
INSERT tb SELECT 'a',1
UNION ALL SELECT 'a',2
UNION ALL SELECT 'b',1
UNION ALL SELECT 'b',2
UNION ALL SELECT 'b',3

--�ϲ�����
--�������������
DECLARE @t TABLE(
	col1 varchar(10),
	col2 varchar(100))

--�����α겢���кϲ�����
DECLARE tb CURSOR LOCAL
FOR
SELECT 
	col1,col2 
FROM tb
ORDER BY  col1,col2
DECLARE 
	@col1_old varchar(10),
	@col1 varchar(10),
	@col2 int,
	@s varchar(100)
OPEN tb
FETCH tb INTO @col1,@col2
WHILE @@FETCH_STATUS = 0
BEGIN
	-- ��� col �ĵ�ǰ��¼ֵ��������¼һ��, ��ʾ����Ҫ���ϲ�����, �ϲ����������� @s ��
	IF @col1 = @col1_old  
		SELECT 
			@s = @s + ',' + CAST(@col2 as varchar)
	ELSE
	BEGIN
		-- ��� col �ĵ�ǰ��¼ֵ��������¼��һ��, ��֮ǰ�ĺϲ������������
		INSERT @t
		SELECT
			@col1_old, @s
		WHERE @s IS NOT NULL

		-- ��ʼ�µĺϲ�����
		SELECT 
			@s = CAST(@col2 as varchar),
			@col1_old = @col1
	END
	FETCH tb INTO @col1,@col2
END
CLOSE tb
DEALLOCATE tb

-- �ڽ�����в������һ�κϲ��Ľ��
INSERT @t
SELECT
	@col1_old, @s
WHERE @s IS NOT NULL

--��ʾ�����ɾ����������
SELECT * FROM @t
DROP TABLE tb
/*--���
col1       col2
---------- -----------
a          1,2
b          1,2,3
--*/



/*==============================================*/


--3.3.2 ʹ���û����庯�������SELECT��������ַ����ϲ������ʾ��
--���������
--���������
CREATE TABLE tb(
	col1 varchar(10),
	col2 int)
INSERT tb SELECT 'a',1
UNION ALL SELECT 'a',2
UNION ALL SELECT 'b',1
UNION ALL SELECT 'b',2
UNION ALL SELECT 'b',3
GO

--�ϲ�������
CREATE FUNCTION dbo.f_str(
	@col1 varchar(10)
)RETURNS varchar(100)
AS
BEGIN
	DECLARE
		@re varchar(100)
	SET @re = ''
	SELECT
		@re = @re + ',' + CAST(col2 as varchar)
	FROM tb
	WHERE col1 = @col1

	RETURN(STUFF(@re, 1, 1, ''))
END
GO

--���ú���
SELECT
	col1,
	col2 = dbo.f_str(col1)
FROM tb
GROUP BY col1

--ɾ������
DROP TABLE tb
DROP FUNCTION dbo.f_str
/*--���
col1       col2
---------- -----------
a          1,2
b          1,2,3
--*/


/*==============================================*/


--3.3.3 ʹ����ʱ��ʵ���ַ����ϲ������ʾ��
--���������
CREATE TABLE tb(
	col1 varchar(10),
	col2 int)
INSERT tb SELECT 'a',1
UNION ALL SELECT 'a',2
UNION ALL SELECT 'b',1
UNION ALL SELECT 'b',2
UNION ALL SELECT 'b',3

--�ϲ�����
-- a. �������ݲ��洢�������ʱ��
SELECT
	col1,
	col2 = CAST(col2 as varchar(100)) 
INTO #t FROM tb
ORDER BY col1,col2

DECLARE
	@col1 varchar(10),
	@col2 varchar(100)

-- b. ͨ�������ۼ�ÿ�� col1 �� col2 ��ֵ
UPDATE #t SET 
	@col2 = CASE
				WHEN @col1 = col1 THEN @col2 + ',' + col2
				ELSE col2
			END,
	@col1 = col1,
	col2 = @col2
-- ��ʾ���´�������ʱ��
SELECT * FROM #t
/*-- ���
col1       col2
---------- -------------
a          1
a          1,2
b          1
b          1,2
b          1,2,3
--*/
--�õ����ս��
SELECT 
	col1,
	col2 = MAX(col2)
FROM #t
GROUP BY col1
/*--���
col1       col2
---------- -----------
a          1,2
b          1,2,3
--*/
--ɾ������
DROP TABLE tb,#t

/*==============================================*/

--3.3.4.1 ÿ�� <=2 ����¼�ĺϲ�
--���������
CREATE TABLE tb(col1 varchar(10),col2 int)
INSERT tb SELECT 'a',1
UNION ALL SELECT 'a',2
UNION ALL SELECT 'b',1
UNION ALL SELECT 'b',2
UNION ALL SELECT 'c',3

--�ϲ�����
SELECT col1,
    col2=CAST(MIN(col2) as varchar)
        +CASE 
            WHEN COUNT(*)=1 THEN ''
            ELSE ','+CAST(MAX(col2) as varchar)
        END
FROM tb
GROUP BY col1
DROP TABLE tb
/*--���
col1       col2      
---------- ----------
a          1,2
b          1,2
c          3
--*/

--3.3.4.2 ÿ�� <=3 ����¼�ĺϲ�
--���������
CREATE TABLE tb(col1 varchar(10),col2 int)
INSERT tb SELECT 'a',1
UNION ALL SELECT 'a',2
UNION ALL SELECT 'b',1
UNION ALL SELECT 'b',2
UNION ALL SELECT 'b',3
UNION ALL SELECT 'c',3

--�ϲ�����
SELECT col1,
    col2=CAST(MIN(col2) as varchar)
        +CASE 
            WHEN COUNT(*)=3 THEN ','
                +CAST((SELECT col2 FROM tb WHERE col1=a.col1 AND col2 NOT IN(MAX(a.col2),MIN(a.col2))) as varchar)
            ELSE ''
        END
        +CASE 
            WHEN COUNT(*)>=2 THEN ','+CAST(MAX(col2) as varchar)
            ELSE ''
        END
FROM tb a
GROUP BY col1
DROP TABLE tb
/*--���
col1       col2
---------- ------------
a          1,2
b          1,2,3
c          3
--*/
GO
