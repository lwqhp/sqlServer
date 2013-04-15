CREATE TABLE tb(
	ID int,
	PID int,
	Name nvarchar(10))
INSERT tb SELECT 1, NULL, N'ɽ��ʡ'
UNION ALL SELECT 2, 1   , N'��̨��'
UNION ALL SELECT 4, 2   , N'��Զ��'
UNION ALL SELECT 3, 1   , N'�ൺ��'
UNION ALL SELECT 5, NULL, N'�Ļ���'
UNION ALL SELECT 6, 5   , N'��Զ��'
UNION ALL SELECT 7, 6   , N'С����'
GO

-- a. ��㸴�ƴ�����(��������㷨)
CREATE FUNCTION dbo.f_CopyNode(
	@ID int,			-- ���ƴ˽���µ������ӽ��
	@PID int,			-- �� @ID �µ������ӽ�㸴�Ƶ��˽������
	@NewID int = NULL	-- �±���Ŀ�ʼֵ,���ָ��Ϊ NULL,��Ϊ���е������� + 1
)RETURNS @t TABLE(
			OldID int, 
			ID int,
			PID int)
AS
BEGIN
	-- ��һ�����ı��
	IF @NewID IS NULL
		SELECT
			@NewID = COUNT(*) + 1
		FROM tb

	DECLARE CUR_tb CURSOR LOCAL
	FOR
	SELECT -- Ҫ���ƽ��ĵ�һ����
		ID
	FROM tb
	WHERE PID = @ID
	OPEN CUR_tb
	FETCH CUR_tb INTO @ID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT @t(
			OldID, ID, PID)
		VALUES(
			@ID, @NewID, @PID)

		-- ��ѯ��ǰ���������ӽ��
		SET @NewID = @NewID + 1
		IF @@NESTLEVEL < 32 -- ����ݹ����δ����32��(�ݹ��������32��)
		BEGIN
			-- �ݹ���ҵ�ǰ�����ӽ��
			DECLARE
				@PID1 int
			SET @PID1 = @NewID - 1
			INSERT @t(
				OldID, ID, PID)
			SELECT * FROM dbo.f_CopyNode(@ID, @PID1, @NewID)
			SET @NewID = @NewID + @@ROWCOUNT  --����ż����ӽ�����
		END

		FETCH CUR_tb INTO @ID
	END
	CLOSE CUR_tb
	DEALLOCATE CUR_tb

	RETURN
END
GO

-- ���ú�������� 1 ����������ӽ�㸴�Ƶ���� 5 ����
INSERT tb(
	ID, PID, Name)
SELECT
	A.ID, A.PID, B.Name
FROM dbo.f_CopyNode(1, 5, DEFAULT) A, tb B
WHERE A.OldID = B.ID
SELECT * FROM tb
/*--���
ID          PID         Name
----------- ----------- ----------
1           NULL        ɽ��ʡ
2           1           ��̨��
4           2           ��Զ��
3           1           �ൺ��
5           NULL        �Ļ���
6           5           ��Զ��
7           6           С����
8           5           ��̨��
10          5           �ൺ��
9           8           ��Զ��
--*/
GO


-- ��㸴�ƴ����� (��������㷨)
CREATE FUNCTION dbo.f_CopyNode(
	@ID int,			-- ���ƴ˽���µ������ӽ��
	@PID int,			-- �� @ID �µ������ӽ�㸴�Ƶ��˽������
	@NewID int = NULL	-- �±���Ŀ�ʼֵ�����ָ��Ϊ NULL����Ϊ���е������� + 1
)RETURNS @t TABLE(
			OldID int,
			ID int,
			PID int,
			Level int)
AS
BEGIN
	IF @NewID IS NULL
		SELECT
			@NewID = COUNT(*)
		FROM tb
	ELSE
		SET @NewID = @NewID - 1

	DECLARE
		@Level int
	SET @Level = 1

	-- Ҫ���ƽ��ĵ�һ����
	INSERT @t(
		OldID, PID, Level)
	SELECT
		ID, @PID, @Level
	FROM tb
	WHERE PID = @ID

	WHILE @@ROWCOUNT > 0
	BEGIN
		-- ���ɽ�� ID
		UPDATE @t SET
			@NewID = @NewID + 1,
			ID = @NewID
		WHERE Level = @Level

		-- �ڶ��㼰�����ӽ��
		SET @Level = @Level + 1
		INSERT @t(
			OldID, PID, Level)
		SELECT
			A.ID, B.ID, @Level
		FROM tb A, @t B
		WHERE A.PID = B.OldID
			AND B.Level = @Level - 1
	END
	RETURN
END
GO

-- ɾ������
DROP TABLE tb
DROP FUNCTION dbo.f_CopyNode