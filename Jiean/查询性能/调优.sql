
--��������
DROP TABLE SalesOrderHeader_test
SELECT * 
INTO dbo.SalesOrderHeader_test
FROM sales.SalesOrderHeader

DROP TABLE SalesOrderDetail_test
SELECT * 
INTO dbo.SalesOrderDetail_test
FROM sales.SalesOrderDetail

--��salesorderid�ϴ����ۼ�����
CREATE CLUSTERED INDEX  SalesOrderHeader_test_CL ON SalesOrderHeader_test(SalesOrderID)

--����ϸ���Ǿۼ�����
CREATE INDEX SalesOrderDetail_test_NCL ON SalesOrderDetail_test(SalesOrderID)

--������������9��������¼�����75124-75132��ÿ�ŵ���12�����ݣ�����ϸ����90%����������9�ŵ�
DECLARE @i INT
SET @i=1
WHILE @i<=9
BEGIN
INSERT INTO dbo.SalesOrderHeader_test( RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, 
SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, TerritoryID, BillToAddressID,
 ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, 
 Freight, TotalDue, Comment, rowguid, ModifiedDate)
 SELECT RevisionNumber, OrderDate, DueDate, ShipDate, Status, OnlineOrderFlag, 
SalesOrderNumber, PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, TerritoryID, BillToAddressID,
 ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode, CurrencyRateID, SubTotal, TaxAmt, 
 Freight, TotalDue, Comment, rowguid, ModifiedDate
 FROM dbo.SalesOrderHeader_test
 WHERE salesorderID = 75123
 
 IF @@ERROR=0
 INSERT INTO dbo.salesorderDetail_test(SalesOrderID,  CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID,
  UnitPrice, UnitPriceDiscount, LineTotal, rowguid, ModifiedDate)
  SELECT 75123+@i,CarrierTrackingNumber, OrderQty, ProductID, SpecialOfferID,
  UnitPrice, UnitPriceDiscount, LineTotal, rowguid, GETDATE()
  FROM sales.SalesOrderDetail
  SET @i = @i+1
END
  
--SELECT COUNT(0) FROM SalesOrderHeader_test
--SELECT COUNT(0) FROM dbo.salesorderDetail_test

--�ڶ��ϱ�ɨ��
SET  STATISTICS PROFILE ON --˹���� '˹������
SELECT salesorderdetailID,unitprice 
FROM salesorderdetail_test
WHERE unitprice>200

/*
�ۼ�����ɨ�裺�ڴ����˾ۼ������ı���ִ�б�ɨ�裬��Ϊ�ۼ�������Ҷ��ҳ��������ҳ����ʵ�����൱�ڱ�ɨ�裬
*/

CREATE CLUSTERED INDEX salesorderdetail_test_cl ON salesorderdetail_test(SalesOrderDetailID)

/*
�����Ǿۼ�������Ϊÿһ�μ�¼�洢һ�ݷǾۼ�����������ֵ��һ�ݾۼ�������������ֵ��û�оۼ�����������RIDֵ��
��Ϊ�Ǿۼ�������Ҷ������ֵҳָ��۾�������ֵ��û�л����������е�IDֵ��
*/

CREATE INDEX salesorderdetail_test_Ncl_price ON salesorderdetail_test(UnitPrice)

/*
�ڷ��ص��ֶ��ϼӼ����ֶΣ�sqlserver ��Ҫ���ڷǾۼ��������ҵ�����unitprice����200�ļ�¼��Ȼ���ٸ���salesorderdetialid ��ֵ�ҵ�
�ҵ��洢�ھۼ������ϵ���ϸ���ݣ�������̳�Ϊ"Bookmark Lookup"
��sqlserver2005�Ժ�bookmark lookup �Ķ���Ҫ��һ��Ƕ��ѭ ������ɣ�������ִ�мƻ�����ܿ�����seek�˷Ǿۼ�
������Ȼ����clustered index seek����Ҫ�����ҳ���
*/
SELECT salesorderID,salesOrderDetailID,unitPrice 
FROM dbo.SalesOrderDetail_test WITH(INDEX(salesorderdetail_test_Ncl_price))
WHERE unitPrice>200

SET STATISTICS PROFILE OFF


/*ͳ����Ϣ
ͳ����Ϣ��sqlServer �����ݵķ������棬�������������������ݱ��������ݵ���ִ�мƻ�
*/
-- stati s tics 
UPDATE STATISTICS SalesOrderHeader_test(SalesOrderHeader_test_CL)
DBCC SHOW_STATISTICS (SalesOrderHeader_test,SalesOrderHeader_test_CL)

/*
all density :�����е�ѡ��ȣ�������ֵ С��0.1˵��ѡ�����ǱȽϸߵģ�����0.1,�Ͳ�Щ��

ֱ��ͼ
range_hi_key ˵���ֳ����飬ÿ�����ݵ����ֵ
range_rows  ÿ���������������������ֵ���⣬��һ��ֻ��һ��43659,���һ����75132,�������ڵڶ�������
distinct_range_rows ��������ظ�ֵ����Ŀ
avg_range_rows ÿ���������ظ�ֵ��ƽ����Ŀ�����㹫ʽ=��range_rows/distinct_range_rows for distinct_range_rows>0��
*/


