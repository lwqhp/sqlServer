--移动一个节点
UPDATE Bas_InterCompany SET parentID ='PT0001' WHERE vendCustID = 'PT0004'

--移动一个节点含深度和路径
/*
隔离爱影响的子树，可以联接根节点所在的行R 和E,联接表达式为e.path like R.path +%，要计算级别和路径的变化，
需要访问根节点的原经理om和新经理NM所在的行，所有节点的新级别等于它们当前的级别加上新旧经理级别之差。*/
CREATE PROC dbo.MoveSubtree
  @root  INT,
  @mgrid INT
AS

SET NOCOUNT ON;

BEGIN TRAN;
/*
更新子树E中所有员工的级别和路径
set level = 
当前level +新经理的level - 旧经理的level
set path = 
在当前路径中删除旧经理的路径，并替换为新经理的中径
*/
  UPDATE E
    SET lvl  = E.lvl + NM.lvl - OM.lvl,
        path = STUFF(E.path, 1, LEN(OM.path), NM.path)
  FROM dbo.Employees AS E          -- E = Employees    (subtree)
    JOIN dbo.Employees AS R        -- R = Root         (one row)
      ON R.empid = @root
      AND E.path LIKE R.path + '%'
    JOIN dbo.Employees AS OM       -- OM = Old Manager (one row)
      ON OM.empid = R.mgrid
    JOIN dbo.Employees AS NM       -- NM = New Manager (one row)
      ON NM.empid = @mgrid;
  
  -- 更新根节点的新经理
  UPDATE dbo.Employees SET mgrid = @mgrid WHERE empid = @root;
COMMIT TRAN;
GO

-- 在移动子树之前先检查树的内容
SELECT empid, REPLICATE(' | ', lvl) + empname AS empname, lvl, path
FROM dbo.Employees
ORDER BY path;

-- 移动子树
  EXEC dbo.MoveSubtree
  @root  = 7,
  @mgrid = 10;

  -- 移动子树之后
  SELECT empid, REPLICATE(' | ', lvl) + empname AS empname, lvl, path
  FROM dbo.Employees
  ORDER BY path;