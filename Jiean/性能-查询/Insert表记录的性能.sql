

--Insert���¼������
/*
insert ����������������Ӱ�죬ͨ����С��insert��������ʵ�ֶ�������־��д����(insert����������ceiling(log2(@max))+1)

*/
select ceiling(log(1000000))+1


/*
@rc�б����Ѳ��뵽�ñ�����������Ȱ�n=1���в���nums,Ȼ��@rc*2<=@max����ʱִ��ѭ������ÿ�ε����У��ù��̰�nums����
���е�nֵ����@rc�����nums�÷���ÿ�ε�������ʹnums���е������ӱ������Ȳ�����{1}��Ȼ����{2},{34},{5678}
*/
IF OBJECT_ID('dbo.Nums') IS NOT NULL
  DROP TABLE dbo.Nums;
GO

CREATE TABLE dbo.Nums(n INT NOT NULL PRIMARY KEY);

DECLARE @max AS INT, @rc AS INT;
SET @max = 1000000;
SET @rc = 1;

INSERT INTO Nums VALUES(1);
WHILE @rc * 2 <= @max
BEGIN
  INSERT INTO dbo.Nums 
  SELECT n + @rc FROM dbo.Nums;
  SET @rc = @rc * 2;
END

INSERT INTO dbo.Nums 
  SELECT n + @rc FROM dbo.Nums WHERE n + @rc <= @max;
GO

--select count(*) from Nums


--���ܱȽ�
DECLARE @n AS BIGINT;
SET @n = 1000000;

WITH Nums AS
(
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM Nums WHERE n < @n
)
SELECT n FROM Nums
OPTION(MAXRECURSION 0);
GO

--�Ż�����1
/*
����һ����������Ŀ������ƽ������CTE����֮Ϊbase��,�Ƚ�������base������ʵ���Եõ�Ŀ�����������Ϊ�����������
��ŵ��кš�
*/
select SQRT(16) --��ƽ��

DECLARE @n AS BIGINT;
SET @n = 1000000;

WITH Base AS
(
  SELECT 1 AS n
  UNION ALL
  SELECT n + 1 FROM Base WHERE n < CEILING(SQRT(@n))
),
Expand AS
(
  SELECT 1 AS c
  FROM Base AS B1, Base AS B2
),
Nums AS
(
  SELECT ROW_NUMBER() OVER(ORDER BY c) AS n
  FROM Expand
)
SELECT n FROM Nums WHERE n <= @n
OPTION(MAXRECURSION 0);
GO


--�Ż�����3
/*
����һ���������е�cte,ͨ������������һ��cte������ʵ���������ÿ��cte���ᱶ���е�����������N����CTE����0��ʼ��
���õ�2^2n����
��һ��cte���������кţ�����ⲿ��ѯɸѡ������������(where�к���<=input)������ɸѡ�к�<=ĳ��ֵʱ��sqlserver
�������ɴ��ڸ�ֵ֮����кš�
*/
DECLARE @n AS BIGINT;
SET @n = 1000000;

WITH
L0   AS(SELECT 1 AS c UNION ALL SELECT 1),
L1   AS(SELECT 1 AS c FROM L0 AS A, L0 AS B),
L2   AS(SELECT 1 AS c FROM L1 AS A, L1 AS B),
L3   AS(SELECT 1 AS c FROM L2 AS A, L2 AS B),
L4   AS(SELECT 1 AS c FROM L3 AS A, L3 AS B),
L5   AS(SELECT 1 AS c FROM L4 AS A, L4 AS B),
Nums AS(SELECT ROW_NUMBER() OVER(ORDER BY c) AS n FROM L5)
SELECT n FROM Nums WHERE n <= @n;
GO

--�Ż�����4
/*
��UDF�з�װ�߼����ý�������ļ�ֵ���ڣ���UDF�Ķ������޷��޸�maxrecursion,���÷�����Զ����ӽ�maxrecursion������
*/
IF OBJECT_ID('dbo.fn_nums') IS NOT NULL
  DROP FUNCTION dbo.Nums;
GO
CREATE FUNCTION dbo.fn_nums(@n AS BIGINT) RETURNS TABLE
AS
RETURN
  WITH
  L0   AS(SELECT 1 AS c UNION ALL SELECT 1),
  L1   AS(SELECT 1 AS c FROM L0 AS A, L0 AS B),
  L2   AS(SELECT 1 AS c FROM L1 AS A, L1 AS B),
  L3   AS(SELECT 1 AS c FROM L2 AS A, L2 AS B),
  L4   AS(SELECT 1 AS c FROM L3 AS A, L3 AS B),
  L5   AS(SELECT 1 AS c FROM L4 AS A, L4 AS B),
  Nums AS(SELECT ROW_NUMBER() OVER(ORDER BY c) AS n FROM L5)
  SELECT n FROM Nums WHERE n <= @n;
GO

-- Test function
SELECT * FROM dbo.fn_nums(8000) AS F;
GO

-----���봴���к�
/*
��Ҫ�ڲ���ļ�¼�д����к�ʱ���ȴ�����Ȼ���ټ������ݣ�û�� select into�����죬��Ϊinsert select ���Ǳ���
����¼��־
*/

create table #salern(emid varchar(5),rn int identity)
insert into #salern
select '1'