DBCC SHOW_STATISTICS(SalesOrderDetail_test,SalesOrderDetail_test_NCL)
/*
SalesOrderDetail_test 90%��������751124-75132��9 �ŵ�

density������������saleorderID��ѡ��ַ������SalesOrderID, SalesOrderDetailID�ϲ�������ѡ����ֵ������һ����
ѡ����Ҫ�ȵ�һ���ߵĶࡣ
*/

--�Ƚ�����д��
SET STATISTICS PROFILE ON 

SELECT b.salesorderID,b.orderDate,a.* 
FROM salesorderdetail_test a
INNER JOIN salesorderheader_test b 
ON a.salesorderID  = b.salesOrderID
WHERE b.salesorderID = 72642

SELECT b.salesorderID,b.orderDate,a.* 
FROM salesorderdetail_test a
INNER JOIN salesorderheader_test b 
ON a.salesorderID  = b.salesOrderID
WHERE b.salesorderID = 75127

/*
��������ͳ����Ϣ���Կ���72642 �� EQ_rows���Ʒ�������3,75127����������121317,����Դ�ѡ���˲�ͬ��ִ�мƻ���
�����ؽ����ʵ�ʷ��ص���������ȵģ�˵��ͳ����Ϣ��׼ȷ�ģ�������ͳ����Ϣ������ִ�мƻ�
*/

/*
ͳ����Ϣ��ά��

�����ݿ������Ĭ�ϴ��������ԣ�auto create statistics ��auto update statistics���ܹ���sqlserver����Ҫ��ʱ��
�Զ�ȥ����ͳ����Ϣ��Ҳ���ڷ���ͳ����Ϣ��ʱ���Զ�ȥ���¡�
auto update statistics asynchronously�첽����(2005�¹���)��������ͳ����Ϣ��ʱʱ�������ϵ�ͳ����Ϣ�������ڵĲ�ѯ���룬
�����ں�̨����һ������ȥ�������ͳ����Ϣ���´�ʹ��ʱ�����µİ汾�ˡ�


��3��������Զ�ȥ����ͳ����Ϣ
1)��������ʱ�����Զ����������ϴ���ͳ����Ϣ

2)�ֶ�����  

3)��sqlserver��Ҫʹ��ĳЩ���ϵ�ͳ����Ϣ������û��ʱ�����Զ�����ͳ����Ϣ��

��ɾ�Ķ���Ӱ��ͳ����Ϣ��׼���ԣ�������ͳ����ϢҲ��Ҫ����һ������Դ�����Դ���ͳ����Ϣ�ĸ�����Ҫһ��ƽ�⡣
1�����ͳ����Ϣ�Ƕ�������ͨ���ϵģ���ô����������仯֮һ��ͳ����Ϣ�ͱ� ��Ϊ�ǹ�ʱ���ˣ��´�ʹ��ʱ����
�Զ��� ��һ�����¶���
1,���¼���޵���
2������������С��500�еģ���ͳ����Ϣ�ĵ�һ���ֶ������ۼƱ仯������500�Ժ�
3,��������������500�еģ���ͳ����Ϣ�ĵ�һ���ֶ����ۼƱ仯������500+(20%*�ܼ�¼��)��Ҳ���ǵ�1/5���ϵ����ݷ���
�仯��,sqlserver�Ż�ȥ����ͳ����Ϣ��
ע����ʱ��Ҳ��ͳ����Ϣ���������û�С�

����С��500�е����ݱ�����ͳ����Ϣ��һ�ֶεĸ����ۼ�û�г���500,���ᴥ���Զ�����ͳ����Ϣ�����������������ֶΣ�
���ٸ��£��������������ȴ�������£���ͳ����Ϣ�ͻ᲻׼ȷ�ˡ�
*/

--����ʵ��

EXEC sp_helpstats salesorderheader_test
--�˶���û���κ�ͳ����Ϣ��

SELECT COUNT(0) FROM salesorderheader_test WHERE orderdate = '2004-06-11 00:00:00.000'
/*
statistics_name                                                                                                                  statistics_keys
-------------------------------------------------------------------------------------------------------------------------------- ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
_WA_Sys_00000003_75035A77                                                                                                        OrderDate

����һ���µ�ͳ����Ϣ
*/

/*
������ر���

sqlServer ��ָ���ִ�У�Ҫ����﷨���������������-������complie,�����ܹ����е�ִ�мƻ�����練浽�ڴ��С�
*/

/*
ֻ����ȫ��ͬ��sql ���Ż�ʹ�õ�����ִ�мƻ�
objtype���� adhoc:select ,insert,update,delete������ָ��
��sql Trace ��
	sp:cacheinsert ��һ��ִ���й������¼�
	sp:cachehit �ڶ���ִ��������ǰ��ִ�мƻ�
*/
--�鿴��ǰ�����ִ�мƻ�
SELECT usecounts,cacheobjtype,objtype,text FROM sys.dm_exec_cached_plans
CROSS APPLY sys.dm_exec_sql_text(plan_handle)
ORDER BY usecounts DESC


