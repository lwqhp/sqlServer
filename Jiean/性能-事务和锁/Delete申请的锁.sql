

--Delete����Ҫ�������

use AdventureWorks2012
go

SET TRAN ISOLATION LEVEL READ COMMITTED --���ύ��
GO

BEGIN TRAN 
DELETE  sales.SalesOrderDetail WHERE SalesOrderDetailID=101180

ROLLBACK TRAN 



/*
delete ��������ڵ������ϼ��������������������ڵ�ҳ����������������������
*/

SET TRAN ISOLATION LEVEL REPEATABLE READ --���ظ���
GO

BEGIN TRAN
DELETE  sales.SalesOrderDetail WHERE SalesOrderDetailID=101180

ROLLBACK TRAN 



/*
��REPEATABLE READ���뼶����
���е�������������һ��X�������������ڵ�ҳ����������һ��IX�������޸ķ�����heapҳ���ϣ�������һ��IX������Ӧ
��RID��(���������ݼ�¼)������һ��X��������ɨ�����ҳ��������IU����

�ܽ᣺
a,delete�Ĺ��������ҵ����������ļ�¼��Ȼ����ɾ����������������һ��select ,Ȼ����delete�����ԣ�����к��ʵ�
��������һ����������ͻ�Ƚ��١�

b,delete�����������б���ɾ������Ҫɾ��������ص�������������һ�ű���������ĿԽ�࣬������Ŀ�ͻ�Խ�࣬Ҳ��Խ����������

���ԣ�Ϊ�˷�ֹ������ �Ǽ����ܾ��Եز���������Ҳ����������ؽ��ܶ�����������Ҫ���Բ�������������������û��ʹ�õ�
������������ȥ���ȽϺá�
*/