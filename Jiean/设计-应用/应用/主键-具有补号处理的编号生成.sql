-- 得到新编号的函数
CREATE FUNCTION dbo.f_NextBH()
RETURNS char(8)
AS
BEGIN
	DECLARE	@r char(8)
	
	SELECT @r = 'BH' + RIGHT(1000001 + MIN(BH), 6)
	FROM(
		SELECT
			BH = RIGHT(BH, 6)
		FROM dbo.tb WITH(XLOCK,PAGLOCK)
		UNION ALL
		SELECT BH = 0
	)A
	WHERE NOT EXISTS(
			SELECT * FROM dbo.tb WITH(XLOCK,PAGLOCK)
			WHERE BH = 'BH' + RIGHT(1000001 + A.BH, 6))
	RETURN(@r)
END
GO

-- 在表中应用函数
CREATE TABLE dbo.tb(
	BH char(8)
		PRIMARY KEY
		DEFAULT dbo.f_NextBH(),
	col int)

-- 数据测试
INSERT dbo.tb(
	col)
VALUES(
	1)

INSERT dbo.tb(
	col)
VALUES(
	2)

INSERT dbo.tb(
	col)
VALUES(
	3)

DELETE FROM dbo.tb
WHERE col = 4

INSERT dbo.tb(
	col)
VALUES(
	4)

SELECT * FROM dbo.tb
/*-- 结果, col = 4 的记录的编号为 BH000002, 说明补号成功
BH       col
-------- -----------
BH000001 1
BH000002 4
BH000003 3
--*/
GO

-- 删除测试环境
DROP TABLE dbo.tb
DROP FUNCTION dbo.f_NextBH