/*
sqlserver ����һ���Զ��������Ĳ�ѯ�������˻�������ִ�мƻ��������ظ�����
������ sp_executesql ����ָ��
*/

DBCC freeproccache
go

SELECT ProductID,SalesOrderID FROM sales.SalesOrderDetail WHERE productid >1000
GO
SELECT ProductID,SalesOrderID FROM sales.SalesOrderDetail WHERE productid >2000
GO
SELECT * FROM sys.syscacheobjects

/*
������۷��ֱ仯��ͳ����Ϣ���Լ�dbcc freeproccache,sp_recompile,keep plan,keepfixed plan�����γ��ر���
*/
--�鿴���������ִ�мƻ�
SELECT * FROM sys.syscacheobjects

--���ִ�мƻ�����
DBCC freeproccache
DBCC flushprocindb(db_id)

/*sql Trace ��������йص��¼�
cursors-cursorrecompile: ���α������ڵĶ������ܹ��仯�����µ�TSQL�α������ر���
performance-AUTO STATS :�����Զ��������߸���ͳ����Ϣ���¼�
stored procedures �����кü��������õ��¼�;
sp:cachehit : ˵����ǰ����ڻ������ҵ�һ�����õ�ִ�мƻ�
sp:cacheinsert :��ǰ��һ����ִ�н������뵽������
sp:cachemiss :˵����ǰ����ڻ������Ҳ���һ�����õ�ִ�мƻ�
sp:cacheremove:��ִ�мƻ����ӻ������Ƴ����ڴ���ѹ��ʱ�ᷢ��
sp:recompile:һ���洢���̷������ر��룬eventsubclass��¼���ر��뷢����ԭ��


���õļ�����
sqlserver:buffer manager
sqlserver:cache manager
sqlserver:memory manager
sqlserver:sql statistics
*/

--=======================================================================
/*
ִ�мƻ�
�����ַ�ʽ���Բ�ѯ������ִ�мƻ�
1)�����ǰ��Щ���أ������Ľ�������Ԥ��ִ�мƻ���ʵ��ִ�мƻ�ͬʱ��ʾ����
set showplan_all on --���ҵ����õ�ִ�мƻ����������䲻ִ��
set showplan_xml on 
set statistics profile on --���������ִ��֮��ʵ�ʵ�ִ�мƻ�
2)��һ����sql Trace�����¼�����������ִ�мƻ�
showplan all --�¼���������俪ʼ֮ǰ
showplan statistics profile --���������ִ��֮��
showplan xml statistcs profile

��Щ��Ϣ�������ǲ���reuse��һ��ִ�мƻ���sql server��û�о���ȱ��������ֻ����xml������￴����
*/

SET SHOWPLAN_ALL ON 
go
SELECT a.SalesOrderID,a.OrderDate,a.CustomerID,b.SalesOrderDetailID,b.ProductID,b.OrderQty,b.UnitPrice 
FROM dbo.SalesOrderHeader_test a
INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b.SalesOrderID
WHERE a.SalesOrderID = 43659
--ֻ��esitmaterows

SET SHOWPLAN_ALL OFF

SET STATISTICS PROFILE ON
go
SELECT a.SalesOrderID,a.OrderDate,a.CustomerID,b.SalesOrderDetailID,b.ProductID,b.OrderQty,b.UnitPrice 
FROM dbo.SalesOrderHeader_test a
INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b.SalesOrderID
WHERE a.SalesOrderID = 43659
--��rows

SET STATISTICS PROFILE OFF

/*
����ִ�мƻ���ִ��˳��
���ṹ����һ���֧��������һ���Ӿ䣬ִ�д���ײ㿪ʼ����xmlͼ�У��Ǵ����ұ����󣬴������Ͽ�ʼ

����ִ�е�6��5�е�index seek��clustered index seek 
�Ĵ�֮�ϣ��������������Ƕ��ѭ���ķ�ʽ����������4���õ��������ִ�е�3�У���salesorderheader_test ����culustered index seek ����Ϊһ��
2����һ��Ƕ��ѭ����˵��sqlserver ��ʹ�õ�Ƕ��ѭ��������������ϲ�������

����salesorderheader_test ��salesorderID���оۼ�������sqlserver����ֱ�����ҵ�salesorderID=43659,Ȼ������ļ�����
��ȡ������һ��culustered index seek

��salesorderdetail_test��salesorderID�ϵ��ǷǾۼ����������ص�ֵ������ȫ���Ǿۼ��������������������÷Ǿ��ҵ�
salesorderID=43659��¼����Ҫ��ָ��;ۼ�������nested loops�����ӣ������е��ֶ�ֵȡ������

--------------
�����֮��Ĺ��������ʾ�������֮���һ��ѭ��������sqlServer��Ա��Ĺ������з�����ѡ��һ�����е�ѭ���㷨.

<sqlserverѭ���㷨�м��֣�ʲô����»�Ӱ����ѡ���㷨>
sqlserver������join������

Nested loops Join
Nested loops ��һ������������ӷ������㷨�Ƕ�������Ҫ�� ������һ��ı��sqlserverѡ��һ����outer table,
��һ���� inner table
*/
SET STATISTICS PROFILE ON 
GO
SELECT * FROM dbo.SalesOrderHeader_test a
INNER LOOP JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID
WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660

