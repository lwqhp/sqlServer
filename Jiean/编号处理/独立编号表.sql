-- 编号表, 此表维护各类编号的规则及当前编号
CREATE TABLE tb_NO(
	Name char(2)                -- 编号种类的名称
		PRIMARY KEY,
	Head nvarchar(10) NOT NULL  -- 编号的前缀
		DEFAULT '',
	CurrentNo int NOT NULL      -- 当前编号
		DEFAULT 0,
	BHLen int NOT NULL          -- 编号数字部分长度
		DEFAULT 6,         
	Description NVARCHAR(50)    -- 编号种类说明
)
-- 初始化编号表
INSERT tb_NO SELECT 'CG', 'CG', 0, 4, N'采购订单'
UNION  ALL   SELECT 'CJ', 'CJ', 0, 4, N'采购进货'
UNION  ALL   SELECT 'JC', 'JC', 0, 4, N'进仓单'
UNION  ALL   SELECT 'ZC', 'ZC', 0, 4, N'转仓单'
UNION  ALL   SELECT 'CC', 'CC', 0, 4, N'出仓单'
GO

--获取新编号的存储过程
CREATE PROC dbo.p_NextBH
	@Name char(2),           --编号种类
	@BH nvarchar(20) OUTPUT --新编号
AS
BEGIN TRAN
	UPDATE tb_NO WITH(ROWLOCK) SET 
		@BH = Head + RIGHT(POWER(10, BHLen) + CurrentNo + 1, BHLen),
		CurrentNo = CurrentNo + 1
	WHERE Name = @Name
COMMIT TRAN
GO

-- 获取 CJ 的新编号
DECLARE
	@bh char(6)
EXEC dbo.p_NextBH
	@Name = 'CJ',
	@BH = @bh OUTPUT
SELECT @bh
-- 结果: CJ0001

EXEC dbo.p_NextBH
	@Name = 'CJ',
	@BH = @bh OUTPUT
SELECT @bh
-- 结果: CJ0002
GO

-- 获取 CC 的新编号
DECLARE
	@bh char(6)
EXEC dbo.p_NextBH
	@Name = 'CC',
	@BH = @bh OUTPUT
SELECT @bh
-- 结果: CC0001
GO

-- 删除测试环境
DROP PROC dbo.p_NextBH
DROP TABLE tb_NO