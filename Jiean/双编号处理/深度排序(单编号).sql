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
-- ����ÿ�����ı����ۼ�(�൱�ڵ���ŷ��ı���)
DECLARE @t_Level TABLE(
	ID char(3),
	Level int,
	Sort varchar(8000)
)
DECLARE
	@Level int
SET @Level = 0
INSERT @t_Level(
	ID, Level, Sort)
SELECT
	ID, @Level, ID
FROM @t
WHERE PID IS NULL
WHILE @@ROWCOUNT > 0
BEGIN
	SET @Level = @Level + 1
	INSERT @t_Level(
		ID, Level, Sort)
	 SELECT
		A.ID, @Level, B.Sort + A.ID
	FROM @t A, @t_Level B
	WHERE A.PID = B.ID
		AND B.Level = @Level - 1
END

-- ��ʾ���
SELECT
	A.*
FROM @t A, @t_Level B
WHERE A.ID = B.ID
ORDER BY B.Sort
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

-- ��ʾ����ͽ��
SELECT
	SPACE(B.Level * 2) + N'|-- ' + A.Name
FROM @t A, @t_Level B
WHERE A.ID = B.ID
ORDER BY B.Sort
/*--���
|-- ɽ��ʡ
  |-- ��̨��
    |-- ��Զ��
  |-- �ൺ��
|-- �Ļ���
  |-- ��Զ��
    |-- С����
--*/