/*
sqlserver ѡ�� a��Ϊouter table ,������header_test��ʹ�þۼ�������һ��seek,�ҳ�ÿһ��a.salesorderid>4365�ļ�¼
��ÿ�ҵ�һ����¼��sqlserver��ʱ��inner table ,���ܹ�����join�������ݵļ�¼ a.saleorderID = b.saleorderID,����
outer table ����10000����¼���ϣ����� inner table ��ɨ����10000�� ��executes��rows

�ؼ���
�㷨���Ӷȵ���inner table *outer table ���outer table ��ܴ�innertable �ᱻɨ��ܶ�Σ����ĺܶ����Դ.
outer table �����ݼ�����ܹ���������ã��Ա����˨��Ч��
inner table �������һ���������ܹ�֧�ּ���
*/

SELECT * FROM dbo.SalesOrderHeader_test a
INNER MERGE JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID
WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660

/*
2) Merge Join

��ϴ�����ӣ������ߵ����ݼ��и�ȡ��һ��ֵ���Ƚ�һ�£������ȣ��Ͱ������������������أ��������ȣ�
�Ͱ�С���Ǹ�ֵ��������˳��ȡ��һ������ġ����ߵ����ݼ���һ�߱�������������join �Ĺ��̾ͽ����ˣ����������㷨
�����Ǵ���Ǹ����ݼ���ļ�¼������

�ؼ���
�����ӵ��������ݼ�����Ҫ���Ȱ���join���ֶ��ź���
���������������ݼ����Ǹ�����salesorderID�ֶε�������seek�����ģ����Բ���Ҫ�������� 

Merge Joinֻ���ԡ�ֵ��ȡ�Ϊ���������ӣ�������ݼ��������ظ������ݣ�merge join Ҫ����mary-to-mary���ֺܷ���Դ
���ӷ�ʽ��������ݼ�1���������߶����¼ֵ��ȣ�sqlserver�ͱؼ��ð����ݼ�2���������������ʱ����һ�����ݽṹ�������
����һ���ݼ�1�����һ����¼�������ֵ���ǻ����ã������ʱ�����ݽṹ��Ϊ worktable �ᱻ ����tempdb �����ڴ��
��totaosubstreecost���Կ������������cl��������ĳ�һ��unique�ľۼ�������sqlserver��֪�����ݼ�1��ֵ�����ظ���
Ҳ�Ͳ���Ҫ��many-to-many join
*/


SELECT * FROM dbo.SalesOrderHeader_test a
INNER HASH JOIN dbo.SalesOrderDetail_test b ON b.SalesOrderID = a.SalesOrderID
WHERE a.SalesOrderID>43659 AND a.SalesOrderID <53660

/*
3) Hash Join 
���ù�ϣ�㷨��ƥ��������㷨������������bulid���͡�Probe���� BULID�׶Σ�sqlserverѡ������Ҫ��join �����ݼ���
��һ�������ݼ�¼��ֵ ������һ�����ڴ��е�hash��Ȼ����probe�׶Σ�sqlserverѡ ������һ�����ݼ���������ļ�¼ֵ 
���δ��룬�ҳ��������������ؿ��������ӵ���

�ؼ���
1,�㷨���ӶȾ��Ƿֱ�����������ݼ�����һ��
2������Ҫ���ݼ����Ȱ�����ʲô˳������Ҳ��Ҫ������������
3�����ԱȽ����׵�������ʹ�öദ�����Ĳ���ִ�мƻ�

hash join�ǱȽϺ���Դ���㷨������join֮ǰ��Ҫ�����ڴ��ｨ��һ��hash������������ʾcpu��Դ��hash��Ҫ���ڴ�
��tempdb��ţ���join�Ĺ���ҲҪʹ��cpu��Դ������ ��probe��,���黹�Ǿ�������join��������ݼ��Ĵ�С�����Ժ���
������������sqlserver����ʹ��nested loop��merge��join

-----ȱһ��ͼƬ
*/

/*
aggregation
��Ҫ�������� sum(),count,max,min�Ⱦۺ����㣬Aggregation������
stream aggreation:�����ݼ��ų�һ�������Ժ�������
hash aggreation:���� hash join ,��Ҫ���ڴ��н�һ��hash������������
*/

SET STATISTICS PROFILE ON 

SELECT SalesOrderID,COUNT(SalesOrderDetailID)
FROM dbo.SalesOrderDetail_test
GROUP BY SalesOrderID

SELECT customerID,COUNT(*)
FROM dbo.SalesOrderheader_test
GROUP BY customerID

