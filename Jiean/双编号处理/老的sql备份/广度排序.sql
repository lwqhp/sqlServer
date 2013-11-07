-- ��������
DECLARE @t TABLE(
	ID char(3),
	PID char(3),
	Name nvarchar(10))
INSERT @t SELECT '001', NULL , N'ɽ��ʡ'
UNION ALL SELECT '002', '001', N'��̨��'
UNION ALL SELECT '004', '002', N'��Զ��'
UNION ALL SELECT '003', '001', N'�ൺ��'
UNION ALL SELECT '005', NULL , N'�Ļ���'
UNION ALL SELECT '006', '005', N'��Զ��'
UNION ALL SELECT '007', '006', N'С����'

-- ���������ʾ����
-- ����ÿ���ڵ�Ĳ������
DECLARE @t_Level TABLE(
	ID char(3),
	Level int
)
DECLARE
	@Level int
SET @Level = 0
INSERT @t_Level
SELECT
	ID, @Level
FROM @t
WHERE PID IS NULL  -- ��һ����
WHILE @@ROWCOUNT > 0  --  ѭ���������н��Ĳ��
BEGIN
	SET @Level = @Level + 1
	INSERT @t_Level
	SELECT A.ID, @Level
	FROM @t A, @t_Level B
	WHERE A.PID = B.ID
		AND B.Level = @Level - 1
END

-- ��ʾ���
SELECT
	A.*
FROM @t A, @t_Level B
WHERE A.ID = B.ID
ORDER BY B.Level, B.ID
/*--���
ID   PID  Name
---- ---- ----------
001  NULL ɽ��ʡ
005  NULL �Ļ���
002  001  ��̨��
003  001  �ൺ��
006  005  ��Զ��
004  002  ��Զ��
007  006  С����
--*/
