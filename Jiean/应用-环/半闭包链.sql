--链结构
/*
链结构通常用来描述节点间的链接关系，用两个节点字段分别表示链路的两端（左-右），由于链结构仅表示链路关系，并不属
于任一节点，所以在设计上往往会单独设计一个链表。

优点：即包含数据的层次关系又摆脱树结构单一的拓扑结构，表现了层级多对多的复杂关系。

链结构有三种设计方案

3.2）半闭包链：链表包含了节点的祖先-后代关系,是闭包链的简化设计，能体现出层次关系，一个祖先可以有多个后代，
一个后代可以分属不同的祖先。

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
采用广度排序法对节点进行遍历
*/

--找出节点PT0005的所有后代节点或祖先节点
;WITH tmp AS(
	SELECT companyID,leftNode,rightNode,0 [level] FROM TreePaths2 WHERE leftNode ='PT0005'
	UNION ALL 
	SELECT a.companyID,a.leftNode,a.rightNode,b.[level]+1 [level] FROM TreePaths2 a
	INNER JOIN tmp b ON a.leftNode = b.rightNode
)
SELECT * FROM tmp


--删除一个子节点PT0005

--删除所有右链接是PT0005的链
DELETE  FROM TreePaths2 WHERE rightNode = 'PT0005'
--删除所有PT0005节点的后代节点链
;WITH tmp AS(
	SELECT companyID,leftNode,rightNode,0 [level] FROM TreePaths2 WHERE leftNode ='PT0005'
	UNION ALL 
	SELECT a.companyID,a.leftNode,a.rightNode,b.[level]+1 [level] FROM TreePaths2 a
	INNER JOIN tmp b ON a.leftNode = b.rightNode
)
DELETE a FROM tmp a
INNER JOIN TreePaths2 b ON a.leftNode = b.leftNode AND a.rightNode = b.rightNode

/*
删除一个链关系，以及移动节点，都只需更新交叉表即可，非常方便。
*/