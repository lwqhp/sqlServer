
/*

CTE：common table expression,通用表表达式

通过CTE可以创建出一张临时表，这张表在定义中可以实现自引用，方便处理父子关系

在之前的案例中讲的是利用CTE进行迭代的功能，

只在查询期间有效，在同一查询中可以多次引用

使用CTE可以获得提高可读性和轻松维护复杂查询的优点

 

CTE用法之一：迭代

SQL2008中实现迭代 CTE  (获取树型结构子孙孩子的迭代)

若下句前还有句子的话，应该用 ; 隔开，如果没有就不用*/

--获取某节点@root及其所有的子孙节点

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
--SubsCTE 是一个临时表。在同一查询中可以多次引用


 

/*CTE用法之二：充当临时表，这是基本用法

在下面的情况下CTE和临时表的功能差不多：如下

CTE的方式：*/

WITH MyCTE( ListPrice, SellPrice)

AS(  SELECT ListPrice, ListPrice * .95  FROM Production.Product)

SELECT * FROM MyCTE

/*对创建的CTE临时表，可以和其他表通过 join 联接使用

比如说要查找的小范围数据的主键可以存放在CTE中

或者要删除的部分的数据可以存放在CTE中，再通过和主表联接删除即可*/

 

--CTE用法之三：分页
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


--我们可以用通用表查询表达式和Row_Numner()函数来选出重复的那行数据。(本质临时表)
 ;WITH [EmployeaaByRowID] AS
(SELECT ROW_NUMBER() OVER (ORDER BY EMPID ASC) AS ROWID, * FROM EMPLOYEEa)
SELECT * FROM [EmployeaaByRowID] WHERE ROWID =4


----------------------
--递归查询：
USE tempdb
GO
-- 建立演示环境
CREATE TABLE Dept(
 id int PRIMARY KEY, 
 parent_id int,
 name nvarchar(20))
INSERT Dept
SELECT 0, -1, N'<全部>' UNION ALL
SELECT 1, 0, N'财务部' UNION ALL
SELECT 2, 0, N'行政部' UNION ALL
SELECT 3, 0, N'业务部' UNION ALL
SELECT 4, 0, N'客服部' UNION ALL
SELECT 5, 4, N'销售部' UNION ALL
SELECT 6, 4, N'MIS' UNION ALL
SELECT 7, 6, N'UI' UNION ALL
SELECT 8, 6, N'程式开发' UNION ALL
SELECT 9, 8, N'财务开发' UNION ALL
SELECT 10, 8, N'进销存开发'

GO

-- 查询指定部门下面的所有部门, 并汇总各部门的下级部门数
DECLARE @Dept_name nvarchar(20)
SET @Dept_name = N'MIS'
;WITH
DEPTS AS(   -- 查询指定部门及其下的所有子部门
 -- 定位点成员
 SELECT * FROM Dept
 WHERE name = @Dept_name
 UNION ALL
 -- 递归成员, 通过引用CTE自身与Dept基表JOIN实现递归
 SELECT A.*
 FROM Dept A, DEPTS B
 WHERE A.parent_id = B.id
),
DEPTCHILD AS(  -- 引用第个CTE,查询其每条记录对应的部门下的所有子部门
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
DEPTCHILDCNT AS( -- 引用第个CTE, 汇总得到各部门下的子部门数
 SELECT 
  Dept_id, Cnt = COUNT(*)
 FROM DEPTCHILD
 GROUP BY Dept_id
)
-- 查询指定部门下面的所有部门, 并汇总各部门的下级部门数


SELECT    -- JOIN第,3个CTE,得到最终的查询结果
 D.*,
 ChildDeptCount = ISNULL(DS.Cnt, 0)
FROM DEPTS D
 LEFT JOIN DEPTCHILDCNT DS
  ON D.id = DS.Dept_id

;WITH
DEPTS AS(   -- 查询指定部门及其下的所有子部门
 -- 定位点成员
 SELECT * FROM Dept
 WHERE name = @Dept_name
 UNION ALL
 -- 递归成员, 通过引用CTE自身与Dept基表JOIN实现递归
 SELECT A.*
 FROM Dept A, DEPTS B
 WHERE A.parent_id = B.id
)
SELECT * FROM DEPTS;

;WITH
DEPTS AS(   -- 查询指定部门及其所有上级部门
 -- 定位点成员
 SELECT * FROM Dept
 WHERE name = @Dept_name
 UNION ALL
 -- 递归成员, 通过引用CTE自身与Dept基表JOIN实现递归
 SELECT A.*
 FROM Dept A, DEPTS B
 WHERE b.parent_id = a.id
)
SELECT * FROM DEPTS;

go
-- 删除演示环境
DROP TABLE Dept

3. 用CTE生成行号，速度极快 
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
--更多见：http://topic.csdn.net/u/20100330/23/b2f663b1-0edf-4847-857e-e75640c90c1a.html
