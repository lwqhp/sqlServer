

--����������ִ�мƻ���Ӱ��
/*
����������Դ�����֣�
һ���Ǵ������̴�������������ô洢���̵�ʱ�򣬱���Ҫ��������ֵ�����ֱ�����slserver�ڱ����ʱ��֪������ֵ�Ƕ��١�
��һ�����ڴ洢�����ж���ı���������ֵ���ڴ洢���̵����ִ�еĹ����еõ��ġ����Զ����ֱ��ر���sqlServer�ڱ����ʱ��֪������ֵ�Ƕ���.

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

DBCC freeproccache
go

EXEC sniff 50000
go
--�������룬����һ��ʹ��nested loops ���ӵ�ִ�мƻ�

EXEC sniff 75124
go
--����ִ�мƻ����ã����������nested loops ��ִ�мƻ�

--����2
DBCC freeproccache
go

EXEC sniff 75124
go
--�������룬����һ��ʹ��Hash Match ���ӵ�ִ�мƻ�

EXEC sniff 50000
go
--����ִ�мƻ����ã����������Hash Match ��ִ�мƻ�

/*
�������ݷֲ����ܴ󣬲���50000��75124ֻ���Լ����ɵ�ִ�мƻ��кõ����ܣ����ʹ�öԷ����ɵ�ִ�мƻ������ܾͻ��½���
����50000���صĽ�����Ƚ�С���������ܲ��½�����̫���أ�����75124���صĽ��������������Ե������½��������ƻ��Ĳ��
�н�10����

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
c��optimize for()
d,Plan Guide


���⣺��������ǰ�ı�ֵ�ı���
�����
A��������β������ option(recompile)
B,�Ѹı��������䵥������һ���Ӵ洢���̣���ԭ���Ĵ洢���̵����Ӵ洢���̣���������䱾��
*/