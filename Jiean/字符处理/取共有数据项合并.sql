
/*
������ID���飬��ÿ��ID����COL�еĵ�����¼�����е���������ȡ�������������Ϊһ����¼��
*/
-- ʾ������
CREATE TABLE tb(
	ID int,
	col varchar(50))
INSERT tb SELECT 1,'1,2,3,4'
UNION ALL SELECT 1,'1,3,4'
UNION ALL SELECT 1,'1,4'
UNION ALL SELECT 2,'11,3,4'
UNION ALL SELECT 2,'1,33,4'
UNION ALL SELECT 3,'1,3,4'
GO

-- �ϲ�������Ĵ�����
CREATE FUNCTION dbo.f_mergSTR(
	@ID int
)RETURNS varchar(50)
AS
BEGIN
	DECLARE @t TABLE(
		ID int IDENTITY,
		b bit)
	--�ֲ�������,������col�������Ϊ50,����ֻ��Ҫ1��50�ķֲ�����¼
	INSERT @t(
		b)
	SELECT TOP 50
		0 
	FROM dbo.syscolumns A, dbo.syscolumns B

	DECLARE
		@r varchar(50)
	SET @r = ''
	SELECT
		-- �ϲ�������������
		@r = @r + ',' + s
	FROM(
		-- �ֲ��ַ���
		SELECT
			s = SUBSTRING(A.col, B.ID, CHARINDEX(',', A.col + ',', B.ID) - B.ID)
		FROM tb A, @t B
		WHERE a.ID = @ID
			AND b.ID <= LEN(A.col) 
			AND SUBSTRING(',' + A.col, B.ID, 1) = ','
		GROUP BY SUBSTRING(A.col, B.ID, CHARINDEX(',', A.col + ',', B.ID) - B.ID)
		-- ����ֲ���������ĸ���������¼����ͬ, �������������ڸ�������м�¼�д���, �����˼�¼
		HAVING COUNT(*) = (SELECT COUNT(*) FROM tb WHERE ID = @ID)
	)A
	ORDER BY s -- �������ɵĽ���е�������λ��(���Ҫ����������, ����Ҫ����������ת��)

	RETURN(STUFF(@r, 1, 1, ''))
END
GO

--�����û�����ʵ�ֽ�������ѯ
SELECT
	ID,
	col = dbo.f_mergStr(ID)
FROM tb
GROUP BY ID
GO

-- ɾ��ʾ������
DROP TABLE tb
DROP FUNCTION dbo.f_mergSTR
