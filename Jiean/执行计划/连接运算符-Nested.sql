

--���������-Nested loops Join

/*
�����֮��Ĺ��������ʾ�������֮���һ��ѭ��������sqlServer��Ա��Ĺ������з�����ѡ��һ�����е�ѭ���㷨.


sqlserver������join������Nested Loops Join , Merge Join , Hash Join
�����ַ�����û����һ������Զ��õģ����Ƕ��������ʺϵ������ģ�sqlServer�������������������ڵı��ṹ���Լ�
������Ĵ�С��ѡ������ʵ����ӷ�������Ȼ����Ҳ�����������ָ��join �ķ�����

*/

--Nested loops Join
/*
Nested loops ��һ������������ӷ���,ֻ�������ڱ����ݼ��Ƚ�С�������
�㷨:��������Ҫ�� ������һ��ı��sqlserverѡ��һ����outer table,��һ���� inner table
*/
USE AdventureWorks
go
SET STATISTICS PROFILE ON 

SELECT * FROM dbo.SalesOrderHeader_test a
INNER LOOP JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID
WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660

SET STATISTICS PROFILE OFF 

/*
	Rows	Executes	StmtText
1	50577	1	SELECT * FROM dbo.SalesOrderHeader_test a  INNER LOOP JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID  WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660
2	50577	1	  |--Parallelism(Gather Streams)
3	50577	4	       |--Nested Loops(Inner Join, OUTER REFERENCES:([Uniq1005], [b].[SalesOrderDetailID], [Expr1007]) WITH UNORDERED PREFETCH)
4	50577	4	            |--Sort(ORDER BY:([b].[SalesOrderDetailID] ASC, [Uniq1005] ASC))
5	50577	4	            |    |--Nested Loops(Inner Join, OUTER REFERENCES:([a].[SalesOrderID], [Expr1006]) WITH UNORDERED PREFETCH)
6	10000	4	            |         |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderHeader_test_CL] AS [a]), SEEK:([a].[SalesOrderID] > (43659) AND [a].[SalesOrderID] < (53660)) ORDERED FORWARD)
7	50577	10000	        |         |--Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetail_test_NCL] AS [b]), SEEK:([b].[SalesOrderID]=[AdventureWorks].[dbo].[SalesOrderHeader_test].[SalesOrderID] as [a].[SalesOrderID]),  WHERE:([AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderID] as [b].[SalesOrderID]>(43659) AND [AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderID] as [b].[SalesOrderID]<(53660)) ORDERED FORWARD)
8	50577	50577	        |--Clustered Index Seek(OBJECT:([AdventureWorks].[dbo].[SalesOrderDetail_test].[salesorderdetail_test_cl] AS [b]), SEEK:([b].[SalesOrderDetailID]=[AdventureWorks].[dbo].[SalesOrderDetail_test].[SalesOrderDetailID] as [b].[SalesOrderDetailID] AND [Uniq1005]=[Uniq1005]) LOOKUP ORDERED FORWARD)

������������ָ����Nested Loops Join ���ӣ����۲�ִ�мƻ����Ż�����

����һ�ۿ���Nested Loops��������뵽ʲô
������һ�����ڱ����ӣ�����¼�������ڱ�ı�������

���ȣ���5�е�OUTER REFERENCES,���Կ�����sqlserverѡ��SalesOrderHeader_test��Ϊouter table(���),��SalesOrderDetail_test��ΪInter table(�ڱ�)

����SalesOrderHeader_test��ʹ�þۼ�������һ��seek,�ҳ�ÿһ��a.SalesOrderID>43659 AND a.SalesOrderID <53660�ļ�¼
�ܹ��ҵ�Rows=10000����¼��

ÿ�ҵ�һ����¼��sqlserver��ʱ��inner table ,���ܹ�����join�������ݵļ�¼ a.saleorderID = b.saleorderID
����outer table ����10000����¼���ϣ����� inner table ��ɨ����Executes=10000�� 

����
Nested Loops Join �㷨����ҪsqlServerΪ���ӽ�����������ݽṹ�����ԱȽ�ʡ�ڴ�ռ䣬Ҳ����ʹ��TempDb�Ŀռ䡣�����õ�join �����Ƿǳ��㷺�ġ�

����ô�۲�����join�㷨�Ƿ��Ч��
��
���ȣ�����Nested Loops ���������һ������������������ӱ�ļ�¼�Ƿ��������Ҫ��Ķ࣬����ǣ�������ԭ�򣬿����ǲ���ͳ����Ϣ��׼��
��Ϊÿ�ҵ�һ��Outer Table��¼������ɨ��һ��Inner Table ����ɨ��Ĵ������࣬�㷨���Ӷ����ӵ÷ǳ��죬�ܵ���Դ
����Ҳ�����ӵúܿ졣

Ȼ���¶�Outer Table�Ĳ��ң�ʵ�ʷ��ض��ټ�¼��Rows,��Ҳ�Ǵ���Nested Loops �������ɨ�����Executes
���Inner Table �������ɨ�裬���Ǿ���Ϊ����Join���Ǹ�Ч�ġ�

������Ż� Nested Loops Join������
��
1)�����ļ���OutTer Table ɸѡ��������ؾ����ٵ�����
2)OutTer Table ��������ã�����ʵ����оۼ����������ھۼ������ϲ��ң���ʱ����밴���������ź���ļ�¼��������Լ���Cost�Ŀ�����
3����Inner Table�����������ֶ���Ҫ��һ���������ܹ�֧�ּ������Ա�����ÿ�����������ݼ���ɨ�衣������ʹInner Table���ݼ���΢��
һ��Ҳû��ϵ ���������ֹ����Ǻܺ���Դ�ġ�


*/