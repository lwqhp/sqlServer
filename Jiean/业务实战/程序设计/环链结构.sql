
--���ṹ
/*
���ṹͨ�����������ڵ������ӹ�ϵ���������ڵ��ֶηֱ��ʾ��·�����ˣ���-�ң����������ṹ����ʾ��·��ϵ��������
����һ�ڵ㣬����������������ᵥ�����һ������

�ŵ㣺���������ݵĲ�ι�ϵ�ְ������ṹ��һ�����˽ṹ�������˲㼶��Զ�ĸ��ӹ�ϵ��

���ṹ��������Ʒ���

3.3������

��Ҫ��ӳ�����ڵ��ĸ��ӹ�ϵ���Ա����ṹ��֧�ֶ�Զ�ڵ����ˡ����ֵ��������ڹ�������ƱȽ϶�,�������ڸ��ӽڵ����С�
*/
DROP TABLE TreePaths
CREATE TABLE TreePaths(companyID VARCHAR(20),leftNode VARCHAR(20),rightNode VARCHAR(20) )
go
INSERT INTO TreePaths(leftNode,rightNode)
SELECT 'PT0001','PT0003' UNION ALL
SELECT 'PT0003','PT0004' UNION ALL
SELECT 'PT0003','PT0007' UNION ALL
SELECT 'PT0004','PT0005' UNION ALL
SELECT 'PT0004','PT0007' UNION ALL
SELECT 'PT0007','PT0004' UNION ALL
SELECT 'PT0005','PT0007' 

SELECT * FROM TreePaths
--UPDATE TreePaths SET companyID = 'PT'

--���ṹ����Ӧ��
/*
�������ϵ������ڵ���ͬһ����¼�ϣ�������ת�����󣬿�������������֮��������
*/