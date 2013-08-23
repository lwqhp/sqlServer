

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

--CTE���ñ��ʽ������

/*
��һ����ҳ�����ӱȶ�CTE����ʱ�������

������Ҫ�鿴ĳһҳʱ�����������شӵ�һҳ�����ڼ䵽��n-1ҳ����û�а취���ʵ�nҳ��
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
top ��������ԣ��ü���ֻɨ���˸ñ��ǰ10�У���Ϊ�ô�������λ�ڵڶ�ҳ��5�����ݣ�ֻ��ɨ��ǰ��ҳ.
filter�����ɸѡ���ڶ�ҳ����

֤��δɨ�����������һ�ַ��������ô��������ñ�Ȼ����set statisition i/oѡ����иò��ˣ��۲쵱����ʾ��n
ҳʱ����Ķ�ȡ������ᷢ�֣����ܱ��ж��ֻ��ɨ��ǰnҳ�е��С�

��ʹ����˳��������ҳʱ�������������һҳ��Ȼ�������2ҳ�����ý������Ҳ���зǳ������õ����ܣ��������һҳʱ��
��ص�����/����ҳ�������ɨ�貢���ص����棬�������2ҳ����ʱ����һ����������ȡ������ҳ�Ѿ�λ�ڻ����У�ֻ������
��ɨ�������2ҳ���е�����ҳ.
*/

--��ʱ����
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
����һ���ǳ���Ч��ִ�мƻ�,ֱ���������в�����Ҫ����
*/


--�����
/*
��������漰���±��룬������־��¼��������Ҳ���٣��Ż�����Ϊ������ռ�ͳ����Ϣ�������ھ���ʹ������ʱҪ�ǳ�
������һ��ֻ���ڴ洢��С�Ľ����ִ������ɨ�衣
*/
