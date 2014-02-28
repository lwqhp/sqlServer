IF OBJECT_ID('dbo.Nums') IS NOT NULL DROP TABLE dbo.Nums;

CREATE TABLE dbo.Nums(n INT NOT NULL PRIMARY KEY);
DECLARE @max AS INT, @rc AS INT;
SET @max = 1000000;
SET @rc = 1;

INSERT INTO Nums VALUES(1);
WHILE @rc * 2 <= @max
BEGIN
  INSERT INTO dbo.Nums SELECT n + @rc FROM dbo.Nums;
  SET @rc = @rc * 2;
END

INSERT INTO dbo.Nums 
  SELECT n + @rc FROM dbo.Nums WHERE n + @rc <= @max;
GO


--��С��ʽ��¼��־����
/*
��С����־��¼��������������־��¼��ȣ������ٶȻ��ܶ�
*/

--������������־��¼����
CHECKPOINT;
GO
DECLARE @numrecords AS INT, @size AS BIGINT, @dt AS DATETIME;

SELECT 
  @numrecords = COUNT(*),
  @size       = COALESCE(SUM([Log Record Length]), 0),
  @dt         = CURRENT_TIMESTAMP
FROM fn_dblog(NULL, NULL) AS D --ָ����ʼ����־���кţ�ָ����������־���кţ�null������������־�е����м�¼
WHERE AllocUnitName = 'dbo.SD_Sal_Order' OR AllocUnitName LIKE 'dbo.SD_Sal_Order.%';

insert into sd_sal_order
select top 1 * from [HK_ERP_PTDW].dbo.sd_sal_order


SELECT 
  COUNT(*) - @numrecords AS numrecords,
  CAST((COALESCE(SUM([Log Record Length]), 0) - @size)
    / 1024. / 1024. AS NUMERIC(12, 2)) AS size_mb,
  CAST(DATEDIFF(millisecond, @dt, CURRENT_TIMESTAMP)/1000. AS DECIMAL(12,3))
    AS duration_sec
FROM fn_dblog(NULL, NULL) AS D
WHERE AllocUnitName = 'dbo.SD_Sal_Order' OR AllocUnitName LIKE 'dbo.SD_Sal_Order.%';



--����ֱ��ͼ(��־�ĳ��ȷֲ����)
DECLARE @numsteps AS INT = 10;
DECLARE @log AS TABLE(id INT IDENTITY, size INT, PRIMARY KEY(size, id));

INSERT INTO @log(size)
  SELECT [Log Record Length]
  FROM fn_dblog(null, null) AS D
  WHERE AllocUnitName = 'dbo.SD_Sal_Order' OR AllocUnitName LIKE 'dbo.SD_Sal_Order.%';

WITH Args AS
(
  SELECT MIN(size) AS mn, MAX(size) AS mx,
    1E0*(MAX(size) - MIN(size)) / @numsteps AS stepsize
  FROM @log
),
Steps AS
(
  SELECT n,
    mn + (n-1)*stepsize - CASE WHEN n = 1 THEN 1 ELSE 0 END AS lb,
    mn + n*stepsize AS hb
  FROM Nums
    CROSS JOIN Args
  WHERE n <= @numsteps
)
SELECT n, lb, hb, COUNT(size) AS numrecords
FROM Steps
  LEFT OUTER JOIN @log
    ON size > lb AND size <= hb
GROUP BY n, lb, hb
ORDER BY n;

--��ȡ��־��¼����ϸ��Ϣ
SELECT Operation, Context,
  AVG([Log Record Length]) AS AvgLen, COUNT(*) AS Cnt
FROM fn_dblog(null, null) AS D
WHERE AllocUnitName = 'dbo.SD_Sal_Order' OR AllocUnitName LIKE 'dbo.SD_Sal_Order.%'
GROUP BY Operation, Context, ROUND([Log Record Length], -2)
ORDER BY AvgLen, Operation, Context;
/*
��־����(LOP) ΪLOP_FORMAT_PAGE,��־������(LCX)ΪLCX_HEAP,����������ڼ����������25000����ҳ������Щҳ�����
�����ݶ�������������־��¼����־����LOP_SET_BITS�������ļ���LCX_GAM��LCX_IAM,����LOP_MODIFY_ROW����������LCX_PFS,
����Щ�����˽⵽�����޸�GAM,IAM��PFSҳ(����λͼ��ҳ���ÿռ�(page free space)λͼ)ʱ��������һЩ��־��¼��
*/

/*
�ܽ᣺��С��־��¼Ҫ��
�������ָ�ģʽ
and ���Ǹ��Ƶ�
and(
	(�� and tablock)
	or (B�� and �� and tablock)
	or(b�� and �� and tf-610)
	or(b�� and �ǿ� and  tf-610 and �µļ�ֵ��Χ)
)
*/