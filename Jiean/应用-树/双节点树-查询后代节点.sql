
--查找节点的所有后代节点(广度遍历)
;WITH tmp AS(
	SELECT CompanyID,vendCustID,ParentID,0 'level' FROM Bas_InterCompany WHERE ParentID is null
	UNION ALL
	SELECT a.CompanyID,a.vendCustID,a.ParentID,b.level+1 as 'level' FROM Bas_InterCompany a
	INNER JOIN tmp b ON a.companyID = b.companyID AND a.parentId = b.vendCustID
)
SELECT * FROM tmp
go

--借助函数的深度遍历
IF EXISTS(SELECT 1 FROM sys.objects WHERE object_id = object_id('fn_GetParentIDs') AND type ='TF') DROP FUNCTION  fn_GetParentIDs
go
CREATE FUNCTION fn_GetParentIDs(
	@id varchar(20)
)RETURNS @rev TABLE(vendCustID varchar(20),ParentID varchar(20),LEVEL INT )
AS 
begin 
	DECLARE @LEVEL int 
	SET @LEVEL=1
	INSERT INTO @rev
	SELECT vendCustID,ParentID,@LEVEL FROM Bas_InterCompany WHERE vendCustID = @id
	WHILE @@ROWCOUNT>0
	BEGIN 
		SET @LEVEL +=1
		INSERT INTO @rev
		SELECT a.vendCustID,a.ParentID,@LEVEL FROM Bas_InterCompany a
		INNER JOIN @rev b ON a.parentID = b.vendCustID
		WHERE b.LEVEL=@LEVEL-1
	end
	
	RETURN;
END

SELECT a.companyID,a.vendcustID,b.parentID,b.level 
FROM Bas_InterCompany a
CROSS APPLY dbo.fn_GetParentIDs(a.vendCustID) b
WHERE a.ParentID is NULL

--删除移动节点同样也需要借助深度遍历函数
delete a
FROM Bas_InterCompany a
CROSS APPLY dbo.fn_GetParentIDs(a.vendCustID) b
WHERE a.vendcustID='PT0001'

/*
增加了节点的节点路径后，祖先节点和后代节点的查找变得非常的方便。
*/

--查找一个节点的所有后代节点
SELECT * FROM Bas_InterCompany WHERE [path] LIKE 'PT0001.PT0003.PT0004%'