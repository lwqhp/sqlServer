/*
ȱ�㣺Ϊ�˱�֤���ɵı�Ų��ظ�������ʹ��������ʾ����ֹ�����ɱ�ź󣬱�������֮ǰ�������û��Ա�ķ��ʣ������û��ķ���������ȡ���ݣ������������ɱ�ŵ�Ŀ�ģ������ܵ�����Ӱ�졣
*/ 

-- �����õ���ǰ���ڵ���ͼ, �Ա����û����庯���п��Ի�ȡ��ǰ����
CREATE VIEW dbo.v_GetDate
AS
SELECT dt = CONVERT(CHAR(6), GETDATE(), 12)
GO

--�õ��±�ŵĺ���
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

--�ڱ���Ӧ�ú���
CREATE TABLE tb(
	BH char(12)
		PRIMARY KEY
		DEFAULT dbo.f_NextBH(),
	col int)

--��������
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

--��ʾ���
SELECT * FROM tb
/*--���
BH           col
------------ -----------
080225000001 1
080225000002 14
--*/
GO

-- ɾ�����Ի���
DROP TABLE tb
DROP FUNCTION dbo.f_NextBH
