

--���������-Hash Join

/*
Hash Join:���ù�ϣ�㷨��ƥ��������㷨����ϣ�㷨����������bulid���͡�Probe�� 
�� BULID�׶Σ�sqlserverѡ������Ҫ��join �����ݼ��е�һ�������ݼ�¼��ֵ ������һ�����ڴ��е�hash��
Ȼ����probe�׶Σ�sqlserverѡ ������һ�����ݼ���������ļ�¼ֵ���δ��룬�ҳ��������������ؿ��������ӵ���

�ص�
1,�㷨���ӶȾ��Ƿֱ�����������ݼ�����һ��
2������Ҫ���ݼ����Ȱ�����ʲô˳������Ҳ��Ҫ������������
3�����ԱȽ����׵�������ʹ�öദ�����Ĳ���ִ�мƻ�


*/
USE AdventureWorks
go

SET STATISTICS PROFILE ON 

SELECT * FROM dbo.SalesOrderHeader_test a
INNER Hash JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID
WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660

SET STATISTICS PROFILE OFF 

/*
	Rows	Executes	StmtText
1	50577	1	SELECT * FROM dbo.SalesOrderHeader_test a  INNER Hash JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID  WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660
2	50577	1	  |--Parallelism(Gather Streams)
3	50577	4	       |--Hash Match(Inner Join, HASH:([a].[SalesOrderID])=([b].[SalesOrderID]))
4	10000	4	            |--Parallelism(Repartition Streams, Hash Partitioning, PARTITION COLUMNS:([a].[SalesOrderID]))
5	10000	4	            |    |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderHeader_test_CL] AS [a]), SEEK:([a].[SalesOrderID] > (43659) AND [a].[SalesOrderID] < (53660)) ORDERED FORWARD)
6	50577	4	            |--Parallelism(Repartition Streams, Hash Partitioning, PARTITION COLUMNS:([b].[SalesOrderID]))
7	50577	4	                 |--Clustered Index Scan(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_cl] AS [b]), WHERE:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderID] as [b].[SalesOrderID]>(43659) AND [AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderID] as [b].[SalesOrderID]<(53660)))

������������ָ���� Hash JOIN ���ӣ����۲�ִ�мƻ����Ż�����

����һ�ۿ���Hash Loops��������뵽ʲô
������һ�������ϣ���ӣ��������������ݼ��������ݼ���ȱ������

�ӵ�5�к͵�7��������Կ�����Hash�㷨�ֱ��������������ߵ����ݼ���һ������10000,һ������50577
Ȼ���� Hash Match �׶�(Probe) ��ѡ������һ�����ݼ���������ļ�¼ֵ���δ��룬�ҳ��������������ؿ��������ӵ���

����ι۲�Merge Join�����Ƿ��Ч
��
Hash�㷨�ǱȽ����е�һ���㷨������Sqlserver���벻�Ż���join�����ݼ��Ƚϴ󣬻�����û�к��ʵ���������ʱ��һ�ֲ�����ѡ��
��Ҫ�۲�ִ�мƻ������߽�����Ĳ��ҷ�����

������Ż�Merge Join����
��
hash join�ǱȽϺ���Դ���㷨������join֮ǰ��Ҫ�����ڴ��ｨ��һ��hash������������ʾcpu��Դ��hash��Ҫ���ڴ�
��tempdb��ţ���join�Ĺ���ҲҪʹ��cpu��Դ������ ��probe��,���黹�Ǿ�������join��������ݼ��Ĵ�С�����Ժ���
������������sqlserver����ʹ��nested loop��merge��join
*/

