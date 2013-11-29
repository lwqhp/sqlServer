CREATE TABLE T_Line(
	ID      nvarchar(10),  -- 公交线路号
	Station nvarchar(10),  -- 站点名称
	Orders  int)           -- 行车方向(通过它反应每个站的上一个、下一个站)
INSERT T_Line 
SELECT N'8路'  ,N'站A', 1 UNION ALL
SELECT N'8路'  ,N'站B', 2 UNION ALL
SELECT N'8路'  ,N'站C', 3 UNION ALL
SELECT N'8路'  ,N'站D', 4 UNION ALL
SELECT N'8路'  ,N'站J', 5 UNION ALL
SELECT N'8路'  ,N'站L', 6 UNION ALL
SELECT N'8路'  ,N'站M', 7 UNION ALL
SELECT N'20路' ,N'站G', 1 UNION ALL
SELECT N'20路' ,N'站H', 2 UNION ALL
SELECT N'20路' ,N'站I', 3 UNION ALL
SELECT N'20路' ,N'站J', 4 UNION ALL
SELECT N'20路' ,N'站L', 5 UNION ALL
SELECT N'20路' ,N'站M', 6 UNION ALL
SELECT N'255路',N'站N', 1 UNION ALL
SELECT N'255路',N'站O', 2 UNION ALL
SELECT N'255路',N'站P', 3 UNION ALL
SELECT N'255路',N'站Q', 4 UNION ALL
SELECT N'255路',N'站J', 5 UNION ALL
SELECT N'255路',N'站D', 6 UNION ALL
SELECT N'255路',N'站E', 7 UNION ALL
SELECT N'255路',N'站F', 8
GO

-- 乘车线路查询存储过程
CREATE PROC dbo.p_qry
	@Station_Start nvarchar(10),
	@Station_Stop  nvarchar(10)
AS
SET NOCOUNT ON
DECLARE
	@l int
SET @l = 0

-- a. 从开始站点查询可能的乘车线路
SELECT
	ID, Station,
	Line = CONVERT(nvarchar(4000), '(' + RTRIM(ID) + ': ' + RTRIM(Station)),
	Orders = Orders,
	[Level] = @l
INTO #
FROM T_Line
WHERE Station = @Station_Start

-- 循环查找所有可能线路, 直到找不到可用线路或者找到达到终止站点的乘车线路
WHILE @@ROWCOUNT > 0 
	AND NOT EXISTS(
			SELECT * FROM #
			WHERE Station = @Station_Stop)
BEGIN
	SET @l = @l + 1
	INSERT #(
		Line, ID, Station, Orders, [Level])
	SELECT 
		Line = A.Line
			+ CASE
					WHEN A.ID = B.ID THEN N'->' + RTRIM(B.Station)
					ELSE N') ∝ (' + RTRIM(B.ID) + N': ' + RTRIM(B.Station)
				END,
		B.ID, B.Station, B.Orders, @l
	FROM # A, T_Line B
	WHERE A.[Level] = @l - 1
		AND(
			(A.Station = B.Station AND A.ID <> B.ID) -- 另一条统一口径
			OR (
				A.ID = B.ID  -- 同一站点的前一站或者下一站
				AND(
					A.Orders = B.Orders + 1 
					OR
					A.Orders = B.Orders - 1)
				)
			)
		AND LEN(A.Line) < 4000
		-- 避免查找已经找过的线路
		AND PATINDEX('%[ >]' + B.Station + '[-)]%', A.Line) = 0
END

-- 显示结果
SELECT
	N'起点站' = @Station_Start,
	N'终点站' = @Station_Stop,
	N'乘车线路' = Line+N')' 
FROM # 
WHERE [Level] = @l 
	AND Station = @Station_Stop
IF @@ROWCOUNT = 0 --如果未有可以到达的线路,则显示处理结果表备查
	SELECT * FROM #
GO

--调用
EXEC dbo.p_qry N'站A', N'站L'
/*--结果
起点站     终点站     乘车线路
---------- ---------- -------------------------------------
站A        站L        (8路: 站A->站B->站C->站D->站J->站L)
--*/
GO

-- 删除测试
DROP TABLE T_Line
DROP PROC p_qry