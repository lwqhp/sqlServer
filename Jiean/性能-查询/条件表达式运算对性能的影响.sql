

--�������ʽ��������ܵ�Ӱ��
/*
filter ����λ��
�����ļ����������ɨ,ͬʱ����һЩwhere�Ӿ�filter��һЩ��¼����ô����filter����¼���������Ӻ��أ������������ӣ�
��filter�أ�һ����������filter��һЩ��¼��ʹ�������ӵļ�¼��Сһ�㣬���󽵵����ӵ����ġ�


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
GO

/*
�ӵ�һ�俴������Ȼֻ��һ��where�Ӿ�p.productid between 758 and 800,������ִ�мƻ�����Կ���������filter������һ����saleorderdetial_test
�ϣ���һ����product�ϣ�������Ϊsqlserver���������ű�Ҫͨ��b.productid = p.productid�����ӣ�������product�ϵ�������ͬ�������
��saleorderdetail_test�ϣ�������sqlServer����salesorderdetail_test����һ��filter,�������С�ö࣬����join

���ڶ������ֻ����һ��filter,��Ϊ(p.productid/2) between 380 and 400���������û�취������SalesOrderDetail_test��.ʹ��filter����
ֻ������product�ϣ�û�з�����salesorderdetail_test�ϣ�����salesorderheader_test��saleorderdetail_test�����ӵ�ʱ�򣬽����Ҫ��һЩ��

*/