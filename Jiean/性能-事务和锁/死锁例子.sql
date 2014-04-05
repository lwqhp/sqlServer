--Ò»¸öËÀËøÀý×Ó
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

WHILE 1=1
BEGIN 
BEGIN TRAN 
	UPDATE purchasing.vendor SET creditrating=1 WHERE businessentityID = 1494
	UPDATE purchasing.vendor SET creditrating=2 WHERE businessentityID = 1492
COMMIT TRAN 
END

--
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE

WHILE 1=1
BEGIN 
BEGIN TRAN 
	UPDATE purchasing.vendor SET creditrating=2 WHERE businessentityID = 1492
	UPDATE purchasing.vendor SET creditrating=1 WHERE businessentityID = 1494
COMMIT TRAN 
END