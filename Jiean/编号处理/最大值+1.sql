
--����ȡ���ֵ�ķ���
SELECT Substring(Cast(10000+A.TransSequence As varchar(5)),2,4)

--������ˮ��ȡ���ֵ
set @sql = 'Select @MaxNo = cast(isnull(max(right(rtrim(BillNo),3)),0) as int) from sd_inv_TransMaster where CompanyID='''+@CompanyID+''' And BillNo like '''+ @PrefixRP + '%'''
exec sp_executesql @sql,N'@MaxNo INT OUTPUT',@MaxNo OUTPUT

-------------------------------------------------------------------------
/*
ȱ�㣺Ϊ�˱�֤���ɵı�Ų��ظ�������ʹ��������ʾ����ֹ�����ɱ�ź󣬱�������֮ǰ�������û��Ա�ķ��ʣ�
�����û��ķ���������ȡ���ݣ������������ɱ�ŵ�Ŀ�ģ������ܵ�����Ӱ�졣
*/ 
 
USE tempdb
GO
--/*-- �õ��±�ŵĺ���(δ���ǲ�������)
CREATE FUNCTION dbo.f_NextBH()
RETURNS char(8)
AS
BEGIN
	RETURN(
		SELECT 
			'BH' + RIGHT(1000001 + ISNULL(RIGHT(MAX(BH), 6) ,0), 6)
		FROM tb)
END
--*/
GO

/*-- �õ��±�ŵĺ���(���ǲ�������)
CREATE FUNCTION f_NextBH()
RETURNS char(8)
AS
BEGIN
	RETURN(
		SELECT 
			'BH' + RIGHT(1000001 + ISNULL(RIGHT(MAX(BH), 6) ,0), 6)
		FROM tb WITH(XLOCK, PAGLOCK))
END
--*/
GO


--�ڱ���Ӧ�ú���
CREATE TABLE tb(
	BH char(8)
		PRIMARY KEY
		DEFAULT dbo.f_NextBH(),
	col int)

--��������
BEGIN TRAN
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
COMMIT TRAN

--��ʾ���
SELECT * FROM tb
/*--���
BH       col
-------- -----------
BH000001 1
BH000002 14
--*/
GO

-- ɾ�����Ի���
DROP TABLE tb
DROP FUNCTION dbo.f_NextBH
