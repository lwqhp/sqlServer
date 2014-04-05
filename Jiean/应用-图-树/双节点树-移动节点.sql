--�ƶ�һ���ڵ�
UPDATE Bas_InterCompany SET parentID ='PT0001' WHERE vendCustID = 'PT0004'

--�ƶ�һ���ڵ㺬��Ⱥ�·��
/*
���밮Ӱ����������������Ӹ��ڵ����ڵ���R ��E,���ӱ��ʽΪe.path like R.path +%��Ҫ���㼶���·���ı仯��
��Ҫ���ʸ��ڵ��ԭ����om���¾���NM���ڵ��У����нڵ���¼���������ǵ�ǰ�ļ�������¾ɾ�����֮�*/
CREATE PROC dbo.MoveSubtree
  @root  INT,
  @mgrid INT
AS

SET NOCOUNT ON;

BEGIN TRAN;
/*
��������E������Ա���ļ����·��
set level = 
��ǰlevel +�¾����level - �ɾ����level
set path = 
�ڵ�ǰ·����ɾ���ɾ����·�������滻Ϊ�¾�����о�
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
  
  -- ���¸��ڵ���¾���
  UPDATE dbo.Employees SET mgrid = @mgrid WHERE empid = @root;
COMMIT TRAN;
GO

-- ���ƶ�����֮ǰ�ȼ����������
SELECT empid, REPLICATE(' | ', lvl) + empname AS empname, lvl, path
FROM dbo.Employees
ORDER BY path;

-- �ƶ�����
  EXEC dbo.MoveSubtree
  @root  = 7,
  @mgrid = 10;

  -- �ƶ�����֮��
  SELECT empid, REPLICATE(' | ', lvl) + empname AS empname, lvl, path
  FROM dbo.Employees
  ORDER BY path;