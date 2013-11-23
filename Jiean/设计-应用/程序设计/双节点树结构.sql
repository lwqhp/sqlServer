

--树结构
/*
在业务逻辑关系中， 层级关系可谓无处不在，部门架构，公司目录，产品列表，论坛评论等，都存在上一级和下一级的关系。
在程序中，我们把这种具有层级关系的数据结构称为树，树结构中的每一个对象称为节点，最上层的节点称为根，没有子节点
的节点称为叶子，而中间的节点简单地称为非叶节点，节点间的关系是父-子节点，兄弟节点。


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

--添加一个节点
INSERT INTO Bas_InterCompany(CompanyID,vendcustID,ParentID)
SELECT 'PT','PT0007','PT0003'

--移动一个节点
UPDATE Bas_InterCompany SET parentID ='PT0001' WHERE vendCustID = 'PT0004'

--删除一个节点PT0003
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

/*
但是，当操作涉及节点的所有祖先节点或所有后代节点时，这种节点编码操作就显得非常困难和复杂。
比如需要展开当前节点的所有后代点，统计后代节点的数量，这往往需要做一次节点深度或广度遍历才能实现
*/

SET STATISTICS PROFILE ON

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
WHERE a.ParentID is null

--查找节点PT0008的所有祖先节点
;WITH tmp AS(
	SELECT CompanyID,vendCustID,ParentID,0 'level' FROM Bas_InterCompany WHERE vendcustID ='PT0008'
	UNION ALL
	SELECT a.CompanyID,a.vendCustID,a.ParentID,b.level+1 as 'level' FROM Bas_InterCompany a
	INNER JOIN tmp b ON a.companyID = b.companyID AND a.vendcustID = b.ParentID
)
SELECT * FROM tmp
go



--删除移动节点同样也需要借助深度遍历函数
delete a
FROM Bas_InterCompany a
CROSS APPLY dbo.fn_GetParentIDs(a.vendCustID) b
WHERE a.vendcustID='PT0001'

--复制一颗节点树
if exists(select 1 from sys.objects where name = 'fn_CopyNodes' and type ='TF') drop function  fn_CopyNodes
go
create function fn_CopyNodes(
	@id varchar(30),	--起始节点
	@pid varchar(30),	--要挂靠节点
	@newid int = null	--新编码的开始值,如果指定为 NULL,则为表中的最大编码 + 1
) returns @t table(oldID varchar(30),VendcustID int,ParentID int,[level] int)
as
begin 
	if @newid is null
		select @newid=max(replace(vendcustID,CompanyID,''))+1
		from Bas_InterCompany
		group by CompanyID
		
	declare @level INT
	DECLARE @maxnode INT 
	DECLARE @curnode INT
	set @level =0
	SET @curnode=0
	insert into @t
	select @id as OldID,@newid as VendcustID,replace(@pid,CompanyID,'') as ParentID,@level  from Bas_InterCompany where vendcustID=@id
	
	IF @@ROWCOUNT >0 SET @maxnode=@newid
	
	while @maxnode>@curnode
	begin 
		set @level= @level+1
		SET @curnode=@maxnode
		insert into @t
		select a.vendcustID,@curnode+row_number() over(order by a.vendCustID),
		b.VendcustID as ParentID,
		@level 
		from Bas_InterCompany a
		inner join @t b on a.ParentID = b.oldID
		where b.level=@level-1
		SET @maxnode = @curnode+@@rowcount
		
	end
	--失败,花了两小时在这钻牛角
	--;with tmp as(
	--	select companyID,@id as OldID,@newid as VendcustID,@pid as ParentID 
	--	from Bas_InterCompany 
	--	where vendcustID=@id
	--	union all
	--	select a.CompanyID,
	--	a.vendcustID as OldID, 
	--	b.VendcustID+@@ROWCOUNT+cast(row_number() over(order by a.vendcustID) as int)-1 VendcustID,
	--	----b.VendcustID+1+@@ROWCOUNT as VendcustID,
	--	cast(a.CompanyID+right(replicate('0',4)+cast(b.VendcustID as varchar),4) as varchar) as ParentID
	--	from Bas_InterCompany a
	--	inner join tmp b on a.CompanyID = b.CompanyID and a.ParentID =b.OldID
	--)
	--insert into @t
	--select OldID,VendcustID,ParentID from tmp
	return;
end

select  
b.oldID,
a.CompanyID+right(replicate('0',4)+cast(b.VendcustID as varchar),4)  as VendcustID,
a.CompanyID+right(replicate('0',4)+cast(b.ParentID as varchar),4)  as ParentID
from Bas_InterCompany a
cross apply fn_CopyNodes(a.vendcustID,'PT0006',null) b
where a.vendcustID='PT0003'


/*
可见，单纯的父子双节点树，在操作一个棵树的时候，是很复杂的，但如果只是获取一个给定节点的直接父子节点，删除插入
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

/*
增加了节点的节点路径后，祖先节点和后代节点的查找变得非常的方便。
*/

--查找一个节点的所有祖先节点
SELECT * FROM Bas_InterCompany WHERE 'PT0001.PT0003.PT0004' LIKE [path]+'%'

--查找一个节点的所有后代节点
SELECT * FROM Bas_InterCompany WHERE [path] LIKE 'PT0001.PT0003.PT0004%'
