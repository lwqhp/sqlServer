--编号表
CREATE TABLE tb_NO(
	Name char(2) NOT NULL,          -- 编号种类的名称
	Days int NOT NULL,              -- 保存的是该种编号那一天的当前编号
	Head nvarchar(10) NOT NULL      -- 编号的前缀
		DEFAULT '',
	CurrentNo int NOT NULL          -- 当前编号
		DEFAULT 0,
	BHLen int NOT NULL              -- 编号数字部分长度
		DEFAULT 6,
	YearMoth int NOT NULL           -- 上次生成编号的年月,格式YYYYMM
		DEFAULT CONVERT(char(6),GETDATE(),112),
	Description nvarchar(50),       -- 编号种类说明
	TableName sysname NOT NULL,     -- 当前编号对应的原始表名 (用于在生成编号的日期过期时, 从原始表中查询最大编号信息)
	KeyFieldName sysname NOT NULL,  -- 当前编号对应的原始表编号字段名(与 TableName 配套使用)
	PRIMARY KEY(
		Name,Days)
)
-- 这里以一种单据的 7 天的资料来做测试
INSERT tb_NO SELECT 'CG', 1, 'CG', 0, 4, 200501, N'采购订单', N'dbo.tb', N'bh'
UNION  ALL   SELECT 'CG', 2, 'CG', 0, 4, 200501, N'采购订单', N'dbo.tb', N'bh'
UNION  ALL   SELECT 'CG', 3, 'CG', 0, 4, 200501, N'采购订单', N'dbo.tb', N'bh'
UNION  ALL   SELECT 'CG', 4, 'CG', 0, 4, 200501, N'采购订单', N'dbo.tb', N'bh'
UNION  ALL   SELECT 'CG', 5, 'CG', 0, 4, 200501, N'采购订单', N'dbo.tb', N'bh'
UNION  ALL   SELECT 'CG', 6, 'CG', 0, 4, 200501, N'采购订单', N'dbo.tb', N'bh'
UNION  ALL   SELECT 'CG', 7, 'CG', 0, 4, 200501, N'采购订单', N'dbo.tb', N'bh'
GO

--获取新编号的存储过程
CREATE PROC dbo.p_NextBH
	@Name char(2),           -- 编号种类
	@Date datetime = NULL,   -- 要获取的当前日期,不指定则为系统当前日期
	@BH nvarchar(20) OUTPUT  -- 新编号
AS
IF @Date IS NULL
	SET @Date = GETDATE()
BEGIN TRAN
	--从编号表中获取新编号
	UPDATE tb_NO SET 
		@BH = Head
			+ CONVERT(CHAR(6), @Date, 12) -- 编号中的日期信息
			+ RIGHT(
				POWER(10, BHLen)
					+ CASE 
							-- 如果编号表中的最大编号已经过期, 则重置编号为 1
							WHEN YearMoth < CONVERT(char(6),@Date,112) THEN 1
							-- 如果编号表中的最大编号未过期, 则新编号为当前编号 + 1
							ELSE CurrentNo + 1
						END,
				BHLen),
		CurrentNo = CASE 
						WHEN YearMoth < CONVERT(char(6),@Date,112) THEN 1
						ELSE CurrentNo + 1
					END,
		YearMoth = CONVERT(char(6), @Date, 112)
	WHERE Name = @Name 
		AND Days = DAY(@Date)
		AND YearMoth <= CONVERT(char(6), @Date, 112)

	--如果要获取的编号在编号表中已经过期,则直接从原始表中取编号
	IF @@ROWCOUNT = 0
	BEGIN
		DECLARE
			@s nvarchar(4000),
			@Head nvarchar(100),
			@BHLen int
			
		SELECT
			@Head = Head + CONVERT(CHAR(6), @Date, 12),
			@BHLen = BHLen,
			@s = N'
SELECT
	@BH = @Head
		+ RIGHT(POWER(10, @BHLen) + 1
				+ ISNULL(
					RIGHT(MAX(' + QUOTENAME(KeyFieldName) +N'), @BHLen),
					0),
				@BHLen)
FROM ' + TableName + N' WITH(XLOCK,PAGLOCK)
WHERE ' + QUOTENAME(KeyFieldName) + N' LIKE @Head + N''%'''
		FROM tb_NO
		WHERE Name = @Name 
			AND Days = DAY(@Date)
			AND YearMoth > CONVERT(char(6), @Date, 112)
		IF @@ROWCOUNT>0
			EXEC sp_executesql
				@s,
				N'
					@Head nvarchar(100),
					@BHLen int,
					@BH nvarchar(20) OUTPUT
				',
				@Head, @BHLen, @BH OUTPUT
	END
COMMIT TRAN
GO

CREATE TABLE dbo.tb(
	BH char(12))

--获取 CG 的新编号
DECLARE
	@Name char(2),
	@bh char(12)
SET @Name = 'CG'

EXEC dbo.p_NextBH 
	@Name = @Name,
	@Date = '2005-1-1',
	@BH = @bh OUT
SELECT @bh
--结果: CG0501010001

EXEC dbo.p_NextBH 
	@Name = @Name,
	@Date = '2005-1-1',
	@BH = @bh OUT
SELECT @bh
--结果: CG0501010002

EXEC dbo.p_NextBH 
	@Name = @Name,
	@Date = '2005-1-2',
	@BH = @bh OUT
SELECT @bh
--结果: CG0501020001

EXEC dbo.p_NextBH 
	@Name = @Name,
	@Date = '2005-2-1',
	@BH = @bh OUT
SELECT @bh
--结果: CG0502010001

EXEC dbo.p_NextBH 
	@Name = @Name,
	@Date = '2004-12-1',
	@BH = @bh OUT
SELECT @bh
--结果: CG0412010001
GO

-- 删除测试环境
DROP TABLE dbo.tb, dbo.tb_NO
DROP PROC dbo.p_NextBH