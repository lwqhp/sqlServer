-- ȡ�����������ͼ
CREATE VIEW dbo.v_RAND
AS
SELECT re = STUFF(RAND(), 1, 2, '') -- STUFF��Ŀ����ȥ��С��λ, ���ҽ�����ת��Ϊ�ַ���
GO

--���������ŵĺ���
CREATE FUNCTION dbo.f_RANDBH(
	@BHLen int
)RETURNS varchar(50)
AS
BEGIN
	DECLARE
		@r varchar(50)

	IF NOT(ISNULL(@BHLen, 0) BETWEEN 1 AND 50)
		SET @BHLen = 10

	SET @r = ''
	-- ѭ��ֱ�����ɵı�ų��� >= ָ���ĳ���
	WHILE LEN(@r) < @BHLen
		SELECT @r = @r
			+ CHAR(
					-- ���������ĸ��Сд
					CASE WHEN SUBSTRING(re, 1, 1) > 5 THEN 65 ELSE 97 END
					-- �������ǰ 3 λ����һ����ĸ
					+ (
						SUBSTRING(re, 1, 1) + SUBSTRING(re, 2, 1) + SUBSTRING(re, 3, 1)
					) % 26)
			+ CHAR(
					-- ���������ĸ��Сд
					CASE WHEN SUBSTRING(re, 4, 1) > 5 THEN 65 ELSE 97 END 
					-- �������ǰ 4 - 6 λ����һ����ĸ
					+ (
						SUBSTRING(re, 4, 1) + SUBSTRING(re, 5, 1) + SUBSTRING(re, 6, 1)
					) % 26)
		FROM dbo.v_RAND
	RETURN(LEFT(@r, @BHLen))
END
GO

--����
SELECT dbo.f_RANDBH(6),dbo.f_RANDBH(8)
--���: UJXIJD  PAPGTQUX
GO

-- ɾ�����Ի���
DROP FUNCTION dbo.f_RANDBH
DROP VIEW dbo.v_RAND
