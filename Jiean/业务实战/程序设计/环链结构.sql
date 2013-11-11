
--链结构
/*
链结构通常用来描述节点间的链接关系，用两个节点字段分别表示链路的两端（左-右），由于链结构仅表示链路关系，并不属
于任一节点，所以在设计上往往会单独设计一个链表。

优点：即包含数据的层次关系又摆脱树结构单一的拓扑结构，表现了层级多对多的复杂关系。

链结构有三种设计方案

3.3）环链

主要反映两个节点间的父子关系，对比树结构，支持多对多节点拓扑。这种递增链用在工作流设计比较多,操作多在父子节点间进行。
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

--链结构特殊应用
/*
由于链上的两个节点在同一条记录上，把数列转成链后，可以在两个数列之间作运算
*/