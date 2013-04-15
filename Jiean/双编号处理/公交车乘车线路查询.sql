CREATE TABLE T_Line(
	ID      nvarchar(10),  -- ������·��
	Station nvarchar(10),  -- վ������
	Orders  int)           -- �г�����(ͨ������Ӧÿ��վ����һ������һ��վ)
INSERT T_Line 
SELECT N'8·'  ,N'վA', 1 UNION ALL
SELECT N'8·'  ,N'վB', 2 UNION ALL
SELECT N'8·'  ,N'վC', 3 UNION ALL
SELECT N'8·'  ,N'վD', 4 UNION ALL
SELECT N'8·'  ,N'վJ', 5 UNION ALL
SELECT N'8·'  ,N'վL', 6 UNION ALL
SELECT N'8·'  ,N'վM', 7 UNION ALL
SELECT N'20·' ,N'վG', 1 UNION ALL
SELECT N'20·' ,N'վH', 2 UNION ALL
SELECT N'20·' ,N'վI', 3 UNION ALL
SELECT N'20·' ,N'վJ', 4 UNION ALL
SELECT N'20·' ,N'վL', 5 UNION ALL
SELECT N'20·' ,N'վM', 6 UNION ALL
SELECT N'255·',N'վN', 1 UNION ALL
SELECT N'255·',N'վO', 2 UNION ALL
SELECT N'255·',N'վP', 3 UNION ALL
SELECT N'255·',N'վQ', 4 UNION ALL
SELECT N'255·',N'վJ', 5 UNION ALL
SELECT N'255·',N'վD', 6 UNION ALL
SELECT N'255·',N'վE', 7 UNION ALL
SELECT N'255·',N'վF', 8
GO

-- �˳���·��ѯ�洢����
CREATE PROC dbo.p_qry
	@Station_Start nvarchar(10),
	@Station_Stop  nvarchar(10)
AS
SET NOCOUNT ON
DECLARE
	@l int
SET @l = 0

-- a. �ӿ�ʼվ���ѯ���ܵĳ˳���·
SELECT
	ID, Station,
	Line = CONVERT(nvarchar(4000), '(' + RTRIM(ID) + ': ' + RTRIM(Station)),
	Orders = Orders,
	[Level] = @l
INTO #
FROM T_Line
WHERE Station = @Station_Start

-- ѭ���������п�����·, ֱ���Ҳ���������·�����ҵ��ﵽ��ֹվ��ĳ˳���·
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
					ELSE N') �� (' + RTRIM(B.ID) + N': ' + RTRIM(B.Station)
				END,
		B.ID, B.Station, B.Orders, @l
	FROM # A, T_Line B
	WHERE A.[Level] = @l - 1
		AND(
			(A.Station = B.Station AND A.ID <> B.ID) -- ��һ��ͳһ�ھ�
			OR (
				A.ID = B.ID  -- ͬһվ���ǰһվ������һվ
				AND(
					A.Orders = B.Orders + 1 
					OR
					A.Orders = B.Orders - 1)
				)
			)
		AND LEN(A.Line) < 4000
		-- ��������Ѿ��ҹ�����·
		AND PATINDEX('%[ >]' + B.Station + '[-)]%', A.Line) = 0
END

-- ��ʾ���
SELECT
	N'���վ' = @Station_Start,
	N'�յ�վ' = @Station_Stop,
	N'�˳���·' = Line+N')' 
FROM # 
WHERE [Level] = @l 
	AND Station = @Station_Stop
IF @@ROWCOUNT = 0 --���δ�п��Ե������·,����ʾ����������
	SELECT * FROM #
GO

--����
EXEC dbo.p_qry N'վA', N'վL'
/*--���
���վ     �յ�վ     �˳���·
---------- ---------- -------------------------------------
վA        վL        (8·: վA->վB->վC->վD->վJ->վL)
--*/
GO

-- ɾ������
DROP TABLE T_Line
DROP PROC p_qry