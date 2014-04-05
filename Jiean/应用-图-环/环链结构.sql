
--���ṹ
/*
���ṹ���ֽ�ͼ���е�ͱ���ɣ����������������
��������ָһ���ߵ������������ĳ�ַ����˳�򣬱���BOMͼ
��������ÿ����ֻ�Ǽ������������㣬û���ض�˳�򣬱����·ϵͳ��

�������������ֱַհ���(��ͨ)�Ͱ�հ���(�޻�)

���ṹͨ�����������ڵ������ӹ�ϵ���������ڵ��ֶηֱ��ʾ��·�����ˣ���-�ң����������ṹ����ʾ��·��ϵ��������
����һ�ڵ㣬����������������ᵥ�����һ������

�ŵ㣺���������ݵĲ�ι�ϵ�ְ������ṹ��һ�����˽ṹ�������˲㼶��Զ�ĸ��ӹ�ϵ��

���ṹ��������Ʒ���

3.3������

��Ҫ��ӳ�����ڵ��ĸ��ӹ�ϵ���Ա����ṹ��֧�ֶ�Զ�ڵ����ˡ����ֵ��������ڹ�������ƱȽ϶�,�������ڸ��ӽڵ����С�
*/
DROP TABLE TreePaths
CREATE TABLE TreePaths(companyID VARCHAR(20),leftNode VARCHAR(20),rightNode VARCHAR(20) )
go
INSERT INTO TreePaths(leftNode,rightNode)
SELECT 'PT0001','PT0003' UNION ALL
SELECT 'PT0003','PT0004' UNION ALL
SELECT 'PT0003','PT0007' UNION ALL
SELECT 'PT0004','PT0005' UNION ALL
SELECT 'PT0004','PT0007' UNION ALL
SELECT 'PT0007','PT0004' UNION ALL
SELECT 'PT0005','PT0007' 

SELECT * FROM TreePaths
--UPDATE TreePaths SET companyID = 'PT'

--���ṹ����Ӧ��
/*
�������ϵ������ڵ���ͬһ����¼�ϣ�������ת�����󣬿�������������֮��������
*/

--����Ƿ���ڻ� 1->3->1
DECLARE @root AS INT = 1;

WITH Subs
AS
(
  SELECT empid, empname, 0 AS lvl,
    CAST('.' + CAST(empid AS VARCHAR(10)) + '.'
         AS VARCHAR(MAX)) AS path,
    -- ��Ȼ�����ڵ㲻���ڻ�
    0 AS cycle
  FROM dbo.Employees
  WHERE empid = @root

  UNION ALL

  SELECT C.empid, C.empname, P.lvl + 1,
    CAST(P.path + CAST(C.empid AS VARCHAR(10)) + '.'
         AS VARCHAR(MAX)),
    -- ������ڵ�·���а����ӽڵ�id,���⵽��
    CASE WHEN P.path LIKE '%.' + CAST(C.empid AS VARCHAR(10)) + '.%'
      THEN 1 ELSE 0 END
  FROM Subs AS P
    JOIN dbo.Employees AS C
      ON C.mgrid = P.empid
      AND P.cycle = 0 -- �������������ڵ�������ķ�֧
)
SELECT empid, empname, cycle, path
FROM Subs;

--�ҳ��������ķ�֧
SELECT path FROM Subs WHERE cycle = 1;
GO
