

--Delete����Ҫ�������

SET TRAN ISOLATION LEVEL READ COMMITTED
GO
SET STATISTICS PROFILE ON

BEGIN TRAN 
DELETE  dbo.employee_demo_Btree WHERE LoginID ='adventure-works\kim1'

ROLLBACK TRAN 

/*
delete ��������ڵ������ϼ��������������������ڵ�ҳ����������������������
*/

SET TRAN ISOLATION LEVEL REPEATABLE READ
GO

BEGIN TRAN
DELETE  dbo.employee_demo_heap WHERE LoginID ='adventure-works\tete0'

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