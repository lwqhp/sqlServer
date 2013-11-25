

----Parameter Sniffing 
/*
��ָ��Ϊ�����������ɵ�ִ�мƻ������µ��������⣬��Ҫ�����ڴ������Ĵ洢���̵���

�洢������ͨ�����룬����ִ�мƻ��ķ�ʽ��ִ�д洢���̵ġ�
���洢���̵�һ��ִ�е�ʱ�򣬻ᷢ�����롣
��������û��ִ�мƻ���ʱ�򣬵��ûᷢ�����롣
�����ǵ�һ��ִ�У���������ִ�мƻ���ʱ��������ִ�мƻ���

�洢���̵ı����Ǹ��ݲ����������ģ�������������涨�崫��ģ�sqlServer�ڶԹ���������ʱ����֪������ֵ�ģ�
���ɵ�ִ�мƻ��Ե�ǰ�����������������ŵġ�

�����������ڲ�����ģ���ôsqlServer�ڶԹ�������ʹ�øñ�����������ʱ���ǲ�֪���ñ���ֵ�ģ�Ҳ����˵���ɵ�
ִ�мƻ��ǱȽ���ӹ�ģ���������ֵ�ı仯��ϵ����

��ע�������
������Щ�����ڹ����в�ѯ�ó��ı����Լ�ʹ�øñ�������䣬�ɲ���ע��
��ע��Щʹ�ô���������Һܴ������ɲ�ѯ����ֲ���ƽ������䡣
��֧����������Ӱ��
*/
USE AdventureWorks
go

CREATE PROC sniff(@i INT )
AS
SELECT COUNT(b.salesorderid),SUM(p.weight)
FROM salesorderheader_test a
INNER JOIN salesorderdetail_test b on a.salesorderid = b.salesorderid
INNER JOIN production.product p ON b.productid = p.productid
WHERE a.salesorderid = @i
GO

--��������
/*
���洢���̵Ĳ������ڵ��õ�ʱ���룬��ô�洢�������ɵ�ִ�мƻ��ǵ�һ������ʱ�����ֵ���ɵġ�

Ǳ�����⣺���ܴ������ɵ�ִ�мƻ����ʺ������еı���ֵ����ᴥ��"parameter sniffing"����
*/

SET STATISTICS PROFILE ON
SET STATISTICS IO ON
SET STATISTICS TIME ON
SET STATISTICS PROFILE OFF 
SET STATISTICS IO OFF
SET STATISTICS TIME OFF

DBCC freeproccache
go

EXEC sniff 50000
go
/*
���ȣ�ִ�мƻ��ȸ����������ҹ���salesorderdetail_test��salesorderidֵ��Ȼ���product���й���
��Ϊsalesorderdetail_test��ļ�¼���࣬ʹ����nestedѭ����ÿһ������product���в��ң�ִֻ����һ�Ρ�

Ȼ����������salesorderheader_test����������ļ�¼����Ϊֻһ���ٵ�һ��������Ҳʹ����nested loop��������
>>��������Կ�����ִ�мƻ������Ǵ������ʼ����������ִ�У����᳢�Զ��ֹ�����ʽ����ѡ����õ�һ����Ϊ����ִ�мƻ�


*/
EXEC sniff 75124
go
/*
����ִ�мƻ����ã����������nested loops ��ִ�мƻ�

������ֵ�����˱仯��salesorderdetail_test �����˺ܶ�ļ�¼121317�������εĲ��ң��߼���242634�Σ�
��ԭ����ִ�мƻ���ʹ��nested loops ��product����ѭ��������Ҫִ��121317�Σ�ÿ�ΰ�һ����¼�ŵ�product�в��ҡ�
��salesorderdetail_test �ټ�һ���߼���121317��productһ���߼���121317��

����121317�ʼ�¼���ٴ�salesorderheader_test ��nested loops�͸ý����ѭ��,��salesorderheader_testֻ��һ����¼�����ﻹ�á�
��product�ټ�һ���߼���121317��

*/
--����2
DBCC freeproccache
go

EXEC sniff 75124
go
/*
����ID=75124���룬����һ��ʹ��Hash Match ���ӵ�ִ�мƻ�

����salesorderdetail_test�᷵����121317�ʼ�¼������ѡ�����Ƚ���salesorderheader_test��product��ѭ������Ϊ��¼��
�࣬����ʹ����nested loops,
Ȼ��ͨ�����򣬶�salesorderdetail_test���������ʹ��Hash Match����������������Worktable��
*/

EXEC sniff 50000
go
--����ִ�мƻ����ã����������Hash Match ��ִ�мƻ�

/*
�������ݷֲ����ܴ󣬲���50000��75124ֻ���Լ����ɵ�ִ�мƻ��кõ����ܣ����ʹ�öԷ����ɵ�ִ�мƻ������ܾͻ��½���
����50000���صĽ�����Ƚ�С���������ܲ��½�����̫���أ�����75124���صĽ��������������Ե������½��������ƻ��Ĳ��
�н�10����

*/

