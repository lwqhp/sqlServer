-- ����
CREATE TABLE tb(
	ID int             -- ��ĿID
		PRIMARY KEY,
	Type int,          -- ����
	col1 nvarchar(10)  -- ������Ҫ���ֶ�
)
INSERT tb SELECT 1, 1, N'����1'
UNION ALL SELECT 2, 1, N'����2'
UNION ALL SELECT 3, 3, N'����3'
UNION ALL SELECT 4, 3, N'����4'
UNION ALL SELECT 5, 3, N'����5'
UNION ALL SELECT 6, 3, N'����6'
GO

-- �����Ծ�Ĵ������
CREATE PROC dbo.p_test
	@�Ծ���� int,
	@������   varchar(100)  -- ��ʽ: ����:��Ŀ��, �ö��ŷָ��������:��Ŀ��
AS
SET NOCOUNT ON
-- �������
IF ISNULL(@�Ծ����, 0) < 1
	RETURN
IF ISNULL(@������, '') = ''
	RETURN

-- �ֲ�����
DECLARE @tb_type TABLE(
	Type int,
	Nums int
)
DECLARE
	@value varchar(100)
WHILE @������ > ''
BEGIN
	SELECT
		-- ȡ��һ�����ͺ���Ŀ��
		@value = LEFT(@������, CHARINDEX(',', @������ + ',') - 1),
		@������ = STUFF(@������, 1, CHARINDEX(',', @������ + ','), '')

	-- ��¼���ͺ���Ŀ��
	INSERT @tb_type(
		Type, Nums)
	SELECT
		LEFT(@value, CHARINDEX(':', @value + ':') - 1),
		STUFF(@value, 1, CHARINDEX(':', @value + ':'), '')
END

-- ʹ���α�, Ϊÿ�����������ȡ��Ŀ
DECLARE @tb_re TABLE(
	GID int IDENTITY,
	Type int,
	ID int)

DECLARE CUR_tb CURSOR LOCAL
FOR
SELECT
	Type,              -- ����
	Nums * @�Ծ����   -- �������ܹ���Ҫȡ����Ŀ��
FROM @tb_type

DECLARE
	@Type int,
	@Nums int
OPEN CUR_tb
FETCH CUR_tb INTO @Type, @Nums
WHILE @@FETCH_STATUS=0
BEGIN
	-- ��ȡָ�����͵���Ŀ, ֱ���ﵽָ��������
	WHILE @Nums > 0
	BEGIN
		SET ROWCOUNT @Nums   -- ��������ȡ�ļ�¼��
		-- �����ȡָ�����͵���Ŀ
		INSERT @tb_re(
			Type, ID)
		SELECT
			@Type, ID
		FROM tb 
		WHERE Type = @Type
		ORDER BY NEWID()

		-- �����Ѿ���ȡ����Ŀ��
		SET @Nums = @Nums - @@ROWCOUNT
	END

	FETCH CUR_tb INTO @Type, @Nums
END
CLOSE CUR_tb
DEALLOCATE CUR_tb

--��ʾ���
SET ROWCOUNT 0
SELECT 
	�Ծ��� = (B.gid - B1.gid) / C.Nums + 1,
	A.*
FROM tb A,
	@tb_re B,
	@tb_type C,
	(
		-- ���ڼ����Ծ���
		SELECT
			Type, gid = MIN(gid)
		FROM @tb_re
		GROUP BY Type
	)B1
WHERE A.ID = B.ID 
	AND B.Type = C.Type
	AND B.Type = B1.Type
ORDER BY �Ծ���, B.gid
GO

--����
EXEC dbo.p_test 2, '1:1,3:2'
/*--���֮һ
�Ծ���        ID          Type        col1
----------- ----------- ----------- ----------
1           2           1           ����2
1           5           3           ����5
1           3           3           ����3
2           1           1           ����1
2           4           3           ����4
2           6           3           ����6
--*/
GO

-- ɾ������
DROP PROC dbo.p_test
DROP TABLE tb