/*
concatenation ���ݺϲ�
���ֲ��������� concatenation����:union ��union all
union �����һ��sort���򣬰��ظ�������ȥ��

parallelism :���в���
*/

---============================================
DBCC DROPCLEANBUFFERS
--���buffer pool������л��������
DBCC freeproccache
--���buffer pool������л����ִ�мƻ�

--���鿴ִ��ʱ��ϸ�ڡ�
/*
ִ����ʱ��������������ʱ���sql��ִ��ʱ��,���У�ռ��ʱ������˶�Ӧ��cpuʱ�䡣ʣ��ΪIO���ڴ棬�ȴ�����ʱ����
*/
SET STATISTICS TIME ON
GO

SELECT DISTINCT ProductID,UnitPrice 
FROM dbo.SalesOrderDetail_test
WHERE ProductID=777
UNION 
SELECT  ProductID,UnitPrice 
FROM dbo.SalesOrderDetail_test
WHERE ProductID=777

SET STATISTICS TIME OFF

--���鿴IO�Ĳ�����
/*
ɨ�����������ִ�мƻ�����scan�˼���
�߼���ȡ�������ݻ����ȡ��ҳ������������ҳ�洢�ģ�ÿһ�δ�ȡ������ҳΪ��λ��ҳ��Խ�࣬˵����ѯҪ���ʵ�
��������Խ���ڴ�������Խ�󣬲�ѯҲ��Խ���󡣿��Լ���Ƿ�Ӧ�õ�������������ɨ��Ĵ�������Сɨ�跶Χ��
�����ȡ���Ӵ��̶�ȡ��ҳ����
Ԥ����Ϊ���в�ѯ��Ԥ���뻺���ҳ��
*/

DBCC DROPCLEANBUFFERS
GO
SET STATISTICS IO ON

SELECT DISTINCT  ProductID,UnitPrice 
FROM dbo.SalesOrderDetail_test
WHERE ProductID=777

SET STATISTICS IO OFF


--���鿴ִ�мƻ���
/*
rows:ִ�мƻ�ÿһ�����ص�ʵ������
executes :ִ�мƻ�ÿһ���������˶��ٴ�
*/

SET STATISTICS PROFILE ON 

SELECT DISTINCT  ProductID,UnitPrice 
FROM dbo.SalesOrderDetail_test
WHERE ProductID=777

/*
������
6,clustered index scanȫ��ۼ�����ɨ�裬�ҳ�porductID =777�ļ�¼
5,ʹ��sort�ķ�ʽ�ѷ��ص�2420��¼��һ�����򣬴���ѡ��distinct ֵ������ֻ��unitprice,Ԥ����������˵��
��productID+unitprice��û��ֱ�ӵ�ͳ����Ϣ
4����unitprice�ų�һ�����к�ProductID,UnitPrice ��distinct()����
3��parallelism������ִ��
2��һ��distinct order by ���򣬷��ؽ��
��ִ�мƻ���������Ҫcost������lustered index scan�ϣ���productID��һ��������һ���Ƚ���Ȼ���뷨
*/
SET STATISTICS PROFILE OFF


SELECT COUNT(b.SalesOrderID)
FROM dbo.SalesOrderHeader_test a 
INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b .SalesOrderID
WHERE a.SalesOrderID>43659 AND a.SalesOrderID<53660

/*
5,a.SalesOrderID���оۼ�����������ֱ��������������clustered index seek,��������ȷ��cost ��
6��SalesOrderDetail_test���ҳ���SalesOrderID>43659 AND SalesOrderID<53660���ļ�¼����ΪSalesOrderID���з�
�ۼ���������������������������index seek ,�����￴����ִ�мƻ��������������ж��ҳ��˷��������ļ�¼������
��join������
4������������Ƚϴ�����ѡ����hash match�ķ�������Ϊ���ű��salesorderid�϶���ͳ����Ϣ������Ԥ���ǱȽ�׼��
3��ִ��count(*)����
2��ֵ����ת����int���ͣ���Ϊ������أ�cost �������Բ��ơ�
*/

/*
������˼·�ͷ���
1)ȷ���Ƿ�����Ϊ��������i/o�����µ����ܲ���
���ĵ��ţ�Ҫ��ȷ������ҳ���ܹ����Ȼ������ڴ������������õ���������ܻ����ܴﵽҪ�󣬲��к�������
�ı�Ҫ�����������������������ܵ��㹻�죬��˵���������Ҳ��һ��ϵͳ��Դƿ�����⣬������Ҫ����䱾������⡣

2��ȷ���Ƿ�����Ϊ����ʱ�䳤�����µ����ܲ���
�󲿷�����£�����ʱ���ԶС��ִ��ʱ�䣬�������ʱ��ռ����ʱ��50%���ң������ִ�е��ٶ��ֺܿ죬���ŵ��ص�
��ת����α����ر��룬���߽��ͱ���ʱ�䡣

3����i/O������ʱ�䶼������������ִ�к�������Ҫ�ص��������ִ�С���ִ�мƻ�����sqlServerѡ���ִ�мƻ�
�Ƿ�׼ȷ����Ҫ��sqlserver�Ƿ���ȷ��Ԥ����ÿһ����cost,��Ϊcost�Ǹ���EstimatedRows�Ĵ�С��Ԥ��cost�ģ����Ԥ
��ֵ��ʵ��ֵ���ܶ࣬˵��sqlServer����һ����׼ȷ��ͳ����Ϣ�ƶ��˵�һ��ִ�мƻ���

4�����sqlserverѡ���ִ�мƻ��Ǻ���ģ��Ǿ�˵�����еı�ṹ��������sqlServer�޷�������Ԥ�ڵ�ʱ���������
���ִ�У��Ǿ�Ҫ����ṹ������߼���ͨ���������ݼ��������������ı�ҵ���߼��Ĵ�������ʵ�ʵ��š�
*/

