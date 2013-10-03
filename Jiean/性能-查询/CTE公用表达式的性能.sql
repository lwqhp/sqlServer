

CREATE TABLE dbo.Sales
(
  empid VARCHAR(10) NOT NULL PRIMARY KEY,
  mgrid VARCHAR(10) NOT NULL,
  qty   INT         NOT NULL
);

INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('A', 'Z', 300);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('B', 'X', 100);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('C', 'X', 200);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('D', 'Y', 200);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('E', 'Z', 250);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('F', 'Z', 300);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('G', 'X', 100);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('H', 'Y', 150);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('I', 'X', 250);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('J', 'Z', 100);
INSERT INTO dbo.Sales(empid, mgrid, qty) VALUES('K', 'Y', 200);

CREATE INDEX idx_qty_empid ON dbo.Sales(qty, empid);
CREATE INDEX idx_mgrid_qty_empid ON dbo.Sales(mgrid, qty, empid);
GO

--CTE公用表达式的性能

/*
用一个分页的例子比对CTE和临时表的性能

当我们要查看某一页时，如果不物理地从第一页访问期间到第n-1页，是没有办法访问第n页的
*/

DECLARE @pagesize AS INT, @pagenum AS INT;
SET @pagesize = 5;
SET @pagenum = 2;

WITH SalesCTE AS
(
  SELECT ROW_NUMBER() OVER(ORDER BY qty, empid) AS rownum,
    empid, mgrid, qty
  FROM dbo.Sales
)
SELECT rownum, empid, mgrid, qty
FROM SalesCTE
WHERE rownum > @pagesize * (@pagenum-1)
  AND rownum <= @pagesize * @pagenum
ORDER BY rownum;
GO

select * from sales
/*
top 运算符属性，该计算只扫描了该表的前10行，因为该代码请求位于第二页的5行数据，只会扫描前两页.
filter运算符筛选出第二页的行

证明未扫描整个表的另一种方法，先用大量行填充该表，然后开启set statisition i/o选项并运行该查谒，观察当你请示第n
页时报告的读取数，你会发现，不管表有多大，只会扫描前n页中的行。

即使当按顺序请求多个页时，（即先请求第一页，然后请求第2页，）该解决方案也具有非常用良好的性能，当请求第一页时，
相关的数据/索引页被物理地扫描并加载到缓存，当请求第2页的行时，第一次请求所读取的数据页已经位于缓存中，只需物理
地扫描包含第2页中行的数据页.
*/

--临时表方案
IF OBJECT_ID('tempdb..#SalesRN') IS NOT NULL
  DROP TABLE #SalesRN;
GO
SELECT ROW_NUMBER() OVER(ORDER BY qty, empid) AS rownum,
  empid, mgrid, qty
INTO #SalesRN
FROM dbo.Sales;

CREATE UNIQUE CLUSTERED INDEX idx_rn ON #SalesRN(rownum);
GO


DECLARE @pagesize AS INT, @pagenum AS INT;
SET @pagesize = 5;
SET @pagenum = 2;

SELECT rownum, empid, mgrid, qty
FROM #SalesRN
WHERE rownum BETWEEN @pagesize * (@pagenum-1) + 1
                 AND @pagesize * @pagenum
ORDER BY rownum;
GO

-- Cleanup
DROP TABLE #SalesRN;
GO
/*
这是一个非常高效的执行计划,直接在索引中查找需要的行
*/


--表变量
/*
表变量不涉及重新编译，而且日志记录和锁问题也更少，优化器不为表变量收集统计信息，所以在决定使用它们时要非常
谨慎，一般只用在存储较小的结果且执行完整扫描。
*/
