--��ű�
CREATE TABLE tb_NO(
	Name char(2) NOT NULL,          -- ������������
	Days int NOT NULL,              -- ������Ǹ��ֱ����һ��ĵ�ǰ���
	Head nvarchar(10) NOT NULL      -- ��ŵ�ǰ׺
		DEFAULT '',
	CurrentNo int NOT NULL          -- ��ǰ���
		DEFAULT 0,
	BHLen int NOT NULL              -- ������ֲ��ֳ���
		DEFAULT 6,
	YearMoth int NOT NULL           -- �ϴ����ɱ�ŵ�����,��ʽYYYYMM
		DEFAULT CONVERT(char(6),GETDATE(),112),
	Description nvarchar(50),       -- �������˵��
	TableName sysname NOT NULL,     -- ��ǰ��Ŷ�Ӧ��ԭʼ���� (���������ɱ�ŵ����ڹ���ʱ, ��ԭʼ���в�ѯ�������Ϣ)
	KeyFieldName sysname NOT NULL,  -- ��ǰ��Ŷ�Ӧ��ԭʼ�����ֶ���(�� TableName ����ʹ��)
	PRIMARY KEY(
		Name,Days)
)
-- ������һ�ֵ��ݵ� 7 ���������������
INSERT tb_NO SELECT 'CG', 1, 'CG', 0, 4, 200501, N'�ɹ�����', N'dbo.tb', N'bh'
UNION  ALL   SELECT 'CG', 2, 'CG', 0, 4, 200501, N'�ɹ�����', N'dbo.tb', N'bh'
UNION  ALL   SELECT 'CG', 3, 'CG', 0, 4, 200501, N'�ɹ�����', N'dbo.tb', N'bh'
UNION  ALL   SELECT 'CG', 4, 'CG', 0, 4, 200501, N'�ɹ�����', N'dbo.tb', N'bh'
UNION  ALL   SELECT 'CG', 5, 'CG', 0, 4, 200501, N'�ɹ�����', N'dbo.tb', N'bh'
UNION  ALL   SELECT 'CG', 6, 'CG', 0, 4, 200501, N'�ɹ�����', N'dbo.tb', N'bh'
UNION  ALL   SELECT 'CG', 7, 'CG', 0, 4, 200501, N'�ɹ�����', N'dbo.tb', N'bh'
GO

--��ȡ�±�ŵĴ洢����
CREATE PROC dbo.p_NextBH
	@Name char(2),           -- �������
	@Date datetime = NULL,   -- Ҫ��ȡ�ĵ�ǰ����,��ָ����Ϊϵͳ��ǰ����
	@BH nvarchar(20) OUTPUT  -- �±��
AS
IF @Date IS NULL
	SET @Date = GETDATE()
BEGIN TRAN
	--�ӱ�ű��л�ȡ�±��
	UPDATE tb_NO SET 
		@BH = Head
			+ CONVERT(CHAR(6), @Date, 12) -- ����е�������Ϣ
			+ RIGHT(
				POWER(10, BHLen)
					+ CASE 
							-- �����ű��е�������Ѿ�����, �����ñ��Ϊ 1
							WHEN YearMoth < CONVERT(char(6),@Date,112) THEN 1
							-- �����ű��е������δ����, ���±��Ϊ��ǰ��� + 1
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

	--���Ҫ��ȡ�ı���ڱ�ű����Ѿ�����,��ֱ�Ӵ�ԭʼ����ȡ���
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

--��ȡ CG ���±��
DECLARE
	@Name char(2),
	@bh char(12)
SET @Name = 'CG'

EXEC dbo.p_NextBH 
	@Name = @Name,
	@Date = '2005-1-1',
	@BH = @bh OUT
SELECT @bh
--���: CG0501010001

EXEC dbo.p_NextBH 
	@Name = @Name,
	@Date = '2005-1-1',
	@BH = @bh OUT
SELECT @bh
--���: CG0501010002

EXEC dbo.p_NextBH 
	@Name = @Name,
	@Date = '2005-1-2',
	@BH = @bh OUT
SELECT @bh
--���: CG0501020001

EXEC dbo.p_NextBH 
	@Name = @Name,
	@Date = '2005-2-1',
	@BH = @bh OUT
SELECT @bh
--���: CG0502010001

EXEC dbo.p_NextBH 
	@Name = @Name,
	@Date = '2004-12-1',
	@BH = @bh OUT
SELECT @bh
--���: CG0412010001
GO

-- ɾ�����Ի���
DROP TABLE dbo.tb, dbo.tb_NO
DROP PROC dbo.p_NextBH