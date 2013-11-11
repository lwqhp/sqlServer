

--���ṹ
/*
��ҵ���߼���ϵ�У� �㼶��ϵ��ν�޴����ڣ����żܹ�����˾Ŀ¼����Ʒ�б���̳���۵ȣ���������һ������һ���Ĺ�ϵ��
�ڳ����У����ǰ����־��в㼶��ϵ�����ݽṹ��Ϊ�������ṹ�е�ÿһ�������Ϊ�ڵ㣬���ϲ�Ľڵ��Ϊ����û���ӽڵ�
�Ľڵ��ΪҶ�ӣ����м�Ľڵ�򵥵س�Ϊ��Ҷ�ڵ㣬�ڵ��Ĺ�ϵ�Ǹ�-�ӽڵ㣬�ֵܽڵ㡣


*/

--�����ݿ�����У�ͨ�����������˼�������������Ľṹ��

/*
2.1)˫�ڵ����:һ���ֶα�ʾ��ǰ�ڵ�ID����һ���ֶα�ʾ�ڵ�ĸ�ID(ParentID),����һ����-���ڵ��ϵ��

������Ʒǳ���ʵ�ã�ÿһ���ڵ㶼����Զ����ģ��ڵ㲻��Ҫ�������������ṹ�е�λ�ã�����Ҫ֪�����ж��ٸ����Ƚڵ㣬
Ҳ����Ҫ֪���ж��ٸ�����ڵ㣬��ֻ�������ĸ��ڵ���˭��

�ɼ��������ֽڵ�Ƚ϶�����������ϵ���ٵĽṹ�У�����ڵ㣬ɾ���ڵ㣬�Լ��ƶ��ڵ㶼�Ƿǳ�����ġ�
*/

-- ������������һ����Ӧ�̷��࣬ϵͳ�в�ͬ�����������Ÿ��ԵĹ�Ӧ�̣���Щ��Ӧ��������һ����Ӧ�̵ļ����̻�����̡�
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

--���һ���ڵ�
INSERT INTO Bas_InterCompany(CompanyID,vendcustID,ParentID)
SELECT 'PT','PT0007','PT0003'

--�ƶ�һ���ڵ�
UPDATE Bas_InterCompany SET parentID ='PT0001' WHERE vendCustID = 'PT0004'

--ɾ��һ���ڵ�PT0003
--���½ڵ�������ӽڵ�ĸ��ڵ�Ϊ�ڵ�ĸ��ڵ㣨���Ǹ��ڵ�ĸ��ڵ㣩

SELECT * 
--UPDATE subNode SET subNode.parentID= superNode.parentID
FROM Bas_InterCompany subNode
INNER JOIN Bas_InterCompany superNode ON subNode.parentID = superNode.vendCustID
WHERE superNode.VendCustID ='PT0003'

--ɾ����ǰ�ڵ�
SELECT * 
--DELETE 
FROM Bas_InterCompany WHERE vendcustID ='PT0003'

/*
���ǣ��������漰�ڵ���������Ƚڵ�����к���ڵ�ʱ�����ֽڵ����������Ե÷ǳ����Ѻ͸��ӡ�
������Ҫչ����ǰ�ڵ�����к���㣬ͳ�ƺ���ڵ����������������Ҫ��һ�νڵ���Ȼ��ȱ�������ʵ��
*/

SET STATISTICS PROFILE ON

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
WHERE a.ParentID is null

--���ҽڵ�PT0008���������Ƚڵ�
;WITH tmp AS(
	SELECT CompanyID,vendCustID,ParentID,0 'level' FROM Bas_InterCompany WHERE vendcustID ='PT0008'
	UNION ALL
	SELECT a.CompanyID,a.vendCustID,a.ParentID,b.level+1 as 'level' FROM Bas_InterCompany a
	INNER JOIN tmp b ON a.companyID = b.companyID AND a.vendcustID = b.ParentID
)
SELECT * FROM tmp
go



--ɾ���ƶ��ڵ�ͬ��Ҳ��Ҫ������ȱ�������
delete a
FROM Bas_InterCompany a
CROSS APPLY dbo.fn_GetParentIDs(a.vendCustID) b
WHERE a.vendcustID='PT0001'

--����һ�Žڵ���
if exists(select 1 from sys.objects where name = 'fn_CopyNodes' and type ='TF') drop function  fn_CopyNodes
go
create function fn_CopyNodes(
	@id varchar(30),	--��ʼ�ڵ�
	@pid varchar(30),	--Ҫ�ҿ��ڵ�
	@newid int = null	--�±���Ŀ�ʼֵ,���ָ��Ϊ NULL,��Ϊ���е������� + 1
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
	--ʧ��,������Сʱ������ţ��
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
�ɼ��������ĸ���˫�ڵ������ڲ���һ��������ʱ���Ǻܸ��ӵģ������ֻ�ǻ�ȡһ�������ڵ��ֱ�Ӹ��ӽڵ㣬ɾ������
һ���½ڵ㣬���ֽṹ�Ǻܷ���ġ�

Ϊ����ҵ������������Ҫ��˫�ڵ���������չ���Լ򻯲���
*/

--A)��������ֶ�[level]
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

--B)����·���ֶ�
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
�����˽ڵ�Ľڵ�·�������Ƚڵ�ͺ���ڵ�Ĳ��ұ�÷ǳ��ķ��㡣
*/

--����һ���ڵ���������Ƚڵ�
SELECT * FROM Bas_InterCompany WHERE 'PT0001.PT0003.PT0004' LIKE [path]+'%'

--����һ���ڵ�����к���ڵ�
SELECT * FROM Bas_InterCompany WHERE [path] LIKE 'PT0001.PT0003.PT0004%'