--�鿴i/o
DBCC DROPCLEANBUFFERS

SET STATISTICS IO ON 
SET STATISTICS TIME ON 

/*
����ڵ���������ʱ�����������⣬ֻ��������i/o��ʱ��ų��֣���
a,��������������Ƿ����ڴ�ƿ�����Ƿ���ھ�����ҳ������
	������������£��ڴ�û��ƿ�������ߺ�����page out/page in�Ķ�������˵��sqlserver�ܹ�������ҳά�����ڴ���
	�㿴������������Ͳ�̫�ᷢ������������̫�����ǡ�
b,�����仰���������ʵ����ݣ��Ǳ�����ʹ�õģ�����ż��ʹ�õģ���һż��ʹ�ã������ʵ��������ִ���sqlserver
û�а����ŵ��ڴ���Ҳ�������ģ�����������䣬������ʱ����������i/oʱ���Ǻ���ġ�
c,������ִ�мƻ����Ƿ��ܹ���������ʵ�������
d,��������ϵͳ������
��������ʵ����ݺܿ��ܾͲ����ڴ����������������һ��Ҫ��������ܣ���Ψһ�ĳ�·������ߴ�����ϵͳ�������ˡ�


2���Ƿ�����Ϊ����ʱ�䳤���������ܲ���
һ����Ҫ����������ص�����룬һ���ǱȽϼ򵥣�������޶̣��漰���Ƚ��٣�������Ӧ�û������ﷴ�����õ����
����ܹ�ͨ��ִ�мƻ�������ȥ������ʱ�䣬����ͨ������ ���ݿ�����ĵ�ƭ��ʱ�䣬���� ���Ч�ʾ��ܹ����40-50%
����һ������䱾��Ƚϸ��ӣ������������ڵı������̫��������ɹ�ѡ��ʹ�ñ���ʱ��ͳ���1�롣
*/
--��sql trace��������ʱ��
DROP PROC longcompile
GO
CREATE PROC longcompile (@i INT ) 
AS
DECLARE @cmd VARCHAR(max)
DECLARE @j INT
SET @J =0
SET @cmd  ='
	select * from dbo.SalesOrderHeader_test a
	INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b.SalesOrderID
	INNER JOIN Production.Product p ON b.ProductID = p.ProductID
	WHERE a.SalesOrderID IN(43659'
WHILE @j<@i
BEGIN
SET @cmd = @cmd +','+STR(@j+43659)
SET @j=@j+1
END
SET @cmd=@cmd + ')'
EXEC(@cmd)
go


dbcc dropcleanbuffers

set statistics time on
longcompile 100
/*
�鿴���(���洢����)�ı��룬ִ������Ҫ��ʱ��
stored Procedures
	PRC:completed
	PRC:starting
	SP:stmtCompleted
	SP:stmtstarting
TSQL
	SQL:BatchCompleted
	SQL:BatchStarting
	SQL:StmtCompleted
	SQL:StmtRecompile
	SQL:StmtStaiting

һ��Batch����ʱ�䣬������SQL:BatchStarting �¼��Ŀ�ʼʱ�䣬��ȥ���һ������SQL:StmtStarting�¼���ʼʱ�䣨��ΪsqlServer
���ȱ�������Batch,Ȼ���ٿ�ʼ���е�һ�䡣���������ʱ����ȣ�˵����ִ�мƻ����ã����߱���ʱ����Ժ��Բ��ơ�

һ��stored procedure �ı���ʱ�䣬���ڵ�������statement��SQL:StmtStarting �¼���ʼʱ�䣨������RPC:startingʱ�䣩��ȥ���һ��
���SP��StmtStarting �Ŀ�ʼʱ��(��ΪSqlserver���ȱ��������SP��Ȼ�������е�һ��)

����Ƕ�̬��䣬��Batch��SP�����ʱ�� �ٲ���������ı���ʱ�䣬���ı���ʱ�䷢��������������֮ǰ��������exec ָ��������������
����sp:stmtstarting�¼�֮��

����
sp:stmtstarting exec(@cmd)�Ŀ�ʼִ��ʱ�䣺370����
����̬���Ŀ�ʼִ�� sp:stmtstarting select *..... �Ŀ�ʼִ��ʱ����437���룬�м��67����Ƕ�̬���ı���ʱ��
sp:cachinsert �¼�˵�����﷢���˱���

��̬����Լ����ʹ�õ�ʱ����1136���� sp:stmtCompleted,����������ʱ��
sp:stmtcompleted exec(@cmd) ����durationʱ����1204����,���а����˶�̬���ִ�е�1136��67��ı���ʱ��=1����

SQL:Stmtcompleted exec longcompile 100 ��ʱ1224����,-1204=20���룬����̬�����������������20����

����㷢�������������ͱ����йأ����ƿ��ǵķ����У�
1�������䱾���Ƿ���ڸ��ӣ�����̫���������԰�һ�仰�۳ɼ�����򵥵���䣬������temp table ������in�Ӿ�

2)������ʹ�õı�����ǲ�����̫�������������Խ�࣬sqlserverҪ������ִ�мƻ���Խ�࣬����ʱ��Խ������
3������sqlserver����������ִ�мƻ������ٱ���
*/


/*
�ж�ִ�мƻ��Ƿ����
�����¼������棬�ж����ڵõ���ִ�мƻ��Ƿ�׼ȷ���Լ���û����ߵĿռ�
1,Ԥ��cost��׼ȷ��
sqlserver�ں�ѡ��ִ�мƻ��У���һ�����totalsubtreecost��͵ģ���totalsubtreecost��ͨ�������estimateio��
estimatecup�ٽ��м���ó��ģ����ǹ�ѡ���ִ�мƻ������⣬��������Ϊestimaterows������.
�и�ע��㣬��sqlserverԤ��ĳһ�������м�¼����ʱ�������ǰ�estimaterows��Ϊ0,������Ϊ1,���ʵ�ʵ�rows��Ϊ0
��estimaterowsΪ1����Ҫ�úü��sqlserver�������Ԥ�������Ƿ�׼ȷ���Ƿ��Ӱ �쵽ִ�мƻ���׼ȷ�ԡ�

�ڿ�ִ�мƻ��У����ʵ�ʷ��ؼ�¼���ܴ��õ�ȴ��nested loops,���ǲ�̫���ʵġ�
*/


/*
index seek ����Table Scan

���ĵڶ����ص㣬��Ҫ���sqlServer�ӱ����������ݵ�ʱ���Ƿ�ѡ���˺��ʵķ�����

seek ��scan��һ��seekҪ��scanҪ�죬��������ص��Ǳ���еĴ󲿷����ݣ���ô�������ϵ�seek�Ͳ�����ʲô����������ֱ����scan����
�������һЩ�����Թؼ�Ҫ��EstimateRows��Rows�Ĵ�С

*/

set statistics profile on

set statistics time on
select count(b.CarrierTrackingNumber) 
from SalesOrderDetail_test b
where b.SalesOrderDetailID>10000 and b.SalesOrderDetailID<=10100


select count(b.CarrierTrackingNumber) 
from SalesOrderDetail_test b
where convert(numeric(9,3),b.SalesOrderDetailID/100)=100

/*
��ΪSalesOrderDetailID�м������㣬�����ò���SalesOrderDetailID�����������ȥscan���������һ���ǳ��úƴ�Ĺ��̡�������
�����Լ���û����������������salesorderdetiaid����ֶΡ���Ϊ����ֻ�����˱���һС�����ֶΣ�ռ�õ�ҳ��������ȱ����ҪС��
�࣬ȥscan���������������Դ�󽵵�scan�����ġ�sqlserver���˱�ͨ����saleOrderID�Ǿۼ������Ͻ�����index sxan
,������Ǿۼ�����û�и���carriertrackingnumber�⸽���ֶΣ�����sqlser��Ҫ�����������ļ�¼��salesorderDetailIDֵ����salesorderDetailID
�ۼ�������ȥ��carriertrackingnumber,Ҳ����clustered index seek
*/
set statistics profile off

/*
��nested loops  ����hash(merge) join
*/

drop proc sniff
go

create proc sniff(@i int)
as
select * from SalesOrderHeader_test a
inner join SalesOrderDetail_test b on a.SalesOrderID = b.SalesOrderID
inner join production.Product p on b.productid = p.productid
where a.salesorderid = @i
go


dbcc freeproccache

exec sniff 50000
go

exec sniff 75124

/*
filter ����λ��
�����������һ������filter������,�����ϲ�

�ӵ�һ�俴������Ȼֻ��һ��where�Ӿ�p.productid between 758 and 800,������ִ�мƻ�����Կ���������filter������һ����saleorderdetial_test
�ϣ���һ����product�ϣ�������Ϊsqlserver���������ű�Ҫͨ��b.productid = p.productid�����ӣ�������product�ϵ�������ͬ�������
��saleorderdetail_test�ϣ�������sqlServer����salesorderdetail_test����һ��filter,�������С�ö࣬����join

���ڶ������ֻ����һ��filter,��Ϊ(p.productid/2) between 380 and 400���������û�취������SalesOrderDetail_test��.
*/

select count(b.ProductID) from SalesOrderHeader_test a
inner join SalesOrderDetail_test b on a.SalesOrderID = b.SalesOrderID
inner join production.Product p on b.productid = p.productid
where p.productid between 758 and 800
option(maxdop 1)
go

select count(b.ProductID) from SalesOrderHeader_test a
inner join SalesOrderDetail_test b on a.SalesOrderID = b.SalesOrderID
inner join production.Product p on b.productid = p.productid
where (p.productid/2) between 380 and 400
option(maxdop 1)
go

/*
�ܽ᣺
1��Ԥ�����ؽ���ݴ�СEstimateRows��׼ȷ������ִ�мƻ�ʵ��TotalSubTreeCost��Ԥ���ĸߺܶࡣ
ͳ����Ϣ�����ڣ�����û�м�ʱ���£��ǲ�������������Ҫԭ��

�Ӿ�̫�����ӣ�Ҳ����ʹsqlserver�²���һ��׼ȷ�ģ�ֻ�ò�һ��ƽ����������where�Ӿ�����ֶ������㣬���뺯������Ϊ�������ܻ�Ӱ
��sqlserverԤ����׼ȷ�ԣ�������������������Ҫ��취����䣬���͸��Ӷȣ����Ч�ʡ�

��������ı�����һ����������sqlserver�ڱ����ʱ�� ���ܲ�֪�����������ֵ��ֻ�ø���ĳЩ�����򣬲�һ��Ԥ��ֵ����Ҳ���ܻ�
Ӱ�쵽Ԥ����׼ȷ��.

2)���������һ�������ʵ�ִ�мƻ�
sqlserver��ִ�мƻ����û��ƣ���һ�α��������ã��������Ĳ������µ����ݷֲ������ȣ��ظ��ļ�¼�࣬�ͻ�����ȱ����ִ�мƻ�
�Ĳ����ʡ�

3��ɸѡ�Ӿ�д�Ĳ�̫���ʣ�����sqlserverѡȡ���ŵ�ִ�мƻ�

*/


/*
parameter sniffing

�������������֣�һ�����ڴ���������ڱ����ʱ��֪��ֵ����һ�����ڴ洢�����ж���ı�������Ҫ��ִ�к��֪������ִ�мƻ����û���
��һ�����󣬽�parameter sniffing 


*/

set statistics profile on


dbcc freeproccache

exec sniff 50000

exec sniff 75124

--2)
exec sniff 75124

