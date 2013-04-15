-- ��ű�, �˱�ά�������ŵĹ��򼰵�ǰ���
CREATE TABLE tb_NO(
	Name char(2)                -- ������������
		PRIMARY KEY,
	Head nvarchar(10) NOT NULL  -- ��ŵ�ǰ׺
		DEFAULT '',
	CurrentNo int NOT NULL      -- ��ǰ���
		DEFAULT 0,
	BHLen int NOT NULL          -- ������ֲ��ֳ���
		DEFAULT 6,         
	Description NVARCHAR(50)    -- �������˵��
)
-- ��ʼ����ű�
INSERT tb_NO SELECT 'CG', 'CG', 0, 4, N'�ɹ�����'
UNION  ALL   SELECT 'CJ', 'CJ', 0, 4, N'�ɹ�����'
UNION  ALL   SELECT 'JC', 'JC', 0, 4, N'���ֵ�'
UNION  ALL   SELECT 'ZC', 'ZC', 0, 4, N'ת�ֵ�'
UNION  ALL   SELECT 'CC', 'CC', 0, 4, N'���ֵ�'
GO

--��ȡ�±�ŵĴ洢����
CREATE PROC dbo.p_NextBH
	@Name char(2),           --�������
	@BH nvarchar(20) OUTPUT --�±��
AS
BEGIN TRAN
	UPDATE tb_NO WITH(ROWLOCK) SET 
		@BH = Head + RIGHT(POWER(10, BHLen) + CurrentNo + 1, BHLen),
		CurrentNo = CurrentNo + 1
	WHERE Name = @Name
COMMIT TRAN
GO

-- ��ȡ CJ ���±��
DECLARE
	@bh char(6)
EXEC dbo.p_NextBH
	@Name = 'CJ',
	@BH = @bh OUTPUT
SELECT @bh
-- ���: CJ0001

EXEC dbo.p_NextBH
	@Name = 'CJ',
	@BH = @bh OUTPUT
SELECT @bh
-- ���: CJ0002
GO

-- ��ȡ CC ���±��
DECLARE
	@bh char(6)
EXEC dbo.p_NextBH
	@Name = 'CC',
	@BH = @bh OUTPUT
SELECT @bh
-- ���: CC0001
GO

-- ɾ�����Ի���
DROP PROC dbo.p_NextBH
DROP TABLE tb_NO