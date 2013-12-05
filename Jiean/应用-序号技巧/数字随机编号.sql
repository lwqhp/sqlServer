-- 取得随机数的视图
CREATE VIEW dbo.v_RAND
AS
SELECT re = STUFF(RAND(), 1, 2, '') -- STUFF的目的是去掉小数位, 并且将数据转换为字符型
GO

--生成随机编号的函数
CREATE FUNCTION dbo.f_RANDBH(
	@BHLen int
)
RETURNS varchar(50)
AS
BEGIN
	DECLARE
		@r varchar(50)

	-- 编号长度只能介于 1 - 50 之间, 不在这个范围的将编号长度设置为 10
	IF NOT(ISNULL(@BHLen, 0) BETWEEN 1 AND 50)
		SET @BHLen = 10

lb_bh:	--生成随机编号的处理
	-- 初始化要生成的编号
	SET @r = ''

	-- 循环直到生成的编号长度 >= 指定的长度
	WHILE LEN(@r) < @BHLen
		SELECT
			@r = @r + re
		FROM dbo.v_RAND

	-- 去掉生成的编号中超过要求长度的部分
	SET @r = LEFT(@r, @BHLen)

	-- 如果生成的编号在基础数据表中已经存在,则重新生成编号
	IF EXISTS(
			SELECT * FROM dbo.tb WITH(XLOCK,PAGLOCK)
			WHERE BH = @r)
		GOTO lb_bh

	RETURN(@r)
END
GO

--创建引用生成随机编号的函数
CREATE TABLE dbo.tb(
	BH char(10)
		PRIMARY KEY
		DEFAULT dbo.f_RANDBH(10),
	col int)

--插入数据
BEGIN TRAN
	INSERT dbo.tb(col) VALUES(1)
	INSERT dbo.tb(col) VALUES(2)
	INSERT dbo.tb(col) VALUES(3)
COMMIT TRAN

-- 显示结果
SELECT * FROM dbo.tb
GO
/*--结果 (因为是随机的, 因此这个结果仅仅是笔者电脑上执行的其中一次的结果)
BH         col
---------- -----------
2511321932 1
3045211697 3
8780620604 2
--*/
GO

-- 删除测试环境
DROP TABLE dbo.tb
DROP FUNCTION dbo.f_RANDBH
DROP VIEW dbo.v_RAND
