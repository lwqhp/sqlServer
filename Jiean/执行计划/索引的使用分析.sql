
--������ʹ�÷���

/*
Table Scan : ��ɨ�裬�������ڴ���ı��û�оۼ�������sqlServer����ɨ�����ű�
Clustered Index Scan : �ۼ�����ɨ�裬����sqlServer ����ɨ��һ���оۼ������ı�񣬵���Ҳ������ɨ�衣
Index Scan : ����ɨ�裬����SqlServer ����ɨ��һ���Ǿۼ����������ڷǾۼ�������һ��ֻ����һС�����ֶΣ���������
	��ȻҲ��ɨ�裬���Ǵ��ۻ������ɨ��ҪС�ܶࡣ
Clustered Index Seek �� Index Seek ���ۼ��������ҺͷǾۼ��������ң����� Sqlserver �������������������Ŀ�����ݣ�
	��������ֻռ�����������һС���ݣ�Seek ���Scan ���˺ܶ࣬����������������ܵ����á�	
*/

USE AdventureWorks
GO

CREATE INDEX salesorderdetail_test_Ncl_price ON salesorderdetail_test(UnitPrice)

SET STATISTICS PROFILE ON 

SELECT salesorderID,salesOrderDetailID,unitPrice 
FROM dbo.SalesOrderDetail_test WITH(INDEX(salesorderdetail_test_Ncl_price))--ָ��ʹ�÷Ǿۼ�����
WHERE unitPrice>200

SET STATISTICS PROFILE OFF


/*
|--Nested Loops(Inner Join, OUTER REFERENCES:([Uniq1002], [AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetailID], [Expr1004]) WITH UNORDERED PREFETCH)
    |--Sort(ORDER BY:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetailID] ASC, [Uniq1002] ASC))
    |    |--Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_Ncl_price]), SEEK:([AdventureWorks].[dbo].[SalesOrderDetail_test].[UnitPrice] > ($200.0000)) ORDERED FORWARD)
    |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_cl]), SEEK:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetailID]=[AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetailID] AND [Uniq1002]=[Uniq1002]) LOOKUP ORDERED FORWARD)
    
? Ϊʲôָ���˷Ǿۼ���������ִ�мƻ��ﻹ�оۼ�������ʹ��

����Ϊ�Ǿۼ�������ʵ��������ֵ,Ϊÿһ�μ�¼�洢һ��"�Ǿۼ�����������ֵ"��һ��"�ۼ�������������ֵ"��û�оۼ�����������RIDֵ��
�Ǿۼ�������Ҷ������ֵҳָ��۾�������ֵ��û�л����������е�IDֵ��

?���� Nested Loops -- Index Seek --Clustered Index Seek Ƕ��ѭ��"Bookmark Lookup"

������ʹ���˷Ǿۼ��������ң������ص��ֶ��в��������еģ��������ڷǾۼ��������ҵ�����unitprice����200�ļ�¼,
Ȼ���ٸ���salesorderdetialid ��ֵ�;ۼ�����Nested LoopsǶ��ѭ�� ,�ҵ��洢�ھۼ������ϵ���ϸ���ݣ�������̳�Ϊ"Bookmark Lookup"

|--Clustered Index Scan(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_cl]), WHERE:([AdventureWorks].[dbo].[SalesOrderDetail_test].[UnitPrice]>($200.0000)))
       
*/

------------------------------------------------------------------------------------------
SELECT a.SalesOrderID,a.OrderDate,a.CustomerID,b.SalesOrderDetailID,b.ProductID,b.OrderQty,b.UnitPrice 
FROM dbo.SalesOrderHeader_test a
INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b.SalesOrderID
WHERE a.SalesOrderID = 43659


/*
|--Nested Loops(Inner Join)
   |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderHeader_test_CL] AS [a]), SEEK:([a].[SalesOrderID]=(43659)) ORDERED FORWARD)
   |--Nested Loops(Inner Join, OUTER REFERENCES:([Uniq1005], [b].[SalesOrderDetailID]))
        |--Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetail_test_NCL] AS [b]), SEEK:([b].[SalesOrderID]=(43659)) ORDERED FORWARD)
        |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_cl] AS [b]), SEEK:([b].[SalesOrderDetailID]=[AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetailID] as [b].[SalesOrderDetailID] AND [Uniq1005]=[Uniq1005]) LOOKUP ORDERED FORWARD)


������SalesOrderID = 43659,��Ϊ���������a.SalesOrderID = b.SalesOrderID,��SalesOrderDetail_test��SalesOrderID��������,
����ִ�мƻ�����SalesOrderDetail_test�ϰ��Ǿۼ���������SalesOrderID = 43659,�ٸ��ݷ��ص��ֶκ;ۼ������������ҵ��������ֶΡ�

��SalesOrderHeader_test ��SalesOrderID���оۼ�����������ֱ��ʹ���˾ۼ���������

Ȼ����������������(Ƕ��ѭ��)���������ս����.
*/

------------------------------------------------------------------------------------------
SELECT a.SalesOrderID,a.OrderDate,a.CustomerID,b.SalesOrderID 
FROM dbo.SalesOrderHeader_test a
INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b.SalesOrderID
WHERE a.SalesOrderID = 43659

/*
|--Nested Loops(Inner Join)
   |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderHeader_test_CL] AS [a]), SEEK:([a].[SalesOrderID]=(43659)) ORDERED FORWARD)
   |--Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetail_test_NCL] AS [b]), SEEK:([b].[SalesOrderID]=(43659)) ORDERED FORWARD)

����sql���ȥ����SalesOrderDetail_test �����ֶ��в��ڷǾۼ������е���
���Կ�������Ϊ���ص��ֶΰ������˷Ǿۼ������У�����ͨ���������Ҽ��ɷ�����Ӧ���ֶΣ�������Ҫͨ���ۼ���������ѭ�����������ֶΡ�
*/