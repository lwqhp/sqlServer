

--�ۺ������ Aggregation��Concatenation ��parallelism

/*
��Ҫ�������� sum(),count,max,min�Ⱦۺ����㣬Aggregation������

stream aggreation: �����ݼ��ų�һ�������Ժ�������

hash aggreation:   ���� hash join ,��Ҫ���ڴ��н�һ��hash������������

Concatenation : ���ݺϲ�
���ֲ��������� concatenation����:union ��union all
union �����һ��sort���򣬰��ظ�������ȥ��

parallelism : ���е�ִ�мƻ�

�۲�ۺ�����
Aggregate���㣬˵���˴�����һ���ۺ����㣬�Ƕ�ǰһ�����ҽ���ľۺϼ��㣬���ǰһ����������û�а����ۺϵ��ֶΣ�
������һ���������㣬����Ҫ�ۺϵ��ֶ�����.
������parallelism�������˵��sqlserverʹ�öദ�������д���
*/

SET STATISTICS PROFILE ON 

SELECT SalesOrderID,COUNT(SalesOrderDetailID)
FROM dbo.SalesOrderDetail_test
GROUP BY SalesOrderID

SET STATISTICS PROFILE OFF 

/*
Rows	Executes	StmtText
31474	1	SELECT SalesOrderID,COUNT(SalesOrderDetailID)  FROM dbo.SalesOrderDetail_test  GROUP BY SalesOrderID
0	0	  |--Compute Scalar(DEFINE:([Expr1004]=CONVERT_IMPLICIT(int,[Expr1007],0)))
31474	1	       |--Stream Aggregate(GROUP BY:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderID]) DEFINE:([Expr1007]=Count(*)))
1213170	1	            |--Index Scan(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetail_test_NCL]), ORDERED FORWARD)

�����ݼ��������ų�һ�������Ժ������㣬������ָSalesOrderDetailID
*/

SET STATISTICS PROFILE ON 

SELECT customerID,COUNT(*)
FROM dbo.SalesOrderheader_test
GROUP BY customerID

SET STATISTICS PROFILE OFF 

/*
Rows	Executes	StmtText
19119	1	SELECT customerID,COUNT(*)  FROM dbo.SalesOrderheader_test  GROUP BY customerID
0	0	  |--Compute Scalar(DEFINE:([Expr1003]=CONVERT_IMPLICIT(int,[Expr1006],0)))
19119	1	       |--Hash Match(Aggregate, HASH:([AdventureWorks].[dbo].[SalesOrderHeader_test].[CustomerID]) DEFINE:([Expr1006]=COUNT(*)))
31474	1	            |--Clustered Index Scan(OBJECT:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderHeader_test_CL]))

��SalesOrderHeader_test�ϰ�����ɨ�裬����һ������������ڴ�Hash���Ͻ��оۺ�����
*/

SET STATISTICS PROFILE ON 

SELECT DISTINCT productid,unitprice 
FROM dbo.salesorderdetail_test
WHERE productid = 776
UNION ALL
SELECT DISTINCT productid,unitprice 
FROM dbo.salesorderdetail_test
WHERE productid = 776

SET STATISTICS PROFILE OFF 
/*
Rows	Executes	StmtText
8	1	SELECT DISTINCT productid,unitprice   FROM dbo.salesorderdetail_test  WHERE productid = 776  UNION ALL  SELECT DISTINCT productid,unitprice   FROM dbo.salesorderdetail_test  WHERE productid = 776
8	1	  |--Concatenation
4	1	       |--Sort(DISTINCT ORDER BY:([AdventureWorks].[dbo].[SalesOrderDetail_test].[UnitPrice] ASC))
16	1	       |    |--Parallelism(Gather Streams)
16	4	       |         |--Stream Aggregate(GROUP BY:([AdventureWorks].[dbo].[SalesOrderDetail_test].[UnitPrice]) DEFINE:([AdventureWorks].[dbo].[SalesOrderDetail_test].[ProductID]=ANY([AdventureWorks].[dbo].[SalesOrderDetail_test].[ProductID])))
2280	4	       |              |--Sort(ORDER BY:([AdventureWorks].[dbo].[SalesOrderDetail_test].[UnitPrice] ASC))
2280	4	       |                   |--Clustered Index Scan(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_cl]), WHERE:([AdventureWorks].[dbo].[SalesOrderDetail_test].[ProductID]=(776)))
4	1	       |--Sort(DISTINCT ORDER BY:([AdventureWorks].[dbo].[SalesOrderDetail_test].[UnitPrice] ASC))
15	1	            |--Parallelism(Gather Streams)
15	4	                 |--Stream Aggregate(GROUP BY:([AdventureWorks].[dbo].[SalesOrderDetail_test].[UnitPrice]) DEFINE:([AdventureWorks].[dbo].[SalesOrderDetail_test].[ProductID]=ANY([AdventureWorks].[dbo].[SalesOrderDetail_test].[ProductID])))
2280	4	                      |--Sort(ORDER BY:([AdventureWorks].[dbo].[SalesOrderDetail_test].[UnitPrice] ASC))
2280	4	                           |--Clustered Index Scan(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_cl]), WHERE:([AdventureWorks].[dbo].[SalesOrderDetail_test].[ProductID]=(776)))


*/