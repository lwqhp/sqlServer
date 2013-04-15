--��������
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

-- �������������
CREATE FUNCTION dbo.f_Sort(
	@ID char(3) = NULL,  -- ������
	@sort int = 1        -- ˳���
)RETURNS @t_Level TABLE(
		ID char(3),
		sort int)
AS
BEGIN
	DECLARE tb CURSOR LOCAL
	FOR
	SELECT ID FROM tb
	WHERE PID = @ID
		OR (@ID IS NULL AND PID IS NULL)
	OPEN TB
	FETCH tb INTO @ID
	WHILE @@FETCH_STATUS = 0
	BEGIN
		INSERT @t_Level
		VALUES(
			@ID, @sort)

		SET @sort = @sort + 1

		IF @@NESTLEVEL < 32 -- �������� 32 ��ݹ������(�ݹ��������32��)
		BEGIN
			-- �ݹ���ҵ�ǰ�����ӽ��
			INSERT @t_Level
			SELECT * FROM dbo.f_Sort(@ID, @sort)

			SET @sort = @sort + @@ROWCOUNT  -- ����ż����ӽ�����
		END
		FETCH tb INTO @ID
	END
	RETURN
END
GO

--��ʾ���
SELECT 
	A.*
FROM tb A, dbo.f_Sort(DEFAULT, DEFAULT) B
WHERE A.ID = B.ID
ORDER BY B.sort
/*--���
ID   PID  Name
---- ---- ----------
001  NULL ɽ��ʡ
002  001  ��̨��
004  002  ��Զ��
003  001  �ൺ��
005  NULL �Ļ���
006  005  ��Զ��
007  006  С����
--*/
GO

-- ɾ�����Ի���
DROP TABLE tb
DROP FUNCTION dbo.f_Sort