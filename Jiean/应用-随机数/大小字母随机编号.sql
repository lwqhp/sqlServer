-- 取得随机数的视图
CREATE VIEW dbo.v_RAND
AS
SELECT re = STUFF(RAND(), 1, 2, '') -- STUFF的目的是去掉小数位, 并且将数据转换为字符型
GO

--生成随机编号的函数
CREATE FUNCTION dbo.f_RANDBH(
	@BHLen int
)RETURNS varchar(50)
AS
BEGIN
	DECLARE
		@r varchar(50)

	IF NOT(ISNULL(@BHLen, 0) BETWEEN 1 AND 50)
		SET @BHLen = 10

	SET @r = ''
	-- 循环直到生成的编号长度 >= 指定的长度
	WHILE LEN(@r) < @BHLen
		SELECT @r = @r
			+ CHAR(
					-- 随机决定字母大小写
					CASE WHEN SUBSTRING(re, 1, 1) > 5 THEN 65 ELSE 97 END
					-- 随机数的前 3 位生成一个字母
					+ (
						SUBSTRING(re, 1, 1) + SUBSTRING(re, 2, 1) + SUBSTRING(re, 3, 1)
					) % 26)
			+ CHAR(
					-- 随机决定字母大小写
					CASE WHEN SUBSTRING(re, 4, 1) > 5 THEN 65 ELSE 97 END 
					-- 随机数的前 4 - 6 位生成一个字母
					+ (
						SUBSTRING(re, 4, 1) + SUBSTRING(re, 5, 1) + SUBSTRING(re, 6, 1)
					) % 26)
		FROM dbo.v_RAND
	RETURN(LEFT(@r, @BHLen))
END
GO

--调用
SELECT dbo.f_RANDBH(6),dbo.f_RANDBH(8)
--结果: UJXIJD  PAPGTQUX
GO

-- 删除测试环境
DROP FUNCTION dbo.f_RANDBH
DROP VIEW dbo.v_RAND
