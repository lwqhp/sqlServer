
--查找节点PT0008的所有祖先节点
;WITH tmp AS(
	SELECT CompanyID,vendCustID,ParentID,0 'level' FROM Bas_InterCompany WHERE vendcustID ='PT0008'
	UNION ALL
	SELECT a.CompanyID,a.vendCustID,a.ParentID,b.level+1 as 'level' FROM Bas_InterCompany a
	INNER JOIN tmp b ON a.companyID = b.companyID AND a.vendcustID = b.ParentID
)
SELECT * FROM tmp
go

/*
增加了节点的节点路径后，祖先节点和后代节点的查找变得非常的方便。
*/

--查找一个节点的所有祖先节点
SELECT * FROM Bas_InterCompany WHERE 'PT0001.PT0003.PT0004' LIKE [path]+'%'