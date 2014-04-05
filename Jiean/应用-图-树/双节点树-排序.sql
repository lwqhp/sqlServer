--����
;WITH tmp AS(
	SELECT CompanyID,vendCustID,ParentID,0 'level' 
	,CAST(1 AS VARBINARY(max)) AS sort_path --���ڵ��·����1(������)
	FROM Bas_InterCompany WHERE ParentID is null
	UNION ALL
	SELECT a.CompanyID,a.vendCustID,a.ParentID,b.level+1 as 'level' 
	,b.sort_path +CAST(ROW_NUMBER() OVER(PARTITION BY a.parentId ORDER BY a.vendcustID --������
	) AS BINARY(4))
	FROM Bas_InterCompany a
	INNER JOIN tmp b ON a.companyID = b.companyID AND a.parentId = b.vendCustID
)
SELECT *,ROW_NUMBER() OVER(ORDER BY sort_path) AS sortval 
FROM tmp
ORDER BY sortval
go