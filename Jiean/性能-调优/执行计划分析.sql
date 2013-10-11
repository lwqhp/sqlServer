
--ִ�мƻ�����
SET STATISTICS PROFILE ON 

/*
���ͣ�
Rows��ִ�мƻ�ÿһ�����ص�ʵ��������
Executes :ִ�мƻ�ÿһ���������˶��ٴΡ�
StmtText : ִ�мƻ��ľ������ݡ�ִ�мƻ���һ��������ʽ��ʾ��ÿһ�У��������е�һ���������н�������أ�Ҳ�������Լ���Cost.
EstimateRows :  sqlServer���ݱ���ϵ�ͳ����Ϣ��Ԥ����ÿһ���ķ���������
EstimateIO: sqlServer����EstimateRows��ͳ����Ϣ���¼���ֶγ��ȣ�Ԥ����ÿһ���������IO Cost.
EstimateCPU: sqlServer����EstimateRows��ͳ����Ϣ���¼���ֶγ���,�Լ�Ҫ��������ĸ��Ӷȣ�Ԥ����ÿһ���������CPU Cost.
TotalSubtreeCost : SQLServers����EstimateIO��EstimateIOͨ��ĳ�ּ��㹫ʽ���������ÿһ��ִ�мƻ�����cost
Wamings : SQLServer ������ÿһ��ʱ�����ľ��档
Parallel : ִ�мƻ�����һ���ǲ���ʹ���˲��е�ִ�мƻ���
*/
USE AdventureWorks
go

SET STATISTICS PROFILE ON 

SELECT COUNT(b.SalesOrderID)
FROM dbo.SalesOrderHeader_test a 
INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b .SalesOrderID
WHERE a.SalesOrderID>43659 AND a.SalesOrderID<53660

SET STATISTICS PROFILE OFF 

/*
?����۲�ִ�мƻ�
��
1�����ȼ��ִ�мƻ��Ĺ����Ƿ�׼ȷ�ԣ��Ա�rows ��EstimateRows��������
��sqlserverԤ��ĳһ�������м�¼����ʱ�������ǰ�estimaterows��Ϊ0,������Ϊ1,���ʵ�ʵ�rows��Ϊ0
��estimaterowsΪ1����Ҫ�úü��sqlserver�������Ԥ�������Ƿ�׼ȷ���Ƿ��Ӱ �쵽ִ�мƻ���׼ȷ�ԡ�

��ʱ��Ȼ���ߵ��������Ƚϴ󣬵��ɱ�cost�ܵͣ�û�����������㣬Ҳ�ǿ��Խ��ܵġ�

2�����ʵ�ʷ��ؼ�¼���ܴ��ٿ���һ���Ƿ���ѭ�����㣬�õ���nested loops,���ǲ�̫���ʵġ�

3����ϸһ���鿴���ҷ�ʽ��index seek ����table Scan ��
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

set statistics profile off
/*
��ΪSalesOrderDetailID�м������㣬�����ò���SalesOrderDetailID�����������ȥscan���������һ���ǳ��úƴ�Ĺ��̡�������
�����Լ���û����������������salesorderdetiaid����ֶΡ���Ϊ����ֻ�����˱���һС�����ֶΣ�ռ�õ�ҳ��������ȱ����ҪС��
�࣬ȥscan���������������Դ�󽵵�scan�����ġ�sqlserver���˱�ͨ����saleOrderID�Ǿۼ������Ͻ�����index sxan
,������Ǿۼ�����û�и���carriertrackingnumber�⸽���ֶΣ�����sqlser��Ҫ�����������ļ�¼��salesorderDetailIDֵ����salesorderDetailID
�ۼ�������ȥ��carriertrackingnumber,Ҳ����clustered index seek
*/

/*
?��θ���ִ�мƻ�����
��
1��Ԥ�����ؽ���ݴ�СEstimateRows��׼ȷ������ִ�мƻ�ʵ��TotalSubTreeCost��Ԥ���ĸߺܶࡣ
ͳ����Ϣ�����ڣ�����û�м�ʱ���£��ǲ�������������Ҫԭ��Ӧ�Եķ������ǿ������ݿ��ϵ�Auto Create Statistics�� Auto Update Statistics
������������ܱ�֤Statistics �ľ�ȷ�Կ��Զ���һ�����񣬶��ڸ���ͳ����Ϣ��

�Ӿ�̫�����ӣ�Ҳ����ʹsqlserver�²���һ��׼ȷ�ģ�ֻ�ò�һ��ƽ����������where�Ӿ�����ֶ������㣬���뺯������Ϊ�������ܻ�Ӱ
��sqlserverԤ����׼ȷ�ԣ�������������������Ҫ��취����䣬���͸��Ӷȣ����Ч�ʡ�

��������ı�����һ����������sqlserver�ڱ����ʱ�� ���ܲ�֪�����������ֵ��ֻ�ø���ĳЩ�����򣬲�һ��Ԥ��ֵ����Ҳ���ܻ�
Ӱ�쵽Ԥ����׼ȷ��.

2)���������һ�������ʵ�ִ�мƻ�
sqlserver��ִ�мƻ����û��ƣ���һ�α��������ã��������Ĳ������µ����ݷֲ������ȣ��ظ��ļ�¼�࣬�ͻ�����ȱ����ִ�мƻ�
�Ĳ����ʡ�

3��ɸѡ�Ӿ�д�Ĳ�̫���ʣ�����sqlserverѡȡ���ŵ�ִ�мƻ�
Sqlserver��ɸѡ����(Search Argument/SARG)��д����һЩ���飺
SARG�����������= ��>,<,>=,<=,in,between, like(��ǰ׺ƥ��)��AND
���ڲ�ʹ��SARG������ı��ʽ��������û���õģ�������NOT ,<>,not exists,not in,not like ���ڲ�����

*/
