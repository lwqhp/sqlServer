

--����UPDATE�����������
/*
����update��䣬���Լ����ΪSQLServer������ѯ������Ҫ�޸ĵļ�¼���ҵ���Ȼ���������¼�����޸ģ��Ҽ�¼�Ķ���
Ҫ�ӹ��������ҵ�Ҫ�޸ĵļ�¼����ȼӸ��������ٽ���������������������
*/

SET TRAN ISOLATION LEVEL REPEATABLE READ
GO

SET STATISTICS PROFILE ON 

BEGIN TRAN
UPDATE dbo.Employee_Demo_Heap SET title ='changedheap' WHERE EmployeeID IN(3,30,200)

/*
�ڷǾۼ�������������3������������RID��������3����������������Ϊ�������Ǿۼ������ҵ�����3����¼���Ǿۼ�����
����û���õ�title��һ�У��������Լ�����Ҫ���޸ģ���������rid�������޸ģ�����rid�ϼӵ���������������������û�м�����

�ܽ᣺���update�������ĸ���������������ļ�ֵ�Ͼͻ��и�������û���õ���������û�����������޸ķ����ĵط�������������
���ڲ�ѯ�漰��ҳ�棬sqlServer����������������޸ķ�����ҳ�棬����������������
*/

--�޸ĵ��б�һ������ʹ�õ���

CREATE NONCLUSTERED INDEX employee_Demo_BTree_Title ON employee_demo_btree(title)
DROP INDEX employee_Demo_BTree_Title ON employee_demo_btree

SET STATISTICS PROFILE ON

BEGIN TRAN 
UPDATE dbo.employee_demo_Btree SET Title='changeed' WHERE EmployeeID IN(3,30,200)

ROLLBACK TRAN 

/*
������þۼ������ҵ����޸ĵ�3����¼���������ǿ�����9��������������
��Ϊindex=1�Ͼۼ�������Ҳ�����ݴ�ŵĵط����ղ�����update���û�иĵ����������У���ֻ���title����е�ֵ�ĵ���
������index1�ϣ���ֻ������3����������

���Ǳ����title������һ���Ǿۼ����� index4,����title�ǵ�һ�У������޸ĺ�ԭ����������ֵ��Ҫ��ɾ�������Ҳ����µļ�ֵ��
������index4��Ҫ����6�����������ϵļ�ֵ3�����µļ�ֵ3����
*/

-------------
/*
�ܽ᣺
a,��ÿһ��ʹ�õ���������sqlServer�������ļ�ֵ��U��
b,sqlserverֻ��Ҫ���޸ĵļ�¼���ֵ��X��
c,ʹ�õ�Ҫ�޸ĵ��е�����Խ�࣬������ĿҲ��Խ��
d,ɨ�����ҳ��Խ�࣬������Ҳ��Խ�࣬��ɨ��Ĺ����У�������ɨ�赽�ļ�¼Ҳ���������������û���޸ġ�

���ԣ�����뽵��һ��update����������ס�ĸ��ʣ�����ע�����Ĳ�ѯ�������⣬���ݿ�����߻�Ҫ���������У�
1�������޸��ٵļ�¼�����޸ĵļ�¼Խ�࣬��Ҫ����Ҳ��Խ�ࡣ
2������������ν����������������ĿԽ�࣬��Ҫ����Ҳ����Խ�ࡣ
3������ҲҪ�ϸ�����ɨ��ķ��������ֻ���޸ı���¼��һС���֣�Ҫ����ʹ��index seek ������ȫ��ɨ����
��ִ�мƻ���
*/

--���������������볡��
IF object_id('t1') IS NOT NULL DROP TABLE t1

CREATE TABLE t1(c1 INT,c2 INT ,c3 DATETIME)
INSERT INTO t1(c1,c2,c3)VALUES(
	11,12,GETDATE()
),(21,22,GETDATE())

--select  * from t1

--����1
BEGIN TRAN 
UPDATE t1 SET c3=GETDATE() WHERE c1 = 11

ROLLBACK TRAN 

--����2
BEGIN TRAN 
SELECT c2 FROM t1 WHERE c1=21
COMMIT TRAN 

/*
���»���ҳ������IU�����ھ����ļ�¼�϶�������U�����ڸ�����������X���������ѯ�õ��Ǳ�ɨ�裬��ʹ������where
��������x���������S����ʹ�ñ�ɨ����X����������
*/