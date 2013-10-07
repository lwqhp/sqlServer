

--���������-Merge Join

/*
Merge Join ��һ�������ȶԵĹ�������Ҫ���������ݼ�������������õģ���Ҳ��ʹ��Merge���ӵ�ǰ������

���ȣ������ߵ����ݼ��и�ȡ��һ��ֵ���Ƚ�һ�£������ȣ��Ͱ������������������أ��������ȣ��Ͱ�С���Ǹ�ֵ������
��˳��ȡ��һ������ġ����ߵ����ݼ���һ�߱�������������join �Ĺ��̾ͽ����ˡ�
���ԣ������㷨�������Ĵ��� ���Ǵ���Ǹ����ݼ���ļ�¼���������ڴ����ݼ��������Ƿǳ������Ƶġ�

mary-to-mary��
Merge Joinֻ���ԡ�ֵ��ȡ�Ϊ���������ӣ�������ݼ��������ظ������ݣ�merge join Ҫ����mary-to-mary���ֺܷ���Դ
���ӷ�ʽ��������ݼ�1���������߶����¼ֵ��ȣ�sqlserver�ͱؼ��ð����ݼ�2���������������ʱ����һ�����ݽṹ�������
����һ���ݼ�1�����һ����¼�������ֵ���ǻ����ã������ʱ�����ݽṹ��Ϊ worktable �ᱻ ����tempdb �����ڴ��


*/
USE AdventureWorks
go

DROP INDEX SalesOrderHeader_test_CL ON SalesOrderHeader_test
CREATE CLUSTERED  INDEX SalesOrderHeader_test_CL ON SalesOrderHeader_test(SalesOrderID)

SET STATISTICS PROFILE ON 

SELECT COUNT(b.SalesOrderID) FROM dbo.SalesOrderHeader_test a
INNER MERGE JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID
WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660

SET STATISTICS PROFILE OFF 

/*
	TotalSubtreeCost	Rows	Executes	StmtText
1	2.177477	1	1	SELECT COUNT(b.SalesOrderID) FROM dbo.SalesOrderHeader_test a  INNER MERGE JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID  WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660
2	2.177477	0	0	  |--Compute Scalar(DEFINE:([Expr1006]=CONVERT_IMPLICIT(int,[globalagg1008],0)))
3	2.177477	1	1	       |--Stream Aggregate(DEFINE:([globalagg1008]=SUM([partialagg1007])))
4	2.177475	4	1	            |--Parallelism(Gather Streams)
5	2.148973	4	4	                 |--Stream Aggregate(DEFINE:([partialagg1007]=Count(*)))
6	2.133881	50577	4	                      |--Merge Join(Inner Join, MANY-TO-MANY MERGE:([a].[SalesOrderID])=([b].[SalesOrderID]), RESIDUAL:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderID] as [a].[SalesOrderID]=[AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderID] as [b].[SalesOrderID]))
7	0.2880782	10000	4	                           |--Parallelism(Repartition Streams, Hash Partitioning, PARTITION COLUMNS:([a].[SalesOrderID]), ORDER BY:([a].[SalesOrderID] ASC))
8	0.1975928	10000	4	                           |    |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderHeader_test_CL] AS [a]), SEEK:([a].[SalesOrderID] > (43659) AND [a].[SalesOrderID] < (53660)) ORDERED FORWARD)
9	0.4232679	50577	4	                           |--Parallelism(Repartition Streams, Hash Partitioning, PARTITION COLUMNS:([b].[SalesOrderID]), ORDER BY:([b].[SalesOrderID] ASC))
10	0.0813826	50577	4	                                |--Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetail_test_NCL] AS [b]), SEEK:([b].[SalesOrderID] > (43659) AND [b].[SalesOrderID] < (53660)) ORDERED FORWARD)

������������ָ���� MERGE JOIN ���ӣ����۲�ִ�мƻ����Ż�����

����һ�ۿ���MERGE Loops��������뵽ʲô
������һ������ƽ�й������ӣ����������Ƿ���Ψһ�ԣ���������Ϊ�����¼����

 
���ȣ� �ӵ�6�� Merge Join�����Կ����������������SalesOrderID���й����Ƚ�
��SalesOrderHeader_test��SalesOrderID���оۼ����������Ե�8��ֱ��ʹ���˾ۼ���������.

��10��˵��ִ�мƻ��ҵ�һ������������������������Ǿۼ��������ҡ�

���ڵ�һ�����ݼ���SalesOrderID��������һ��Ψһ����������MANY-TO-MANY ����

(ע���������select ���ص��ֶβ���������������������ͬ��ִ�мƻ������SalesOrderDetail_test�ľۼ�����SalesOrderDetailID)��
����ɨ����Ҫ���ֶΡ�
|--Parallelism(Repartition Streams, Hash Partitioning, PARTITION COLUMNS:([b].[SalesOrderID]))
  |--Clustered Index Scan(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_cl] AS [b]), WHERE:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderID] as [b].[SalesOrderID]>(43659) AND [AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderID] as [b].[SalesOrderID]<(53660)))



����ι۲�Merge Join�����Ƿ��Ч
��
���ȿ��Ƿ����Sort���������ͨ������Ϊ�������ֶ�û����������еĲ��������㷨����ֵģ�����������е�ͨ��SalesOrderDetailID�ۼ�����
ȥɨ��SalesOrderID�ֶΣ�Ȼ���ٰ�SalesOrderID���򣬴�TotalSubtreeCost��������ɨ����úܴ��Cost.

Ȼ���ٿ�Merge Join ��û��ʹ����mary-to-mary����˵����һ�����������ȷ����Ψһ�ġ�

������Ż�Merge Join����
��
1)����������ڹ���ǰ�������ڹ����ֶ���������
2����֤��һ�������Ϊunique�ľۼ�����
*/

--��SalesOrderID ��ΪΨһ�ۼ�����
DROP INDEX SalesOrderHeader_test_CL ON SalesOrderHeader_test
CREATE UNIQUE CLUSTERED INDEX SalesOrderHeader_test_CL  ON SalesOrderHeader_test(SalesOrderID)

SET STATISTICS PROFILE ON 

SELECT COUNT(b.SalesOrderID) FROM dbo.SalesOrderHeader_test a
INNER MERGE JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID
WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660

SET STATISTICS PROFILE OFF   
/*
TotalSubtreeCost	Rows	Executes	StmtText
0.4796984	1	1	SELECT COUNT(b.SalesOrderID) FROM dbo.SalesOrderHeader_test a  INNER MERGE JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID  WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660
0.4796984	0	0	  |--Compute Scalar(DEFINE:([Expr1005]=CONVERT_IMPLICIT(int,[Expr1008],0)))
0.4796984	1	1	       |--Stream Aggregate(DEFINE:([Expr1008]=Count(*)))
0.4495145	50577	1	            |--Merge Join(Inner Join, MERGE:([a].[SalesOrderID])=([b].[SalesOrderID]), RESIDUAL:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderID] as [a].[SalesOrderID]=[AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderID] as [b].[SalesOrderID]))
0.2024309	10000	1	                 |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderHeader_test_CL] AS [a]), SEEK:([a].[SalesOrderID] > (43659) AND [a].[SalesOrderID] < (53660)) ORDERED FORWARD)
0.1092698	50577	1	                 |--Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetail_test_NCL] AS [b]), SEEK:([b].[SalesOrderID] > (43659) AND [b].[SalesOrderID] < (53660)) ORDERED FORWARD)

���Կ���Merge Joinû��ʹ��mary-to-mary���㣬����ɱ�Ҳ������1.6843665 Cost=2.133881-0.4495145=1.6843665
*/
