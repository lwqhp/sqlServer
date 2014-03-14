

--����ִ�мƻ���ִ��˳��

USE AdventureWorks
go

SET STATISTICS PROFILE ON 

SELECT a.SalesOrderID,a.OrderDate,a.CustomerID,b.SalesOrderDetailID,b.ProductID,b.OrderQty,b.UnitPrice 
FROM dbo.SalesOrderHeader_test a
INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b.SalesOrderID
WHERE a.SalesOrderID = 43659

SET STATISTICS PROFILE OFF 

/*
SELECT a.SalesOrderID,a.OrderDate,a.CustomerID,b.SalesOrderDetailID,b.ProductID,b.OrderQty,b.UnitPrice   FROM dbo.SalesOrderHeader_test a  INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b.SalesOrderID  WHERE a.SalesOrderID = 43659
  |--Nested Loops(Inner Join)
       |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderHeader_test_CL] AS [a]), SEEK:([a].[SalesOrderID]=(43659)) ORDERED FORWARD)
       |--Nested Loops(Inner Join, OUTER REFERENCES:([Uniq1005], [b].[SalesOrderDetailID]))
            |--Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetail_test_NCL] AS [b]), SEEK:([b].[SalesOrderID]=(43659)) ORDERED FORWARD)
            |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_cl] AS [b]), SEEK:([b].[SalesOrderDetailID]=[AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetailID] as [b].[SalesOrderDetailID] AND [Uniq1005]=[Uniq1005]) LOOKUP ORDERED FORWARD)

ִ�мƻ������ṹ����һ���֧��������һ���Ӿ䣬ִ�д���ײ㿪ʼ����xmlͼ�У��Ǵ����ұ����󣬴������Ͽ�ʼ

����ִ�е�6��5�е�index seek��clustered index seek 
�Ĵ�֮�ϣ��������������Ƕ��ѭ���ķ�ʽ����������4���õ��������ִ�е�3�У���salesorderheader_test ����culustered index seek ����Ϊһ��
2����һ��Ƕ��ѭ����˵��sqlserver ��ʹ�õ�Ƕ��ѭ��������������ϲ�������

����salesorderheader_test ��salesorderID���оۼ�������sqlserver����ֱ���ҵ�salesorderID=43659,Ȼ������ļ�����
��ȡ������һ��culustered index seek

��salesorderdetail_test��salesorderID�ϵ��ǷǾۼ����������ص�ֵ������ȫ���Ǿۼ��������������������÷Ǿ��ҵ�
salesorderID=43659��¼����Ҫ��ָ��;ۼ�������nested loops�����ӣ������е��ֶ�ֵȡ������
*/