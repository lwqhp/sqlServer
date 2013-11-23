/*
缺点：为了保证生成的编号不重复，必须使用锁定提示来阻止在生成编号后，保存数据之前，其它用户对表的访问，不管用户的访问是正常取数据，还是用于生成编号的目的，都会受到锁的影响。
*/ 

-- 创建得到当前日期的视图, 以便在用户定义函数中可以获取当前日期
CREATE VIEW dbo.v_GetDate
AS
SELECT dt = CONVERT(CHAR(6), GETDATE(), 12)
GO

--得到新编号的函数
CREATE FUNCTION dbo.f_NextBH()
RETURNS char(12)
AS
BEGIN
	DECLARE
		@dt CHAR(6)
	SELECT
		@dt = dt
	FROM dbo.v_GetDate

	RETURN(
		SELECT
			@dt + RIGHT(1000001 + ISNULL(RIGHT(MAX(BH), 6), 0), 6) 
		FROM tb WITH(XLOCK,PAGLOCK)
		WHERE BH LIKE @dt + '%')
END
GO

--在表中应用函数
CREATE TABLE tb(
	BH char(12)
		PRIMARY KEY
		DEFAULT dbo.f_NextBH(),
	col int)

--插入资料
INSERT tb(
	col)
VALUES(
	1)

INSERT tb(
	col)
VALUES(
	3)

DELETE tb
WHERE col = 3

INSERT tb(
	BH, col)
VALUES(
	dbo.f_NextBH(), 14)

--显示结果
SELECT * FROM tb
/*--结果
BH           col
------------ -----------
080225000001 1
080225000002 14
--*/
GO

-- 删除测试环境
DROP TABLE tb
DROP FUNCTION dbo.f_NextBH
