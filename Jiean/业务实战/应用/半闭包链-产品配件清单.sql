

/*
ERP 生产BOM表展开，每一个产品由一或多个半成品构成，半成品又由多个物料构成，产品也可能是另一个产品的构成部份
这是一个半闭包链结构，使用一个关系表，左右节点表示产品的构成关系
*/
CREATE TABLE Item(
	ID int,
	Name nvarchar(10),
	Wast decimal(2,2)
)
INSERT Item SELECT 1, N'A产品', 0.01
UNION  ALL  SELECT 2, N'B产品', 0.02
UNION  ALL  SELECT 3, N'C产品', 0.10
UNION  ALL  SELECT 4, N'D配件', 0.15
UNION  ALL  SELECT 5, N'E物料', 0.03
UNION  ALL  SELECT 6, N'F物料', 0.01
UNION  ALL  SELECT 7, N'G配件', 0.02


CREATE TABLE Bom(
	ItemID int,	--主节点
	ChildId int	--次节点
)
INSERT Bom SELECT 1, 4
UNION  ALL SELECT 1, 7   -- A 产品由 D 配件和 G 配件组成
UNION  ALL SELECT 2, 1
UNION  ALL SELECT 2, 6
UNION  ALL SELECT 2, 7   -- B 产品由 F 物料及 G 配件组成
UNION  ALL SELECT 4, 5
UNION  ALL SELECT 4, 6    -- D 配件由 E 物料和 F 物料组成
UNION  ALL SELECT 3 ,2
UNION  ALL SELECT 3, 1    -- C 产品由 A 产品和 B 产品组成
GO

/*
select * from Item
select * from Bom
*/

ALTER  FUNCTION dbo.f_Bom(
	@ItemIDs varchar(1000),	-- 要查询物料清单及生产量的产品编号列表(逗号分隔)
	@Num   int				-- 要生产的数量
)RETURNS @t TABLE(
				ItemID int,
				ChildId int,
				Nums int,
				Level int)
AS
BEGIN
	DECLARE @Level int
	SET @Level = 1

	--通过链的两个节点，把节点按层次链接起来
	--INSERT @t(
	--	ItemID, ChildId, Nums, Level)
	--SELECT
	--	A.ItemID, A.ChildId,
	--	ROUND(@Num / (1 - B.Wast), 0),
	--	@Level
	--FROM Bom A 
	--INNER JOIN Item B ON a.childID = b.id
	--WHERE CHARINDEX(',' + RTRIM(A.ItemID) + ',', ',' + @ItemIDs + ',') > 0

	--WHILE @@ROWCOUNT > 0 AND @Level < 140  -- 最多循环 140 层
	--BEGIN
	--	SET @Level = @Level + 1

	--	INSERT @t(
	--		ItemID, ChildId, Nums, Level)
	--	SELECT
	--		A.ItemID, B.ChildId,
	--		ROUND(A.Nums / (1 - C.Wast), 0),
	--		@Level
	--	FROM @t A, Bom B, Item C
	--	WHERE A.ChildId = B.ItemID
	--		AND B.ChildId = C.ID
	--		AND A.Level = @Level - 1
	--END
	;WITH tmp AS(
		SELECT A.ItemID, A.ChildId,	CAST(ROUND(@Num / (1 - B.Wast), 0) AS INT) AS Nums,1 AS [Level]
		FROM Bom A 
		INNER JOIN Item B ON a.childID = b.id
		WHERE CHARINDEX(',' + RTRIM(A.ItemID) + ',', ',' + @ItemIDs + ',') > 0
		UNION ALL
		SELECT A.ItemID, B.ChildId,	CAST(ROUND(A.Nums / (1 - C.Wast), 0) AS INT) AS Nums,a.[level]+1 AS [Level]
		FROM tmp A
		INNER JOIN Bom B ON a.childid = b.itemID
		INNER JOIN Item C ON b.childid = c.id
	)
	INSERT INTO  @t
	SELECT * FROM tmp
	
	RETURN
END
GO

-- 调用函数展开产品 1、2、3 的结构及计算生产 10 个产品时,各需要多少个配件
SELECT	A.ItemID,	ItemName = B.Name,	A.ChildId,	ChildName = C.Name,	A.Nums,	A.Level
FROM dbo.f_Bom('1,2,3', 10) A, Item B, Item C
WHERE A.ItemID = B.ID
	AND A.ChildId = C.ID
ORDER BY A.ItemID, A.Level, A.ChildId
GO

