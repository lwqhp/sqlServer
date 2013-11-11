--���ṹ
/*
���ṹͨ�����������ڵ������ӹ�ϵ���������ڵ��ֶηֱ��ʾ��·�����ˣ���-�ң����������ṹ����ʾ��·��ϵ��������
����һ�ڵ㣬����������������ᵥ�����һ������

�ŵ㣺���������ݵĲ�ι�ϵ�ְ������ṹ��һ�����˽ṹ�������˲㼶��Զ�ĸ��ӹ�ϵ��

���ṹ��������Ʒ���

3.2����հ�������������˽ڵ������-�����ϵ,�Ǳհ����ļ���ƣ������ֳ���ι�ϵ��һ�����ȿ����ж�������
һ��������Է�����ͬ�����ȡ�

*/

SELECT * FROM dbo.TreePaths2

CREATE TABLE TreePaths2(companyID VARCHAR(20),leftNode VARCHAR(20),rightNode VARCHAR(20) )
go
INSERT INTO TreePaths2(leftNode,rightNode)
SELECT 'PT0001','PT0002' UNION ALL
SELECT 'PT0001','PT0003' UNION ALL
SELECT 'PT0002','PT0004' UNION ALL
SELECT 'PT0004','PT0005' UNION ALL
SELECT 'PT0003','PT0005' UNION ALL
SELECT 'PT0005','PT0006' UNION ALL
SELECT 'PT0005','PT0007' UNION ALL
SELECT 'PT0006','PT0008' 

UPDATE TreePaths2 SET companyID = 'PT'

/*
���ù�����򷨶Խڵ���б���
*/

--�ҳ��ڵ�PT0005�����к���ڵ�����Ƚڵ�
;WITH tmp AS(
	SELECT companyID,leftNode,rightNode,0 [level] FROM TreePaths2 WHERE leftNode ='PT0005'
	UNION ALL 
	SELECT a.companyID,a.leftNode,a.rightNode,b.[level]+1 [level] FROM TreePaths2 a
	INNER JOIN tmp b ON a.leftNode = b.rightNode
)
SELECT * FROM tmp


--ɾ��һ���ӽڵ�PT0005

--ɾ��������������PT0005����
DELETE  FROM TreePaths2 WHERE rightNode = 'PT0005'
--ɾ������PT0005�ڵ�ĺ���ڵ���
;WITH tmp AS(
	SELECT companyID,leftNode,rightNode,0 [level] FROM TreePaths2 WHERE leftNode ='PT0005'
	UNION ALL 
	SELECT a.companyID,a.leftNode,a.rightNode,b.[level]+1 [level] FROM TreePaths2 a
	INNER JOIN tmp b ON a.leftNode = b.rightNode
)
DELETE a FROM tmp a
INNER JOIN TreePaths2 b ON a.leftNode = b.leftNode AND a.rightNode = b.rightNode

/*
ɾ��һ������ϵ���Լ��ƶ��ڵ㣬��ֻ����½�����ɣ��ǳ����㡣
*/