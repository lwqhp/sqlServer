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

-- ɾ����������(ͬ��ɾ����ɾ�����������ӽ��)
CREATE TRIGGER dbo.tr_DeleteNode
ON tb
FOR DELETE
AS
-- ���û������ɾ�������ļ�¼,ֱ���˳�
IF @@ROWCOUNT = 0
	RETURN 

-- �������б�ɾ�������ӽ��
DECLARE @t TABLE(
	ID int,
	Level int
)
DECLARE
	@Level int
SET @Level = 1
INSERT @t
SELECT
	A.ID, @Level
FROM tb A, deleted D
WHERE A.PID = D.ID
WHILE @@ROWCOUNT > 0
BEGIN
	SET @Level = @Level + 1

	INSERT @t
	SELECT A.ID, @Level
	FROM tb A, @t B
	WHERE A.PID = B.ID
		AND B.Level = @Level - 1
END
-- ɾ�����
DELETE A
FROM tb A, @t B
WHERE A.ID = B.ID
GO

--ɾ��
DELETE FROM tb
WHERE ID IN(2, 3, 5)
SELECT * FROM tb
/*--���
ID          PID         Name
----------- ----------- ----------
1           NULL        ɽ��ʡ
--*/
GO

-- ɾ�����Ա�
DROP TABLE tb