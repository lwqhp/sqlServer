

--链结构
/*
链结构通常用来描述节点间的链接关系，用两个节点字段分别表示链路的两端（左-右），由于链结构仅表示链路关系，并不属
于任一节点，所以在设计上往往会单独设计一个链表。

优点：即包含数据的层次关系又摆脱树结构单一的拓扑结构，表现了层级多对多的复杂关系。

链结构有三种设计方案
2.1）闭包链：链表包含了所有节点的祖先-后代关系（节点自身指向自己）。    
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
闭包链额外的增加了所有祖先-后代节点的关系，以方便日常的操作和查询
*/

--查找节点PT0003的所有子节点
SELECT a.companyId,a.vendCustID FROM dbo.Bas_InterCompany a
INNER JOIN treepaths b ON a.companyId = b.companyID AND a.vendcustID = b.rightNode
WHERE b.leftNode ='PT0003'

--查找节点PT0005的所有祖先节点
SELECT b.companyId,b.vendCustID FROM treepaths a
INNER JOIN Bas_InterCompany b ON a.leftNode = b.vendcustID
WHERE a.rightNode = 'PT0005'

--插入一个节点到PT0007
INSERT INTO TreePaths(companyID,leftNode,rightNode)
SELECT 'PT',a.leftNode,'PT0008' 
FROM treepaths a
WHERE a.rightNode = 'PT0007'
UNION ALL
SELECT 'PT','PT0008' ,'PT0008' 

--删除一个节点及所有子节点PT0003
SELECT * FROM treepaths a
WHERE a.rightNode IN(SELECT rightNode FROM treepaths WHERE leftNode ='PT0004')

--移动一节点及所有子节点PT0007->PT0004
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
闭包链的缺点是增加多余的链接，不能反映出节点层递关系，查找子父节点困难。
*/
-----------------


