

--�������
SET STATISTICS TIME ON 
/*
���ͣ�
	CPUʱ��(cpu Time) :ָ��������һ����sqlServer�����Ĵ�cpuʱ���Ƕ��٣�Ҳ����˵����仨�˶���cpu��Դ��
	ռ��ʱ��(elapsed time) : һ��һ�����˶���ʱ�䣬��Ҳ��������е�ʱ�䳤�̡�
	
	
*/
--�ڶ��������¹۲쵥�����ı���ԭʼ���---------------------------------------

USE AdventureWorks
go
DBCC DROPCLEANBUFFERS --���buffer pool������л��������
DBCC freeproccache --���buffer pool������л����ִ�мƻ�
go

SET STATISTICS TIME ON 
SET NOCOUNT ON 
DROP PROC longcompile
GO
ALTER PROC longcompile (@i INT ) 
AS
--PRINT 1
--PRINT 14
DECLARE @cmd VARCHAR(max)
--PRINT 2
DECLARE @j INT
--PRINT 3
SET @J =0
--PRINT 4
SET @cmd  ='
	select * from dbo.SalesOrderHeader_test a
	INNER JOIN dbo.SalesOrderDetail_test b ON a.SalesOrderID = b.SalesOrderID
	INNER JOIN Production.Product p ON b.ProductID = p.ProductID
	WHERE a.SalesOrderID IN(43659'
	PRINT 5
	
WHILE @j<@i
BEGIN
PRINT 33
SET @cmd = @cmd +','+STR(@j+43659)
SET @j=@j+1
END
PRINT 9
SET @cmd=@cmd + ')'
PRINT @cmd
EXEC(@cmd)
PRINT 11
go
--PRINT 12
longcompile 1
--PRINT 13
SET STATISTICS TIME OFF 

/*
������

sql server�����ͱ���ʱ�䣺�������ı���ʱ�䣬���ڱ�����Ҫ��CPU�����㣬����һ��cpu time ��Elapsed Time �ǲ��ģ����
���Ƚϴ󣬾��б�Ҫ����sql server ��ϵͳ��Դ����û��ƿ����
ע����һ������ʱ����sqlBatch�ı���ʱ�䣬�ڶ�������ʱ���Ǵ洢���̵ı���ʱ�䡣

sql serverִ��ʱ�䣺������������ִ��ʱ�䣬ռ��ʱ�������cpuʱ�������i/o������i/o�ȴ��������������ȴ�ʱ�䡣
DECLARE ���û��ִ��ʱ��
EXEC(@cmd) �������������ʱ�������ִ��ʱ�䣬һ������������ִ��ʱ�䣬һ��������exce ��ִ��ʱ�䣬����֮���������
	ռ��ʱ���io�ȴ��ϡ�
*/

--��Ӧ�û����¹۲����ķ����������---------------------------------------

/*
��Ӧ�û����¹۲���Ҫ�õ�SQL Trace����Ҫͨ���Ƚ�ĳЩ�¼���ʼʱ���֮��ļ���������ʱ�ı���ʱ�䡣

һ��SQL������(Batch)��ı���ʱ�䣬������SQL:BatchStarting �¼��Ŀ�ʼʱ�䣬��ȥ���һ������SQL:StmtStarting�¼���ʼʱ�䣨��ΪsqlServer
���ȱ�������Batch,Ȼ���ٿ�ʼ���е�һ�䡣���������ʱ����ȣ�˵����ִ�мƻ����ã����߱���ʱ����Ժ��Բ��ơ�

һ��stored procedure �ı���ʱ�䣬���ڵ�������statement��SQL:StmtStarting �¼���ʼʱ�䣨������RPC:startingʱ�䣩��ȥ���һ��
���SP��StmtStarting �Ŀ�ʼʱ��(��ΪSqlserver���ȱ��������SP��Ȼ�������е�һ��)���������ʱ����ȣ�˵����ִ�мƻ����ã����߱���ʱ����Ժ��Բ��ơ�
����SP:CacheInsert�¼������Կ����洢�����Ƿ����˱��롣

����Ƕ�̬��䣬��Batch��SP�����ʱ�� �ٲ���������ı���ʱ�䣬���ı���ʱ�䷢��������������֮ǰ��
Ҳ����exec ָ������������������sp:stmtstarting�¼�֮��

exec(@cmd)��Durationʱ���ȥ@cmd��Durationʱ��(���ʱ�䲻��������ʱ��)=exec(@cmd)�Ķ�̬����ʱ��
exec(@cmd)�Ŀ�ʼʱ���ȥ@cmd�Ŀ�ʼʱ��=exec(@cmd)�Ķ�̬����ʱ��


*/

/*
--?�Ż�����ʱ����������
��
����㷢�������������ͱ����йأ��迼�ǵķ����У�
1�������䱾���Ƿ���ڸ��ӣ�����̫�������԰�һ�仰�۳ɼ�����򵥵���䣬������temp table ������in�Ӿ�

2)������ʹ�õı�����ǲ�����̫�������������Խ�࣬sqlserverҪ������ִ�мƻ���Խ�࣬����ʱ��Խ������
3������sqlserver����������ִ�мƻ������ٱ���
*/