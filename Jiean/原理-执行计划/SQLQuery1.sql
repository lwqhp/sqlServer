

USE AdventureWorks
GO

SET STATISTICS PROFILE ON

SELECT b.name,AVG(a.LineTotal) 
FROM sales.SalesOrderDetail a
JOIN production.product b ON a.productid = b.ProductID
WHERE a.ProductID=776
GROUP BY a.CarrierTrackingNumber,b.Name
HAVING MAX(OrderQty)>1
ORDER BY MIN(a.linetotal)


SELECT * FROM sales.SalesOrderDetail
WHERE ProductID=776

SELECT * FROM sales.SalesOrderDetail
WHERE ProductID=793

SELECT 
NationalIDNumber,hiredate
 FROM HumanResources.Employee a
WHERE a.NationalIDNumber='693168613'