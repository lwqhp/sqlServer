
/*
���󣺲�ѯ�û�������½��ʱ��κ�������½����

�ص�����������ʱ�����䣬��ʱ���ȥһ���̶�ʱ�䣬ת����һ����ֵ���С�
��ֵ���� - ����ֵ���õ���������ֵ������������ֵ������ֵ�Ĳ�Ϊ��ֵͬ��
����������ֵ������Լ�������������ڵ����ݡ�
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

--�ű�
;WITH tmp AS(
	SELECT [Uid],
	logindate,
	DiffDay = DENSE_RANK() OVER(PARTITION BY [Uid] ORDER BY CONVERT(CHAR(10), loginDate, 120))
		-DATEDIFF(DAY,GETDATE(),CONVERT(CHAR(10), loginDate, 120))
	FROM Member_LoginLog 
)
SELECT uid,mindt = MIN(logindate),--�����½ʱ�� 
maxdt = MAX(logindate),	--�����½ʱ��
logNum = COUNT(diffday),--��½����
logDay = DATEDIFF(DAY,MIN(logindate)-1,MAX(logindate)) --��½����
FROM tmp
GROUP BY uid,DiffDay
ORDER BY mindt


--ԭ����
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


