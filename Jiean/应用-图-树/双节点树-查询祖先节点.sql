
--���ҽڵ�PT0008���������Ƚڵ�
;WITH tmp AS(
	SELECT CompanyID,vendCustID,ParentID,0 'level' FROM Bas_InterCompany WHERE vendcustID ='PT0008'
	UNION ALL
	SELECT a.CompanyID,a.vendCustID,a.ParentID,b.level+1 as 'level' FROM Bas_InterCompany a
	INNER JOIN tmp b ON a.companyID = b.companyID AND a.vendcustID = b.ParentID
)
SELECT * FROM tmp
go

/*
�����˽ڵ�Ľڵ�·�������Ƚڵ�ͺ���ڵ�Ĳ��ұ�÷ǳ��ķ��㡣
*/

--����һ���ڵ���������Ƚڵ�
SELECT * FROM Bas_InterCompany WHERE 'PT0001.PT0003.PT0004' LIKE [path]+'%'