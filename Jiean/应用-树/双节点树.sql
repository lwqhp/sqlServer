

--树结构
/*
在业务逻辑关系中， 层级关系可谓无处不在，部门架构，公司目录，产品列表，论坛评论等，都存在上一级和下一级的关系。
在程序中，我们把这种具有层级关系的数据结构称为树，树结构中的每一个对象称为节点，最上层的节点称为根，没有子节点
的节点称为叶子，而中间的节点简单地称为非叶节点，节点间的关系是父-子节点，兄弟节点。

排序
如果想遍历的节点可以子-父节点的层次排序，则需要做些特珠处理
1）构造的路径使用表示节点位置的值（行号），这些值基于请求的顺序
2）改用固定长度的二进制字符串。
3）构造出二进制路径之后，再计算表示路径顺序的整数值（行号），最终用这些值对层次结构进行排序。

*/

--在数据库设计中，通常有两种设计思想体现这种树的结构。

/*
2.1)双节点设计:一个字段表示当前节点ID，另一个字段表示节点的父ID(ParentID),构成一个子-父节点关系。

这种设计非常简单实用，每一个节点都是相对独立的，节点不需要考虑自身在树结构中的位置，不需要知道其有多少个祖先节点，
也不需要知道有多少个后代节点，它只关心他的父节点是谁。

可见，在这种节点比较独立，关联关系很少的结构中，插入节点，删除节点，以及移动节点都是非常方便的。
*/

-- 假设我们这样一个供应商分类，系统中不同的帐套下有着各自的供应商，有些供应商又是上一级供应商的加盟商或代理商。
--DROP TABLE Bas_InterCompany
CREATE TABLE Bas_InterCompany(
	CompanyID VARCHAR(20),
	vendcustID VARCHAR(30),
	ParentID VARCHAR(30)
)
go
INSERT INTO Bas_InterCompany(CompanyID,vendcustID,ParentID)
VALUES('PT','PT0001',NULL),('PT','PT0002',NULL),('PT','PT0003','PT0001'),('PT','PT0004','PT0003')

--SELECT * FROM Bas_InterCompany



/*
单纯的父子双节点树，在操作一个棵树的时候，是很复杂的，但如果只是获取一个给定节点的直接父子节点，删除插入
一个新节点，这种结构是很方便的。

为满足业务需求，往往需要给双节点树进行扩展，以简化操作
*/

--A)增加深度字段[level]
ALTER TABLE dbo.Bas_InterCompany ADD [level] INT 

--SELECT * FROM Bas_InterCompany

;WITH tmp AS(
	SELECT CompanyID,vendcustID,0 [level] FROM Bas_InterCompany WHERE ParentID IS NULL
	UNION ALL 
	SELECT a.CompanyID,a.vendcustID,b.level+1 [level] FROM Bas_InterCompany a
	INNER JOIN tmp b ON a.ParentID = b.vendcustID
)
--SELECT * 
UPDATE a SET a.LEVEL = b.level
FROM Bas_InterCompany a
INNER JOIN  tmp b ON a.CompanyID = b.CompanyID AND a.vendcustID = b.vendcustID

/**/

--B)增加路径字段
ALTER TABLE Bas_InterCompany ADD [path] VARCHAR(1000)

;WITH tmp AS(
	SELECT CompanyID,vendcustID,CAST(vendcustID AS  varchar) [path] FROM Bas_InterCompany WHERE ParentID IS NULL
	UNION ALL 
	SELECT a.CompanyID,a.vendcustID,CAST(b.[path]+'.'+a.vendcustID AS  varchar) FROM Bas_InterCompany a
	INNER JOIN tmp b ON a.ParentID = b.vendcustID
)
--SELECT * FROM tmp
UPDATE a SET a.[path] = b.[path]
FROM Bas_InterCompany a
INNER JOIN  tmp b ON a.CompanyID = b.CompanyID AND a.vendcustID = b.vendcustID





