-- ��������
CREATE TABLE tb(
	ID char(3),
	PID char(3),
	Name nvarchar(10)
)
INSERT tb SELECT '001', NULL , N'ɽ��ʡ'
UNION ALL SELECT '002', '001', N'��̨��'
UNION ALL SELECT '004', '002', N'��Զ��'
UNION ALL SELECT '003', '001', N'�ൺ��'
UNION ALL SELECT '005', NULL , N'�Ļ���'
UNION ALL SELECT '006', '005', N'��Զ��'
UNION ALL SELECT '007', '006', N'С����'
GO

-- A. ��ѯָ����㼰�������ӽ��ĺ���
CREATE FUNCTION dbo.f_Cid(
	@ID char(3)
)RETURNS @t_Level TABLE(
	ID char(3),
	Level int)
AS
BEGIN
	DECLARE
		@Level int
	SET @Level = 1
	INSERT @t_Level
	SELECT
		@ID, @Level
	WHILE @@ROWCOUNT > 0
	BEGIN
		SET @Level = @Level + 1
		INSERT @t_Level
		SELECT
			A.ID, @Level
		FROM tb A, @t_Level B
		WHERE A.PID = B.ID
			AND B.Level = @Level - 1
	END
	RETURN
END
GO

-- ���ú�����ѯ 002 ���������ӽ��
SELECT 
	A.*
FROM tb A, dbo.f_Cid('002') B
WHERE A.ID = B.ID
/*--���
ID   PID  Name
---- ---- ----------
002  001  ��̨��
004  002  ��Զ��
--*/
GO


-- B. ��ѯָ����㼰�����и����ĺ���(�ุ���)
CREATE FUNCTION dbo.f_Pid(
	@ID char(3)
)RETURNS @t_Level TABLE(
	ID char(3),
	Level int)
AS
BEGIN
	DECLARE
		@Level int
	SET @Level = 1
	INSERT @t_Level
	SELECT
		@ID, @Level
	WHILE @@ROWCOUNT > 0
	BEGIN
		SET @Level = @Level + 1
		INSERT @t_Level
		SELECT
			A.PID, @Level
		FROM tb A, @t_Level B
		WHERE A.ID = B.ID
			AND B.Level = @Level - 1
	END
	RETURN
END
GO


-- C. ��ѯָ����㼰�����и����ĺ���(�������)
CREATE FUNCTION dbo.f_Pid_Single(
	@ID char(3))
RETURNS @t_Level TABLE(
	ID char(3))
AS
BEGIN
	INSERT @t_Level
	SELECT @ID

	SELECT
		@ID = PID
	FROM tb
	WHERE ID = @ID
		AND PID IS NOT NULL
	WHILE @@ROWCOUNT > 0
	BEGIN
		INSERT @t_Level
		SELECT
			@ID

		SELECT
			@ID = PID
		FROM tb
		WHERE ID = @ID
			AND PID IS NOT NULL
	END
	RETURN
END
GO


-- ɾ������
DROP TABLE tb
DROP FUNCTION dbo.f_Cid, dbo.f_Pid, dbo.f_Pid_Single