exec sniff 50000


/*
��һ�����������⣬�����Ѿ��ų���ϵͳ��Դƿ��������������������i/o�������ر��룬parameter sniffing ��Щ�����Ժ�Ҫ�����ǵ�
�����ݿ���ƣ����������ܣ�Ҫ�������޸ĸľ䱾���Դﵽ���ߵ�Ч��

1)��������
��ȷ��EstimateSubtreeCost��һ����׼ȷ���Ժ�Ӧ���Ҷ�cost���������Ӿ䣬������õ���table scan,����index scan,��Ƚ�������
�������ͱ��ʵ�������������������ԶС��ʵ���������Ǿ�˵��sqlserverû�к��ʵ�������������seek,��ʱ�����������һ���ȽϺõ�
ѡ��

*/
set statistics profile on

select distinct ProductID,UnitPrice from SalesOrderDetail_test where ProductID=777

/*
sql trace�и������йص��¼�
performance-showplan xml statistics profile

�������йص���ͼ
sys.dm_db_missing_index_details

���ݿ������Ż�����

1��ÿ�η�����������Ҫ����
2)��ò�Ҫ���������ݿ���ֱ������DTA
3)DTA ���Ľ��飬Ҫ����ȷ���Ժ󣬲��������ݿ���ʵʩ��
*/


/*
�����������������
����������ķ������þ��˵�ʱ�򣬾�Ҫ������������Ƿ������

ɸѡ�����ͼ����ֶ�
���ʹ��sarg���������=,>,<,>=,<=,in,between,likeǰ׺
��sarg����� not ,<>,not exists,not in, not like,�ڲ�����,����convert upper��

*/

--һ�����������,���������30��Ա��
select datediff(yy,birthdate,getdate())>30 --�ò���
select birthdate<dateadd(yy,-30,getdate())

/*
��������ǰ�ı�ֵ�ı���
���ڴ洢���̴���ı�����sqlserver֪����ֵ��Ҳ���������ֵ���������Ż�������������ʹ����֮ǰ��������������޸Ĺ�����sqlserver
���ɵ�ִ�н����Ͳ�׼�ˣ������������ʱҲ�ᵼ����������

һ�ַ�������ʹ�ñ������������һ��option(recompile)��query hint,������sqlserver ���е���仰��ʱ�򣬻��ر�����ܳ���������

��һ�ַ����ǰѿ��ܳ�������������һ���Ӵ洢���̣���ԭ���Ĵ洢���̵����Ӵ洢���̣��������ﱾ�������ĺô��ǿ���ʡ������ر���
��ʱ�䡣
*/
