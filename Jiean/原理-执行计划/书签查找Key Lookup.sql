

USE AdventureWorks
GO

--��ǩ����
/*
��ǩ���ң��ֽм����ң�key lookup ,��һ���зǾۼ������;ۼ������ı���У��Ż���ѡ��Ӿۼ������в��ң�����ѯ
�����õĲ����������У�Ҫ��ȡ��Щ�е�ֵ���Ǿۼ�����Ҫͨ���ۼ�������������Ӧ�������С�
������Ǿۼ�������������ѯ�ж���Ҫÿһ��������һ�ξۼ�������lookup�����ҵ���Ӧ�������нм����ҡ�

������ͨ������һ��Nestd lookup���ѭ������ǩ����Ҫ������ҳ�����֮�������ҳ����ʣ���������ҳ�������˲�ѯ
�߼��������������ɼ���������Խ���Խ�ã������ң����ҳ�治���ڴ��У���ǩ���ҿ�����Ҫ�ڴ����ϵ�һ�����io��
����������ҳ����ת������ҳ�棬����Ҫ��Ҫ��cpu�������㼯��һ���ݲ�ִ�б�Ҫ�Ĳ�����������Ϊ���ڴ�ı�����ҳ
��Ͷ�Ӧ������ҳ��ͨ���ڴ����ϲ����ٽ���
���ӵ��߼��������Ϳ����ϴ�����������ʹ��ǩ���ҵ����ݼ��������Ŀ����൱��
*/
SET STATISTICS PROFILE ON

--һ�����͵���ǩ����
SELECT b.name,AVG(a.LineTotal) 
FROM sales.SalesOrderDetail a
JOIN production.product b ON a.productid = b.ProductID
WHERE a.ProductID=776
GROUP BY a.CarrierTrackingNumber,b.Name
HAVING MAX(OrderQty)>1
ORDER BY MIN(a.linetotal)


/*
�Ǿۼ��������ʺϷ��ؽ�С���м������ŷ��ص��м�Խ��Խ��key lookup�Ĳ�ѯ����Ҳ��Խ��Խ������ʹ�Ż�������
�Ǿۼ��������ң���ʹ�þۼ�����ɨ�衣
*/
SELECT * FROM sales.SalesOrderDetail
WHERE ProductID=776

SELECT * FROM sales.SalesOrderDetail
WHERE ProductID=793

SELECT 
NationalIDNumber,hiredate
 FROM HumanResources.Employee a
WHERE a.NationalIDNumber='693168613'


--�����ǩ����

/*
1����ʹ��һ���ۼ�����
���ھۼ�������Ҷ��ҳ��ͱ������ҳ����ͬ����ˣ�����ȡ�ۼ��������е�ֵʱ������������Զ�ȡ�����е�ֵ������
Ҫ�κε��������ճ���Ŀ�оۼ��������������޸ġ�

2��ʹ�ð�������
��Ϊ����������ֻ�洢�ڷǾۼ�������Ҷ�Ӽ����ϣ��������������������ң����Լ����������������������ֲ���Ҫ
�ٵ�����ҳȥ�������ݡ�
*/


SELECT  Nationalidnumber,hiredate 
FROM HumanResources.Employee
WHERE NationalIDNumber=N'693168613'-- nationalidnumber��nvarchar���ͣ�Ҫ��N��������ת��

--��������
CREATE NONCLUSTERED INDEX IX_Employee ON HumanResources.Employee(NationalIDNumber) INCLUDE(hiredate)

DROP INDEX IX_Employee on HumanResources.Employee 
/*
3,��ѯ�бܿ����ڷ�Χ���ֶΣ�ʹ�þۼ������е��ֶ�
��Ϊ���оۼ������ı��ϣ��ۼ����������洢Ϊ�Ǿۼ�����ָ�����ݵ�ָ�룬����ζ���κν��ۼ�������һ�����ԷǾۼ�
����������Ϊ��ѯ���ƣ�where�Ӿ�����������Ĳ�ѯ�����������ָ�������
*/

DBCC SHOW_STATISTICS('HumanResources.Employee','AK_employee_nationalIDnumber')
/*
��ͳ����Ϣ���Կ������������������Լ��ķǾۼ�����nationalDnumber,Ȼ���Ǻ;ۼ�����EmployeeID������
*/

SELECT  NationalIDNumber, EmployeeID
FROM HumanResources.Employee
WHERE NationalIDNumber=N'693168613'

/*
��������
����������ָʹ���������������֮���һ��������������ȫ����һ����ѯ����Ȼ����������Ҫ���ʶ���һ������������
������������������ʹ�õ�������ִ���߼���������Ҫ�ȸ����������ߵ��߼Ӷ����������ǣ���Ϊ�����������õĶ��խ��
���ܹ��ȿ�ĸ��������������Ĳ�ѯ��

1�����խ�����Ϳ�ĸ���������ȣ�����Ϊ�������Ĳ�ѯ�ṩ����
2��խ�����ȿ�ĸ���������Ҫ��ά��������С
*/

SELECT 
PurchaseOrderID,VendorID,OrderDate
 FROM Purchasing.PurchaseOrderHeader
WHERE VendorID=83 AND OrderDate='2001-05-17 00:00:00.000'

--���һ���Ǿۼ�����
CREATE NONCLUSTERED INDEX IX_PurchaseOrderHeader ON Purchasing.PurchaseOrderHeader(OrderDate)
/*
����������Ż���ʹ����vendorID�ϵķǾۼ��������µķǾۼ�����orderdate�������ط����ڸò�ѯ��������Ҫ����������
*/

