--删除节点PT0003
--更新节点的所有子节点的父节点为节点的父节点（就是父节点的父节点）

SELECT * 
--UPDATE subNode SET subNode.parentID= superNode.parentID
FROM Bas_InterCompany subNode
INNER JOIN Bas_InterCompany superNode ON subNode.parentID = superNode.vendCustID
WHERE superNode.VendCustID ='PT0003'

--删除当前节点
SELECT * 
--DELETE 
FROM Bas_InterCompany WHERE vendcustID ='PT0003'


--删除子树
DELETE FROM dbo.Employees
  WHERE path LIKE 
    (SELECT M.path + '%'
     FROM dbo.Employees as M
     WHERE M.empid = 7);

/*
但是，当操作涉及节点的所有祖先节点或所有后代节点时，这种节点编码操作就显得非常困难和复杂。
比如需要展开当前节点的所有后代点，统计后代节点的数量，这往往需要做一次节点深度或广度遍历才能实现
*/


