
--两种取最大值的方法
SELECT Substring(Cast(10000+A.TransSequence As varchar(5)),2,4)

--单据流水号取最大值
set @sql = 'Select @MaxNo = cast(isnull(max(right(rtrim(BillNo),3)),0) as int) from sd_inv_TransMaster where CompanyID='''+@CompanyID+''' And BillNo like '''+ @PrefixRP + '%'''
exec sp_executesql @sql,N'@MaxNo INT OUTPUT',@MaxNo OUTPUT

-------------------------------------------------------------------------
/*
缺点：为了保证生成的编号不重复，必须使用锁定提示来阻止在生成编号后，保存数据之前，其它用户对表的访问，
不管用户的访问是正常取数据，还是用于生成编号的目的，都会受到锁的影响。
*/ 
 
USE tempdb
GO
--/*-- 得到新编号的函数(未考虑并发处理)
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

/*-- 得到新编号的函数(考虑并发处理)
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


--在表中应用函数
CREATE TABLE tb(
	BH char(8)
		PRIMARY KEY
		DEFAULT dbo.f_NextBH(),
	col int)

--插入资料
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

--显示结果
SELECT * FROM tb
/*--结果
BH       col
-------- -----------
BH000001 1
BH000002 14
--*/
GO

-- 删除测试环境
DROP TABLE tb
DROP FUNCTION dbo.f_NextBH
