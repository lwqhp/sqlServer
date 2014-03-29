
/*
需求：查询用户连续登陆的时间段和连续登陆天数

重点在于连续的时间区间，把时间减去一个固定时间，转换成一个数值序列。
数值序列 - 序列值，得到连续区间值，（连续的数值和序列值的差为相同值）
对连续区间值分组可以计算出连续区间内的数据。
*/
IF object_id('Member_LoginLog') IS NOT NULL DROP TABLE Member_LoginLog

CREATE TABLE Member_LoginLog(
uid INT,
logindate DATETIME
)
go
INSERT INTO Member_LoginLog
SELECT 268,'2014-01-01 14:01:19.000' UNION ALL 
SELECT 268,'2014-01-02 08:01:19.000' UNION ALL 
SELECT 268,'2014-01-04 15:01:19.000' UNION ALL 
SELECT 268,'2014-01-04 16:01:19.000' UNION ALL 
SELECT 268,'2014-01-05 08:01:19.000' UNION ALL 
SELECT 268,'2014-01-05 09:01:19.000' UNION ALL 
SELECT 268,'2014-01-06 09:01:19.000' 
go
SELECT * FROM Member_LoginLog

--脚本
;WITH tmp AS(
	SELECT [Uid],
	logindate,
	DiffDay = DENSE_RANK() OVER(PARTITION BY [Uid] ORDER BY CONVERT(CHAR(10), loginDate, 120))
		-DATEDIFF(DAY,GETDATE(),CONVERT(CHAR(10), loginDate, 120))
	FROM Member_LoginLog 
)
SELECT uid,mindt = MIN(logindate),--最早登陆时间 
maxdt = MAX(logindate),	--最晚登陆时间
logNum = COUNT(diffday),--登陆次数
logDay = DATEDIFF(DAY,MIN(logindate)-1,MAX(logindate)) --登陆天数
FROM tmp
GROUP BY uid,DiffDay
ORDER BY mindt


--原方案
;WITH tmp AS(
	SELECT [Uid],
	dt = CONVERT(CHAR(10), loginDate, 120),
	mindt = MIN(loginDate),
	maxdt = MAX(loginDate) ,
	lognum = COUNT(*),
	DiffDay = ROW_NUMBER() OVER(PARTITION BY [Uid] ORDER BY CONVERT(CHAR(10), loginDate, 120))
		-DATEDIFF(DAY,GETDATE(),CONVERT(CHAR(10), loginDate, 120))
	FROM Member_LoginLog 
	GROUP BY [Uid],CONVERT(CHAR(10), loginDate, 120)
)
SELECT uID,MIN(mindt) mindt,MAX(maxdt),COUNT(lognum) lognum 
FROM tmp
GROUP BY uID,DiffDay
order BY uID,mindt


