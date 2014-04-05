
--链结构
/*
链结构，又叫图，有点和边组成，分有向和无向链：
有向链是指一条边的两个顶点具有某种方向和顺序，比如BOM图
无向链则每条边只是简单连接两个顶点，没有特定顺序，比如道路系统。

跟据链的连接又分闭包链(连通)和半闭包链(无环)

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

--检测是否存在环 1->3->1
DECLARE @root AS INT = 1;

WITH Subs
AS
(
  SELECT empid, empname, 0 AS lvl,
    CAST('.' + CAST(empid AS VARCHAR(10)) + '.'
         AS VARCHAR(MAX)) AS path,
    -- 显然，根节点不存在环
    0 AS cycle
  FROM dbo.Employees
  WHERE empid = @root

  UNION ALL

  SELECT C.empid, C.empname, P.lvl + 1,
    CAST(P.path + CAST(C.empid AS VARCHAR(10)) + '.'
         AS VARCHAR(MAX)),
    -- 如果父节点路径中包含子节点id,则检测到环
    CASE WHEN P.path LIKE '%.' + CAST(C.empid AS VARCHAR(10)) + '.%'
      THEN 1 ELSE 0 END
  FROM Subs AS P
    JOIN dbo.Employees AS C
      ON C.mgrid = P.empid
      AND P.cycle = 0 -- 不继续遍历父节点包含环的分支
)
SELECT empid, empname, cycle, path
FROM Subs;

--找出包含环的分支
SELECT path FROM Subs WHERE cycle = 1;
GO
