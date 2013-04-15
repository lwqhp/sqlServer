CREATE TABLE Item(
	ID int,
	Name nvarchar(10),
	Wast decimal(2,2)
)
INSERT Item SELECT 1, N'A��Ʒ', 0.01
UNION  ALL  SELECT 2, N'B��Ʒ', 0.02
UNION  ALL  SELECT 3, N'C��Ʒ', 0.10
UNION  ALL  SELECT 4, N'D���', 0.15
UNION  ALL  SELECT 5, N'E����', 0.03
UNION  ALL  SELECT 6, N'F����', 0.01
UNION  ALL  SELECT 7, N'G���', 0.02

CREATE TABLE Bom(
	ItemID int,
	ChildId int
)
INSERT Bom SELECT 1, 4
UNION  ALL SELECT 1, 7   -- A ��Ʒ�� D ����� G ������
UNION  ALL SELECT 2, 1
UNION  ALL SELECT 2, 6
UNION  ALL SELECT 2, 7   -- B ��Ʒ�� F ���ϼ� G ������
UNION  ALL SELECT 4, 5
UNION  ALL SELECT 4, 6    -- D ����� F �������
UNION  ALL SELECT 3 ,2
UNION  ALL SELECT 3, 1    -- C ��Ʒ�� A ��Ʒ�� B ��Ʒ���
GO

CREATE FUNCTION dbo.f_Bom(
	@ItemIDs varchar(1000),	-- Ҫ��ѯ�����嵥���������Ĳ�Ʒ����б�(���ŷָ�)
	@Num   int				-- Ҫ����������
)RETURNS @t TABLE(
				ItemID int,
				ChildId int,
				Nums int,
				Level int)
AS
BEGIN
	DECLARE @Level int
	SET @Level = 1

	INSERT @t(
		ItemID, ChildId, Nums, Level)
	SELECT
		A.ItemID, A.ChildId,
		ROUND(@Num / (1 - B.Wast), 0),
		@Level
	FROM Bom A, Item B
	WHERE A.ChildId = B.ID
		AND CHARINDEX(',' + RTRIM(A.ItemID) + ',', ',' + @ItemIDs + ',') > 0

	WHILE @@ROWCOUNT > 0 AND @Level < 140  -- ���ѭ�� 140 ��
	BEGIN
		SET @Level = @Level + 1

		INSERT @t(
			ItemID, ChildId, Nums, Level)
		SELECT
			A.ItemID, B.ChildId,
			ROUND(A.Nums / (1 - C.Wast), 0),
			@Level
		FROM @t A, Bom B, Item C
		WHERE A.ChildId = B.ItemID
			AND B.ChildId = C.ID
			AND A.Level = @Level - 1
	END
	RETURN
END
GO

-- ���ú���չ����Ʒ 1��2��3 �Ľṹ���������� 10 ����Ʒʱ,����Ҫ���ٸ����
SELECT
	A.ItemID,
	ItemName = B.Name,
	A.ChildId,
	ChildName = C.Name,
	A.Nums,
	A.Level
FROM dbo.f_Bom('1,2,3', 10) A, Item B, Item C
WHERE A.ItemID = B.ID
	AND A.ChildId = C.ID
ORDER BY A.ItemID, A.Level, A.ChildId
GO

-- ɾ������
DROP TABLE Item, bom
DROP FUNCTION dbo.f_Bom