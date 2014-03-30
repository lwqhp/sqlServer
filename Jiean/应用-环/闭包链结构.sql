

--���ṹ
/*
���ṹͨ�����������ڵ������ӹ�ϵ���������ڵ��ֶηֱ��ʾ��·�����ˣ���-�ң����������ṹ����ʾ��·��ϵ��������
����һ�ڵ㣬����������������ᵥ�����һ������

�ŵ㣺���������ݵĲ�ι�ϵ�ְ������ṹ��һ�����˽ṹ�������˲㼶��Զ�ĸ��ӹ�ϵ��

���ṹ��������Ʒ���
2.1���հ�����������������нڵ������-�����ϵ���ڵ�����ָ���Լ�����    
*/

SELECT * FROM dbo.Bas_InterCompany

CREATE TABLE TreePaths(companyID VARCHAR(20),leftNode VARCHAR(20),rightNode VARCHAR(20) )
go
INSERT INTO TreePaths(leftNode,rightNode)
SELECT 'PT0001','PT0001' UNION ALL
SELECT 'PT0001','PT0003' UNION ALL
SELECT 'PT0001','PT0004' UNION ALL
SELECT 'PT0001','PT0007' UNION ALL
SELECT 'PT0001','PT0005' UNION ALL
SELECT 'PT0003','PT0004' UNION ALL
SELECT 'PT0003','PT0005' UNION ALL
SELECT 'PT0003','PT0007' UNION ALL
SELECT 'PT0003','PT0003' UNION ALL
SELECT 'PT0004','PT0004' UNION ALL
SELECT 'PT0004','PT0005' UNION ALL
SELECT 'PT0007','PT0007' 

--UPDATE treepaths SET companyID = 'PT'

/*
�հ����������������������-����ڵ�Ĺ�ϵ���Է����ճ��Ĳ����Ͳ�ѯ
*/

--���ҽڵ�PT0003�������ӽڵ�
SELECT a.companyId,a.vendCustID FROM dbo.Bas_InterCompany a
INNER JOIN treepaths b ON a.companyId = b.companyID AND a.vendcustID = b.rightNode
WHERE b.leftNode ='PT0003'

--���ҽڵ�PT0005���������Ƚڵ�
SELECT b.companyId,b.vendCustID FROM treepaths a
INNER JOIN Bas_InterCompany b ON a.leftNode = b.vendcustID
WHERE a.rightNode = 'PT0005'

--����һ���ڵ㵽PT0007
INSERT INTO TreePaths(companyID,leftNode,rightNode)
SELECT 'PT',a.leftNode,'PT0008' 
FROM treepaths a
WHERE a.rightNode = 'PT0007'
UNION ALL
SELECT 'PT','PT0008' ,'PT0008' 

--ɾ��һ���ڵ㼰�����ӽڵ�PT0003
SELECT * FROM treepaths a
WHERE a.rightNode IN(SELECT rightNode FROM treepaths WHERE leftNode ='PT0004')

--�ƶ�һ�ڵ㼰�����ӽڵ�PT0007->PT0004
SELECT * 
--DELETE 
FROM treepaths 
WHERE rightNode IN(SELECT rightNode FROM treepaths WHERE leftNode ='PT0007')
	AND leftNode IN(SELECT leftNode FROM treepaths WHERE rightNode ='PT0007' AND leftNode !=rightNode)
	
INSERT INTO treepaths
SELECT superNode.companyID,superNode.leftNode,subNode.rightNode FROM treepaths AS superNode
CROSS JOIN treepaths AS subNode
WHERE superNode.rightNode = 'PT0004' AND subNode.leftNode = 'PT0007'

/*
�հ�����ȱ�������Ӷ�������ӣ����ܷ�ӳ���ڵ��ݹ�ϵ�������Ӹ��ڵ����ѡ�
*/
-----------------