-----------------------------------------------------------------------------------------------
--���ر�����ִ�мƻ�
CREATE PROC sniff2(@i INT )
AS
DECLARE @j INT
SET @j = @i
SELECT COUNT(b.salesorderid),SUM(p.weight)
FROM salesorderheader_test a
INNER JOIN salesorderdetail_test b on a.salesorderid = b.salesorderid
INNER JOIN production.product p ON b.productid = p.productid
WHERE a.salesorderid = @j
GO

DBCC freeproccache

EXEC sniff2 50000
/*
ִ�мƻ���ԭ���Ĳ��nested loop
*/

EXEC sniff2 75124
/*
������nested loopִ�мƻ�
*/

DBCC freeproccache

EXEC  sniff2 75124
/*
���ڲ�֪��@j������ֵ������ʹ����nested loop��ִ�мƻ�

�ɼ������ر����������ʱ��֪��������ֵ�����ɵ�ִ�мƻ��ڴ�������������ʱ�����ܻ�Ƚϲ
���ǰѱ����ŵ������ﴫ�룬��ֻ�����ɵ�һ��ִ��ʱ�Ĵ�������ĸ�Ч�ƻ���
*/

--��֧��ѯ
CREATE PROC sniffIF(@i INT,@flag int  )
AS
IF @flag=0 
BEGIN 
SELECT COUNT(b.salesorderid),SUM(p.weight)
FROM salesorderheader_test a
INNER JOIN salesorderdetail_test b on a.salesorderid = b.salesorderid
INNER JOIN production.product p ON b.productid = p.productid
WHERE a.salesorderid = @i
END
ELSE IF @flag=1 
BEGIN 
	SELECT COUNT(b.salesorderid),SUM(p.weight)
	FROM salesorderheader_test a
	INNER JOIN salesorderdetail_test b on a.salesorderid = b.salesorderid
	INNER JOIN production.product p ON b.productid = p.productid
	WHERE a.salesorderid = @i+1
END 

DBCC freeproccache

EXEC sniffIF 50000,1


alter PROC sniffIF2(@i INT,@flag int  )
AS
SELECT COUNT(b.salesorderid),SUM(p.weight)
	FROM salesorderheader_test a
	INNER JOIN salesorderdetail_test b on a.salesorderid = b.salesorderid
	INNER JOIN production.product p ON b.productid = p.productid
	WHERE a.salesorderid = @i
IF @flag=0 
BEGIN 
DECLARE @j INT
SET @j=@i
SELECT COUNT(b.salesorderid),SUM(p.weight)
FROM salesorderheader_test a
INNER JOIN salesorderdetail_test b on a.salesorderid = b.salesorderid
INNER JOIN production.product p ON b.productid = p.productid
WHERE a.salesorderid = @j
END
ELSE IF @flag=1 
BEGIN 
	SELECT COUNT(b.salesorderid),SUM(p.weight)
	FROM salesorderheader_test a
	INNER JOIN salesorderdetail_test b on a.salesorderid = b.salesorderid
	INNER JOIN production.product p ON b.productid = p.productid
	WHERE a.salesorderid = @i
END 

DBCC freeproccache

EXEC sniffIF2 50000,0
EXEC sniffIF2 75124,0



/*------------------------------------------------------------------------------
��Parameter Sniffing �Ľ������
��
1����exec()�ķ�ʽ֧�ж�̬sql��䣺 exec() ����ÿ��ִ��ǰ�Ƚ����ر���
�ŵ㣺���ױ�����Parameter Sniffing�����⡣
ȱ�㣺�����˴洢����һ�α��룬������е��ŵ㣬�ڱ���������������ʧ��

2)ʹ�ñ��ر���
�ѱ��Ǹ�ֵ��һ�����ر���,sqlServer�ڱ����ʱ����û�취֪��������ر�����ֵ�ģ�����������ݱ�������ݵ�һ��ֲ������
���²⡱һ������ֵ�������û��ڵ��ô洢���̵�ʱ�����ı���ֵ�Ƕ��٣���������ִ�мƻ�����һ���ģ���������ִ�мƻ�һ��
�Ƚ���ӹ�����������ŵ�ִ�мƻ������ǶԴ��������ֵ������Ҳ������һ���ܲ��ִ�мƻ���
ȱ�㣺�������ŵġ�

3���������ʹ��Query Hint ,ָ��ִ�мƻ�
��DML����������option(<query_hint>)�Ӿ䣬ָ��sqlServer��β���ִ�мƻ���
��� Parameter Sniffing���õ��У�
a,Recompile :�ر��� �������β��option(recompile) �ڴ洢���̶��崦��with recompile
b,ָ��join ����
c��optimize for() option(optimize fro(@i>1000))
d,Plan Guide


���⣺��������ǰ�ı�ֵ�ı���
�����
A��������β������ option(recompile)
B,�Ѹı��������䵥������һ���Ӵ洢���̣���ԭ���Ĵ洢���̵����Ӵ洢���̣���������䱾��
*/


