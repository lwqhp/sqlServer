
/*

CTE��common table expression,ͨ�ñ���ʽ

ͨ��CTE���Դ�����һ����ʱ�����ű��ڶ����п���ʵ�������ã����㴦���ӹ�ϵ

��֮ǰ�İ����н���������CTE���е����Ĺ��ܣ�

ֻ�ڲ�ѯ�ڼ���Ч����ͬһ��ѯ�п��Զ������

ʹ��CTE���Ի����߿ɶ��Ժ�����ά�����Ӳ�ѯ���ŵ�

 

CTE�÷�֮һ������

SQL2008��ʵ�ֵ��� CTE  (��ȡ���ͽṹ���ﺢ�ӵĵ���)

���¾�ǰ���о��ӵĻ���Ӧ���� ; ���������û�оͲ���*/

--��ȡĳ�ڵ�@root�������е�����ڵ�

DECLARE @root INT
SET @root = 3
;
WITH    SubsCTE
          AS ( 
  -- Anchor member returns root node 
               SELECT   id ,
                        0 AS lvl
               FROM     dbo.Bi_Tree
               WHERE    id = @root
               UNION ALL 

 -- Recursive member returns next level of children 
               SELECT   C.id ,
                        P.lvl + 1
               FROM     SubsCTE AS P
                        JOIN dbo.Bi_Tree AS C ON C.pid = P.id
             )
    SELECT  *
    FROM    SubsCTE
--SubsCTE ��һ����ʱ����ͬһ��ѯ�п��Զ������


 

/*CTE�÷�֮�����䵱��ʱ�����ǻ����÷�

������������CTE����ʱ��Ĺ��ܲ�ࣺ����

CTE�ķ�ʽ��*/

WITH MyCTE( ListPrice, SellPrice)

AS(  SELECT ListPrice, ListPrice * .95  FROM Production.Product)

SELECT * FROM MyCTE

/*�Դ�����CTE��ʱ�����Ժ�������ͨ�� join ����ʹ��

����˵Ҫ���ҵ�С��Χ���ݵ��������Դ����CTE��

����Ҫɾ���Ĳ��ֵ����ݿ��Դ����CTE�У���ͨ������������ɾ������*/

 

--CTE�÷�֮������ҳ
;
WITH    MyCTE ( ID, Name, RowID )
          AS ( SELECT   Id ,
                        name ,
                        Row_Number() OVER ( ORDER BY id ) AS RowID
               FROM     bi_tree
             )
    SELECT  *
    FROM    MyCTE
    WHERE   RowID BETWEEN 11 AND 21


--���ǿ�����ͨ�ñ��ѯ���ʽ��Row_Numner()������ѡ���ظ����������ݡ�(������ʱ��)
 ;WITH [EmployeaaByRowID] AS
(SELECT ROW_NUMBER() OVER (ORDER BY EMPID ASC) AS ROWID, * FROM EMPLOYEEa)
SELECT * FROM [EmployeaaByRowID] WHERE ROWID =4


----------------------
--�ݹ��ѯ��
USE tempdb
GO
-- ������ʾ����
CREATE TABLE Dept(
 id int PRIMARY KEY, 
 parent_id int,
 name nvarchar(20))
INSERT Dept
SELECT 0, -1, N'<ȫ��>' UNION ALL
SELECT 1, 0, N'����' UNION ALL
SELECT 2, 0, N'������' UNION ALL
SELECT 3, 0, N'ҵ��' UNION ALL
SELECT 4, 0, N'�ͷ���' UNION ALL
SELECT 5, 4, N'���۲�' UNION ALL
SELECT 6, 4, N'MIS' UNION ALL
SELECT 7, 6, N'UI' UNION ALL
SELECT 8, 6, N'��ʽ����' UNION ALL
SELECT 9, 8, N'���񿪷�' UNION ALL
SELECT 10, 8, N'�����濪��'

GO

-- ��ѯָ��������������в���, �����ܸ����ŵ��¼�������
DECLARE @Dept_name nvarchar(20)
SET @Dept_name = N'MIS'
;WITH
DEPTS AS(   -- ��ѯָ�����ż����µ������Ӳ���
 -- ��λ���Ա
 SELECT * FROM Dept
 WHERE name = @Dept_name
 UNION ALL
 -- �ݹ��Ա, ͨ������CTE������Dept����JOINʵ�ֵݹ�
 SELECT A.*
 FROM Dept A, DEPTS B
 WHERE A.parent_id = B.id
),
DEPTCHILD AS(  -- ���õڸ�CTE,��ѯ��ÿ����¼��Ӧ�Ĳ����µ������Ӳ���
 SELECT 
  Dept_id = P.id, C.id, C.parent_id
 FROM DEPTS P, Dept C
 WHERE P.id = C.parent_id
 UNION ALL
 SELECT 
  P.Dept_id, C.id, C.parent_id
 FROM DEPTCHILD P, Dept C
 WHERE P.id = C.parent_id
),
DEPTCHILDCNT AS( -- ���õڸ�CTE, ���ܵõ��������µ��Ӳ�����
 SELECT 
  Dept_id, Cnt = COUNT(*)
 FROM DEPTCHILD
 GROUP BY Dept_id
)
-- ��ѯָ��������������в���, �����ܸ����ŵ��¼�������


SELECT    -- JOIN��,3��CTE,�õ����յĲ�ѯ���
 D.*,
 ChildDeptCount = ISNULL(DS.Cnt, 0)
FROM DEPTS D
 LEFT JOIN DEPTCHILDCNT DS
  ON D.id = DS.Dept_id

;WITH
DEPTS AS(   -- ��ѯָ�����ż����µ������Ӳ���
 -- ��λ���Ա
 SELECT * FROM Dept
 WHERE name = @Dept_name
 UNION ALL
 -- �ݹ��Ա, ͨ������CTE������Dept����JOINʵ�ֵݹ�
 SELECT A.*
 FROM Dept A, DEPTS B
 WHERE A.parent_id = B.id
)
SELECT * FROM DEPTS;

;WITH
DEPTS AS(   -- ��ѯָ�����ż��������ϼ�����
 -- ��λ���Ա
 SELECT * FROM Dept
 WHERE name = @Dept_name
 UNION ALL
 -- �ݹ��Ա, ͨ������CTE������Dept����JOINʵ�ֵݹ�
 SELECT A.*
 FROM Dept A, DEPTS B
 WHERE b.parent_id = a.id
)
SELECT * FROM DEPTS;

go
-- ɾ����ʾ����
DROP TABLE Dept

3. ��CTE�����кţ��ٶȼ��� 
;WITH t AS    
(    
    SELECT 1 AS num   
    UNION ALL   
    SELECT num+1    
    FROM t   
    WHERE num<100000   
)   
SELECT * FROM t    
OPTION(MAXRECURSION 0)  
--�������http://topic.csdn.net/u/20100330/23/b2f663b1-0edf-4847-857e-e75640c90c1a.html
