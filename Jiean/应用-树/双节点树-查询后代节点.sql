
--���ҽڵ�����к���ڵ�(��ȱ���)
;WITH tmp AS(
	SELECT CompanyID,vendCustID,ParentID,0 'level' FROM Bas_InterCompany WHERE ParentID is null
	UNION ALL
	SELECT a.CompanyID,a.vendCustID,a.ParentID,b.level+1 as 'level' FROM Bas_InterCompany a
	INNER JOIN tmp b ON a.companyID = b.companyID AND a.parentId = b.vendCustID
)
SELECT * FROM tmp
go

--������������ȱ���
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

--ɾ���ƶ��ڵ�ͬ��Ҳ��Ҫ������ȱ�������
delete a
FROM Bas_InterCompany a
CROSS APPLY dbo.fn_GetParentIDs(a.vendCustID) b
WHERE a.vendcustID='PT0001'

/*
�����˽ڵ�Ľڵ�·�������Ƚڵ�ͺ���ڵ�Ĳ��ұ�÷ǳ��ķ��㡣
*/

--����һ���ڵ�����к���ڵ�
SELECT * FROM Bas_InterCompany WHERE [path] LIKE 'PT0001.PT0003.PT0004%'