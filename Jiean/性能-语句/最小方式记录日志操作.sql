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


--最小方式记录日志操作
/*
最小化日志记录操作，和完整日志记录相比，运行速度会快很多
*/

--分析操作的日志记录方法
CHECKPOINT;
GO
DECLARE @numrecords AS INT, @size AS BIGINT, @dt AS DATETIME;

SELECT 
  @numrecords = COUNT(*),
  @size       = COALESCE(SUM([Log Record Length]), 0),
  @dt         = CURRENT_TIMESTAMP
FROM fn_dblog(NULL, NULL) AS D --指定起始的日志序列号，指定结束的日志序列号，null，返回事务日志中的所有记录
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



--生成直方图(日志的长度分布情况)
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

--获取日志记录的明细信息
SELECT Operation, Context,
  AVG([Log Record Length]) AS AvgLen, COUNT(*) AS Cnt
FROM fn_dblog(null, null) AS D
WHERE AllocUnitName = 'dbo.SD_Sal_Order' OR AllocUnitName LIKE 'dbo.SD_Sal_Order.%'
GROUP BY Operation, Context, ROUND([Log Record Length], -2)
ORDER BY AvgLen, Operation, Context;
/*
日志操作(LOP) 为LOP_FORMAT_PAGE,日志上下文(LCX)为LCX_HEAP,这表明操作期间分配和填充了25000个堆页，在这些页中填充
的数据都具有完整的日志记录，日志操作LOP_SET_BITS的上下文件是LCX_GAM和LCX_IAM,操作LOP_MODIFY_ROW的上下文是LCX_PFS,
从这些可以了解到，在修改GAM,IAM和PFS页(分配位图和页可用空间(page free space)位图)时，发生的一些日志记录。
*/

/*
总结：最小日志记录要求
非完整恢复模式
and 不是复制的
and(
	(堆 and tablock)
	or (B树 and 空 and tablock)
	or(b树 and 空 and tf-610)
	or(b树 and 非空 and  tf-610 and 新的键值范围)
)
*/