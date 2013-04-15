-- ȡ�����������ͼ
CREATE VIEW dbo.v_RAND
AS
SELECT re = STUFF(RAND(), 1, 2, '') -- STUFF��Ŀ����ȥ��С��λ, ���ҽ�����ת��Ϊ�ַ���
GO

--���������ŵĺ���
CREATE FUNCTION dbo.f_RANDBH(
	@BHLen int
)
RETURNS varchar(50)
AS
BEGIN
	DECLARE
		@r varchar(50)

	-- ��ų���ֻ�ܽ��� 1 - 50 ֮��, ���������Χ�Ľ���ų�������Ϊ 10
	IF NOT(ISNULL(@BHLen, 0) BETWEEN 1 AND 50)
		SET @BHLen = 10

lb_bh:	--���������ŵĴ���
	-- ��ʼ��Ҫ���ɵı��
	SET @r = ''

	-- ѭ��ֱ�����ɵı�ų��� >= ָ���ĳ���
	WHILE LEN(@r) < @BHLen
		SELECT
			@r = @r + re
		FROM dbo.v_RAND

	-- ȥ�����ɵı���г���Ҫ�󳤶ȵĲ���
	SET @r = LEFT(@r, @BHLen)

	-- ������ɵı���ڻ������ݱ����Ѿ�����,���������ɱ��
	IF EXISTS(
			SELECT * FROM dbo.tb WITH(XLOCK,PAGLOCK)
			WHERE BH = @r)
		GOTO lb_bh

	RETURN(@r)
END
GO

--�����������������ŵĺ���
CREATE TABLE dbo.tb(
	BH char(10)
		PRIMARY KEY
		DEFAULT dbo.f_RANDBH(10),
	col int)

--��������
BEGIN TRAN
	INSERT dbo.tb(col) VALUES(1)
	INSERT dbo.tb(col) VALUES(2)
	INSERT dbo.tb(col) VALUES(3)
COMMIT TRAN

-- ��ʾ���
SELECT * FROM dbo.tb
GO
/*--��� (��Ϊ�������, ��������������Ǳ��ߵ�����ִ�е�����һ�εĽ��)
BH         col
---------- -----------
2511321932 1
3045211697 3
8780620604 2
--*/
GO

-- ɾ�����Ի���
DROP TABLE dbo.tb
DROP FUNCTION dbo.f_RANDBH
DROP VIEW dbo.v_RAND
